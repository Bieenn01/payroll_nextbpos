import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package

class Logs extends StatefulWidget {
  @override
  _LogsState createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  late Stream<QuerySnapshot> _userRecordsStream;
  late int _perPage;
  late int _currentPage;
  late int _totalPages;

  @override
  void initState() {
    super.initState();
    _perPage = 5; // Set initial records per page
    _currentPage = 1;
    _fetchUserRecords();
  }

  void _fetchUserRecords() {
    _userRecordsStream = FirebaseFirestore.instance
        .collection('Records')
        .orderBy('timeIn', descending: true)
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

          List<DocumentSnapshot> allDocs = snapshot.data!.docs;
          _totalPages = (allDocs.length / _perPage).ceil();
          List<DocumentSnapshot> currentPageDocs = allDocs
              .skip((_currentPage - 1) * _perPage)
              .take(_perPage)
              .toList();

          return Column(
            children: [
              DataTable(
                columns: [
                  DataColumn(label: Text('User Name')),
                  DataColumn(label: Text('Time In')),
                  DataColumn(label: Text('Time Out')),
                  DataColumn(label: Text('Department')),
                ],
                rows: currentPageDocs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  return DataRow(cells: [
                    DataCell(Text(data['userName'] ?? 'Unknown')),
                    DataCell(Text(_formatTimestamp(data['timeIn']))),
                    DataCell(Text(_formatTimestamp(data['timeOut']))),
                    DataCell(Text(data['department'] ?? 'Unknown')),
                  ]);
                }).toList(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: _currentPage == 1
                        ? null
                        : () {
                            setState(() {
                              _currentPage--;
                            });
                          },
                  ),
                  Text('Page $_currentPage of $_totalPages'),
                  IconButton(
                    icon: Icon(Icons.arrow_forward),
                    onPressed: _currentPage == _totalPages
                        ? null
                        : () {
                            setState(() {
                              _currentPage++;
                            });
                          },
                  ),
                ],
              ),
            ],
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