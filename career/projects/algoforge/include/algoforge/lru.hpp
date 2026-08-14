#pragma once

#include <cstddef>
#include <functional>
#include <list>
#include <optional>
#include <stdexcept>
#include <unordered_map>
#include <utility>
#include <vector>

namespace algoforge {

template <typename K, typename V, typename Hash = std::hash<K>>
class LruCache {
 public:
  explicit LruCache(std::size_t capacity) : capacity_(capacity) {
    if (!capacity_) throw std::invalid_argument("LruCache capacity must be > 0");
  }

  // Promotes key to most-recent. nullptr on miss.
  V* get(const K& key) {
    auto it = index_.find(key);
    if (it == index_.end()) {
      ++misses_;
      return nullptr;
    }
    ++hits_;
    order_.splice(order_.begin(), order_, it->second);
    return &it->second->second;
  }

  // Lookup without changing recency (does not count as hit/miss).
  const V* peek(const K& key) const {
    auto it = index_.find(key);
    return it == index_.end() ? nullptr : &it->second->second;
  }

  void put(const K& key, V value) {
    auto it = index_.find(key);
    if (it != index_.end()) {
      it->second->second = std::move(value);
      order_.splice(order_.begin(), order_, it->second);
      return;
    }
    if (order_.size() == capacity_) evict_one();
    order_.emplace_front(key, std::move(value));
    index_[order_.front().first] = order_.begin();
  }

  bool erase(const K& key) {
    auto it = index_.find(key);
    if (it == index_.end()) return false;
    order_.erase(it->second);
    index_.erase(it);
    return true;
  }

  bool contains(const K& key) const { return index_.find(key) != index_.end(); }

  // Most-recent first.
  std::vector<K> keys() const {
    std::vector<K> out;
    out.reserve(order_.size());
    for (const auto& kv : order_) out.push_back(kv.first);
    return out;
  }

  std::optional<K> lru_key() const {
    if (order_.empty()) return std::nullopt;
    return order_.back().first;
  }

  std::optional<K> mru_key() const {
    if (order_.empty()) return std::nullopt;
    return order_.front().first;
  }

  void set_capacity(std::size_t capacity) {
    if (!capacity) throw std::invalid_argument("LruCache capacity must be > 0");
    capacity_ = capacity;
    while (order_.size() > capacity_) evict_one();
  }

  void clear() {
    order_.clear();
    index_.clear();
  }

  std::size_t size() const { return order_.size(); }
  std::size_t capacity() const { return capacity_; }
  bool empty() const { return order_.empty(); }
  std::size_t hits() const { return hits_; }
  std::size_t misses() const { return misses_; }
  std::size_t evictions() const { return evictions_; }

  double hit_rate() const {
    const std::size_t total = hits_ + misses_;
    return total ? static_cast<double>(hits_) / static_cast<double>(total) : 0.0;
  }

 private:
  void evict_one() {
    index_.erase(order_.back().first);
    order_.pop_back();
    ++evictions_;
  }

  std::size_t capacity_;
  std::list<std::pair<K, V>> order_;
  std::unordered_map<K, typename std::list<std::pair<K, V>>::iterator, Hash> index_;
  std::size_t hits_ = 0;
  std::size_t misses_ = 0;
  std::size_t evictions_ = 0;
};

}  // namespace algoforge
