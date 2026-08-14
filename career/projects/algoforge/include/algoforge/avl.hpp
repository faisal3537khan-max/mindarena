#pragma once

#include <algorithm>
#include <cmath>
#include <cstddef>
#include <functional>
#include <memory>
#include <optional>
#include <utility>
#include <vector>

namespace algoforge {

// Height-balanced BST. Every insert and erase restores |balance| <= 1.
// Search / insert / erase: O(log n). Inorder walk: O(n).
template <typename K, typename V, typename Compare = std::less<K>>
class AvlTree {
  struct Node {
    K key;
    V value;
    int height = 1;
    std::unique_ptr<Node> left;
    std::unique_ptr<Node> right;
    Node(K k, V v) : key(std::move(k)), value(std::move(v)) {}
  };

 public:
  AvlTree() = default;
  AvlTree(const AvlTree&) = delete;
  AvlTree& operator=(const AvlTree&) = delete;
  AvlTree(AvlTree&&) noexcept = default;
  AvlTree& operator=(AvlTree&&) noexcept = default;

  void insert(K key, V value) {
    bool grew = false;
    root_ = upsert(std::move(root_), std::move(key), std::move(value), grew);
    if (grew) ++size_;
  }

  // Alias used by older call sites.
  void put(K key, V value) { insert(std::move(key), std::move(value)); }

  bool erase(const K& key) {
    bool removed = false;
    root_ = erase_node(std::move(root_), key, removed);
    if (removed) --size_;
    return removed;
  }

  const V* find(const K& key) const {
    const Node* n = root_.get();
    while (n) {
      if (less_(key, n->key)) n = n->left.get();
      else if (less_(n->key, key)) n = n->right.get();
      else return &n->value;
    }
    return nullptr;
  }

  V* find(const K& key) {
    return const_cast<V*>(static_cast<const AvlTree*>(this)->find(key));
  }

  const V* get(const K& key) const { return find(key); }
  V* get(const K& key) { return find(key); }

  bool contains(const K& key) const { return find(key) != nullptr; }

  std::optional<K> min_key() const {
    const Node* n = leftmost(root_.get());
    if (!n) return std::nullopt;
    return n->key;
  }

  std::optional<K> max_key() const {
    const Node* n = root_.get();
    if (!n) return std::nullopt;
    while (n->right) n = n->right.get();
    return n->key;
  }

  // First key that is not less than `key` (lower_bound).
  const K* lower_bound(const K& key) const {
    const Node* n = root_.get();
    const Node* cand = nullptr;
    while (n) {
      if (!less_(n->key, key)) {
        cand = n;
        n = n->left.get();
      } else {
        n = n->right.get();
      }
    }
    return cand ? &cand->key : nullptr;
  }

  void inorder_keys(std::vector<K>& out) const {
    out.clear();
    out.reserve(size_);
    walk(root_.get(), [&](const Node* n) { out.push_back(n->key); });
  }

  std::size_t size() const { return size_; }
  bool empty() const { return size_ == 0; }
  int height() const { return h(root_.get()); }

  void clear() {
    root_.reset();
    size_ = 0;
  }

  // BST order + AVL height invariant. Used by tests; O(n).
  bool valid() const {
    int counted = 0;
    return valid_node(root_.get(), nullptr, nullptr, counted) &&
           static_cast<std::size_t>(counted) == size_;
  }

 private:
  static int h(const Node* n) { return n ? n->height : 0; }
  static int bal(const Node* n) { return n ? h(n->left.get()) - h(n->right.get()) : 0; }

  static void fix(Node* n) {
    n->height = 1 + std::max(h(n->left.get()), h(n->right.get()));
  }

  static const Node* leftmost(const Node* n) {
    while (n && n->left) n = n->left.get();
    return n;
  }

  static std::unique_ptr<Node> rotate_right(std::unique_ptr<Node> y) {
    auto x = std::move(y->left);
    y->left = std::move(x->right);
    fix(y.get());
    x->right = std::move(y);
    fix(x.get());
    return x;
  }

  static std::unique_ptr<Node> rotate_left(std::unique_ptr<Node> x) {
    auto y = std::move(x->right);
    x->right = std::move(y->left);
    fix(x.get());
    y->left = std::move(x);
    fix(y.get());
    return y;
  }

  std::unique_ptr<Node> rebalance(std::unique_ptr<Node> n) {
    if (!n) return n;
    fix(n.get());
    const int b = bal(n.get());
    if (b > 1) {
      if (bal(n->left.get()) < 0) n->left = rotate_left(std::move(n->left));
      return rotate_right(std::move(n));
    }
    if (b < -1) {
      if (bal(n->right.get()) > 0) n->right = rotate_right(std::move(n->right));
      return rotate_left(std::move(n));
    }
    return n;
  }

  std::unique_ptr<Node> upsert(std::unique_ptr<Node> n, K key, V value, bool& grew) {
    if (!n) {
      grew = true;
      return std::make_unique<Node>(std::move(key), std::move(value));
    }
    if (less_(key, n->key)) {
      n->left = upsert(std::move(n->left), std::move(key), std::move(value), grew);
    } else if (less_(n->key, key)) {
      n->right = upsert(std::move(n->right), std::move(key), std::move(value), grew);
    } else {
      n->value = std::move(value);
      return n;
    }
    return rebalance(std::move(n));
  }

  std::unique_ptr<Node> erase_node(std::unique_ptr<Node> n, const K& key, bool& removed) {
    if (!n) return nullptr;
    if (less_(key, n->key)) {
      n->left = erase_node(std::move(n->left), key, removed);
    } else if (less_(n->key, key)) {
      n->right = erase_node(std::move(n->right), key, removed);
    } else {
      removed = true;
      if (!n->left) return std::move(n->right);
      if (!n->right) return std::move(n->left);
      const Node* succ = leftmost(n->right.get());
      n->key = succ->key;
      n->value = std::move(succ->value);
      bool dummy = false;
      n->right = erase_node(std::move(n->right), n->key, dummy);
    }
    return rebalance(std::move(n));
  }

  template <typename Fn>
  static void walk(const Node* n, Fn&& fn) {
    if (!n) return;
    walk(n->left.get(), fn);
    fn(n);
    walk(n->right.get(), fn);
  }

  bool valid_node(const Node* n, const K* lo, const K* hi, int& counted) const {
    if (!n) return true;
    if (lo && !less_(*lo, n->key)) return false;
    if (hi && !less_(n->key, *hi)) return false;
    if (std::abs(bal(n)) > 1) return false;
    if (n->height != 1 + std::max(h(n->left.get()), h(n->right.get()))) return false;
    ++counted;
    return valid_node(n->left.get(), lo, &n->key, counted) &&
           valid_node(n->right.get(), &n->key, hi, counted);
  }

  std::unique_ptr<Node> root_;
  std::size_t size_ = 0;
  Compare less_{};
};

}  // namespace algoforge
