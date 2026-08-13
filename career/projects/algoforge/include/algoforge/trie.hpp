#pragma once
#include <memory>
#include <string>
#include <vector>

namespace algoforge {

class Trie {
  struct Node {
    bool terminal = false;
    std::unique_ptr<Node> next[26]{};
  };

 public:
  void insert(const std::string& word) {
    Node* n = &root_;
    for (char c : word) {
      int i = idx(c);
      if (i < 0) continue;
      if (!n->next[i]) n->next[i] = std::make_unique<Node>();
      n = n->next[i].get();
    }
    n->terminal = true;
  }

  bool contains(const std::string& word) const {
    const Node* n = find(word);
    return n && n->terminal;
  }

  bool starts_with(const std::string& prefix) const { return find(prefix) != nullptr; }

 private:
  static int idx(char c) {
    if (c >= 'A' && c <= 'Z') c = static_cast<char>(c - 'A' + 'a');
    if (c < 'a' || c > 'z') return -1;
    return c - 'a';
  }

  const Node* find(const std::string& s) const {
    const Node* n = &root_;
    for (char c : s) {
      int i = idx(c);
      if (i < 0 || !n->next[i]) return nullptr;
      n = n->next[i].get();
    }
    return n;
  }

  Node root_{};
};

}  // namespace algoforge
