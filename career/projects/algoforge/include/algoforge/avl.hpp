#pragma once
#include <algorithm>
#include <memory>
#include <utility>

namespace algoforge {

template <typename K, typename V>
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
  void put(K key, V value) { root_ = upsert(std::move(root_), std::move(key), std::move(value)); }

  V* get(const K& key) {
    Node* n = root_.get();
    while (n) {
      if (key < n->key) n = n->left.get();
      else if (n->key < key) n = n->right.get();
      else return &n->value;
    }
    return nullptr;
  }

  int height() const { return h(root_.get()); }

 private:
  static int h(const Node* n) { return n ? n->height : 0; }
  static int bal(const Node* n) { return n ? h(n->left.get()) - h(n->right.get()) : 0; }
  static void fix(Node* n) {
    n->height = 1 + std::max(h(n->left.get()), h(n->right.get()));
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

  static std::unique_ptr<Node> upsert(std::unique_ptr<Node> n, K key, V value) {
    if (!n) return std::make_unique<Node>(std::move(key), std::move(value));
    if (key < n->key) n->left = upsert(std::move(n->left), key, std::move(value));
    else if (n->key < key) n->right = upsert(std::move(n->right), key, std::move(value));
    else {
      n->value = std::move(value);
      return n;
    }
    fix(n.get());
    int b = bal(n.get());
    if (b > 1 && key < n->left->key) return rotate_right(std::move(n));
    if (b < -1 && n->right->key < key) return rotate_left(std::move(n));
    if (b > 1 && n->left->key < key) {
      n->left = rotate_left(std::move(n->left));
      return rotate_right(std::move(n));
    }
    if (b < -1 && key < n->right->key) {
      n->right = rotate_right(std::move(n->right));
      return rotate_left(std::move(n));
    }
    return n;
  }

  std::unique_ptr<Node> root_;
};

}  // namespace algoforge
