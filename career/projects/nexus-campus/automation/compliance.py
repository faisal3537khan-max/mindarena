#!/usr/bin/env python3
"""Nexus Campus — IOS config compliance auditor.

Reads every *.cfg next to ../configs and scores the security baseline
documented in README.md. Stdlib only. Exit 0 when every device passes.
"""

from __future__ import annotations

import re
import sys
from dataclasses import dataclass, field
from pathlib import Path


CONFIG_DIR = Path(__file__).resolve().parent.parent / "configs"


@dataclass
class Finding:
    device: str
    severity: str
    rule: str
    detail: str


@dataclass
class Device:
    name: str
    text: str
    findings: list[Finding] = field(default_factory=list)

    def fail(self, rule: str, detail: str, severity: str = "high") -> None:
        self.findings.append(Finding(self.name, severity, rule, detail))


def load_devices() -> list[Device]:
    files = sorted(CONFIG_DIR.glob("*.cfg"))
    if not files:
        sys.stderr.write(f"No configs in {CONFIG_DIR}\n")
        sys.exit(2)
    devices = []
    for path in files:
        text = path.read_text(encoding="utf-8", errors="replace")
        host = re.search(r"^hostname\s+(\S+)", text, re.M)
        devices.append(Device(host.group(1) if host else path.stem, text))
    return devices


def has(text: str, pattern: str) -> bool:
    return re.search(pattern, text, re.I | re.M) is not None


def audit(dev: Device) -> None:
    t = dev.text
    role = "access" if dev.name.startswith("ACCESS") else (
        "dist" if dev.name.startswith("DIST") else (
            "core" if dev.name.startswith("CORE") else "edge"
        )
    )

    if not has(t, r"^service password-encryption"):
        dev.fail("PWD-ENC", "Missing 'service password-encryption'")
    if not has(t, r"^enable secret"):
        dev.fail("ENABLE-SECRET", "Missing enable secret")
    if not has(t, r"transport input ssh"):
        dev.fail("VTY-SSH", "VTY must be SSH-only")
    if has(t, r"transport input telnet") or has(t, r"transport input all"):
        dev.fail("VTY-TELNET", "Telnet must not be enabled on VTY")
    if not has(t, r"ip ssh version 2"):
        dev.fail("SSH-V2", "ip ssh version 2 required", "medium")
    if not has(t, r"access-class MGMT-ONLY in"):
        dev.fail("VTY-ACL", "VTY missing MGMT-ONLY access-class")

    if role == "access":
        if not has(t, r"switchport mode access"):
            dev.fail("ACCESS-MODE", "No access ports defined")
        if not has(t, r"spanning-tree portfast"):
            dev.fail("PORTFAST", "Access ports need portfast")
        if not has(t, r"bpduguard"):
            dev.fail("BPDUGUARD", "Access ports need BPDU Guard")
        if not has(t, r"switchport port-security"):
            dev.fail("PORT-SEC", "Port-security missing on access")
        if not has(t, r"ip dhcp snooping"):
            dev.fail("DHCP-SNOOP", "DHCP snooping required on access")
        if not has(t, r"ip arp inspection vlan"):
            dev.fail("DAI", "Dynamic ARP Inspection required")

    if role == "dist":
        if not has(t, r"standby \d+ ip"):
            dev.fail("HSRP", "Distribution SVIs must run HSRP")
        if not has(t, r"ip access-group GUEST-IN in"):
            dev.fail("GUEST-ACL", "Guest SVI must apply GUEST-IN")
        if not has(t, r"router ospf 1"):
            dev.fail("OSPF", "Distribution must run OSPF")
        if not has(t, r"passive-interface default"):
            dev.fail("OSPF-PASSIVE", "OSPF passive-interface default missing", "medium")

    if role == "core":
        if not has(t, r"router ospf 1"):
            dev.fail("OSPF", "Core must run OSPF")
        if not has(t, r"spanning-tree vlan .* priority 4096"):
            dev.fail("STP-ROOT", "Core should be STP root (priority 4096)", "medium")

    if role == "edge":
        if not has(t, r"ip nat inside source"):
            dev.fail("NAT", "Edge router should NAT inside list")
        if not has(t, r"default-information originate"):
            dev.fail("DEFAULT-ORIG", "Edge should originate default into OSPF", "medium")


def main() -> int:
    devices = load_devices()
    for d in devices:
        audit(d)

    high = sum(1 for d in devices for f in d.findings if f.severity == "high")
    med = sum(1 for d in devices for f in d.findings if f.severity != "high")

    print("Nexus Campus — config compliance")
    print(f"Devices: {len(devices)}")
    print("-" * 64)
    for d in devices:
        status = "PASS" if not d.findings else "FAIL"
        print(f"{d.name:16} {status:4}  {len(d.findings)} finding(s)")
        for f in d.findings:
            print(f"  [{f.severity:6}] {f.rule:16} {f.detail}")
    print("-" * 64)
    print(f"High: {high}   Medium: {med}")
    if high:
        print("RESULT: FAIL")
        return 1
    print("RESULT: PASS")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
