import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/main_calendar.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/userTimeInToday.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardMobile extends StatefulWidget {
  const DashboardMobile({super.key});

  @override
  State<DashboardMobile> createState() => _DashboardMobileState();
}

class _DashboardMobileState extends State<DashboardMobile> {
  int totalEmployees = 0;

  @override
  void initState() {
    super.initState();
    fetchEmployeeCount();
  }

  Future<void> fetchEmployeeCount() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('User') // Change this to your collection name
          .get();

      setState(() {
        totalEmployees = querySnapshot.size;
      });
    } catch (e) {
      print("Error fetching employee count: $e");
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
                          height: 10,
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
                                    height: 600,
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
                      padding: EdgeInsets.all(8),
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
                  child: Container(
                    height: 120,
                    padding: EdgeInsets.all(8),
                    decoration: container1Decoration(),
                    child: smallContainerRow(
                        '62', Icons.more_time_sharp, 'Late Arrival'),
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
                          height: 120,
                          padding: EdgeInsets.all(8),
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
                  ],
                ),
                SizedBox(
                  height: 3,
                ),
                Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        height: 90,
                        padding: EdgeInsets.all(8),
                        decoration: container1Decoration(),
                        child: smallContainer(
                            '62', Icons.more_time_sharp, 'Late Arrival'),
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
