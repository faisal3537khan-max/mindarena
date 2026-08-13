#include <algoforge/algoforge.hpp>

#include <chrono>
#include <iostream>
#include <random>
#include <string>
#include <vector>

using clock_t = std::chrono::high_resolution_clock;

template <typename F>
double ms(F&& fn) {
  auto t0 = clock_t::now();
  fn();
  auto t1 = clock_t::now();
  return std::chrono::duration<double, std::milli>(t1 - t0).count();
}

int main() {
  constexpr int n = 50000;
  std::mt19937 rng(42);
  std::uniform_int_distribution<int> dist(0, n * 4);

  std::vector<int> raw(n);
  for (int& x : raw) x = dist(rng);

  algoforge::HashMap<int, int> map;
  double t_map = ms([&] {
    for (int x : raw) map.put(x, x);
  });

  algoforge::AvlTree<int, int> avl;
  double t_avl = ms([&] {
    for (int x : raw) avl.put(x, x);
  });

  algoforge::LruCache<int, int> lru(1024);
  double t_lru = ms([&] {
    for (int x : raw) {
      if (!lru.get(x)) lru.put(x, x);
    }
  });

  algoforge::Graph g(200);
  for (int i = 0; i < 199; ++i) g.add_edge(i, i + 1, 1.0, true);
  for (int i = 0; i < 400; ++i) g.add_edge(rng() % 200, rng() % 200, 1.0 + (rng() % 9), true);
  double t_dij = ms([&] { g.dijkstra(0); });

  std::vector<int> sorted = raw;
  double t_merge = ms([&] { algoforge::merge_sort(sorted); });

  std::cout << "AlgoForge benchmarks (n=" << n << ")\n";
  std::cout << "  HashMap put:     " << t_map << " ms\n";
  std::cout << "  AVL put:         " << t_avl << " ms\n";
  std::cout << "  LRU get/put:     " << t_lru << " ms\n";
  std::cout << "  Dijkstra V=200:  " << t_dij << " ms\n";
  std::cout << "  Merge sort:      " << t_merge << " ms\n";
  return 0;
}
