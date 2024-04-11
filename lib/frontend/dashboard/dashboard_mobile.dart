import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/main_calendar.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/userTimeInToday.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_payroll_nextbpo/frontend/mobileHomeScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardMobile extends StatefulWidget {
  const DashboardMobile({super.key});

  @override
  State<DashboardMobile> createState() => _DashboardMobileState();
}

class _DashboardMobileState extends State<DashboardMobile> {
  int totalEmployees = 0;
  late String _role = 'Guest';
  late int _lateCount = 0; // Late count variable
  late Timer _resetTimer; // Timer for count reset

  @override
  void initState() {
    super.initState();
    fetchEmployeeCount();
    _fetchRole();
    fetchLateCount(); //.then((lateCount) {
    //   setState(() {
    //     _lateCount = lateCount;
    //   });
    // });

    // // Schedule count reset timer
    // _startResetTimer();
  }

  @override
  void dispose() {
    super.dispose();
    // Cancel the timer when the widget is disposed
    _resetTimer.cancel();
  }

  void _startResetTimer() {
    // Get the current time
    DateTime now = DateTime.now();

    // Calculate the duration until midnight
    DateTime midnight = DateTime(now.year, now.month, now.day + 1);
    Duration durationUntilMidnight = midnight.difference(now);

    // Schedule a timer to reset the count at midnight
    _resetTimer = Timer(durationUntilMidnight, () {
      _resetLateCount();
    });
  }

  Future<void> _fetchRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();

