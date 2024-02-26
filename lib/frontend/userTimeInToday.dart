import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // Import the intl package

class UserTimedInToday extends StatefulWidget {
  @override
  _UserTimedInTodayState createState() => _UserTimedInTodayState();
}

class _UserTimedInTodayState extends State<UserTimedInToday> {
  late Stream<QuerySnapshot> _userRecordsStream;

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
        .orderBy('timeIn',
            descending: true) // Sort by timeIn in descending order
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Users Timed In Today'),
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
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              child: DataTable(
                columns: [
                  DataColumn(label: Text('User Name')),
                  DataColumn(label: Text('Time In')),
                  DataColumn(label: Text('Department')),
                ],
                rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  return DataRow(cells: [
                    DataCell(Text(data['userName'])),
                    DataCell(Text(_formatTimestamp(data['timeIn']))),
                    DataCell(Text(data['department'])),
                  ]);
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-------';

    // Check if timestamp is already a Timestamp object
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MMMM dd, yyyy HH:mm:ss').format(dateTime);
    } else {
      // If not a Timestamp object, assume it's a String and return as is
      return timestamp.toString();
    }
  }
}
