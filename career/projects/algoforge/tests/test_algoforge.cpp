#include <algoforge/algoforge.hpp>

#include <algorithm>
#include <cmath>
#include <iostream>
#include <map>
#include <random>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

using namespace algoforge;

namespace {

int g_failed = 0;
int g_passed = 0;

void expect(bool cond, const char* msg) {
  if (cond) {
    ++g_passed;
    return;
  }
  ++g_failed;
  std::cerr << "FAIL: " << msg << "\n";
}

#define EXPECT(cond) expect(static_cast<bool>(cond), #cond)

void test_avl_sequential() {
  AvlTree<int, int> t;
  EXPECT(t.empty());
  for (int i = 1; i <= 64; ++i) t.insert(i, i * 10);
  EXPECT(t.size() == 64);
  EXPECT(t.valid());
  EXPECT(t.find(13) && *t.find(13) == 130);
  EXPECT(*t.min_key() == 1);
  EXPECT(*t.max_key() == 64);
  EXPECT(t.height() <= 8);  // ceil(1.44*log2(66)) ≈ 8
  EXPECT(t.lower_bound(40) && *t.lower_bound(40) == 40);
  EXPECT(t.lower_bound(41) && *t.lower_bound(41) == 41);
  std::vector<int> keys;
  t.inorder_keys(keys);
  EXPECT(std::is_sorted(keys.begin(), keys.end()));
  EXPECT(keys.front() == 1 && keys.back() == 64);
}

void test_avl_erase_and_rebalance() {
  AvlTree<int, int> t;
  for (int i = 0; i < 31; ++i) t.insert(i, i);
  EXPECT(t.valid());
  EXPECT(t.erase(0));
  EXPECT(t.erase(15));
  EXPECT(t.erase(30));
  EXPECT(!t.erase(99));
  EXPECT(t.size() == 28);
  EXPECT(t.valid());
  EXPECT(!t.contains(15));
  t.insert(15, 150);
  EXPECT(t.contains(15) && *t.find(15) == 150);
  EXPECT(t.valid());
}

void test_avl_vs_map_random() {
  AvlTree<int, int> t;
  std::map<int, int> ref;
  std::mt19937 rng(2026);
  std::uniform_int_distribution<int> keys(0, 400);
  for (int i = 0; i < 2000; ++i) {
    const int k = keys(rng);
    if ((rng() & 3) == 0) {
      EXPECT(t.erase(k) == (ref.erase(k) > 0));
    } else {
      t.insert(k, i);
      ref[k] = i;
    }
  }
  EXPECT(t.size() == ref.size());
  EXPECT(t.valid());
  for (const auto& kv : ref) {
    const int* v = t.find(kv.first);
    EXPECT(v && *v == kv.second);
  }
}

void test_lru_classic() {
  LruCache<int, int> c(2);
  c.put(1, 10);
  c.put(2, 20);
  EXPECT(c.get(1) && *c.get(1) == 10);
  c.put(3, 30);
  EXPECT(c.get(2) == nullptr);
  EXPECT(c.get(1) && *c.get(1) == 10);
  EXPECT(c.mru_key() && *c.mru_key() == 1);
  EXPECT(c.lru_key() && *c.lru_key() == 3);
  EXPECT(c.erase(1));
  EXPECT(!c.contains(1));
  EXPECT(c.size() == 1);
}

void test_lru_capacity_and_stats() {
  LruCache<std::string, int> c(3);
  c.put("a", 1);
  c.put("b", 2);
  c.put("c", 3);
  EXPECT(c.get("z") == nullptr);
  EXPECT(c.get("a") && *c.get("a") == 1);
  c.set_capacity(2);
  EXPECT(c.size() == 2);
  EXPECT(!c.contains("b"));  // oldest after promoting a
  EXPECT(c.hits() >= 1);
  EXPECT(c.misses() >= 1);
  EXPECT(c.peek("a") != nullptr);
  const auto order = c.keys();
  EXPECT(!order.empty() && order[0] == "a");
}

void test_dijkstra_textbook() {
  Graph g(4);
  g.add_edge(0, 1, 1, true);
  g.add_edge(1, 2, 2, true);
  g.add_edge(0, 3, 10, true);
  g.add_edge(1, 3, 4, true);
  const PathResult r = dijkstra(g, 0);
  EXPECT(r.dist[2] == 3);
  EXPECT(r.dist[3] == 5);
  const auto path = r.reconstruct(2);
  EXPECT((path == std::vector<int>{0, 1, 2}));
}

void test_dijkstra_early_exit_and_unreachable() {
  Graph g(5);
  g.add_edge(0, 1, 2, true);
  g.add_edge(1, 2, 2, true);
  g.add_edge(2, 3, 2, true);
  const PathResult r = dijkstra(g, 0, 2);
  EXPECT(r.reachable(2));
  EXPECT(!r.reachable(4));
  EXPECT(r.reconstruct(4).empty());
}

void test_dijkstra_matches_bellman_ford() {
  Graph g(8);
  std::mt19937 rng(7);
  for (int i = 0; i < 7; ++i) g.add_edge(i, i + 1, 1.0 + (rng() % 5), true);
  for (int i = 0; i < 20; ++i) {
    int u = rng() % 8, v = rng() % 8;
    if (u != v) g.add_edge(u, v, 1.0 + (rng() % 9), true);
  }
  const PathResult a = dijkstra(g, 0);
  const PathResult b = bellman_ford(g, 0);
  for (int i = 0; i < 8; ++i) EXPECT(a.dist[i] == b.dist[i]);
}

void test_bidirectional_matches() {
  Graph g(6);
  g.add_edge(0, 1, 2, true);
  g.add_edge(1, 2, 2, true);
  g.add_edge(2, 5, 2, true);
  g.add_edge(0, 3, 10, true);
  g.add_edge(3, 4, 1, true);
  g.add_edge(4, 5, 1, true);
  const PathResult uni = dijkstra(g, 0, 5);
  const PathResult bi = dijkstra_bidirectional(g, 0, 5);
  EXPECT(uni.dist[5] == bi.dist[5]);
  EXPECT(uni.dist[5] == 6);
}

void test_dijkstra_rejects_negative() {
  Graph g(2);
  g.add_edge(0, 1, -1, true);
  bool threw = false;
  try {
    dijkstra(g, 0);
  } catch (const std::invalid_argument&) {
    threw = true;
  }
  EXPECT(threw);
  bool neg = false;
  const PathResult r = bellman_ford(g, 0, &neg);
  EXPECT(r.dist[1] == -1);
  EXPECT(!neg);
}

void test_astar_zero_heuristic_is_dijkstra() {
  Graph g(4);
  g.add_edge(0, 1, 3, true);
  g.add_edge(0, 2, 1, true);
  g.add_edge(2, 1, 1, true);
  g.add_edge(1, 3, 2, true);
  std::vector<double> h(4, 0.0);
  const PathResult a = astar(g, 0, 3, h);
  const PathResult d = dijkstra(g, 0, 3);
  EXPECT(a.dist[3] == d.dist[3]);
}

void test_support_structures() {
  HashMap<std::string, int> map;
  map.put("alpha", 1);
  map.put("beta", 2);
  EXPECT(map.get("alpha") && *map.get("alpha") == 1);
  EXPECT(map.erase("beta"));
  EXPECT(map.size() == 1);

  UnionFind uf(6);
  uf.unite(0, 1);
  uf.unite(1, 2);
  uf.unite(3, 4);
  EXPECT(uf.find(0) == uf.find(2));
  EXPECT(uf.components() == 3);

  Trie trie;
  trie.insert("flutter");
  trie.insert("flow");
  EXPECT(trie.contains("flutter"));
  EXPECT(trie.starts_with("fl"));
  EXPECT(!trie.contains("fl"));

  std::vector<int> order;
  Graph dag(3);
  dag.add_edge(0, 1, 1, true);
  dag.add_edge(1, 2, 1, true);
  EXPECT(dag.topo_sort(order));
  EXPECT((order == std::vector<int>{0, 1, 2}));

  std::vector<int> a{5, 1, 4, 2, 3};
  merge_sort(a);
  EXPECT((a == std::vector<int>{1, 2, 3, 4, 5}));
  EXPECT(binary_search_index(a, 4) == 3);

  BinaryHeap<int> heap;
  heap.push(9);
  heap.push(1);
  heap.push(4);
  EXPECT(heap.pop() == 1);
}

void test_vector_grow_copy_move() {
  Vector<int> v;
  for (int i = 0; i < 100; ++i) v.push_back(i);
  EXPECT(v.size() == 100);
  EXPECT(v.capacity() >= 100);
  EXPECT(v.front() == 0 && v.back() == 99);
  Vector<int> c = v;
  EXPECT(c.size() == 100 && c[50] == 50);
  Vector<int> m = std::move(v);
  EXPECT(m.size() == 100);
  EXPECT(v.empty());
  m.pop_back();
  EXPECT(m.size() == 99);
}

void test_hashmap_rehash() {
  HashMap<int, int> m(8);
  for (int i = 0; i < 64; ++i) m.insert(i, i * 3);
  EXPECT(m.size() == 64);
  EXPECT(m.contains(17) && *m.find(17) == 51);
  EXPECT(m.bucket_count() >= 8);
  EXPECT(m.erase(17));
  EXPECT(!m.contains(17));
  m[2] = 99;
  EXPECT(*m.find(2) == 99);
}

void test_heapify_and_heap_sort() {
  BinaryHeap<int> h(std::vector<int>{9, 1, 4, 0, 7});
  EXPECT(h.pop() == 0);
  EXPECT(h.pop() == 1);
  std::vector<int> a{5, 1, 4, 2, 3, 0};
  heap_sort(a);
  EXPECT((a == std::vector<int>{0, 1, 2, 3, 4, 5}));
}

void test_trie_erase() {
  Trie t;
  t.insert("flow");
  t.insert("flower");
  t.insert("flight");
  EXPECT(t.size() == 3);
  EXPECT(t.erase("flow"));
  EXPECT(!t.contains("flow"));
  EXPECT(t.contains("flower"));
  EXPECT(t.starts_with("fl"));
  EXPECT(t.size() == 2);
}

void test_mst_and_dfs() {
  Graph g(4, false);
  g.add_edge(0, 1, 1);
  g.add_edge(1, 2, 2);
  g.add_edge(2, 3, 3);
  g.add_edge(0, 3, 10);
  const MstResult m = kruskal(g);
  EXPECT(m.spanning);
  EXPECT(m.edges.size() == 3);
  EXPECT(m.total_weight == 6);
  const auto d = g.dfs(0);
  EXPECT(!d.empty() && d[0] == 0);
  EXPECT(g.bfs(0).size() == 4);
}

void test_version() {
  EXPECT(kVersion != nullptr);
  EXPECT(ALGOFORGE_VERSION_MAJOR == 1);
}

}  // namespace

int main() {
  test_avl_sequential();
  test_avl_erase_and_rebalance();
  test_avl_vs_map_random();
  test_lru_classic();
  test_lru_capacity_and_stats();
  test_dijkstra_textbook();
  test_dijkstra_early_exit_and_unreachable();
  test_dijkstra_matches_bellman_ford();
  test_bidirectional_matches();
  test_dijkstra_rejects_negative();
  test_astar_zero_heuristic_is_dijkstra();
  test_support_structures();
  test_vector_grow_copy_move();
  test_hashmap_rehash();
  test_heapify_and_heap_sort();
  test_trie_erase();
  test_mst_and_dfs();
  test_version();

  std::cout << "algoforge tests: " << g_passed << " passed, " << g_failed << " failed\n";
  return g_failed ? 1 : 0;
}
