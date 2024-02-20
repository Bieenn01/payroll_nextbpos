import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MobileHomeScreen extends StatefulWidget {
  final String userId;
  final String email;

  const MobileHomeScreen({
    Key? key,
    required this.userId,
    required this.email,
  }) : super(key: key);

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  bool checkedIn = false;

  void handleCheckIn() {
    setState(() {
      checkedIn = true;
    });
  }

  void handleCheckOut() {
    setState(() {
      checkedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              checkedIn ? 'You are checked in!' : 'You are checked out',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (!checkedIn) {
                  handleCheckIn();
                }
              },
              child: Text('Check In'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  if (checkedIn) {
                    handleCheckOut();
                  }
                },
                child: Text('Check Out')),
          ],
        ),
      ),
    );
  }
}
