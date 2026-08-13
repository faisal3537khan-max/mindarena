# LinkedIn → Add profile section → Projects

Create **five** projects. Associate each with **Air University** (education) or **Independent Developer**. Character limit is 2,000.

Link GitHub: https://github.com/khan0011/mindarena

---

## Project 1 — MindArena (Flutter)

**Name:** MindArena — Competitive Mini-Game Platform  
**Dates:** Jan 2026 – Present  
**Associated with:** Air University  
**Skills:** Flutter, Dart, Provider, Mobile Application Development, UI/UX, Git

```
MindArena is a cross-platform competitive arena I built in Flutter as a 3rd-year CS student at Air University: ten game categories, multiple live modes, and a full player economy.

I designed the session loop — splash → identity → home → match → results → progression — so a first-time player understands rank, coins, and season goals in under a minute.

Engineering
• State: Provider + a central GameStore for profile, match history, missions, shop, and audio.
• Persistence: JSON snapshots in SharedPreferences (profile, accounts, question pipeline).
• Modes: 60-second rush, practice, daily, CPU duel, weekly, tournament, plus reaction / memory / accuracy arenas.
• Systems: seasons with a reward track, daily missions, achievements, friends list, leaderboards (global / country / university), review notebook, and a content pipeline for new questions.
• UX: custom neon design system, reduce-motion, color-blind support, graphics quality tiers, and haptics.

This is the product I point to when a hiring manager asks “show me an app you actually finished.”
```

Media: screenshots of home, rush, results, shop.

---

## Project 2 — AlgoForge (C++ / DSA)

**Name:** AlgoForge — C++ Algorithms & Data Structures  
**Dates:** 2026 – Present  
**Associated with:** Air University  
**Skills:** C++, Data Structures, Algorithms, Graph Algorithms, Object-Oriented Programming

```
AlgoForge is a modern C++17 library of the structures and algorithms used in software interviews and in real systems. I built it to prove CS fundamentals beyond coursework.

It is not a dump of LeetCode files. Each structure has documented complexity and a benchmark binary that times the hot path.

Includes
• Sequences & maps: dynamic array, separate-chaining hash map, LRU cache (O(1) get/put).
• Trees & sets: AVL tree, binary heap, trie, disjoint-set (union by rank + path compression).
• Graphs: adjacency list, BFS/DFS, Dijkstra, A*, topological sort, Kahn cycle detection.
• Sorting: merge sort and binary search helpers.

I built this to reason about memory, invariants, and Big-O — not only UI.
```

---

## Project 3 — Arena Intel (Python + Database)

**Name:** Arena Intel — Match Analytics API  
**Dates:** 2026 – Present  
**Associated with:** Air University  
**Skills:** Python, SQL, SQLite, REST APIs, Database Design

```
Arena Intel is an analytics backend for competitive game data. It models players, matches, answers, and categories in 3NF SQLite, then exposes a REST API and SQL views that product teams actually ask for.

Schema
• Players, matches, match_answers, categories, seasons — foreign keys and indexes on (player_id, played_at) and leaderboard score.
• Views: v_player_form, v_category_skill, v_season_standings.

API (Python stdlib http.server)
• GET /players/:id/stats — win rate, best category, recent form
• GET /leaderboard?scope=global|country — indexed top-N
• GET /intel/risk — players whose results sit in a fragile mid win-rate band
• POST /matches — transactional insert of a match + answers

This is how I talk about databases in interviews: keys, indexes, transactions, and queries with a purpose.
```

---

## Project 4 — Nexus Campus (Cisco + Python)

**Name:** Nexus Campus — Enterprise Network Design & Compliance  
**Dates:** 2026 – Present  
**Associated with:** Air University  
**Skills:** Cisco Networking, VLAN, OSPF, Network Automation, Python

```
Nexus Campus is a documented enterprise campus for a fictional 800-user HQ: three-tier switching, dual-homed WAN edge, and a Python auditor that reads Cisco IOS configs.

This is a lab design for my CS / networks work. It is not employment at Cisco.

Design
• Access / distribution / core with 802.1Q VLANs (Users, Voice, Servers, Guest, IoT, Mgmt).
• OSPF single-area on core/distribution, passive interfaces toward access SVIs.
• HSRP on distribution SVIs for first-hop redundancy.
• Security baseline: DHCP snooping, Dynamic ARP Inspection, port-security, BPDU Guard, SSH-only VTY, named ACLs for guest isolation.

Automation
• A Python compliance engine parses the .cfg files and fails if a switch is missing portfast + BPDU Guard on access ports, or if telnet is left on.
```

---

## Project 5 — Pulsefolio (HTML)

**Name:** Pulsefolio — Recruiter Portfolio  
**Dates:** 2026 – Present  
**Associated with:** Air University  
**Skills:** HTML, CSS, JavaScript, UI/UX, Documentation

```
Pulsefolio is my public case-study site: semantic HTML, a tight visual system, keyboard-accessible navigation, and project pages written for hiring managers who skim.

• One-page architecture with in-page case studies (problem → approach → stack → proof).
• No framework — CSS Grid/Flex, custom properties, reduced-motion support.
• LinkedIn banner SVG at 1584×396.

The site exists so a recruiter can go from headline → proof in two clicks.
```
