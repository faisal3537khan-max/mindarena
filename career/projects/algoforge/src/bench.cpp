#include <algoforge/algoforge.hpp>

#include <algorithm>
#include <chrono>
#include <iomanip>
#include <iostream>
#include <map>
#include <random>
#include <string>
#include <vector>

using SteadyClock = std::chrono::steady_clock;

template <typename F>
double median_ms(F&& fn, int trials = 7, int warmup = 1) {
  for (int i = 0; i < warmup; ++i) fn();
  std::vector<double> samples;
  samples.reserve(trials);
  for (int i = 0; i < trials; ++i) {
    const auto t0 = SteadyClock::now();
    fn();
    const auto t1 = SteadyClock::now();
    samples.push_back(std::chrono::duration<double, std::milli>(t1 - t0).count());
  }
  std::nth_element(samples.begin(), samples.begin() + samples.size() / 2, samples.end());
  return samples[samples.size() / 2];
}

void row(const std::string& name, double ms) {
  std::cout << "  " << std::left << std::setw(36) << name << std::right << std::setw(10)
            << std::fixed << std::setprecision(3) << ms << " ms\n";
}

int main() {
  std::mt19937 rng(42);
  std::cout << "AlgoForge benchmarks (median of 7 trials, 1 warmup)\n\n";

  for (const int n : {10000, 50000}) {
    std::uniform_int_distribution<int> dist(0, n * 4);
    std::vector<int> raw(n);
    for (int& x : raw) x = dist(rng);

    std::cout << "n = " << n << "\n";

    row("AVL insert", median_ms([&] {
          algoforge::AvlTree<int, int> avl;
          for (int x : raw) avl.insert(x, x);
        }));

    row("std::map insert (baseline)", median_ms([&] {
          std::map<int, int> m;
          for (int x : raw) m[x] = x;
        }));

    algoforge::AvlTree<int, int> avl;
    for (int x : raw) avl.insert(x, x);
    row("AVL find all", median_ms([&] {
          volatile int sink = 0;
          for (int x : raw) {
            if (const int* v = avl.find(x)) sink += *v;
          }
          (void)sink;
        }));

    row("LRU get/put cap=1024", median_ms([&] {
          algoforge::LruCache<int, int> lru(1024);
          for (int x : raw) {
            if (!lru.get(x)) lru.put(x, x);
          }
        }));

    row("Naive O(n) cache cap=1024", median_ms([&] {
          std::vector<std::pair<int, int>> naive;
          naive.reserve(1024);
          for (int x : raw) {
            auto it = std::find_if(naive.begin(), naive.end(),
                                   [&](const auto& kv) { return kv.first == x; });
            if (it == naive.end()) {
              if (naive.size() == 1024) naive.erase(naive.begin());
              naive.push_back({x, x});
            } else {
              std::pair<int, int> hit = *it;
              naive.erase(it);
              naive.push_back(hit);
            }
          }
        }));

    std::cout << "\n";
  }

  constexpr int V = 2000;
  constexpr int extra = 8000;
  algoforge::Graph g(V);
  for (int i = 0; i < V - 1; ++i) g.add_edge(i, i + 1, 1.0, true);
  std::uniform_int_distribution<int> vertex(0, V - 1);
  std::uniform_real_distribution<double> w(1.0, 12.0);
  for (int i = 0; i < extra; ++i) {
    int u = vertex(rng), v = vertex(rng);
    if (u != v) g.add_edge(u, v, w(rng), true);
  }

  std::cout << "shortest paths  V=" << V << "  E≈" << g.edge_count() << "\n";
  row("Dijkstra (lazy heap)", median_ms([&] { algoforge::dijkstra(g, 0); }, 5, 1));
  row("Dijkstra to target V-1", median_ms([&] { algoforge::dijkstra(g, 0, V - 1); }, 5, 1));
  row("Bidirectional Dijkstra", median_ms([&] { algoforge::dijkstra_bidirectional(g, 0, V - 1); }, 5, 1));
  row("Bellman-Ford (oracle)", median_ms([&] { algoforge::bellman_ford(g, 0); }, 3, 0));

  return 0;
}
