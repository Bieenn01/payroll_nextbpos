import 'dart:html';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class UserListScreen extends StatefulWidget {
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  bool _showFilterCategory = false;
  int _rowsPerPage = 5; // Default number of rows per page
  int _currentPage = 0; // Current page number

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(() {
      setState(() {
        _showFilterCategory = _searchFocusNode.hasFocus;
      });
    });
  }

  Widget build(BuildContext context) {
    var styleFrom = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      padding: EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    List<Map<String, dynamic>> _pagedData = [];

    void _updatePagedData(List<DocumentSnapshot> documents) {
      _pagedData = documents
          .skip(_currentPage * _rowsPerPage)
          .take(_rowsPerPage)
          .map((document) => document.data() as Map<String, dynamic>)
          .toList();
    }

    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.teal.shade700,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(15, 5, 15, 15),
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Leave Records",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        dateFilterSearchRow(context, styleFrom),
                        StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('User')
                              .where('role', whereIn: [
                                'Employee',
                                'Admin'
                              ]) // Filter by role
                              .orderBy('fname')
                              .snapshots(), // Ordering by fname
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            if (snapshot.hasError) {
                              return Center(
                                  child: Text('Error: ${snapshot.error}'));
                            }

                            if (snapshot.hasData &&
                                snapshot.data!.docs.isEmpty) {
                              return Center(child: Text('No users found'));
                            } else {
                              List<DocumentSnapshot> leaveDocs =
                                  snapshot.data!.docs;

                              List<DocumentSnapshot> filteredDocs =
                                  leaveDocs.where((document) {
                                Map<String, dynamic> data =
                                    document.data() as Map<String, dynamic>;
                                String fname = data['fname'];
                                String mname = data['mname'];
                                String name = data['lname'];
                                String id = data['employeeId'];

                                String department = data['department'] ?? '';
                                DateTime? timeIn =
                                    (data['timeIn'] as Timestamp?)?.toDate();

                                String query =
                                    _searchController.text.toLowerCase();
                                bool matchesSearchQuery =
                                    id.toLowerCase().contains(query) ||
                                        fname.toLowerCase().contains(query) ||
                                        mname.toLowerCase().contains(query) ||
                                        name.toLowerCase().contains(query);

                                return matchesSearchQuery;
                              }).toList();

                              return DataTable(
                                columns: const [
                                  DataColumn(
                                      label: Text('#',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('ID',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Department',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Role',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Action',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                ],
                                rows: List<DataRow>.generate(
                                    filteredDocs.length, (index) {
                                  DocumentSnapshot document =
                                      filteredDocs[index];
                                  Map<String, dynamic> data =
                                      document.data() as Map<String, dynamic>;

                                  Color? color = index % 2 == 0
                                      ? Colors.grey[200]
                                      : Colors.white;

                                  return DataRow(
                                      color: MaterialStateColor.resolveWith(
                                          (states) => color!),
                                      cells: [
                                        DataCell(Text('${index + 1}')),
                                        DataCell(Text(
                                            data['employeeId'] ?? 'Unknown')),
                                        DataCell(Text(
                                            '${data['fname'] ?? 'Unknown'} ${data['mname'] ?? 'Unknown'} ${data['lname'] ?? 'Unknown'}')),
                                        DataCell(Text(
                                            data['department'] ?? 'Unknown')),
                                        DataCell(
                                            Text(data['role'] ?? 'Unknown')),
                                        DataCell(
                                          Container(
                                            width: 80,
                                            padding: EdgeInsets.all(0),
                                            child: ElevatedButton(
                                              onPressed: () {
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return UserLeaveRequests(
                                                      userID: document.id,
                                                      employeeId:
                                                          data['employeeId'],
                                                      role: data['role'],
                                                      maxLeaveDays: {
                                                        'Leave with Pay': 15,
                                                        'Leave Without Pay': 30,
                                                        'Sick Leave': 10,
                                                        'Vacation Leave': 6,
                                                        'Maternity Leave': 90,
                                                        'OBL - Official Business Leave':
                                                            40
                                                      },
                                                    );
                                                  },
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                padding: EdgeInsets.all(5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                              child: const Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Icon(
                                                    Icons.visibility,
                                                    color: Colors.blue,
                                                    size: 18,
                                                  ),
                                                  Text(
                                                    'View',
                                                    style: TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.blue),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ]);
                                }).toList(),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container dateFilterSearchRow(BuildContext context, ButtonStyle styleFrom) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: MediaQuery.of(context).size.width > 600
                        ? Row(
                            children: [
                              Text('Show entries: '),
                              Container(
                                width: 70,
                                height: 30,
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey.shade200)),
                                child: DropdownButton<int>(
                                  padding: EdgeInsets.all(5),
                                  underline: SizedBox(),
                                  value: _rowsPerPage,
                                  items: [5, 10, 15, 20, 25]
                                      .map<DropdownMenuItem<int>>(
                                    (int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text('$value'),
                                      );
                                    },
                                  ).toList(),
                                  onChanged: (int? value) {
                                    setState(() {
                                      _rowsPerPage = value!;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          )
                        : DropdownButton<int>(
                            padding: EdgeInsets.all(5),
                            underline: SizedBox(),
                            items:
                                [5, 10, 15, 20, 25].map<DropdownMenuItem<int>>(
                              (int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value'),
                                );
                              },
                            ).toList(),
                            onChanged: (int? newValue) {
                              setState(() {
                                //_itemsPerPage = newValue!;
                              });
                            },
                          ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width > 600
                                ? 400
                                : 100,
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
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 5),
        ],
      ),
    );
  }
}

class UserLeaveRequests extends StatefulWidget {
  final String userID;
  final String employeeId;
  final String role;
  final Map<String, int> maxLeaveDays;

  const UserLeaveRequests({
    Key? key,
    required this.userID,
    required this.employeeId,
    required this.role,
    required this.maxLeaveDays,
  }) : super(key: key);

  @override
  _UserLeaveRequestsState createState() => _UserLeaveRequestsState();
}

class _UserLeaveRequestsState extends State<UserLeaveRequests> {
  bool _showDataTable = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      surfaceTintColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('View Leave Records'),
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('leaveRequests')
                  .where('userID', isEqualTo: widget.userID)
                  .where('status', isEqualTo: 'Approved')
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                  return Center(child: Text(''));
                }

                // Assuming you want to display the fullName of the first document
                // If there are multiple documents, you may need to loop through them
                var fullName = 'N/A';
                var department = 'N/A';

                var documents = snapshot.data!.docs;
                if (documents.isNotEmpty) {
                  var data = documents[0].data() as Map<String, dynamic>;
                  fullName = data['fullName'] ?? 'N/A';
                  department = data['department'] ?? 'N/A';
                }

                return Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: widget.role == 'Admin'
                                ? AssetImage('assets/images/Admin.jpg')
                                : widget.role == 'Superadmin'
                                    ? AssetImage('assets/images/SAdmin.jpg')
                                    : AssetImage('assets/images/Employee.jpg'),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(widget.employeeId,
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              Text("$fullName"),
                              Text('$department Department')
                            ],
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _showDataTable = !_showDataTable;
                          });
                        },
                        child: _showDataTable
                            ? Text('Hide Logs')
                            : Text('View Logs'),
                      ),
                    ],
                  ),
                );
              },
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('leaveRequests')
                    .where('userID', isEqualTo: widget.userID)
                    .where('status', isEqualTo: 'Approved') // Filter by status
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  if (snapshot.hasData && snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No leave requests found'));
                  }

                  // Calculate leave type counts
                  final leaveTypeCounts =
                      calculateLeaveTypeCounts(snapshot.data!.docs);

                  var dataTable = DataTable(
                    columns: const [
                      DataColumn(
                          label: Text('#',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Leave Type',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Start Leave',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('End Leave',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Description',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Date Submitted',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Status',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: List<DataRow>.generate(snapshot.data!.docs.length,
                        (index) {
                      DocumentSnapshot document = snapshot.data!.docs[index];
                      Map<String, dynamic> data =
                          document.data() as Map<String, dynamic>;

                      Color? color =
                          index % 2 == 0 ? Colors.grey[200] : Colors.white;

                      return DataRow(
                        color:
                            MaterialStateColor.resolveWith((states) => color!),
                        cells: [
                          DataCell(Text('${index + 1}')),
                          DataCell(Text(data['leaveType'] ?? 'N/A')),
                          DataCell(Text(DateFormat('MM-dd-yyyy HH:mm').format(
                              (data['startLeave'] as Timestamp).toDate()))),
                          DataCell(Text(DateFormat('MM-dd-yyyy HH:mm').format(
                              (data['endLeave'] as Timestamp).toDate()))),
                          DataCell(Text(data['description'] ?? 'N/A')),
                          DataCell(Text(DateFormat('MM-dd-yyyy').format(
                              (data['datesubmitted'] as Timestamp).toDate()))),
                          DataCell(Text(data['status'] ?? 'N/A')),
                        ],
                      );
                    }).toList(),
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Divider(),
                      SizedBox(
                        height: 10,
                      ),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.maxLeaveDays.entries
                                .take(3)
                                .map((entry) => Expanded(
                                      flex: 1,
                                      child: _buildLeaveTypeCountCard(entry,
                                          leaveTypeCounts), // You need to pass the actual leaveTypeCounts
                                    ))
                                .toList(),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.maxLeaveDays.entries
                                .skip(3)
                                .take(3)
                                .map((entry) => Expanded(
                                      flex: 1,
                                      child: _buildLeaveTypeCountCard(entry,
                                          leaveTypeCounts), // You need to pass the actual leaveTypeCounts
                                    ))
                                .toList(),
                          ),
                        ],
                      ),
                      Divider(),
                      _showDataTable
                          ? MediaQuery.of(context).size.width > 1500
                              ? SizedBox(
                                  height: 350,
                                  child: SingleChildScrollView(
                                    child: Flexible(
                                      child: dataTable,
                                    ),
                                  ),
                                )
                              : SizedBox(
                                  height: 350,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.vertical,
                                      child: Flexible(
                                        child: dataTable,
                                      ),
                                    ),
                                  ),
                                )
                          : Container(),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }

  // Calculate leave type counts
  Map<String, int> calculateLeaveTypeCounts(
      List<QueryDocumentSnapshot> documents) {
    final Map<String, int> leaveTypeCounts = {};

    final currentYear = DateTime.now().year; // Get the current year

    documents.forEach((document) {
      final leaveType = document['leaveType'];
      final datesubmitted = (document['datesubmitted'] as Timestamp).toDate();
      final submissionYear = datesubmitted.year;

      // Check if the submission year matches the current year
      if (submissionYear == currentYear) {
        if (leaveType.isNotEmpty) {
          // Exclude empty leave types
          final startLeave = (document['startLeave'] as Timestamp).toDate();
          final endLeave = (document['endLeave'] as Timestamp).toDate();
          final daysDifference = endLeave.difference(startLeave).inDays;
          leaveTypeCounts[leaveType] =
              (leaveTypeCounts[leaveType] ?? 0) + daysDifference;
        }
      }
    });

    return leaveTypeCounts;
  }

  Widget _buildLeaveTypeCountCard(
      MapEntry<String, int> entry, Map<String, int> leaveTypeCounts) {
    final leaveType = entry.key;
    final maxDays = entry.value;
    final count = leaveTypeCounts[leaveType] ?? 0;
    final remaining = maxDays - count;
    return Container(
      width: 250,
      margin: EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: LeaveTypeCountCard(
        leaveType: leaveType,
        count: count,
        maxLeaveDays: maxDays,
        remaining: remaining,
      ),
    );
  }
}

class LeaveTypeCountCard extends StatelessWidget {
  final String leaveType;
  final int count;
  final int maxLeaveDays;
  final int remaining;

  const LeaveTypeCountCard({
    Key? key,
    required this.leaveType,
    required this.count,
    required this.maxLeaveDays,
    required this.remaining,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$leaveType',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Count: $count'),
            Text('Max: $maxLeaveDays'),
            Text('Remaining: $remaining'),
          ],
        ),
      ),
    );
  }
}
