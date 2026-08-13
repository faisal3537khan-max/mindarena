#pragma once
#include <cstddef>
#include <stdexcept>
#include <utility>
#include <vector>

namespace algoforge {

template <typename T>
class Vector {
 public:
  Vector() = default;
  explicit Vector(std::size_t n, const T& value = T()) : data_(n, value) {}

  void push_back(T value) { data_.push_back(std::move(value)); }
  T& operator[](std::size_t i) { return data_.at(i); }
  const T& operator[](std::size_t i) const { return data_.at(i); }
  std::size_t size() const { return data_.size(); }
  bool empty() const { return data_.empty(); }
  T* begin() { return data_.data(); }
  T* end() { return data_.data() + data_.size(); }
  const T* begin() const { return data_.data(); }
  const T* end() const { return data_.data() + data_.size(); }

 private:
  std::vector<T> data_;
};

}  // namespace algoforge
