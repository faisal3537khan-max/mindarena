#pragma once

#include "graph.hpp"
#include "heap.hpp"
#include "version.hpp"

#include <algorithm>
#include <stdexcept>
#include <utility>
#include <vector>

namespace algoforge {

struct PathResult {
  std::vector<double> dist;
  std::vector<int> parent;

  bool reachable(int v) const {
    return v >= 0 && v < static_cast<int>(dist.size()) && dist[v] < kInf;
  }

  std::vector<int> reconstruct(int target) const {
    std::vector<int> path;
    if (!reachable(target)) return path;
    for (int v = target; v != -1; v = parent[static_cast<std::size_t>(v)]) path.push_back(v);
    std::reverse(path.begin(), path.end());
    return path;
  }
};

inline PathResult make_path_result(int n, int source) {
  PathResult r;
  r.dist.assign(static_cast<std::size_t>(n), kInf);
  r.parent.assign(static_cast<std::size_t>(n), -1);
  if (source >= 0 && source < n) r.dist[static_cast<std::size_t>(source)] = 0.0;
  return r;
}

// Lazy Dijkstra with a binary heap. O((V + E) log V).
// Rejects negative weights. Optional `target` enables early exit once that
// vertex is settled (still correct for that destination).
inline PathResult dijkstra(const Graph& g, int source, int target = -1) {
  g.check_node(source);
  if (target != -1) g.check_node(target);
  if (g.has_negative_weight()) {
    throw std::invalid_argument("dijkstra requires non-negative weights; use bellman_ford");
  }

  PathResult r = make_path_result(g.node_count(), source);
  using Node = std::pair<double, int>;
  BinaryHeap<Node> heap;
  heap.reserve(static_cast<std::size_t>(g.node_count()) * 2);
  heap.push({0.0, source});

  while (!heap.empty()) {
    const auto [d, u] = heap.pop();
    if (d > r.dist[u]) continue;  // stale heap entry
    if (target != -1 && u == target) break;
    for (const Edge& e : g.adjacency()[u]) {
      const double nd = r.dist[u] + e.weight;
      if (nd < r.dist[e.to]) {
        r.dist[e.to] = nd;
        r.parent[e.to] = u;
        heap.push({nd, e.to});
      }
    }
  }
  return r;
}

// Bidirectional Dijkstra. Often ~2x fewer relaxations on long paths.
// Both directions must be directed graphs (we reverse internally).
inline PathResult dijkstra_bidirectional(const Graph& g, int source, int target) {
  g.check_node(source);
  g.check_node(target);
  if (source == target) return make_path_result(g.node_count(), source);
  if (g.has_negative_weight()) {
    throw std::invalid_argument("dijkstra_bidirectional requires non-negative weights");
  }

  const Graph rev = g.reversed();
  const int n = g.node_count();
  std::vector<double> df(n, kInf), db(n, kInf);
  std::vector<int> pf(n, -1), pb(n, -1);
  std::vector<char> sf(n, 0), sb(n, 0);
  using Node = std::pair<double, int>;
  BinaryHeap<Node> hf, hb;
  df[source] = 0;
  db[target] = 0;
  hf.push({0.0, source});
  hb.push({0.0, target});

  double best = kInf;
  int meet = -1;

  auto relax = [](const Graph& gr, int u, std::vector<double>& dist, std::vector<int>& parent,
                  BinaryHeap<Node>& heap) {
    for (const Edge& e : gr.adjacency()[u]) {
      const double nd = dist[u] + e.weight;
      if (nd < dist[e.to]) {
        dist[e.to] = nd;
        parent[e.to] = u;
        heap.push({nd, e.to});
      }
    }
  };

  while (!hf.empty() && !hb.empty()) {
    if (hf.top().first + hb.top().first >= best) break;

    if (hf.top().first <= hb.top().first) {
      const auto [d, u] = hf.pop();
      if (d > df[u] || sf[u]) continue;
      sf[u] = 1;
      if (sb[u] && df[u] + db[u] < best) {
        best = df[u] + db[u];
        meet = u;
      }
      relax(g, u, df, pf, hf);
    } else {
      const auto [d, u] = hb.pop();
      if (d > db[u] || sb[u]) continue;
      sb[u] = 1;
      if (sf[u] && df[u] + db[u] < best) {
        best = df[u] + db[u];
        meet = u;
      }
      relax(rev, u, db, pb, hb);
    }
  }

  PathResult r = make_path_result(n, source);
  if (meet < 0 || best >= kInf) return r;

  // Stitch source -> meet -> target using the two parent arrays.
  std::vector<int> left;
  for (int v = meet; v != -1; v = pf[v]) left.push_back(v);
  std::reverse(left.begin(), left.end());
  std::vector<int> right;
  for (int v = pb[meet]; v != -1; v = pb[v]) right.push_back(v);

  r.dist[source] = 0;
  r.parent[source] = -1;
  for (std::size_t i = 1; i < left.size(); ++i) {
    r.parent[left[i]] = left[i - 1];
    r.dist[left[i]] = df[left[i]];
  }
  int prev = meet;
  r.dist[meet] = df[meet];
  for (int v : right) {
    r.parent[v] = prev;
    r.dist[v] = df[meet] + (db[meet] - db[v]);
    prev = v;
  }
  r.dist[target] = best;
  return r;
}

// O(V*E). Detects negative cycles reachable from `source`.
// `negative_cycle` is true when a relaxation still exists after V-1 rounds.
inline PathResult bellman_ford(const Graph& g, int source, bool* negative_cycle = nullptr) {
  g.check_node(source);
  const int n = g.node_count();
  PathResult r = make_path_result(n, source);
  if (negative_cycle) *negative_cycle = false;

  for (int i = 0; i < n - 1; ++i) {
    bool changed = false;
    for (int u = 0; u < n; ++u) {
      if (r.dist[u] == kInf) continue;
      for (const Edge& e : g.adjacency()[u]) {
        const double nd = r.dist[u] + e.weight;
        if (nd < r.dist[e.to]) {
          r.dist[e.to] = nd;
          r.parent[e.to] = u;
          changed = true;
        }
      }
    }
    if (!changed) break;
  }

  if (negative_cycle) {
    for (int u = 0; u < n; ++u) {
      if (r.dist[u] == kInf) continue;
      for (const Edge& e : g.adjacency()[u]) {
        if (r.dist[u] + e.weight < r.dist[e.to]) {
          *negative_cycle = true;
          return r;
        }
      }
    }
  }
  return r;
}

// A* with caller-provided heuristic. Heuristic must be admissible
// (never overestimate) for optimality.
inline PathResult astar(const Graph& g, int source, int goal, const std::vector<double>& heuristic) {
  g.check_node(source);
  g.check_node(goal);
  if (static_cast<int>(heuristic.size()) != g.node_count()) {
    throw std::invalid_argument("heuristic size must equal node count");
  }
  if (g.has_negative_weight()) {
    throw std::invalid_argument("astar requires non-negative weights");
  }

  PathResult r = make_path_result(g.node_count(), source);
  using Node = std::pair<double, int>;
  BinaryHeap<Node> heap;
  heap.push({heuristic[source], source});

  while (!heap.empty()) {
    const auto [f, u] = heap.pop();
    (void)f;
    if (u == goal) break;
    for (const Edge& e : g.adjacency()[u]) {
      const double nd = r.dist[u] + e.weight;
      if (nd < r.dist[e.to]) {
        r.dist[e.to] = nd;
        r.parent[e.to] = u;
        heap.push({nd + heuristic[e.to], e.to});
      }
    }
  }
  return r;
}

}  // namespace algoforge
