#pragma once
#include <numeric>
#include <vector>

namespace algoforge {

class UnionFind {
 public:
  explicit UnionFind(int n) : parent_(n), rank_(n, 0), components_(n) {
    std::iota(parent_.begin(), parent_.end(), 0);
  }

  int find(int x) {
    if (parent_[x] != x) parent_[x] = find(parent_[x]);
    return parent_[x];
  }

  bool unite(int a, int b) {
    a = find(a);
    b = find(b);
    if (a == b) return false;
    if (rank_[a] < rank_[b]) std::swap(a, b);
    parent_[b] = a;
    if (rank_[a] == rank_[b]) ++rank_[a];
    --components_;
    return true;
  }

  int components() const { return components_; }

 private:
  std::vector<int> parent_;
  std::vector<int> rank_;
  int components_;
};

}  // namespace algoforge
