import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SpecialHolidayPage extends StatefulWidget {
  const SpecialHolidayPage({Key? key}) : super(key: key);

  @override
  State<SpecialHolidayPage> createState() => _SpecialHolidayPageState();
}

class _SpecialHolidayPageState extends State<SpecialHolidayPage> {
  late List<String> _selectedHolidayTypes;
  TextEditingController _searchController = TextEditingController();
  int _itemsPerPage = 5;
  int _currentPage = 0;
  int indexRow = 0;

  DateTime? fromDate;
  DateTime? toDate;
  bool endPicked = false;
  bool startPicked = false;

  @override
  void initState() {
    super.initState();
    _selectedHolidayTypes = [];
  }

  @override
  Widget build(BuildContext context) {
    var styleFrom = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      padding: EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
    return Scaffold(
        body: Center(
      child: Container(
        color: Colors.teal.shade700,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
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
                              "Special Holiday",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      dateFilterSearchRow(context, styleFrom),
                      Divider(),
                      _buildTable(),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 5),
                      pagination(),
                      SizedBox(height: 20),
                    ],
                  )),
            ),
          ],
        ),
      ),
    ));
  }

  Row pagination() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text('Previous'),
      ),
      SizedBox(width: 10),
      Container(
          height: 35,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200)),
          child: Text('$_currentPage')),
      SizedBox(width: 10),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text('Next'),
      ),
    ]);
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
                    child: Row(
                      children: [
                        Text('Show entries: '),
                        Container(
                          width: 70,
                          height: 30,
                          padding: EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200)),
                          child: DropdownButton<int>(
                            padding: EdgeInsets.all(5),
                            underline: SizedBox(),
                            value: _itemsPerPage,
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
                                _itemsPerPage = newValue!;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ),
                  Flexible(
                    child: ElevatedButton(
                      onPressed: () async {
                        await _computeAndAddSpecialHolidayPay();
                      },
                      child: Text('Compute All'),
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
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width > 600
                                ? 150
                                : 80,
                            padding: EdgeInsets.all(2),
                            child: ElevatedButton(
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: fromDate ?? DateTime.now(),
                                  firstDate: DateTime(2015, 8),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null && picked != fromDate) {
                                  setState(() {
                                    fromDate = picked;
                                    startPicked = true;
                                  });
                                }
                              },
                              style: styleFrom,
                              child: MediaQuery.of(context).size.width > 600
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'From: ',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              fromDate != null
                                                  ? DateFormat('yyyy-MM-dd')
                                                      .format(fromDate!)
                                                  : 'Select Date',
                                              style: TextStyle(
                                                  color: startPicked == !true
                                                      ? Colors.black
                                                      : Colors.teal.shade800),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        const Icon(
                                          Icons.calendar_month,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ],
                                    )
                                  : const Icon(
                                      Icons.calendar_month,
                                      color: Colors.black,
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width > 600
                                ? 150
                                : 50,
                            padding: EdgeInsets.all(2),
                            child: ElevatedButton(
                              onPressed: () async {
                                final DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: toDate ?? DateTime.now(),
                                  firstDate: DateTime(2015, 8),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null && picked != toDate) {
                                  setState(() {
                                    toDate = picked;
                                    endPicked = true;
                                  });
                                }
                              },
                              style: styleFrom,
                              child: MediaQuery.of(context).size.width > 600
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            const Text(
                                              'To: ',
                                              style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Text(
                                              toDate != null
                                                  ? DateFormat('yyyy-MM-dd')
                                                      .format(toDate!)
                                                  : 'Select Date',
                                              style: TextStyle(
                                                  color: endPicked == !true
                                                      ? Colors.black
                                                      : Colors.teal.shade800),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        const Icon(
                                          Icons.calendar_month,
                                          color: Colors.black,
                                          size: 20,
                                        ),
                                      ],
                                    )
                                  : const Icon(
                                      Icons.calendar_month,
                                      color: Colors.black,
                                    ),
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

  Widget _buildTable() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('SpecialHoliday').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available yet'));
        } else {
          List<DocumentSnapshot> holidayDocs = snapshot.data!.docs;

          holidayDocs = holidayDocs.where((doc) {
            DateTime timeIn = doc['timeIn'].toDate();
            DateTime timeOut = doc['timeOut'].toDate();
            if (fromDate != null && toDate != null) {
              return timeIn.isAfter(fromDate!) &&
                  timeOut.isBefore(toDate!.add(Duration(
                      days: 1))); // Adjusted toDate to include end of the day
            } else if (fromDate != null) {
              return timeIn.isAfter(fromDate!);
            } else if (toDate != null) {
              return timeOut.isBefore(toDate!.add(Duration(
                  days: 1))); // Adjusted toDate to include end of the day
            }
            return true;
          }).toList();
          if (_searchController.text.isNotEmpty) {
            String searchText = _searchController.text.toLowerCase();
            holidayDocs = holidayDocs.where((doc) {
              String employeeId = doc['employeeId'].toString().toLowerCase();
              String userName = doc['userName'].toString().toLowerCase();
              return employeeId.contains(searchText) ||
                  userName.contains(searchText);
            }).toList();
          }
          // Sort documents by timestamp in descending order
          holidayDocs.sort((a, b) {
            Timestamp aTimestamp = a['timeIn'];
            Timestamp bTimestamp = b['timeIn'];
            return bTimestamp.compareTo(aTimestamp);
          });
          // Sort the documents by timestamp in descending order
          holidayDocs.sort((a, b) =>
              (b['timeIn'] as Timestamp).compareTo(a['timeIn'] as Timestamp));

          const textStyle = TextStyle(fontWeight: FontWeight.bold);

          return SizedBox(
            height: 600,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('#', style: textStyle)),
                  DataColumn(label: Text('ID', style: textStyle)),
                  DataColumn(label: Text('Name', style: textStyle)),
                  DataColumn(label: Text('Department', style: textStyle)),
                  DataColumn(
                      label: Text('Total Hours (h:m)', style: textStyle)),
                  DataColumn(label: Text('Holiday Pay', style: textStyle)),
                  DataColumn(label: Text('Holiday Type', style: textStyle)),
                  DataColumn(label: Text('Action', style: textStyle))
                ],
                rows: List.generate(holidayDocs.length, (index) {
                  DocumentSnapshot holidayDoc = holidayDocs[index];
                  Map<String, dynamic> holidayData =
                      holidayDoc.data() as Map<String, dynamic>;
                  _selectedHolidayTypes.add('Special Holiday');

                  Color? rowColor = indexRow % 2 == 0
                      ? Colors.white
                      : Colors.grey[200]; // Alternating row colors
                  indexRow++; //

                  return DataRow(
                      color:
                          MaterialStateColor.resolveWith((states) => rowColor!),
                      cells: [
                        DataCell(Text('#')),
                        DataCell(Text(holidayData['employeeId'])),
                        DataCell(Text(
                            holidayData['userName'] ?? 'Not Available Yet')),
                        DataCell(Text(
                            holidayData['department'] ?? 'Not Available Yet')),
                        DataCell(
                          Container(
                            width: 100,
                            decoration:
                                BoxDecoration(color: Colors.amber.shade200),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  child: Row(
                                    children: [
                                      Text(
                                        holidayData['regular_hours']
                                                ?.toString() ??
                                            'Not Available Yet',
                                        style: textStyle,
                                      ),
                                      Text(':'),
                                      Text(
                                        holidayData['regular_minute']
                                                ?.toString() ??
                                            '0',
                                        style: textStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        DataCell(
                          Text(NumberFormat.currency(
                                  locale: 'en_PH',
                                  symbol: '₱ ',
                                  decimalDigits: 2)
                              .format(holidayData['holidayPay'] ?? 0.0)),
                        ),
                        DataCell(
                          DropdownButton<String>(
                            value: _selectedHolidayTypes[index],
                            items: <String>[
                              'Special Holiday',
                              'Regular Holiday',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) async {
                              if (newValue == 'Regular Holiday') {
                                await _showConfirmationDialog2(holidayDoc);
                              }
                              setState(() {
                                _selectedHolidayTypes[index] = newValue!;
                              });
                              if (newValue == 'Special Holiday') {
                                //   await _showConfirmationDialog2(holidayDoc);
                              }
                              setState(() {
                                _selectedHolidayTypes[index] = newValue!;
                              });
                            },
                          ),
                        ),
                        DataCell(
                          Row(children: [
                            IconButton(
                              icon: Icon(Icons.delete,
                                  color: Colors.red), // Setting color to red
                              onPressed: () async {
                                await _showConfirmationDialog3(holidayDoc);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.visibility,
                                  color: Colors.blue), // Setting color to red
                              onPressed: () async {
                                await _showConfirmationDialog4(holidayDoc);
                              },
                            ),
                          ]),
                        ),
                      ]);
                }),
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _selectDate2(BuildContext context, bool isFromDate) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isFromDate) {
          fromDate = pickedDate;
        } else {
          toDate = pickedDate;
        }
      });
    }
  }

  Future<void> _showConfirmationDialog4(DocumentSnapshot overtimeDoc) async {
    String userId = overtimeDoc['userId'];
    QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
        .collection('SpecialHoliday')
        .where('userId', isEqualTo: userId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Special Holiday Logs'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Employee ID', overtimeDoc['employeeId']),
                _buildInfoRow(
                    'Name', overtimeDoc['userName'] ?? 'Not Available'),
                _buildInfoRow(
                    'Department', overtimeDoc['department'] ?? 'Not Available'),
                SizedBox(height: 10),
                _buildOvertimeTable(userOvertimeDocs),
              ],
            ),
          ),
          actions: <Widget>[
//             TextButton(
//               child: Text('Total Holiday Pay'),
//               onPressed: () async {
//                 try {
//                   // Show a loading indicator
//                   showDialog(
//                     context: context,
//                     barrierDismissible: false,
//                     builder: (BuildContext context) {
//                       return Center(
//                         child: CircularProgressIndicator(),
//                       );
//                     },
//                   );

//                   // Delay Firestore operations by a very short duration
//                   await Future.delayed(Duration(milliseconds: 10));

//                   // Calculate total overtime pay
//                   double totalspecialholidayPay = 0;
//                   for (var holidayDoc in userOvertimeDocs) {
//                     if (holidayDoc['holidayPay'] != null) {
//                       totalspecialholidayPay += holidayDoc['holidayPay'];
//                     }
//                   }

//                   // Update total_overtimePay in the Overtime collection
//                   // Update total_overtimePay in the Overtime collection
//                   DocumentReference userOvertimeDocRef = FirebaseFirestore
//                       .instance
//                       .collection('SpecialHolidayPay')
//                       .doc(userId);

// // Get user details
//                   final userDoc = await FirebaseFirestore.instance
//                       .collection('User')
//                       .doc(userId)
//                       .get();
//                   final userData = userDoc.data() as Map<String, dynamic>;

// // Check if the document exists
//                   var docSnapshot = await userOvertimeDocRef.get();
//                   if (docSnapshot.exists) {
//                     // If the document exists, update it
//                     await userOvertimeDocRef.update({
//                       'total_specialHolidayPay': totalspecialholidayPay,
//                       'employeeId': userData['employeeId'],
//                       'userName':
//                           '${userData['fname']} ${userData['mname']} ${userData['lname']}',
//                       'department': userData['department'],
//                     });
//                   } else {
//                     // If the document doesn't exist, create a new one
//                     await userOvertimeDocRef.set({
//                       'total_specialHolidayPay': totalspecialholidayPay,
//                       'userId': userId,
//                       'employeeId': userData['employeeId'],
//                       'userName':
//                           '${userData['fname']} ${userData['mname']} ${userData['lname']}',
//                       'department': userData['department'],
//                     });
//                   }

//                   // Dismiss the loading indicator
//                   Navigator.of(context).pop();

//                   // Dismiss the dialog
//                   Navigator.of(context).pop();
//                 } catch (e) {
//                   // Handle any errors
//                   print('Error updating total overtime pay: $e');
//                   // Dismiss the loading indicator
//                   Navigator.of(context).pop();
//                   // Show an error message
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) {
//                       return AlertDialog(
//                         title: Text('Error'),
//                         content: Text(
//                             'Failed to update total overtime pay. Please try again.'),
//                         actions: [
//                           TextButton(
//                             child: Text('OK'),
//                             onPressed: () {
//                               Navigator.of(context).pop();
//                             },
//                           ),
//                         ],
//                       );
//                     },
//                   );
//                 }
//               },
//             ),
            TextButton(
              child: Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildOvertimeTable(List<DocumentSnapshot> overtimeDocs) {
    // Sort documents by timestamp in descending order
    overtimeDocs.sort((a, b) {
      Timestamp aTimestamp = a['timeIn'];
      Timestamp bTimestamp = b['timeIn'];
      return bTimestamp.compareTo(aTimestamp);
    });

    int index = 0;
    return Container(
      height: 300,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: DataTable(
        columns: const [
          DataColumn(
              label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label:
                  Text('Date', style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Time In',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Time Out',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
              label: Text('Total Hours (h:m)',
                  style: TextStyle(fontWeight: FontWeight.bold))),
          DataColumn(
            label: Text('Holiday Pay'),
          ),
        ],
        rows: overtimeDocs.map((overtimeDoc) {
          Color? rowColor = index % 2 == 0
              ? Colors.grey[200]
              : Colors.transparent; // Alternating row colors
          index++;
          return DataRow(
              color: MaterialStateColor.resolveWith((states) => rowColor!),
              cells: [
                DataCell(Text('#')),
                DataCell(Text(_formatDate(overtimeDoc['timeIn']))),
                DataCell(Text(_formatTime(overtimeDoc['timeIn']))),
                DataCell(Text(_formatTime(overtimeDoc['timeOut']))),
                DataCell(Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      child: Row(
                        children: [
                          Text(
                              overtimeDoc['regular_hours']?.toString() ??
                                  'Not Available Yet',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(':'),
                          Text(
                              overtimeDoc['regular_minute']?.toString() ??
                                  'Not Available Yet',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )
                  ],
                )),
                DataCell(
                  Text(overtimeDoc['holidayPay'].toString()),
                ),
              ]);
        }).toList(),
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MMMM d, yyyy').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('HH:mm:ss').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label + ':', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Future<void> deleteRecordFromHoliday(DocumentSnapshot holidayDoc) async {
    try {
      await holidayDoc.reference.delete();
    } catch (e) {
      print('Error deleting record from Overtime collection: $e');
    }
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

  Future<void> _showConfirmationDialog2(DocumentSnapshot holidayDoc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to proceed?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                await moveRecordToRegularHoliday(holidayDoc);
                await deleteRecordFromHoliday(holidayDoc);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> moveRecordToRegularHoliday(DocumentSnapshot holidayDoc) async {
    try {
      if (holidayDoc.exists) {
        Map<String, dynamic> holidayData = Map<String, dynamic>.from(
            holidayDoc.data() as Map<String, dynamic>);

        final monthlySalary = holidayData['monthly_salary'];
        final minute = holidayData['regular_minute'];
        final specialHolidayRate = 0.3;
        final daysInMonth = 22;

        if (monthlySalary != null && minute != null) {
          // Set specialHolidayPay
          holidayData['holidayPay'] =
              (monthlySalary / daysInMonth / 8 * minute * specialHolidayRate);

          // Add to SpecialHoliday collection
          await FirebaseFirestore.instance
              .collection('Holiday')
              .add(holidayData);

          // Delete the record from Holiday collection
          await deleteRecordFromHoliday(holidayDoc);
        } else {
          print('Monthly salary or minute data is null');
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error moving record to SpecialHoliday collection: $e');
    }
  }

  Future<void> deleteRecordFromOvertime(DocumentSnapshot overtimeDoc) async {
    try {
      await overtimeDoc.reference.delete();
    } catch (e) {
      print('Error deleting record from Overtime collection: $e');
    }
  }

  Future<void> _showConfirmationDialog3(DocumentSnapshot overtimeDoc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmation'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to proceed?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                await deleteRecordFromOvertime(overtimeDoc);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _computeAndAddSpecialHolidayPay() async {
    try {
      // Get the list of all users from Firestore
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('User').get();

      // Loop through each user
      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;

        // Fetch all overtime records for the current user
        QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
            .collection('SpecialHoliday')
            .where('userId', isEqualTo: userId)
            .get();

        // List to store overtime documents
        List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

        // Calculate total overtime pay for the current user
        double totalspecialholidayPay = 0;
        for (var overtimeDoc in userOvertimeDocs) {
          if (overtimeDoc['holidayPay'] != null) {
            totalspecialholidayPay += overtimeDoc['holidayPay'];
          }
        }

        // Get user details
        final userData = userDoc.data() as Map<String, dynamic>;

        // Update total_overtimePay in the OvertimePay collection
        DocumentReference userOvertimeDocRef = FirebaseFirestore.instance
            .collection('SpecialHolidayPay')
            .doc(userId);

        // Check if the document exists
        var docSnapshot = await userOvertimeDocRef.get();
        if (docSnapshot.exists) {
          // If the document exists, update it
          await userOvertimeDocRef.update({
            'total_specialHolidayPay': totalspecialholidayPay,
            'employeeId': userData['employeeId'],
            'userName':
                '${userData['fname']} ${userData['mname']} ${userData['lname']}',
            'department': userData['department'],
          });
        } else {
          // If the document doesn't exist, create a new one
          await userOvertimeDocRef.set({
            'total_specialHolidayPay': totalspecialholidayPay,
            'userId': userId,
            'employeeId': userData['employeeId'],
            'userName':
                '${userData['fname']} ${userData['mname']} ${userData['lname']}',
            'department': userData['department'],
          });
        }
      }
      // Show a success message
      print('Total overtime pay computed and added to OvertimePay collection');
    } catch (e) {
      // Handle any errors
      print('Error computing and adding to OvertimePay collection: $e');
    }
  }
}
