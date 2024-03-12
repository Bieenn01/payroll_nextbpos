import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:project_payroll_nextbpo/frontend/raw%20backend/userTimeOutToday.dart';

class UserTimedInToday extends StatefulWidget {
  @override
  _UserTimedInTodayState createState() => _UserTimedInTodayState();
}

class _UserTimedInTodayState extends State<UserTimedInToday> {
  late Stream<QuerySnapshot> _userRecordsStream;

  bool table = false;

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
          'Attendace Overview',
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
                  shape: RoundedRectangleBorder(),
                ),
                onPressed: () {
                  setState(() {
                    table = false;
                  });
                },
                child: Text(
                  ' Time In ',
                  style: TextStyle(
                      color: table == false ? Colors.white : Colors.black),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      table == true ? Colors.teal.shade700 : Colors.white,
                  padding: EdgeInsets.all(5),
                  shape: RoundedRectangleBorder(),
                ),
                onPressed: () {
                  setState(() {
                    table = true;
                  });
                },
                child: Text(
                  ' Time Out ',
                  style: TextStyle(
                      color: table == true ? Colors.white : Colors.black),
                ),
              ),
            ],
          )
        ],
      ),
      body: table == false ? TimeInTable() : TimeoutTable(),
    );
  }

  StreamBuilder<QuerySnapshot<Object?>> TimeoutTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _userRecordsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
            child: Text('No users timed in today.'),
          );
        }

        final List<DocumentSnapshot> documents = snapshot.data!.docs;
        final int rowsPerPage = 10; // Number of rows per page

        return Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            child: DataTable(
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
                    'Time-Out',
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
                documents.length,
                (index) {
                  final document = documents[index];
                  return DataRow(
                    cells: [
                      DataCell(Text('#')),
                      DataCell(Text(document['userName'].toString())),
                      DataCell(Text(_formatTimestamp(
                          snapshot.data!.docs[index]['timeOut']))),
                      DataCell(Text(document['department'].toString())),
                    ],
                  );
                },
              ),
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
            child: Text('No users timed in today.'),
          );
        }

        return Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: SingleChildScrollView(
              child: DataTable(
                // rowsPerPage: _rowsPerPage, // Remove this line
                // onSelectAll: (isSelected) {}, // Remove this line
                // source: _UserRecordsDataSource(snapshot.data!.docs), // Remove this line
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
                      DataCell(Text('#')),
                      DataCell(Text(snapshot.data!.docs[index]['userName'])),
                      DataCell(Text(_formatTimestamp(
                          snapshot.data!.docs[index]['timeIn']))),
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
