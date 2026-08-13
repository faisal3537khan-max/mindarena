# Career kit — LinkedIn + proof projects

This folder is the professional layer on top of **MindArena** for **Muhammad Faisal Khan** (Air University, Lahore).

LinkedIn will not let this chat log into your account. Do not send a password.
Paste `LINKEDIN.md` and `PROJECTS.md` yourself.

## Contents

| Path | What it is |
| --- | --- |
| [LINKEDIN.md](LINKEDIN.md) | Headline, About, Experience, skills — paste these |
| [PROJECTS.md](PROJECTS.md) | Five LinkedIn project write-ups |
| [HOW_TO_PUBLISH.md](HOW_TO_PUBLISH.md) | Click-by-click on LinkedIn |
| [portfolio/](portfolio/) | HTML site + 1584×396 banner SVG |
| [projects/algoforge](projects/algoforge/) | C++ data structures & algorithms |
| [projects/arena-intel](projects/arena-intel/) | Python + SQLite API |
| [projects/nexus-campus](projects/nexus-campus/) | Cisco campus + compliance auditor |

MindArena itself is the Flutter project (repo root). Product and architecture docs: [docs/GAMEPLAY.md](../docs/GAMEPLAY.md), [docs/ARCHITECTURE.md](../docs/ARCHITECTURE.md).

## Order of operations

1. Fill every `REPLACE:` in `LINKEDIN.md` and `portfolio/index.html`.
2. Run the auditor and the C++ tests so you can speak to them.
3. Push GitHub. Host `career/portfolio` on GitHub Pages.
4. Paste LinkedIn using `HOW_TO_PUBLISH.md`.

## Sanity checks

```bash
python career/projects/nexus-campus/automation/compliance.py
python career/projects/arena-intel/seed.py
python career/projects/arena-intel/server.py
```

```bash
cd career/projects/algoforge
cmake -S . -B build && cmake --build build
```
