#pragma once
#include <list>
#include <stdexcept>
#include <unordered_map>
#include <utility>

namespace algoforge {

template <typename K, typename V>
class LruCache {
 public:
  explicit LruCache(std::size_t capacity) : capacity_(capacity) {
    if (!capacity_) throw std::invalid_argument("capacity");
  }

  V* get(const K& key) {
    auto it = index_.find(key);
    if (it == index_.end()) return nullptr;
    order_.splice(order_.begin(), order_, it->second);
    return &it->second->second;
  }

  void put(const K& key, V value) {
    auto it = index_.find(key);
    if (it != index_.end()) {
      it->second->second = std::move(value);
      order_.splice(order_.begin(), order_, it->second);
      return;
    }
    if (order_.size() == capacity_) {
      index_.erase(order_.back().first);
      order_.pop_back();
    }
    order_.emplace_front(key, std::move(value));
    index_[key] = order_.begin();
  }

  std::size_t size() const { return order_.size(); }

 private:
  std::size_t capacity_;
  std::list<std::pair<K, V>> order_;
  std::unordered_map<K, typename std::list<std::pair<K, V>>::iterator> index_;
};

}  // namespace algoforge
