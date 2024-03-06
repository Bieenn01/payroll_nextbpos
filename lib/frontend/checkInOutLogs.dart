import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package

class Logs extends StatefulWidget {
  @override
  _LogsState createState() => _LogsState();
}

class _LogsState extends State<Logs> {
  late Stream<QuerySnapshot> _userRecordsStream;
  TextEditingController _searchController = TextEditingController();
  String _selectedDepartment = '';
  DateTime? _startDate;
  DateTime? _endDate;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Logs'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  width: 500,
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  height: 35,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search User Name',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
                SizedBox(width: 20),
                Text('From:'),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _startDate ?? DateTime.now(),
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != _startDate) {
                      setState(() {
                        _startDate = picked;
                      });
                    }
                  },
                  child: Text(_startDate != null
                      ? DateFormat('yyyy-MM-dd').format(_startDate!)
                      : 'Select Date'),
                ),
                SizedBox(width: 20),
                Text('To:'),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _endDate ?? DateTime.now(),
                      firstDate: DateTime(2015, 8),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null && picked != _endDate) {
                      setState(() {
                        _endDate = picked;
                      });
                    }
                  },
                  child: Text(_endDate != null
                      ? DateFormat('yyyy-MM-dd').format(_endDate!)
                      : 'Select Date'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _startDate = null;
                      _endDate = null;
                    });
                  },
                  child: Text('Show All Data'),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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

                var filteredDocs = snapshot.data!.docs.where((document) {
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String userName = data['userName'];
                  String query = _searchController.text.toLowerCase();
                  String department = data['department'] ?? '';
                  DateTime? timeIn = (data['timeIn'] as Timestamp?)?.toDate();
                  return userName.toLowerCase().contains(query) &&
                      (_selectedDepartment.isEmpty ||
                          department == _selectedDepartment) &&
                      (_startDate == null || timeIn!.isAfter(_startDate!)) &&
                      (_endDate == null ||
                          timeIn!.isBefore(_endDate!.add(Duration(days: 1))));
                }).toList();

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    alignment: Alignment.topLeft, // Set alignment to top left
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('User Name')),
                        DataColumn(label: Text('Time In')),
                        DataColumn(label: Text('Time Out')),
                        DataColumn(label: Text('Department')),
                      ],
                      rows: filteredDocs.map((DocumentSnapshot document) {
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MMMM dd, yyyy HH:mm:ss').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }
}
