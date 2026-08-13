#pragma once
#include <functional>
#include <list>
#include <utility>
#include <vector>

namespace algoforge {

template <typename K, typename V, typename Hash = std::hash<K>>
class HashMap {
 public:
  explicit HashMap(std::size_t buckets = 16) : buckets_(buckets) {}

  void put(const K& key, V value) {
    maybe_rehash();
    auto& chain = buckets_[Hash{}(key) % buckets_.size()];
    for (auto& kv : chain) {
      if (kv.first == key) {
        kv.second = std::move(value);
        return;
      }
    }
    chain.emplace_back(key, std::move(value));
    ++size_;
  }

  V* get(const K& key) {
    auto& chain = buckets_[Hash{}(key) % buckets_.size()];
    for (auto& kv : chain) {
      if (kv.first == key) return &kv.second;
    }
    return nullptr;
  }

  bool erase(const K& key) {
    auto& chain = buckets_[Hash{}(key) % buckets_.size()];
    for (auto it = chain.begin(); it != chain.end(); ++it) {
      if (it->first == key) {
        chain.erase(it);
        --size_;
        return true;
      }
    }
    return false;
  }

  std::size_t size() const { return size_; }

 private:
  void maybe_rehash() {
    if (buckets_.empty()) buckets_.resize(16);
    if (size_ < buckets_.size() * 3 / 4) return;
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
};

}  // namespace algoforge
