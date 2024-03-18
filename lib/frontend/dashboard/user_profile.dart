import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/dashboard_page.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/pov_dashboard.dart';

class UserProfile extends StatefulWidget {
  UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Text('User Profile'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
