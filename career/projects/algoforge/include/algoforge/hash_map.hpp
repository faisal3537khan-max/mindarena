#pragma once

#include <algorithm>
#include <cstddef>
#include <functional>
#include <list>
#include <stdexcept>
#include <utility>
#include <vector>

namespace algoforge {

// Separate-chaining hash map. Average O(1) find/insert/erase. Rehashes at load 0.75.
template <typename K, typename V, typename Hash = std::hash<K>, typename Eq = std::equal_to<K>>
class HashMap {
 public:
  explicit HashMap(std::size_t buckets = 16) : buckets_(std::max<std::size_t>(buckets, 8)) {}

  void insert(const K& key, V value) { put(key, std::move(value)); }

  void put(const K& key, V value) {
    maybe_rehash();
    auto& chain = buckets_[hash_of(key)];
    for (auto& kv : chain) {
      if (eq_(kv.first, key)) {
        kv.second = std::move(value);
        return;
      }
    }
    chain.emplace_back(key, std::move(value));
    ++size_;
  }

  const V* find(const K& key) const {
    const auto& chain = buckets_[hash_of(key)];
    for (const auto& kv : chain) {
      if (eq_(kv.first, key)) return &kv.second;
    }
    return nullptr;
  }

  V* find(const K& key) {
    return const_cast<V*>(static_cast<const HashMap*>(this)->find(key));
  }

  V* get(const K& key) { return find(key); }
  const V* get(const K& key) const { return find(key); }

  bool contains(const K& key) const { return find(key) != nullptr; }

  V& operator[](const K& key) {
    if (V* v = find(key)) return *v;
    put(key, V{});
    return *find(key);
  }

  bool erase(const K& key) {
    auto& chain = buckets_[hash_of(key)];
    for (auto it = chain.begin(); it != chain.end(); ++it) {
      if (eq_(it->first, key)) {
        chain.erase(it);
        --size_;
        return true;
      }
    }
    return false;
  }

  void clear() {
    for (auto& c : buckets_) c.clear();
    size_ = 0;
  }

  std::size_t size() const { return size_; }
  bool empty() const { return size_ == 0; }
  std::size_t bucket_count() const { return buckets_.size(); }
  double load_factor() const {
    return buckets_.empty() ? 0.0 : static_cast<double>(size_) / static_cast<double>(buckets_.size());
  }

 private:
  std::size_t hash_of(const K& key) const { return Hash{}(key) % buckets_.size(); }

  void maybe_rehash() {
    if (size_ + 1 <= buckets_.size() * 3 / 4) return;
    std::vector<std::list<std::pair<K, V>>> next(buckets_.size() * 2);
    for (auto& chain : buckets_) {
      for (auto& kv : chain) {
        next[Hash{}(kv.first) % next.size()].push_back(std::move(kv));
      }
    }
    buckets_.swap(next);
  }

  std::vector<std::list<std::pair<K, V>>> buckets_;
  std::size_t size_ = 0;
  Eq eq_{};
};

}  // namespace algoforge
