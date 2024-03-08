import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class Overtime extends StatefulWidget {
  Overtime({super.key});

  @override
  State<Overtime> createState() => _OvertimeState();
}

class _OvertimeState extends State<Overtime> {
  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateFormat Dayformatter = DateFormat('EEEE');
    final DateFormat formatter = DateFormat('dd MMM H:mm a');
    final String dateFormat = formatter.format(now);
    final String DayFormat = Dayformatter.format(now);

    return Scaffold(
      body: Container(
        color: Color.fromARGB(255, 92, 124, 58).withOpacity(0.5),
        child: Column(
          children: [
            Expanded(
              flex: 6,
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(color: Colors.white, boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 5,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ]),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 0,
                          child: Container(
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/images/icons8-clock-96.png',
                                  height: 40,
                                ),
                                MediaQuery.of(context).size.width > 1300
                                    ? Container(
                                        margin: EdgeInsets.only(right: 100),
                                        child: const Text(
                                          ' Regular Overtime',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 22,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1),
                                        ),
                                      )
                                    : Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: const [
                                          Text(
                                            '  Regular',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1),
                                          ),
                                          Text(
                                            '  Overtime',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w300,
                                                fontStyle: FontStyle.italic,
                                                letterSpacing: 1),
                                          )
                                        ],
                                      ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width > 900
                              ? MediaQuery.of(context).size.width / 5
                              : 5,
                        ),
                        Expanded(
                            flex: 2,
                            child: Container(
                              width: MediaQuery.of(context).size.width > 600
                                  ? (MediaQuery.of(context).size.width / 3)
                                      .clamp(200, 1000)
                                  : 150,
                              margin: EdgeInsets.all(5),
                              child: TextField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  prefixIconColor: Colors.green.shade900,
                                  hoverColor: Colors.green.shade900,
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide(
                                    color: Colors.green.shade900,
                                  )),
                                  hintText: 'Search',
                                ),
                              ),
                            )),
                        Flexible(
                            flex: 1,
                            child: Container(
                              width: MediaQuery.of(context).size.width > 600
                                  ? (MediaQuery.of(context).size.width / 3)
                                      .clamp(100, 200)
                                  : 80,
                              margin: EdgeInsets.all(5),
                              padding: EdgeInsets.all(0),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.green.shade100.withOpacity(1)),
                                child: MediaQuery.of(context).size.width > 900
                                    ? ListTile(
                                        leading: Image.asset(
                                          'assets/images/icons8-filter-40.png',
                                          height: 30,
                                        ),
                                        title: Text('Filter'),
                                        subtitle: Text('Report'),
                                      )
                                    : Image.asset(
                                        'assets/images/icons8-filter-40.png',
                                        height: 50,
                                      ),
                              ),
                            )),
                        Flexible(
                            flex: 1,
                            child: Container(
                              width: MediaQuery.of(context).size.width > 600
                                  ? (MediaQuery.of(context).size.width / 3)
                                      .clamp(50, 200)
                                  : 80,
                              margin: EdgeInsets.all(2),
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.green.shade100.withOpacity(1)),
                                child: MediaQuery.of(context).size.width > 900
                                    ? ListTile(
                                        leading: Image.asset(
                                          'assets/images/icons8-report-96.png',
                                          height: 40,
                                        ),
                                        title: Text('Generate'),
                                        subtitle: Text('Report'),
                                      )
                                    : Image.asset(
                                        'assets/images/icons8-report-96.png',
                                        height: 50,
                                      ),
                              ),
                            ))
                      ],
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 0.5,
                    ),
                    Expanded(
                        child: Container(
                      margin: EdgeInsets.all(0),
                      padding: const EdgeInsets.all(10.0),
                      height: MediaQuery.of(context).size.height / 1.3,
                      color: Colors.white,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: DataTable(
                            columns: [
                              ColumnInput('#'),
                              ColumnInput('Name'),
                              ColumnInput('Department'),
                              ColumnInput('Hours'),
                            ],
                            rows: [
                              RowInputs(
                                '1',
                                'Majksd kakjshd',
                                'IT',
                                '5',
                              ),
                              RowInputs(
                                '2',
                                'Hlasdn kakjshd',
                                'HR',
                                '4',
                              ),
                              RowInputs(
                                '3',
                                'Skjhsdd kakjshd',
                                'Accounting',
                                '3',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

DataColumn ColumnInput(Label) {
  return DataColumn(
      label: Text(
    Label,
    style: const TextStyle(
      fontWeight: FontWeight.w900,
    ),
  ));
}

DataRow RowInputs(num, name, username, password) {
  bool pass = false;
  var pas1ength = password.length;
  return DataRow(cells: [
    DataCell(Text(num)),
    DataCell(Text(name)),
    DataCell(Text(username)),
    DataCell(Row(
      children: [
        Text(password),
      ],
    )),
  ]);
}
