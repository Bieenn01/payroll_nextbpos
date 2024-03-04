import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package

class Logs extends StatefulWidget {
  @override
  _Logs createState() => _Logs();
}

class _Logs extends State<Logs> {
  late Stream<QuerySnapshot> _userRecordsStream;
  int index = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserRecords();
  }

  void _fetchUserRecords() {
    _userRecordsStream = FirebaseFirestore.instance
        .collection('Records')
        .orderBy('timeIn',
            descending: true) // Sort by timeIn in descending order
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs'),
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
              child: Text('No user records available.'),
            );
          }
          return DataTable(
            columns: [
              DataColumn(label: Text('User Name')),
              DataColumn(label: Text('Time In')),
              DataColumn(label: Text('Time Out')),
              DataColumn(label: Text('Department')),
            ],
            rows: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              Color? rowColor = index % 2 == 0
                  ? Colors.white
                  : Colors.grey[200]; // Alternating row colors
              index++; //
              return DataRow(
                  color: MaterialStateColor.resolveWith((states) => rowColor!),
                  cells: [
                    DataCell(Text(data['userName'] ?? 'Unknown')),
                    DataCell(Text(_formatTimestamp(data['timeIn']))),
                    DataCell(Text(_formatTimestamp(data['timeOut']))),
                    DataCell(Text(data['department'] ?? 'Unknown')),
                  ]);
            }).toList(),
          );
        },
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    if (timestamp == null) return 'Not Available';
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMMM dd, yyyy HH:mm:ss').format(dateTime);
  }
}
