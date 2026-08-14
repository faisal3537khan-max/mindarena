#pragma once

#include <queue>
#include <stdexcept>
#include <utility>
#include <vector>

namespace algoforge {

struct Edge {
  int to = 0;
  double weight = 1.0;
};

class Graph {
 public:
  explicit Graph(int nodes, bool directed = true)
      : n_(nodes), directed_(directed), adj_(static_cast<std::size_t>(nodes < 0 ? 0 : nodes)) {
    if (nodes < 0) throw std::invalid_argument("Graph node count must be >= 0");
  }

  int node_count() const { return n_; }
  bool directed() const { return directed_; }
  const std::vector<std::vector<Edge>>& adjacency() const { return adj_; }

  void add_edge(int u, int v, double w, bool directed) {
    check_node(u);
    check_node(v);
    adj_[static_cast<std::size_t>(u)].push_back(Edge{v, w});
    ++edge_count_;
    if (!directed && u != v) {
      adj_[static_cast<std::size_t>(v)].push_back(Edge{u, w});
      ++edge_count_;
    }
    if (w < 0.0) has_negative_ = true;
  }

  void add_edge(int u, int v, double w = 1.0) { add_edge(u, v, w, directed_); }

  Graph reversed() const {
    Graph r(n_, true);
    for (int u = 0; u < n_; ++u) {
      for (const Edge& e : adj_[static_cast<std::size_t>(u)]) r.add_edge(e.to, u, e.weight, true);
    }
    r.has_negative_ = has_negative_;
    return r;
  }

  bool has_negative_weight() const { return has_negative_; }
  int edge_count() const { return edge_count_; }

  void check_node(int u) const {
    if (u < 0 || u >= n_) throw std::out_of_range("vertex out of range");
  }

  std::vector<int> bfs(int start) const {
    check_node(start);
    std::vector<int> order;
    std::vector<char> seen(static_cast<std::size_t>(n_), 0);
    std::queue<int> q;
    seen[static_cast<std::size_t>(start)] = 1;
    q.push(start);
    while (!q.empty()) {
      const int u = q.front();
      q.pop();
      order.push_back(u);
      for (const Edge& e : adj_[static_cast<std::size_t>(u)]) {
        if (!seen[static_cast<std::size_t>(e.to)]) {
          seen[static_cast<std::size_t>(e.to)] = 1;
          q.push(e.to);
        }
      }
    }
    return order;
  }

  std::vector<int> dfs(int start) const {
    check_node(start);
    std::vector<int> order;
    std::vector<char> seen(static_cast<std::size_t>(n_), 0);
    dfs_visit(start, seen, order);
    return order;
  }

  bool topo_sort(std::vector<int>& out) const {
    std::vector<int> indeg(static_cast<std::size_t>(n_), 0);
    for (int u = 0; u < n_; ++u) {
      for (const Edge& e : adj_[static_cast<std::size_t>(u)]) {
        ++indeg[static_cast<std::size_t>(e.to)];
      }
    }
    std::queue<int> q;
    for (int i = 0; i < n_; ++i) {
      if (indeg[static_cast<std::size_t>(i)] == 0) q.push(i);
    }
    out.clear();
    out.reserve(static_cast<std::size_t>(n_));
    while (!q.empty()) {
      const int u = q.front();
      q.pop();
      out.push_back(u);
      for (const Edge& e : adj_[static_cast<std::size_t>(u)]) {
        if (--indeg[static_cast<std::size_t>(e.to)] == 0) q.push(e.to);
      }
    }
    return static_cast<int>(out.size()) == n_;
  }

 private:
  void dfs_visit(int u, std::vector<char>& seen, std::vector<int>& order) const {
    seen[static_cast<std::size_t>(u)] = 1;
    order.push_back(u);
    for (const Edge& e : adj_[static_cast<std::size_t>(u)]) {
      if (!seen[static_cast<std::size_t>(e.to)]) dfs_visit(e.to, seen, order);
    }
  }

  int n_ = 0;
  bool directed_ = true;
  std::vector<std::vector<Edge>> adj_;
  int edge_count_ = 0;
  bool has_negative_ = false;
};

}  // namespace algoforge
