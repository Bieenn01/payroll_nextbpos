import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import the intl package

class UserListScreen extends StatefulWidget {
  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  Widget build(BuildContext context) {
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
                            }

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
                              rows: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data() as Map<String, dynamic>;
                                return DataRow(cells: [
                                  DataCell(Text('')),
                                  DataCell(
                                      Text(data['employeeId'] ?? 'Unknown')),
                                  DataCell(Text(
                                      '${data['fname'] ?? 'Unknown'} ${data['mname'] ?? 'Unknown'} ${data['lname'] ?? 'Unknown'}')),
                                  DataCell(
                                      Text(data['department'] ?? 'Unknown')),
                                  DataCell(Text(data['role'] ?? 'Unknown')),
                                  DataCell(
                                    Container(
                                      width: 80,
                                      padding: EdgeInsets.all(0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UserLeaveRequests(
                                                userID: document.id,
                                                maxLeaveDays: {
                                                  'Leave': 15,
                                                  'Leave Without Pay': 30,
                                                  'Sick Leave': 10,
                                                  'Vacation Leave': 6,
                                                  'Maternity Leave': 90,
                                                  'OBL - Official Business Leave':
                                                      40
                                                },
                                              ),
                                            ),
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
                                              MainAxisAlignment.spaceEvenly,
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
}

class UserLeaveRequests extends StatelessWidget {
  final String userID;
  final Map<String, int> maxLeaveDays;

  const UserLeaveRequests(
      {Key? key, required this.userID, required this.maxLeaveDays})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Leave Requests'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('leaveRequests')
            .where('userID', isEqualTo: userID)
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
          final leaveTypeCounts = calculateLeaveTypeCounts(snapshot.data!.docs);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DataTable(
                  columns: [
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Date Submitted')),
                    DataColumn(label: Text('Full Name')),
                    DataColumn(label: Text('Department')),
                    DataColumn(label: Text('Start Leave')),
                    DataColumn(label: Text('End Leave')),
                    DataColumn(label: Text('Leave Type')),
                    DataColumn(label: Text('Description')),
                  ],
                  rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                        document.data() as Map<String, dynamic>;
                    return DataRow(
                      cells: [
                        DataCell(Text(data['status'] ?? 'N/A')),
                        DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(
                            (data['datesubmitted'] as Timestamp).toDate()))),
                        DataCell(Text(data['fullName'] ?? 'N/A')),
                        DataCell(Text(data['department'] ?? 'N/A')),
                        DataCell(Text(DateFormat('yyyy-MM-dd HH:mm').format(
                            (data['startLeave'] as Timestamp).toDate()))),
                        DataCell(Text(DateFormat('yyyy-MM-dd HH:mm')
                            .format((data['endLeave'] as Timestamp).toDate()))),
                        DataCell(Text(data['leaveType'] ?? 'N/A')),
                        DataCell(Text(data['description'] ?? 'N/A')),
                      ],
                    );
                  }).toList(),
                ),
                SizedBox(height: 20),
                Text('Leave Records this year'),
                Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: maxLeaveDays.entries.map((entry) {
                      final leaveType = entry.key;
                      final maxDays = entry.value;
                      final count = leaveTypeCounts[leaveType] ?? 0;
                      final remaining = maxDays - count;
                      return LeaveTypeCountCard(
                        leaveType: leaveType,
                        count: count,
                        maxLeaveDays: maxDays,
                        remaining: remaining,
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        },
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Leave Type: $leaveType',
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
