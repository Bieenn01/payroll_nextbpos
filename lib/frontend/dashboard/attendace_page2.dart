import 'dart:ui';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class AttendacePage extends StatefulWidget {
  const AttendacePage({super.key});

  @override
  State<AttendacePage> createState() => _AttendacePageState();
}

class _AttendacePageState extends State<AttendacePage> {
  late Stream<QuerySnapshot> _userRecordsStream;
  TextEditingController _searchController = TextEditingController();
  String _selectedDepartment = '';

  @override
  void initState() {
    super.initState();
    _fetchUserRecords();
  }

  void _fetchUserRecords() {
    _userRecordsStream = FirebaseFirestore.instance
        .collection('Records')
        .orderBy('timeIn', descending: true)
        .snapshots();
  }

  int _documentLimit = 8;
  int _currentPage = 0;
  int _rowsPerPage = 8;
  DateTime? selectedDate;
  DateTime? selectedTime;
  DateTime? selectedDateTime;
  bool passwordVisible = false;
  bool showDropdown = false;
  int index2 = 0;

  String selectedRole = 'Select Role';
  String selectedDep = '--Select--';
  String typeEmployee = 'Type of Employee';

  get searchController => null;

  get colorController => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.teal.shade700,
        child: Column(
          children: [
            Flexible(
              child: Container(
                margin: EdgeInsets.fromLTRB(15, 5, 15, 15),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Attendance Overview',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Text('From:'),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width > 600
                                    ? 170
                                    : 50,
                                height: 30,
                                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(8)),
                                child: DateTimeFormField(
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.only(bottom: 15),
                                      hintText: 'Select Date',
                                      suffixIcon: Icon(Icons.calendar_month)),
                                  mode: DateTimeFieldPickerMode.date,
                                  onSaved: (DateTime? value) {},
                                  onChanged: (DateTime? value) {},
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text('To:'),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width > 600
                                    ? 170
                                    : 50,
                                height: 30,
                                padding: EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(8)),
                                child: DateTimeFormField(
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.only(bottom: 15),
                                      hintText: 'Select Date',
                                      suffixIcon: Icon(Icons.calendar_month)),
                                  mode: DateTimeFieldPickerMode.date,
                                  onSaved: (DateTime? value) {},
                                  onChanged: (DateTime? value) {},
                                ),
                              ),
                              Container(
                                child: InkWell(
                                    onTap: () {},
                                    child: Container(
                                      margin: EdgeInsets.only(left: 5),
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.teal.shade900),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(
                                            Icons.filter_list,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Filter',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    )),
                              ),
                            ],
                          ),
                          Flexible(
                            child: Container(
                              width: MediaQuery.of(context).size.width > 600
                                  ? 300
                                  : 50,
                              height: 30,
                              margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.5)),
                              ),
                              child: TextField(
                                controller: _searchController,
                                textAlign: TextAlign.start,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(bottom: 15),
                                  prefixIcon: Icon(Icons.search),
                                  border: InputBorder.none,
                                  hintText: 'Search',
                                ),
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Divider(),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _userRecordsStream,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                            return Center(
                              child: Text('No user records available.'),
                            );
                          }

                          var filteredDocs =
                              snapshot.data!.docs.where((document) {
                            String userName =
                                (document.data() as Map)['userName'];
                            String query = _searchController.text.toLowerCase();
                            String department =
                                (document.data() as Map)['department'] ?? '';
                            return userName.toLowerCase().contains(query) &&
                                (_selectedDepartment.isEmpty ||
                                    department == _selectedDepartment);
                          }).toList();

                          return ListView.builder(
                            itemCount: filteredDocs.length,
                            itemBuilder: (context, index) {
                              return DataTable(
                                columns: [
                                  ColumnInput('#'),
                                  ColumnInput('Name'),
                                  ColumnInput('Time in'),
                                  ColumnInput('Time out'),
                                  ColumnInput('Department')
                                ],
                                rows: filteredDocs
                                    .map((DocumentSnapshot document) {
                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;

                                  Color? rowColor = index % 2 == 0
                                      ? Colors.white
                                      : Colors
                                          .grey[200]; // Alternating row colors
                                  index++; //

                                  return DataRow(
                                      color: MaterialStateColor.resolveWith(
                                          (states) => rowColor!),
                                      cells: [
                                        DataCell(Text(index.toString())),
                                        DataCell(
                                          Container(
                                            width:
                                                100, // Adjust the width as needed
                                            child: Text(
                                                data['userName'] ?? 'Unknown'),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            width:
                                                150, // Adjust the width as needed
                                            child: Text(_formatTimestamp(
                                                data['timeIn'])),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            width:
                                                150, // Adjust the width as needed
                                            child: Text(_formatTimestamp(
                                                data['timeOut'])),
                                          ),
                                        ),
                                        DataCell(
                                          Container(
                                            width:
                                                100, // Adjust the width as needed
                                            child: Text(data['department'] ??
                                                'Unknown'),
                                          ),
                                        ),
                                      ]);
                                }).toList(),
                              );
                            },
                          );
                        },
                      ),
                    )
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

String _formatTimestamp(dynamic timestamp) {
  if (timestamp == null) return '-------';

  if (timestamp is Timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMMM dd, yyyy HH:mm:ss:a').format(dateTime);
  } else {
    return timestamp.toString();
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
