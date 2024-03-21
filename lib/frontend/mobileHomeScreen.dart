import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:project_payroll_nextbpo/frontend/login.dart';

class MobileHomeScreen extends StatefulWidget {
  const MobileHomeScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen> {
  late Timer timer;
  late String currentTime;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  User? currentUser;
  Map<String, dynamic> userData = {};
  bool checkedIn = false;
  bool isProcessing = false;

  @override
  void initState() {
    super.initState();
    currentTime = _getCurrentTime();
    currentUser = _auth.currentUser;
    getUserData();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = _getCurrentTime();
      });
    });

    _auth.authStateChanges().listen((User? user) {
      setState(() {
        currentUser = user;
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(text: formattedDate),
              ),
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: RichText(
                text: TextSpan(
                  text: currentTime,
                ),
              ),
            ),
            Text(
              'Hello: ${userData['fname']} ${userData['mname']} ${userData['lname']}',
            ),
            Text(
              checkedIn ? 'You timed in!' : 'You timed out',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (!checkedIn && !isProcessing) {
                  recordTimeIn();
                }
              },
              child: Text('Time In'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (checkedIn && !isProcessing) {
                  recordTimeOut();
                }
              },
              child: Text('Time Out'),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut(); // Sign out the user
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) =>
                            Login()), // Navigate back to the login page
                    (route) =>
                        false, // Remove all existing routes from the navigation stack
                  );
                },
                child: Text('Logout'))
          ],
        ),
      ),
    );
  }

  Future<void> getUserData() async {
    if (currentUser != null) {
      final docUser = _firestore.collection('User').doc(currentUser!.uid);
      try {
        final docSnapshot = await docUser.get();

        if (docSnapshot.exists) {
          setState(() {
            userData = docSnapshot.data() as Map<String, dynamic>;
          });
        }
      } catch (e) {
        print('Error getting user data: $e');
      }
    }
  }

  void recordTimeIn() async {
    if (currentUser != null) {
      setState(() {
        isProcessing = true;
      });

      final currentTime = DateTime.now();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      try {
        final lastRecordSnapshot = await _firestore
            .collection('Records')
            .where('userId', isEqualTo: userId)
            .where('timeIn', isGreaterThanOrEqualTo: _today())
            .where('timeIn', isLessThan: _tomorrow())
            .get();

        if (lastRecordSnapshot.docs.isEmpty) {
          final userDoc = await FirebaseFirestore.instance
              .collection('User')
              .doc(userId)
              .get();
          final userData = userDoc.data() as Map<String, dynamic>;

          await _firestore.collection('Records').add({
            'userId': userId,
            'timeIn': currentTime,
            'timeOut': null,
            'userName':
                '${userData['fname']} ${userData['mname']} ${userData['lname']}',
            'department':
                userData['department'], // Assuming department is in user data
            'role': userData['role']
          });

          setState(() {
            checkedIn = true;
          });
        } else {
          print('User already timed in today.');
        }
      } catch (e) {
        print('Error recording time in: $e');
      } finally {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  void recordTimeOut() async {
    if (currentUser != null) {
      setState(() {
        isProcessing = true;
      });

      final currentTime = DateTime.now();
      final userId = FirebaseAuth.instance.currentUser!.uid;

      try {
        final lastRecordSnapshot = await _firestore
            .collection('Records')
            .where('userId', isEqualTo: userId)
            .where('timeOut', isEqualTo: null)
            .where('timeIn', isGreaterThanOrEqualTo: _today())
            .where('timeIn', isLessThan: _tomorrow())
            .orderBy('timeIn', descending: true)
            .get();

        if (lastRecordSnapshot.docs.isNotEmpty) {
          final recordId = lastRecordSnapshot.docs.first.id;

          await _firestore.collection('Records').doc(recordId).update({
            'timeOut': currentTime,
          });

          // Calculate time rendered
          final recordData = lastRecordSnapshot.docs.first.data();
          final timeIn = recordData['timeIn'].toDate();
          final timeOut = currentTime;
          final duration = calculateTimeRendered(timeIn, timeOut);

          // Update the 'hours' and 'minutes' fields in Firestore
          await _firestore.collection('Records').doc(recordId).update({
            'hours': duration.inHours,
            'minutes': duration.inMinutes.remainder(60),
          });

          setState(() {
            checkedIn = false;
          });
        } else {
          print(
              'No matching document found for time out or user already timed out today.');
        }
      } catch (e) {
        print('Error updating time out: $e');
      } finally {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

  Duration calculateTimeRendered(DateTime timeIn, DateTime timeOut) {
    return timeOut.difference(timeIn);
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _tomorrow() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + 1);
  }

  String _getCurrentTime() {
    return DateFormat('hh:mm:ss a').format(DateTime.now());
  }

  String formattedDate = DateFormat('MMMM dd, yyyy').format(DateTime.now());
}
