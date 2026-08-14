#pragma once

#include <numeric>
#include <stdexcept>
#include <utility>
#include <vector>

namespace algoforge {

class UnionFind {
 public:
  explicit UnionFind(int n) : parent_(n), rank_(n, 0), sz_(n, 1), components_(n) {
    if (n < 0) throw std::invalid_argument("UnionFind size must be >= 0");
    std::iota(parent_.begin(), parent_.end(), 0);
  }

  int find(int x) {
    check(x);
    if (parent_[x] != x) parent_[x] = find(parent_[x]);
    return parent_[x];
  }

  bool unite(int a, int b) {
    a = find(a);
    b = find(b);
    if (a == b) return false;
    if (rank_[a] < rank_[b]) std::swap(a, b);
    parent_[b] = a;
    sz_[a] += sz_[b];
    if (rank_[a] == rank_[b]) ++rank_[a];
    --components_;
    return true;
  }

  bool connected(int a, int b) { return find(a) == find(b); }
  int component_size(int x) { return sz_[find(x)]; }
  int components() const { return components_; }
  int size() const { return static_cast<int>(parent_.size()); }

 private:
  void check(int x) const {
    if (x < 0 || x >= static_cast<int>(parent_.size())) {
      throw std::out_of_range("UnionFind index");
    }
  }

  std::vector<int> parent_;
  std::vector<int> rank_;
  std::vector<int> sz_;
  int components_;
};

}  // namespace algoforge
