"""Generate lightweight WAV sound effects for MindArena."""
from __future__ import annotations

import math
import os
import struct
import wave

RATE = 22050
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "sfx")


def clamp(v: float) -> int:
    return max(-32767, min(32767, int(v)))


def write_wav(name: str, samples: list[float]) -> None:
    os.makedirs(OUT, exist_ok=True)
    path = os.path.abspath(os.path.join(OUT, name))
    with wave.open(path, "w") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(b"".join(struct.pack("<h", clamp(s * 32767)) for s in samples))
    print("wrote", path, "n=", len(samples))


def env(i: int, n: int, attack: float = 0.01, release: float = 0.08) -> float:
    t = i / RATE
    dur = n / RATE
    a = min(1.0, t / attack) if attack > 0 else 1.0
    r = min(1.0, max(0.0, (dur - t) / release)) if release > 0 else 1.0
    return a * r


def tone(freq: float, dur: float, vol: float = 0.28, attack: float = 0.008, release: float = 0.06) -> list[float]:
    n = int(dur * RATE)
    out = []
    for i in range(n):
        t = i / RATE
        out.append(vol * env(i, n, attack, release) * math.sin(2 * math.pi * freq * t))
    return out


def mix(*tracks: list[float]) -> list[float]:
    n = max(len(t) for t in tracks)
    out = [0.0] * n
    for t in tracks:
        for i, v in enumerate(t):
            out[i] += v
    peak = max(1e-6, max(abs(x) for x in out))
    if peak > 0.95:
        out = [x * 0.95 / peak for x in out]
    return out


def pad(samples: list[float], extra: float) -> list[float]:
    return samples + [0.0] * int(extra * RATE)


write_wav("click.wav", tone(920, 0.07, 0.22, 0.002, 0.05))
write_wav(
    "correct.wav",
    mix(tone(523.25, 0.12, 0.22), [0] * int(0.05 * RATE) + tone(783.99, 0.18, 0.28)),
)
write_wav(
    "wrong.wav",
    mix(tone(180, 0.22, 0.3, 0.005, 0.12), tone(140, 0.28, 0.18, 0.005, 0.14)),
)
write_wav("countdown.wav", tone(440, 0.16, 0.26, 0.004, 0.08))
write_wav(
    "go.wav",
    mix(tone(392, 0.18, 0.22), [0] * int(0.04 * RATE) + tone(659.25, 0.28, 0.3)),
)
write_wav(
    "levelup.wav",
    mix(
        tone(392, 0.16, 0.2),
        [0] * int(0.09 * RATE) + tone(523.25, 0.16, 0.22),
        [0] * int(0.18 * RATE) + tone(659.25, 0.16, 0.24),
        [0] * int(0.27 * RATE) + tone(783.99, 0.28, 0.28),
    ),
)
write_wav(
    "victory.wav",
    mix(
        tone(523.25, 0.22, 0.2),
        [0] * int(0.12 * RATE) + tone(659.25, 0.22, 0.22),
        [0] * int(0.24 * RATE) + tone(783.99, 0.22, 0.24),
        [0] * int(0.36 * RATE) + tone(1046.5, 0.4, 0.28, 0.01, 0.18),
    ),
)
write_wav("reward.wav", mix(tone(880, 0.12, 0.2), [0] * int(0.08 * RATE) + tone(1320, 0.22, 0.24)))

# Short looping cyber drone
drone = []
n = int(3.2 * RATE)
for i in range(n):
    t = i / RATE
    s = 0.07 * math.sin(2 * math.pi * 55 * t)
    s += 0.04 * math.sin(2 * math.pi * 110 * t + 0.4)
    s += 0.025 * math.sin(2 * math.pi * 220.5 * t)
    pulse = 0.5 + 0.5 * math.sin(2 * math.pi * 0.6 * t)
    arp = 0.0
    if int(t * 8) % 8 in (0, 3, 5):
        arp = 0.05 * math.sin(2 * math.pi * (440 if int(t * 8) % 8 == 0 else 660) * t)
    drone.append((s * pulse + arp) * env(i, n, 0.15, 0.2))
write_wav("music.wav", drone)
