import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:project_payroll_nextbpo/frontend/raw%20backend/userTimeOutToday.dart';
import 'package:shimmer/shimmer.dart' as ShimmerPackage;

class UserTimedInToday extends StatefulWidget {
  @override
  _UserTimedInTodayState createState() => _UserTimedInTodayState();
}

class _UserTimedInTodayState extends State<UserTimedInToday> {
  late Stream<QuerySnapshot> _userRecordsStream;

  bool table = false;

  String selectedDepartment = 'All';

  @override
  void initState() {
    super.initState();
    _fetchUserTimedInToday();
  }

  void _fetchUserTimedInToday() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    _userRecordsStream = FirebaseFirestore.instance
        .collection('Records')
        .where('timeIn',
            isGreaterThanOrEqualTo: startOfDay, isLessThan: endOfDay)
        .orderBy('timeIn', descending: true)
        .snapshots();
  }

  void _fetchUserTimedOutToday() {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = startOfDay.add(Duration(days: 1));

    _userRecordsStream = FirebaseFirestore.instance
        .collection('Records')
        .where('timeOut',
            isGreaterThanOrEqualTo: startOfDay, isLessThan: endOfDay)
        .orderBy('timeOut', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Attendance Overview',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        actions: [
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        table == false ? Colors.teal.shade700 : Colors.white,
                    padding: EdgeInsets.all(5),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    )),
                    side: BorderSide(color: Colors.teal.shade900)),
                onPressed: () {
                  setState(() {
                    table = false;
                  });
                },
                child: Text(
                  ' Time In ',
                  style: TextStyle(
                      color:
                          table == false ? Colors.white : Colors.teal.shade900),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor:
                        table == true ? Colors.teal.shade700 : Colors.white,
                    padding: EdgeInsets.all(5),
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    )),
                    side: BorderSide(color: Colors.teal.shade900)),
                onPressed: () {
                  setState(() {
                    table = true;
                  });
                },
                child: Text(
                  ' Time Out ',
                  style: TextStyle(
                      color:
                          table == true ? Colors.white : Colors.teal.shade900),
                ),
              ),
            ],
          )
        ],
      ),
      body: table == false ? TimeIn2Table() : TimeoutTable(),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> TimeoutTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _userRecordsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No users timed in today.'),
          );
        }

        final List<DocumentSnapshot> documents = snapshot.data!.docs;
        final int rowsPerPage = 10; // Number of rows per page
        List<DocumentSnapshot> filteredDocuments = documents;
        if (selectedDepartment != 'All') {
          filteredDocuments = documents
              .where((doc) => doc['department'] == selectedDepartment)
              .toList();
        }

        var dataTable = DataTable(
          dataRowMinHeight: 30,
          dataRowMaxHeight: 65,
          columns: [
            DataColumn(
              label: Text(
                '#',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Time-Out',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: PopupMenuButton<String>(
                child: Row(
                  children: [
                    Text(
                      'Department',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.arrow_drop_down)
                  ],
                ),
                onSelected: (String value) {
                  setState(() {
                    selectedDepartment = value;
                  });
                },
                itemBuilder: (BuildContext context) => [
                  'All', // Default option
                  'IT',
                  'HR',
                  'ACCOUNTING',
                  'SERVICING',
                ].map((String value) {
                  return PopupMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
          rows: List<DataRow>.generate(
            filteredDocuments.length, // Use filteredDocuments.length here
            (index) {
              final document = filteredDocuments[index];
              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Text(
                    document['userName'].toString(),
                  )),
                  DataCell(Text(_formatTimestamp(document['timeOut']),
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(document['department'].toString())),
                ],
              );
            },
          ),
        );
        return Expanded(
          child: MediaQuery.of(context).size.width > 1300
              ? SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: dataTable,
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: FittedBox(fit: BoxFit.fill, child: dataTable),
                  ),
                ),
        );
      },
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> TimeIn2Table() {
    return StreamBuilder<QuerySnapshot>(
      stream: _userRecordsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No users timed in today.'),
          );
        }

        final List<DocumentSnapshot> documents = snapshot.data!.docs;
        final int rowsPerPage = 10; // Number of rows per page
        List<DocumentSnapshot> filteredDocuments = documents;
        if (selectedDepartment != 'All') {
          filteredDocuments = documents
              .where((doc) => doc['department'] == selectedDepartment)
              .toList();
        }

        var dataTable = DataTable(
          dataRowMinHeight: 30,
          dataRowMaxHeight: 65,
          columns: [
            DataColumn(
              label: Text(
                '#',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Name',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: Text(
                'Time-In',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            DataColumn(
              label: PopupMenuButton<String>(
                child: Row(
                  children: [
                    Text(
                      'Department',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.arrow_drop_down)
                  ],
                ),
                onSelected: (String value) {
                  setState(() {
                    selectedDepartment = value;
                  });
                },
                itemBuilder: (BuildContext context) => [
                  'All', // Default option
                  'IT',
                  'HR',
                  'ACCOUNTING',
                  'SERVICING',
                ].map((String value) {
                  return PopupMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ),
          ],
          rows: List<DataRow>.generate(
            filteredDocuments.length, // Use filteredDocuments.length here
            (index) {
              final document = filteredDocuments[index];
              return DataRow(
                cells: [
                  DataCell(Text((index + 1).toString())),
                  DataCell(Text(
                    document['userName'].toString(),
                  )),
                  DataCell(Text(_formatTimestamp(document['timeIn']),
                      style: TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(document['department'].toString())),
                ],
              );
            },
          ),
        );
        return Expanded(
          child: MediaQuery.of(context).size.width > 1300
              ? SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: dataTable,
                  ),
                )
              : SingleChildScrollView(
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    child: FittedBox(fit: BoxFit.fill, child: dataTable),
                  ),
                ),
        );
      },
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> TimeInTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _userRecordsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildShimmerLoading();
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No users timed in today.'),
          );
        }

        return Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: DataTable(
                dataRowMinHeight: 30,
                dataRowMaxHeight: 65,
                columns: const [
                  DataColumn(
                    label: Text(
                      '#',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Time-In',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Department',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
                rows: List<DataRow>.generate(
                  snapshot.data!.docs.length,
                  (index) => DataRow(
                    cells: [
                      DataCell(Text((index + 1).toString())),
                      DataCell(Flexible(
                          child: Text(snapshot.data!.docs[index]['userName']))),
                      DataCell(Text(
                          _formatTimestamp(
                            snapshot.data!.docs[index]['timeIn'],
                          ),
                          style: TextStyle(fontWeight: FontWeight.bold))),
                      DataCell(Text(snapshot.data!.docs[index]['department'])),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('HH:mm:ss').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }
}

class _UserRecordsDataSource extends DataTableSource {
  final List<DocumentSnapshot> _userRecords;

  _UserRecordsDataSource(this._userRecords);

  @override
  DataRow? getRow(int index) {
    if (index >= _userRecords.length) {
      return null;
    }
    final record = _userRecords[index];
    final data = record.data() as Map<String, dynamic>;
    return DataRow(cells: [
      DataCell(Text(data['userName'])),
      DataCell(Text(_formatTimestamp(data['timeIn']))),
      DataCell(Text(data['department'])),
    ]);
  }

  @override
  int get rowCount => _userRecords.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => 0;

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('HH:mm:ss a').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }
}

Widget _buildShimmerLoading() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: ShimmerPackage.Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: DataTable(
        columns: const [
          DataColumn(
            label: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Time-In/Time-Out',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Department',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: List.generate(
          5, // You can change this to the number of shimmer rows you want
          (index) => DataRow(cells: [
            DataCell(Container(width: 250, height: 16, color: Colors.white)),
            DataCell(Container(width: 60, height: 16, color: Colors.white)),
            DataCell(Container(width: 120, height: 16, color: Colors.white)),
            DataCell(Container(width: 80, height: 16, color: Colors.white)),
          ]),
        ),
      ),
    ),
  );
}
