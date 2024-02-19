import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';

final menuTree = TreeNode.root()
  ..addAll(
    [
      TreeNode(key: "Dashboard", data: Icons.dashboard),
      TreeNode(key: "Documentation", data: Icons.description)
        ..addAll([
          TreeNode(key: "Dart"),
          TreeNode(key: "Flutter"),
        ]),
      TreeNode(key: "Plugins", data: Icons.cable)
        ..addAll([
          TreeNode(key: "Animated Tree View"),
          TreeNode(key: "Flutter BLoC"),
          TreeNode(key: "Material"),
        ]),
      TreeNode(key: "Analytics", data: Icons.analytics),
      TreeNode(key: "Collection", data: Icons.collections_bookmark)
        ..addAll([
          TreeNode(key: "Framework"),
          TreeNode(key: "Technology"),
        ]),
      TreeNode(key: "Settings", data: Icons.settings),
    ],
  );
