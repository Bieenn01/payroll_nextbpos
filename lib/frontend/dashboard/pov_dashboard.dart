import 'package:flutter/material.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar_menu.dart';

class PovDashboard extends StatelessWidget {
  final String userId;
  final String id;
  final String username;
  final String department;
  final String email;

  // Constructor for initializing the parameters
  const PovDashboard({
    required this.userId,
    required this.id,
    required this.username,
    required this.department, 
    required this.email,
  });
  Widget build(BuildContext context) {
    return Container(
      // You can add any necessary properties or child widgets here
      child: SidebarMenu(), // Calling the SidebarMenu class
    );
  }
}

