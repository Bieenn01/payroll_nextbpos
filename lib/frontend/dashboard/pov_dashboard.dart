import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/sidebar_menu.dart';

class PovDashboard extends StatelessWidget {
  final String userId;

  // Constructor for initializing the parameters
  const PovDashboard({
    required this.userId,
  });

  // Factory method to create an instance of PovDashboard with userId obtained from Firebase
  factory PovDashboard.fromFirebase() {
    User? user = FirebaseAuth.instance.currentUser;
    String userId =
        user?.uid ?? ''; // If user is null, set userId as empty string
    return PovDashboard(userId: userId);
  }

  // Factory method to create an instance of PovDashboard with userId obtained from Firebase asynchronously
  static Future<PovDashboard> fromFirebaseAsync() async {
    try {
      User? user = await FirebaseAuth.instance.authStateChanges().first;
      String userId =
          user?.uid ?? ''; // If user is null, set userId as empty string
      return PovDashboard(userId: userId);
    } catch (e) {
      // Handle error, such as Firebase connection error
      print('Error retrieving user from Firebase: $e');
      rethrow; // Rethrow the error for better debugging and handling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // You can add any necessary properties or child widgets here
      child: SidebarMenu(), // Calling the SidebarMenu class
    );
  }
}
