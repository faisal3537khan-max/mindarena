#pragma once

#include "graph.hpp"
#include "union_find.hpp"

#include <algorithm>
#include <map>
#include <utility>
#include <vector>

namespace algoforge {

struct MstEdge {
  int u = 0;
  int v = 0;
  double weight = 0.0;
};

struct MstResult {
  std::vector<MstEdge> edges;
  double total_weight = 0.0;
  bool spanning = false;
};

// Kruskal on the undirected projection of `g` (min weight kept per unordered pair).
inline MstResult kruskal(const Graph& g) {
  std::map<std::pair<int, int>, double> best;
  for (int u = 0; u < g.node_count(); ++u) {
    for (const Edge& e : g.adjacency()[static_cast<std::size_t>(u)]) {
      int a = u, b = e.to;
      if (a == b) continue;
      if (a > b) std::swap(a, b);
      auto key = std::make_pair(a, b);
      auto it = best.find(key);
      if (it == best.end() || e.weight < it->second) best[key] = e.weight;
    }
  }

  std::vector<MstEdge> cand;
  cand.reserve(best.size());
  for (const auto& kv : best) {
    cand.push_back(MstEdge{kv.first.first, kv.first.second, kv.second});
  }
  std::sort(cand.begin(), cand.end(),
            [](const MstEdge& a, const MstEdge& b) { return a.weight < b.weight; });

  UnionFind uf(g.node_count());
  MstResult out;
  for (const MstEdge& e : cand) {
    if (uf.unite(e.u, e.v)) {
      out.edges.push_back(e);
      out.total_weight += e.weight;
    }
  }
  out.spanning = g.node_count() == 0 ||
                 (uf.components() == 1 && static_cast<int>(out.edges.size()) == g.node_count() - 1);
  return out;
}

}  // namespace algoforge
