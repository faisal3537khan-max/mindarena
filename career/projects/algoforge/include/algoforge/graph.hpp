#pragma once
#include <algorithm>
#include <limits>
#include <queue>
#include <utility>
#include <vector>

#include "heap.hpp"

namespace algoforge {

struct Graph {
  int n = 0;
  std::vector<std::vector<std::pair<int, double>>> adj;

  explicit Graph(int nodes) : n(nodes), adj(nodes) {}

  void add_edge(int u, int v, double w = 1.0, bool directed = false) {
    adj[u].push_back({v, w});
    if (!directed) adj[v].push_back({u, w});
  }

  std::vector<int> bfs(int start) const {
    std::vector<int> order;
    std::vector<char> seen(n, 0);
    std::queue<int> q;
    seen[start] = 1;
    q.push(start);
    while (!q.empty()) {
      int u = q.front();
      q.pop();
      order.push_back(u);
      for (auto [v, w] : adj[u]) {
        (void)w;
        if (!seen[v]) {
          seen[v] = 1;
          q.push(v);
        }
      }
    }
    return order;
  }

  std::vector<double> dijkstra(int start) const {
    const double inf = std::numeric_limits<double>::infinity();
    std::vector<double> dist(n, inf);
    using Node = std::pair<double, int>;
    BinaryHeap<Node> heap;
    dist[start] = 0;
    heap.push({0, start});
    while (!heap.empty()) {
      auto [d, u] = heap.pop();
      if (d != dist[u]) continue;
      for (auto [v, w] : adj[u]) {
        if (dist[u] + w < dist[v]) {
          dist[v] = dist[u] + w;
          heap.push({dist[v], v});
        }
      }
    }
    return dist;
  }

  std::vector<double> astar(int start, int goal, const std::vector<double>& h) const {
    const double inf = std::numeric_limits<double>::infinity();
    std::vector<double> g(n, inf);
    using Node = std::pair<double, int>;
    BinaryHeap<Node> heap;
    g[start] = 0;
    heap.push({h[start], start});
    while (!heap.empty()) {
      auto [f, u] = heap.pop();
      (void)f;
      if (u == goal) break;
      for (auto [v, w] : adj[u]) {
        if (g[u] + w < g[v]) {
          g[v] = g[u] + w;
          heap.push({g[v] + h[v], v});
        }
      }
    }
    return g;
  }

  // Kahn. Returns false if the graph has a cycle.
  bool topo_sort(std::vector<int>& out) const {
    std::vector<int> indeg(n, 0);
    for (int u = 0; u < n; ++u) {
      for (auto [v, w] : adj[u]) {
        (void)w;
        ++indeg[v];
      }
    }
    std::queue<int> q;
    for (int i = 0; i < n; ++i) if (!indeg[i]) q.push(i);
    out.clear();
    while (!q.empty()) {
      int u = q.front();
      q.pop();
      out.push_back(u);
      for (auto [v, w] : adj[u]) {
        (void)w;
        if (--indeg[v] == 0) q.push(v);
      }
    }
    return static_cast<int>(out.size()) == n;
  }
};

}  // namespace algoforge
