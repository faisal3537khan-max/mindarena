#pragma once
#include <algorithm>
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
    int mid = lo + (hi - lo) / 2;
    if (a[mid] == key) return mid;
    if (a[mid] < key) lo = mid + 1;
    else hi = mid - 1;
  }
  return -1;
}

template <typename T>
void merge_sort(std::vector<T>& a) {
  std::vector<T> tmp(a.size());
  auto rec = [&](auto&& self, int l, int r) -> void {
    if (r - l <= 1) return;
    int m = (l + r) / 2;
    self(self, l, m);
    self(self, m, r);
    int i = l, j = m, k = l;
    while (i < m && j < r) tmp[k++] = (a[i] < a[j]) ? a[i++] : a[j++];
    while (i < m) tmp[k++] = a[i++];
    while (j < r) tmp[k++] = a[j++];
    for (int t = l; t < r; ++t) a[t] = std::move(tmp[t]);
  };
  rec(rec, 0, static_cast<int>(a.size()));
}

}  // namespace algoforge
