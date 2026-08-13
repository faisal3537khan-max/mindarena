# AlgoForge

C++17 library of the data structures and algorithms used in software interviews and in production systems. Header-only. Documented complexity. A benchmark binary times the hot path.

This is not a folder of unsolved LeetCode screenshots.

## Layout

```
include/algoforge/   public headers
src/bench.cpp        micro-benchmarks
tests/test_algoforge.cpp
CMakeLists.txt
```

## Structures

| Component | Average | Worst | Notes |
| --- | --- | --- | --- |
| `Vector<T>` | amort. O(1) push | O(n) grow | doubling buffer |
| `HashMap<K,V>` | O(1) | O(n) | separate chaining |
| `BinaryHeap<T>` | O(log n) push/pop | O(log n) | 4-ary optional later |
| `AvlTree<K,V>` | O(log n) | O(log n) | height-balanced |
| `Trie` | O(L) | O(L) | prefix search |
| `UnionFind` | ~O(α(n)) | ~O(α(n)) | rank + path compression |
| `LruCache<K,V>` | O(1) get/put | O(1) | list + hash |
| `Graph` BFS/DFS | O(V+E) | O(V+E) | adjacency list |
| `dijkstra` | O((V+E) log V) | same | binary heap |
| `topo_sort` | O(V+E) | O(V+E) | Kahn; false if cycle |

## Build

```bash
cd career/projects/algoforge
cmake -S . -B build
cmake --build build
./build/algoforge_bench
./build/algoforge_test
```

On Windows (Visual Studio generator):

```bat
cmake -S . -B build
cmake --build build --config Release
build\Release\algoforge_test.exe
```

## Interview talking points

- Why LRU is list + hashmap, not a vector scan.
- Why union-by-rank plus path compression is α(n), not “almost O(1)” as a slogan without the inverse Ackermann name.
- Why Dijkstra needs a decrease-key story (here: lazy heap).
- Why AVL rotations preserve BST order.
