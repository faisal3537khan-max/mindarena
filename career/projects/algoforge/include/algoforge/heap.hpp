#pragma once

#include <cstddef>
#include <functional>
#include <stdexcept>
#include <utility>
#include <vector>

namespace algoforge {

template <typename T, typename Less = std::less<T>>
class BinaryHeap {
 public:
  BinaryHeap() = default;

  explicit BinaryHeap(std::vector<T> data) : data_(std::move(data)) { heapify(); }

  void push(T value) {
    data_.push_back(std::move(value));
    sift_up(data_.size() - 1);
  }

  const T& top() const {
    if (data_.empty()) throw std::out_of_range("BinaryHeap::top on empty");
    return data_[0];
  }

  T pop() {
    if (data_.empty()) throw std::out_of_range("BinaryHeap::pop on empty");
    T out = std::move(data_[0]);
    data_[0] = std::move(data_.back());
    data_.pop_back();
    if (!data_.empty()) sift_down(0);
    return out;
  }

  std::size_t size() const { return data_.size(); }
  bool empty() const { return data_.empty(); }
  void reserve(std::size_t n) { data_.reserve(n); }
  void clear() { data_.clear(); }

 private:
  static std::size_t parent(std::size_t i) { return (i - 1) / 2; }
  static std::size_t left(std::size_t i) { return 2 * i + 1; }
  static std::size_t right(std::size_t i) { return 2 * i + 2; }

  void heapify() {
    if (data_.size() < 2) return;
    for (std::size_t i = data_.size() / 2; i-- > 0;) sift_down(i);
  }

  void sift_up(std::size_t i) {
    while (i > 0 && less_(data_[i], data_[parent(i)])) {
      std::swap(data_[i], data_[parent(i)]);
      i = parent(i);
    }
  }

  void sift_down(std::size_t i) {
    for (;;) {
      std::size_t best = i;
      const std::size_t l = left(i), r = right(i);
      if (l < data_.size() && less_(data_[l], data_[best])) best = l;
      if (r < data_.size() && less_(data_[r], data_[best])) best = r;
      if (best == i) return;
      std::swap(data_[i], data_[best]);
      i = best;
    }
  }

  std::vector<T> data_;
  Less less_{};
};

}  // namespace algoforge
