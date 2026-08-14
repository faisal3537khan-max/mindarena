# AlgoForge

Header-only C++17 library of core data structures and graph algorithms.

| Component | API | Complexity |
| --- | --- | --- |
| `Vector<T>` | grow, copy/move, `at` / `[]` | amort. O(1) push |
| `HashMap<K,V>` | insert, find, erase, rehash @ 0.75 | average O(1) |
| `AvlTree<K,V>` | insert, erase, lower_bound, `valid()` | O(log n) |
| `LruCache<K,V>` | get/put/erase O(1), peek, stats | O(1) |
| `BinaryHeap<T>` | push/pop, heapify from range | O(log n) / O(n) build |
| `UnionFind` | find, unite, component size | ~O(α(n)) |
| `Trie` | insert, contains, prefix, erase | O(L) |
| `Graph` | BFS, DFS, Kahn topological sort | O(V+E) |
| `dijkstra` | distances + parent path | O((V+E) log V) |
| `dijkstra_bidirectional` | s–t shortest path | O((V+E) log V) |
| `bellman_ford` | negative-cycle flag | O(VE) |
| `astar` | admissible heuristic | O((V+E) log V) |
| `kruskal` | undirected MST | O(E log E) |
| `merge_sort` / `heap_sort` | in-place / buffer | O(n log n) |

Dijkstra rejects negative weights (`std::invalid_argument`). Use `bellman_ford` for those graphs.

Not thread-safe. Single-threaded ownership of each container.

## Layout

```
include/algoforge/   public headers
tests/               unit tests (invariants + oracles)
src/bench.cpp        median-of-trials microbenchmarks
CMakeLists.txt
```

## Build

```bat
g++ -std=c++17 -Wall -Wextra -Werror -O2 -I include tests\test_algoforge.cpp -o build\algoforge_test.exe
g++ -std=c++17 -Wall -Wextra -Werror -O2 -I include src\bench.cpp -o build\algoforge_bench.exe
build\algoforge_test.exe
```

```bash
cmake -S . -B build -DALGOFORGE_BUILD_TESTS=ON
cmake --build build
ctest --test-dir build --output-on-failure
```

## Use

```cpp
#include <algoforge/algoforge.hpp>

algoforge::AvlTree<int, int> tree;
tree.insert(8, 80);
tree.erase(8);

algoforge::LruCache<int, int> cache(128);
cache.put(1, 10);
int* hit = cache.get(1);

algoforge::Graph g(4, /*directed=*/true);
g.add_edge(0, 1, 2.0);
algoforge::PathResult path = algoforge::dijkstra(g, 0);
std::vector<int> nodes = path.reconstruct(1);
```

Include only the header you need (`avl.hpp`, `lru.hpp`, `shortest_path.hpp`, …) or `algoforge.hpp` for the full surface.

## Invariants covered by tests

- AVL: BST order, `|balance| ≤ 1`, height vs sequential insert, random ops vs `std::map`
- LRU: eviction order, capacity shrink, hit/miss
- Dijkstra: reconstructed path, unreachable vertices, equality with Bellman-Ford, bidirectional match, negative-weight rejection
- Kruskal: spanning tree weight on a known graph
- Vector / HashMap / Heap / Trie: growth, rehash, heapify, prefix erase
