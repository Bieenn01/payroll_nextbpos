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
  int lateCount = 0;

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
      appBar: AppBar(
        title: const Text(
          'ATTENDANCE',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  backgroundImage: AssetImage('assets/images/Employee.jpg'),
                  radius: 50, // Adjust as needed
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${userData['fname']} ${userData['mname']} ${userData['lname']}',
                  style: const TextStyle(fontSize: 24),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: checkedIn
                  ? const Text(
                      'You are currently timed in.',
                      style: TextStyle(fontSize: 24, color: Colors.green),
                    )
                  : const Text(
                      'You are currently timed out.',
                      style: TextStyle(fontSize: 24, color: Colors.red),
                    ),
            ),
            const SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        if (!checkedIn && !isProcessing) {
                          recordTimeIn();
                        }
                      },
                      child: isProcessing
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 10),
                                Text('Processing...'),
                              ],
                            )
                          : const Text('Time In'),
                    ),
                    const SizedBox(
                        width:
                            20), // Adjust the width between buttons as needed
                    ElevatedButton(
                      onPressed: () {
                        if (checkedIn && !isProcessing) {
                          recordTimeOut();
                        }
                      },
                      child: isProcessing
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(width: 10),
                                Text('Processing...'),
                              ],
                            )
                          : const Text('Time Out'),
                    ),
                  ],
                ),
              ],
            ),
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

  bool checkLateArrival(Timestamp? startShift) {
    if (startShift != null) {
      final startTime = startShift.toDate(); // Extract time part only
      final currentTime =
          TimeOfDay.fromDateTime(DateTime.now()); // Get current time

      // Convert startTime to TimeOfDay for comparison
      final startShiftTime =
          TimeOfDay(hour: startTime.hour, minute: startTime.minute);

      // Compare only the time parts to determine if the user is late
      if (currentTime.hour > startShiftTime.hour ||
          (currentTime.hour == startShiftTime.hour &&
              currentTime.minute >= startShiftTime.minute)) {
        setState(() {
          lateCount++; // Increment late count if late or on time
        });
        return true; // User arrived late
      }
    }
    return false; // User arrived on time
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

          bool isLate = checkLateArrival(userData['startShift']);

          Timestamp? onTimeTimestamp;

          if (isLate) {
            onTimeTimestamp = Timestamp.fromDate(currentTime);
          } else {
            onTimeTimestamp = null;
          }

          await _firestore.collection('Records').add({
            'userId': userId,
            'timeIn': currentTime,
            'timeOut': null,
            'userName':
                '${userData['fname']} ${userData['mname']} ${userData['lname']}',
            'department':
                userData['department'], // Assuming department is in user data
            'role': userData['role'],
            'lateCount': isLate ? lateCount : 0, // Add lateCount field
            'lateTime': onTimeTimestamp, // Save timestamp for onTime field
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
