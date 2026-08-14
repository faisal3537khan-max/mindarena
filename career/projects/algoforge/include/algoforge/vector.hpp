#pragma once

#include <cstddef>
#include <new>
#include <stdexcept>
#include <utility>

namespace algoforge {

// Contiguous buffer with geometric growth. Owns storage; does not wrap std::vector.
template <typename T>
class Vector {
 public:
  Vector() = default;

  explicit Vector(std::size_t n, const T& value = T()) {
    if (!n) return;
    reserve(n);
    for (std::size_t i = 0; i < n; ++i) {
      ::new (static_cast<void*>(data_ + i)) T(value);
      ++size_;
    }
  }

  Vector(const Vector& other) {
    reserve(other.size_);
    for (std::size_t i = 0; i < other.size_; ++i) {
      ::new (static_cast<void*>(data_ + i)) T(other.data_[i]);
      ++size_;
    }
  }

  Vector(Vector&& other) noexcept
      : data_(other.data_), size_(other.size_), cap_(other.cap_) {
    other.data_ = nullptr;
    other.size_ = 0;
    other.cap_ = 0;
  }

  Vector& operator=(const Vector& other) {
    if (this == &other) return *this;
    Vector tmp(other);
    swap(tmp);
    return *this;
  }

  Vector& operator=(Vector&& other) noexcept {
    if (this == &other) return *this;
    destroy_all();
    deallocate();
    data_ = other.data_;
    size_ = other.size_;
    cap_ = other.cap_;
    other.data_ = nullptr;
    other.size_ = 0;
    other.cap_ = 0;
    return *this;
  }

  ~Vector() {
    destroy_all();
    deallocate();
  }

  void push_back(T value) { emplace_back(std::move(value)); }

  template <typename... Args>
  T& emplace_back(Args&&... args) {
    if (size_ == cap_) grow();
    ::new (static_cast<void*>(data_ + size_)) T(std::forward<Args>(args)...);
    return data_[size_++];
  }

  void pop_back() {
    if (!size_) throw std::out_of_range("Vector::pop_back on empty");
    data_[--size_].~T();
  }

  T& at(std::size_t i) {
    if (i >= size_) throw std::out_of_range("Vector::at");
    return data_[i];
  }
  const T& at(std::size_t i) const {
    if (i >= size_) throw std::out_of_range("Vector::at");
    return data_[i];
  }

  T& operator[](std::size_t i) { return data_[i]; }
  const T& operator[](std::size_t i) const { return data_[i]; }

  T& front() { return at(0); }
  const T& front() const { return at(0); }
  T& back() { return at(size_ - 1); }
  const T& back() const { return at(size_ - 1); }

  T* begin() { return data_; }
  T* end() { return data_ + size_; }
  const T* begin() const { return data_; }
  const T* end() const { return data_ + size_; }

  std::size_t size() const { return size_; }
  std::size_t capacity() const { return cap_; }
  bool empty() const { return size_ == 0; }

  void reserve(std::size_t n) {
    if (n <= cap_) return;
    T* nd = allocate(n);
    for (std::size_t i = 0; i < size_; ++i) {
      ::new (static_cast<void*>(nd + i)) T(std::move(data_[i]));
      data_[i].~T();
    }
    deallocate();
    data_ = nd;
    cap_ = n;
  }

  void clear() { destroy_all(); }

  void swap(Vector& other) noexcept {
    std::swap(data_, other.data_);
    std::swap(size_, other.size_);
    std::swap(cap_, other.cap_);
  }

 private:
  static T* allocate(std::size_t n) {
    if (!n) return nullptr;
    return static_cast<T*>(::operator new(n * sizeof(T)));
  }

  void deallocate() {
    ::operator delete(data_);
    data_ = nullptr;
    cap_ = 0;
  }

  void destroy_all() {
    for (std::size_t i = size_; i > 0; --i) data_[i - 1].~T();
    size_ = 0;
  }

  void grow() { reserve(cap_ ? cap_ * 2 : 8); }

  T* data_ = nullptr;
  std::size_t size_ = 0;
  std::size_t cap_ = 0;
};

}  // namespace algoforge
