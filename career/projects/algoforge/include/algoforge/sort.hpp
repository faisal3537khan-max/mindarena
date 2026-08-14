#pragma once

#include <algorithm>
#include <cstddef>
#include <vector>

namespace algoforge {

template <typename T>
void insertion_sort(std::vector<T>& a) {
  for (std::size_t i = 1; i < a.size(); ++i) {
    T key = std::move(a[i]);
    std::size_t j = i;
    while (j > 0 && key < a[j - 1]) {
      a[j] = std::move(a[j - 1]);
      --j;
    }
    a[j] = std::move(key);
  }
}

template <typename T>
int binary_search_index(const std::vector<T>& a, const T& key) {
  int lo = 0, hi = static_cast<int>(a.size()) - 1;
  while (lo <= hi) {
    const int mid = lo + (hi - lo) / 2;
    if (a[mid] == key) return mid;
    if (a[mid] < key) lo = mid + 1;
    else hi = mid - 1;
  }
  return -1;
}

template <typename T>
void merge_sort(std::vector<T>& a) {
  if (a.size() < 2) return;
  std::vector<T> tmp(a.size());
  auto rec = [&](auto&& self, int l, int r) -> void {
    if (r - l <= 1) return;
    const int m = (l + r) / 2;
    self(self, l, m);
    self(self, m, r);
    int i = l, j = m, k = l;
    while (i < m && j < r) tmp[k++] = (a[i] < a[j]) ? std::move(a[i++]) : std::move(a[j++]);
    while (i < m) tmp[k++] = std::move(a[i++]);
    while (j < r) tmp[k++] = std::move(a[j++]);
    for (int t = l; t < r; ++t) a[t] = std::move(tmp[t]);
  };
  rec(rec, 0, static_cast<int>(a.size()));
}

template <typename T>
void heap_sort(std::vector<T>& a) {
  auto sift = [&](std::size_t root, std::size_t end) {
    for (;;) {
      std::size_t best = root;
      const std::size_t l = 2 * root + 1, r = 2 * root + 2;
      if (l < end && a[best] < a[l]) best = l;
      if (r < end && a[best] < a[r]) best = r;
      if (best == root) return;
      std::swap(a[root], a[best]);
      root = best;
    }
  };
  const std::size_t n = a.size();
  if (n < 2) return;
  for (std::size_t i = n / 2; i-- > 0;) sift(i, n);
  for (std::size_t end = n; end-- > 1;) {
    std::swap(a[0], a[end]);
    sift(0, end);
  }
}

}  // namespace algoforge
