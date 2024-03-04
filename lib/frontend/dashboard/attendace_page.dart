import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late Future<List<DocumentSnapshot>> _userRecordsFuture;
  TextEditingController _searchController = TextEditingController();
  String _selectedDepartment = '';
  int _itemsPerPage = 5;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserRecords();
  }

  Future<void> _fetchUserRecords() async {
    _userRecordsFuture = FirebaseFirestore.instance
        .collection('Records')
        .orderBy('timeIn', descending: true)
        .get()
        .then((querySnapshot) => querySnapshot.docs);
  }

  DateTime? _startDate;
  DateTime? _endDate;

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
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(_startDate!)
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
                      child: FutureBuilder<List<DocumentSnapshot>>(
                        future: _userRecordsFuture,
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
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Text('No user records available.'),
                            );
                          }

                          var filteredDocs = snapshot.data!.where((document) {
                            String userName =
                                (document.data() as Map)['userName'];
                            String query = _searchController.text.toLowerCase();
                            String department =
                                (document.data() as Map)['department'] ?? '';
                            return userName.toLowerCase().contains(query) &&
                                (_selectedDepartment.isEmpty ||
                                    department == _selectedDepartment);
                          }).toList();

                          int startIndex = _currentPage * _itemsPerPage;
                          int endIndex = startIndex + _itemsPerPage;
                          if (endIndex > filteredDocs.length) {
                            endIndex = filteredDocs.length;
                          }
                          List<DocumentSnapshot> pageItems =
                              filteredDocs.sublist(startIndex, endIndex);

                          return ListView.builder(
                            itemCount: pageItems.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    DropdownButton<int>(
                                      value: _itemsPerPage,
                                      items: [
                                        5,
                                        10,
                                        15,
                                        20,
                                        25
                                      ].map<DropdownMenuItem<int>>((int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text('$value'),
                                        );
                                      }).toList(),
                                      onChanged: (int? newValue) {
                                        setState(() {
                                          _itemsPerPage = newValue!;
                                        });
                                      },
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (_currentPage > 0) {
                                          setState(() {
                                            _currentPage--;
                                          });
                                        }
                                      },
                                      icon: Icon(Icons.arrow_back),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        if (_currentPage <
                                            (filteredDocs.length /
                                                        _itemsPerPage)
                                                    .ceil() -
                                                1) {
                                          setState(() {
                                            _currentPage++;
                                          });
                                        }
                                      },
                                      icon: Icon(Icons.arrow_forward),
                                    ),
                                  ],
                                );
                              } else {
                                int dataIndex = index - 1;
                                Map<String, dynamic> data = pageItems[dataIndex]
                                    .data() as Map<String, dynamic>;
                                return DataTable(
                                  columns: [
                                    ColumnInput('Username'),
                                    ColumnInput('Time in'),
                                    ColumnInput('Time out'),
                                    ColumnInput('Department')
                                  ],
                                  rows: [
                                    DataRow(cells: [
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
                                          child: Text(
                                              _formatTimestamp(data['timeIn'])),
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
                                          child: Text(
                                              data['department'] ?? 'Unknown'),
                                        ),
                                      ),
                                    ])
                                  ],
                                );
                              }
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

DataColumn ColumnInput(String label) {
  return DataColumn(
      label: Text(
    label,
    style: const TextStyle(
      fontWeight: FontWeight.w900,
    ),
  ));
}
