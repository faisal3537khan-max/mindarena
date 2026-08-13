#include <algoforge/algoforge.hpp>

#include <cassert>
#include <iostream>
#include <vector>

int main() {
  algoforge::HashMap<std::string, int> map;
  map.put("alpha", 1);
  map.put("beta", 2);
  assert(map.get("alpha") && *map.get("alpha") == 1);
  assert(map.erase("beta"));
  assert(map.size() == 1);

  algoforge::AvlTree<int, int> avl;
  for (int i = 0; i < 64; ++i) avl.put(i, i * 10);
  assert(avl.get(13) && *avl.get(13) == 130);
  assert(avl.height() <= 8);

  algoforge::UnionFind uf(6);
  uf.unite(0, 1);
  uf.unite(1, 2);
  uf.unite(3, 4);
  assert(uf.find(0) == uf.find(2));
  assert(uf.components() == 3);

  algoforge::LruCache<int, int> lru(2);
  lru.put(1, 10);
  lru.put(2, 20);
  lru.get(1);
  lru.put(3, 30);
  assert(lru.get(2) == nullptr);
  assert(lru.get(1) && *lru.get(1) == 10);

  algoforge::Trie trie;
  trie.insert("flutter");
  trie.insert("flow");
  assert(trie.contains("flutter"));
  assert(trie.starts_with("fl"));
  assert(!trie.contains("fl"));

  algoforge::Graph g(4);
  g.add_edge(0, 1, 1, true);
  g.add_edge(1, 2, 2, true);
  g.add_edge(0, 3, 10, true);
  auto d = g.dijkstra(0);
  assert(d[2] == 3);

  std::vector<int> order;
  algoforge::Graph dag(3);
  dag.add_edge(0, 1, 1, true);
  dag.add_edge(1, 2, 1, true);
  assert(dag.topo_sort(order));
  assert((order == std::vector<int>{0, 1, 2}));

  std::vector<int> a{5, 1, 4, 2, 3};
  algoforge::merge_sort(a);
  assert((a == std::vector<int>{1, 2, 3, 4, 5}));
  assert(algoforge::binary_search_index(a, 4) == 3);

  algoforge::BinaryHeap<int> heap;
  heap.push(9);
  heap.push(1);
  heap.push(4);
  assert(heap.pop() == 1);

  std::cout << "algoforge tests: ok\n";
  return 0;
}
