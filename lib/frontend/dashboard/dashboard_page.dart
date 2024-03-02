import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/main_calendar.dart';
import 'package:project_payroll_nextbpo/frontend/userTimeInToday.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(color: Colors.teal.shade700),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: Container(
                margin: EdgeInsets.all(8),
                child: Row(
                  children: [
                    //small container
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: smallContainer(
                          '416',
                          Icons.supervisor_account_rounded,
                          'Total Employees',
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: smallContainer(
                          '360',
                          Icons.access_time,
                          'On Time',
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: smallContainer(
                          '62',
                          Icons.more_time_sharp,
                          'Late Arrival',
                        ),
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(8),
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: smallContainer(
                          '360',
                          Icons.list_alt,
                          'Check Out',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
              flex: 5,
              child: Container(
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(8, 0, 8, 8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(
                                margin: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  children: [
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(0, 0, 8, 8),
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: smallContainer('7',
                                            Icons.wb_sunny, 'Early Departure'),
                                      ),
                                    ),
                                    Flexible(
                                      flex: 1,
                                      child: Container(
                                        margin: EdgeInsets.fromLTRB(8, 0, 0, 8),
                                        padding: EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: smallContainer(
                                            '7', Icons.punch_clock, 'Late'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //Attendance
                            Flexible(
                              flex: 4,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(8, 8, 8, 0),
                                padding: EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15)),
                                child: Column(
                                  children: [
                                    Text('Attendance Overview'),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Expanded(child: UserTimedInToday()),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    //Calendar
                    Flexible(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(10),
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15)),
                        child: Column(
                          children: [
                            Flexible(
                              flex: 5,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(30, 10, 20, 30),
                                child: GestureDetector(
                                  onTap: () {
                                    _navigateToCalendarPageWithDialog(context);
                                  },
                                  child: CalendarPage(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Column smallContainer(
    total,
    icon,
    title,
  ) {
    return Column(
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
            )
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
    );
  }

  void _navigateToCalendarPageWithDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child:
              CalendarPage(), // Replace CalendarPage() with your dialog content
        );
      },
    );
  }
}