      setState(() {
        final role = docSnapshot['role'];
        _role = role ?? 'Guest'; // Default to 'Guest' if role is not specified
      });
    }
  }

  Future<void> fetchEmployeeCount() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('User').get();

      setState(() {
        totalEmployees = querySnapshot.size;
      });
    } catch (e) {
      print("Error fetching employee count: $e");
    }
  }

  Future<int> fetchLateCount() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Records')
        .where('lateTime', isGreaterThanOrEqualTo: startOfDay)
        .where('lateTime', isLessThanOrEqualTo: endOfDay)
        .get();

    return querySnapshot.size;
  }

  Future<void> _resetLateCount() async {
    try {
      // Update lateCount for all documents in Firestore
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Query documents where lateCount is greater than 0 and update to 0
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Records')
          .where('lateCount', isGreaterThan: 0)
          .get();

      querySnapshot.docs.forEach((doc) {
        batch.update(doc.reference, {'lateCount': 0});
      });

      // Commit the batch update
      await batch.commit();
    } catch (e) {
      print('Error resetting late count: $e');
    }
  }

  Future<int> countDocumentsForToday() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Records')
        .where('timeIn', isGreaterThanOrEqualTo: startOfDay)
        .where('timeIn', isLessThanOrEqualTo: endOfDay)
        .get();

    return querySnapshot.size;
  }

  Future<int> countendDocumentsForToday() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Records')
        .where('timeOut', isGreaterThanOrEqualTo: startOfDay)
        .where('timeOut', isLessThanOrEqualTo: endOfDay)
        .get();

    return querySnapshot.size;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Container(
        color: Colors.teal.shade700,
        margin: EdgeInsets.only(top: 0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 15),
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 15),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container1Dashboard(context),
                        SizedBox(
                          height: 5,
                        ),
                        MediaQuery.of(context).size.width > 1100
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      height: 500,
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: UserTimedInToday(),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Flexible(
                                    flex: 1,
                                    child: Container(
                                      height: 680,
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: CalendarPage(),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Container(
                                    height: 500,
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: UserTimedInToday(),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    height: 650,
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: CalendarPage(),
                                  ),
                                ],
                              )
                      ],
                    )),
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Container Container1Dashboard(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.width > 800 ? 130 : 200,
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.all(0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: MediaQuery.of(context).size.width > 800
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(
                    flex: 1,
                    child: Container(
                      height: 120,
                      padding: EdgeInsets.fromLTRB(15, 8, 8, 8),
                      decoration: container1Decoration(),
                      child: smallContainerRow(
                        '$totalEmployees',
                        Icons.supervisor_account_rounded,
                        'Total Employees',
                      ),
                    )),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    height: 120,
                    padding: EdgeInsets.all(8),
                    decoration: container1Decoration(),
                    child: FutureBuilder(
                      future: countDocumentsForToday(),
                      builder: (context, AsyncSnapshot<int> snapshot) {
                        if (snapshot.data == null || snapshot.data == 0) {
                          return smallContainerRow(
                              '0', Icons.access_time, 'Time in');
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return smallContainerRow(snapshot.data.toString(),
                              Icons.access_time, 'Time in');
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                  flex: 1,
                  child: FutureBuilder<int>(
                    future: fetchLateCount(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return Center(
                          child: Text('Error: ${snapshot.error}'),
                        );
                      } else {
                        return Container(
                          height: 120,
                          padding: EdgeInsets.all(8),
                          decoration: container1Decoration(),
                          child: smallContainerRow(
                            '${snapshot.data ?? 0}', // Display late count retrieved from snapshot, with fallback value of 0
                            Icons.more_time_sharp,
                            'Late Arrival',
                          ),
                        );
                      }
                    },
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Flexible(
                  flex: 1,
                  child: Container(
                    height: 120,
                    padding: EdgeInsets.all(8),
                    decoration: container1Decoration(),
                    child: FutureBuilder(
                      future: countendDocumentsForToday(),
                      builder: (context, AsyncSnapshot<int> snapshot) {
                        if (snapshot.data == null || snapshot.data == 0) {
                          return smallContainerRow(
                              '0', Icons.access_time, 'Time out');
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          return smallContainerRow(snapshot.data.toString(),
                              Icons.access_time, 'Time out');
                        }
                      },
                    ),
                  ),
                ),
              ],
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  children: [
                    Flexible(
                        flex: 1,
                        child: Container(
                          height: 90,
                          padding: EdgeInsets.all(8),
                          decoration: container1Decoration(),
                          child: smallContainer(
                            '$totalEmployees',
                            Icons.supervisor_account_rounded,
                            'Total Employees',
                          ),
                        )),
                    SizedBox(
                      width: 5,
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        height: 90,
                        padding: EdgeInsets.all(8),
                        decoration: container1Decoration(),
                        child: FutureBuilder(
                          future: countDocumentsForToday(),
                          builder: (context, AsyncSnapshot<int> snapshot) {
                            if (snapshot.data == null || snapshot.data == 0) {
                              return smallContainer(
                                  '0', Icons.access_time, 'Time in');
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return smallContainer(snapshot.data.toString(),
                                  Icons.access_time, 'Time in');
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: FutureBuilder<int>(
                        future: fetchLateCount(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          } else {
                            return Container(
                              height: 90,
                              padding: EdgeInsets.all(8),
                              decoration: container1Decoration(),
                              child: smallContainer(
                                '${snapshot.data ?? 0}', // Display late count retrieved from snapshot, with fallback value of 0
                                Icons.more_time_sharp,
                                'Late Arrival',
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        height: 90,
                        padding: EdgeInsets.all(8),
                        decoration: container1Decoration(),
                        child: FutureBuilder(
                          future: countendDocumentsForToday(),
                          builder: (context, AsyncSnapshot<int> snapshot) {
                            if (snapshot.data == null || snapshot.data == 0) {
                              return smallContainer(
                                  '0', Icons.access_time, 'Time out');
                            } else if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            } else {
                              return smallContainer(snapshot.data.toString(),
                                  Icons.access_time, 'Time out');
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
    );
  }

  BoxDecoration container1Decoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    );
  }
}

Widget smallContainerRow(String total, IconData icon, String title) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              total,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Icon(
              icon,
              size: 30,
              color: Colors.blue.shade300.withOpacity(1),
            ),
          ],
        ),
        SizedBox(
          height: 10,
        ),
        Text(title),
        SizedBox(
          height: 10,
        ),
      ],
    ),
  );
}

Widget smallContainer(String total, IconData icon, String title) {
  return Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              total,
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Icon(
              icon,
              size: 30,
              color: Colors.blue.shade300.withOpacity(1),
            ),
          ],
        ),
        Text(title),
      ],
    ),
  );
}
