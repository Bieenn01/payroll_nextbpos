import 'package:animated_tree_view/animated_tree_view.dart';
import 'package:flutter/material.dart';
import 'package:project_payroll_nextbpo/backend/user_model.dart';

final Future<TreeNode> menuTreeFuture = getMenuTree();

Future<TreeNode> getMenuTree() async {
  UserModel? user = await AuthService().user.first;

  // Default menu items that are not role-specific or para sa Employees
  List<TreeNode> defaultMenuItems = [
    TreeNode(key: "Dashboard", data: Icons.dashboard),
    TreeNode(key: "Calendar", data: Icons.edit_calendar_outlined),
  ];
  // Add role-specific menu items based on user's role
  if (user != null && (user.role == 'Superadmin' || user.role == 'Admin')) {
    defaultMenuItems.addAll([
      TreeNode(key: "Overtime", data: Icons.access_time_filled_outlined)
        ..addAll([
          TreeNode(key: "Regular OT"),
          TreeNode(key: "Rest day OT"),
          TreeNode(key: "Regular Holiday OT"),
          TreeNode(key: "Special Holiday OT"),
        ]),
      TreeNode(key: "Holiday", data: Icons.calendar_month_outlined)
        ..addAll([
          TreeNode(key: "Regular"),
          TreeNode(key: "Special"),
        ]),
      TreeNode(key: "Leave", data: Icons.recent_actors_outlined),
      TreeNode(key: "Logs", data: Icons.analytics),
      TreeNode(key: "Calendar", data: Icons.edit_calendar_outlined),
      TreeNode(key: "Payroll", data: Icons.payments),
    ]);
  }

  return TreeNode.root()..addAll(defaultMenuItems);
}
