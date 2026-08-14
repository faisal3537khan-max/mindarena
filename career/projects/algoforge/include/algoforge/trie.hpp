#pragma once

#include <memory>
#include <string>
#include <utility>

namespace algoforge {

class Trie {
  struct Node {
    bool terminal = false;
    int kids = 0;
    std::unique_ptr<Node> next[26]{};
  };

 public:
  void insert(const std::string& word) {
    Node* n = &root_;
    for (char c : word) {
      const int i = idx(c);
      if (i < 0) continue;
      if (!n->next[i]) {
        n->next[i] = std::make_unique<Node>();
        ++n->kids;
      }
      n = n->next[i].get();
    }
    if (!n->terminal) {
      n->terminal = true;
      ++size_;
    }
  }

  bool contains(const std::string& word) const {
    const Node* n = find(word);
    return n && n->terminal;
  }

  bool starts_with(const std::string& prefix) const { return find(prefix) != nullptr; }

  bool erase(const std::string& word) {
    bool removed = false;
    erase_rec(&root_, word, 0, removed);
    if (removed) --size_;
    return removed;
  }

  std::size_t size() const { return size_; }
  bool empty() const { return size_ == 0; }

 private:
  static int idx(char c) {
    if (c >= 'A' && c <= 'Z') c = static_cast<char>(c - 'A' + 'a');
    if (c < 'a' || c > 'z') return -1;
    return c - 'a';
  }

  const Node* find(const std::string& s) const {
    const Node* n = &root_;
    for (char c : s) {
      const int i = idx(c);
      if (i < 0 || !n->next[i]) return nullptr;
      n = n->next[i].get();
    }
    return n;
  }

  static bool erase_rec(Node* n, const std::string& word, std::size_t pos, bool& removed) {
    if (!n) return false;
    if (pos == word.size()) {
      if (!n->terminal) return n->kids == 0;
      n->terminal = false;
      removed = true;
      return n->kids == 0;
    }
    const int i = idx(word[pos]);
    if (i < 0) return erase_rec(n, word, pos + 1, removed);
    if (!n->next[i]) return false;
    if (erase_rec(n->next[i].get(), word, pos + 1, removed)) {
      n->next[i].reset();
      --n->kids;
    }
    return !n->terminal && n->kids == 0;
  }

  Node root_{};
  std::size_t size_ = 0;
};

}  // namespace algoforge
