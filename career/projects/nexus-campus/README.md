# Nexus Campus

Enterprise campus network for a fictional 800-person HQ (Karachi). Three-tier switching, redundant first hop, OSPF, guest isolation, and a Python compliance auditor that reads the IOS configs in this repo.

This is a **design + lab** project. It is not employment at Cisco.

## Topology

```
                    [ISP-A]              [ISP-B]
                       |                    |
                   EDGE-RTR01           EDGE-RTR02
                       |                    |
                       +-------- FW01 ------+
                                  |
                            CORE-SW01  ===  CORE-SW02
                                  |
                    DIST-SW01 (HSRP) === DIST-SW02 (HSRP)
                         |                    |
              ACCESS-SW01..04          ACCESS-SW05..08
                    |                         |
              Users / Voice / IoT        Users / Voice / Guest
```

## Addressing

| VLAN | Name | SVI | Purpose |
| --- | --- | --- | --- |
| 10 | USERS | 10.10.10.0/23 | Staff data |
| 20 | VOICE | 10.10.20.0/24 | IP phones |
| 30 | SERVERS | 10.10.30.0/24 | App / DB |
| 40 | GUEST | 10.10.40.0/24 | Isolated Wi-Fi |
| 50 | IOT | 10.10.50.0/24 | Cameras, badges |
| 99 | MGMT | 10.10.99.0/24 | Out-of-band / SVIs |

HSRP VIP per SVI: `.1` · DIST-SW01 priority 110 · DIST-SW02 priority 100.

## Routing & edge

- OSPF process 1, area 0 on core and distribution point-to-point links (`10.255.0.0/24`).
- Access switches are Layer-2 only; SVIs live on distribution.
- Passive-interface default on DIST SVIs (no OSPF hellos toward PCs).
- Edge: static default to ISP, OSPF default-information originate on EDGE-RTR01 (primary).

## Security baseline (what the auditor checks)

1. `vty` transport `ssh` only — telnet is a fail.
2. Access ports: `switchport mode access` + `portfast` + `bpduguard`.
3. DHCP snooping + DAI on USERS/GUEST/IOT.
4. Port-security (max 3, violation restrict) on access.
5. Guest ACL applied inbound on VLAN 40 SVI.
6. Enable secret present; `service password-encryption`.

## Run the auditor

```bash
python career/projects/nexus-campus/automation/compliance.py
```

Exit code 0 = all devices pass. Non-zero = a hiring-manager-friendly report on stdout.

## Interview talking points

- Why three-tier vs collapsed core for 800 users.
- Why guest is a dedicated VLAN + ACL, not “just NAT”.
- Why HSRP on distribution, not on access.
- How a Python parser turns config review into CI.
