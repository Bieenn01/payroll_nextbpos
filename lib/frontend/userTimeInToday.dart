import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:project_payroll_nextbpo/frontend/userTimeOutToday.dart';

class UserTimedInToday extends StatefulWidget {
  @override
  _UserTimedInTodayState createState() => _UserTimedInTodayState();
}

class _UserTimedInTodayState extends State<UserTimedInToday> {
  late Stream<QuerySnapshot> _userRecordsStream;
  final int _rowsPerPage = 5;
  int _selectedRowIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users Timed In Today'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserTimedOutToday(),
                ),
              );
            },
            child: Text('TimeOut'),
          )
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              child: PaginatedDataTable(
                rowsPerPage: _rowsPerPage,
                onSelectAll: (isSelected) {},
                source: _UserRecordsDataSource(snapshot.data!.docs),
                columns: const [
                  DataColumn(
                      label: Text(
                    'Name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'Time-In',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                  DataColumn(
                      label: Text(
                    'Department',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  )),
                ],
                onPageChanged: (newPage) {
                  setState(() {
                    _selectedRowIndex = newPage * _rowsPerPage;
                  });
                },
              ),
            ),
          );
        },
      ),
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
