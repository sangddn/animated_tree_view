import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tree_structure_view/exceptions/exceptions.dart';
import 'base/i_node_actions.dart';
import 'base/i_node.dart';

class IndexedNode<T> extends INode<T> implements IIndexedNodeActions<T> {
  final List<IndexedNode<T>> children;
  final String key;
  INode<T>? parent;
  Map<String, dynamic>? meta;

  @mustCallSuper
  IndexedNode({String? key, this.parent})
      : this.children = <IndexedNode<T>>[],
        this.key = key ?? UniqueKey().toString();

  factory IndexedNode.root() => IndexedNode(key: INode.ROOT_KEY);

  UnmodifiableListView<INode<T>> get childrenAsList =>
      UnmodifiableListView(children);

  IndexedNode<T> get first {
    if (children.isEmpty) throw ChildrenNotFoundException(this);
    return children.first;
  }

  set first(IndexedNode<T> value) {
    if (children.isEmpty) throw ChildrenNotFoundException(this);
    children.first = value;
  }

  IndexedNode<T> get last {
    if (children.isEmpty) throw ChildrenNotFoundException(this);
    return children.last;
  }

  set last(IndexedNode<T> value) {
    if (children.isEmpty) throw ChildrenNotFoundException(this);
    children.last = value;
  }

  IndexedNode<T> firstWhere(bool Function(IndexedNode<T> element) test,
      {IndexedNode<T> orElse()?}) {
    return children.firstWhere(test, orElse: orElse);
  }

  int indexWhere(bool Function(IndexedNode<T> element) test, [int start = 0]) {
    return children.indexWhere(test, start);
  }

  IndexedNode<T> lastWhere(bool Function(IndexedNode<T> element) test,
      {IndexedNode<T> orElse()?}) {
    return children.lastWhere(test, orElse: orElse);
  }

  void add(INode<T> value) {
    value.parent = this;
    // final updatedValue = _updateChildrenPaths<T>(value as IndexedNode<T>);
    children.add(value as IndexedNode<T>);
  }

  void addAll(Iterable<INode<T>> iterable) {
    for (final node in iterable) {
      add(node);
    }
  }

  void insert(int index, IndexedNode<T> element) {
    element.parent = this;
    // final updatedValue = _updateChildrenPaths<T>(element);
    children.insert(index, element);
  }

  int insertAfter(IndexedNode<T> after, IndexedNode<T> element) {
    final index = children.indexWhere((node) => node.key == after.key);
    if (index < 0) throw NodeNotFoundException.fromNode(after);
    insert(index + 1, element);
    return index + 1;
  }

  int insertBefore(IndexedNode<T> before, IndexedNode<T> element) {
    final index = children.indexWhere((node) => node.key == before.key);
    if (index < 0) throw NodeNotFoundException.fromNode(before);
    insert(index, element);
    return index;
  }

  void insertAll(int index, Iterable<IndexedNode<T>> iterable) {
    for (final node in iterable) {
      node.parent = this;
    }
    children.insertAll(index, iterable);
  }

  void remove(INode<T> value) {
    final index = children.indexWhere((node) => node.key == value.key);
    if (index < 0) throw NodeNotFoundException(key: key);
    children.removeAt(index);
  }

  IndexedNode<T> removeAt(int index) {
    return children.removeAt(index);
  }

  void removeAll(Iterable<INode<T>> iterable) {
    for (final node in iterable) {
      remove(node);
    }
  }

  void removeWhere(bool Function(INode<T> element) test) {
    children.removeWhere(test);
  }

  void clear() {
    children.clear();
  }

  INode<T> elementAt(String path) {
    IndexedNode<T> currentNode = this;
    for (final nodeKey in path.splitToNodes) {
      if (nodeKey == currentNode.key) {
        continue;
      } else {
        final index =
            currentNode.children.indexWhere((node) => node.key == nodeKey);
        if (index < 0)
          throw NodeNotFoundException(parentKey: path, key: nodeKey);
        final nextNode = currentNode.children[index];
        currentNode = nextNode;
      }
    }
    return currentNode;
  }

  IndexedNode<T> at(int index) => children[index];

  IndexedNode<T> operator [](String path) => elementAt(path) as IndexedNode<T>;
}