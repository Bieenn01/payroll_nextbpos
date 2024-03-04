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
  int index2 = 0;

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
                Expanded(
                  child: Container(
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
                ),
                SizedBox(width: 20),
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
                  String userName = (document.data() as Map)['userName'];
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
                        DataColumn(label: Text('User Name')),
                        DataColumn(label: Text('Time In')),
                        DataColumn(label: Text('Time Out')),
                        DataColumn(label: Text('Department')),
                      ],
                      rows: filteredDocs.map((DocumentSnapshot document) {
                        Map<String, dynamic> data =
                            document.data() as Map<String, dynamic>;
                        Color? rowColor = index2 % 2 == 0
                            ? Colors.white
                            : Colors.grey[200]; // Alternating row colors
                        index2++; //
                        return DataRow(
                            color: MaterialStateColor.resolveWith(
                                (states) => rowColor!),
                            cells: [
                              DataCell(
                                Container(
                                  width: 100, // Adjust the width as needed
                                  child: Text(data['userName'] ?? 'Unknown'),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 150, // Adjust the width as needed
                                  child: Text(_formatTimestamp(data['timeIn'])),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 150, // Adjust the width as needed
                                  child:
                                      Text(_formatTimestamp(data['timeOut'])),
                                ),
                              ),
                              DataCell(
                                Container(
                                  width: 100, // Adjust the width as needed
                                  child: Text(data['department'] ?? 'Unknown'),
                                ),
                              ),
                            ]);
                      }).toList(),
                    );
                  },
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
      return DateFormat('MMMM dd, yyyy HH:mm:ss:a').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }
}
