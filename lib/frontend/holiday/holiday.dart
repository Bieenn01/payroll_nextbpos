import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class HolidayPage extends StatefulWidget {
  const HolidayPage({Key? key}) : super(key: key);

  @override
  State<HolidayPage> createState() => _HolidayPageState();
}

class _HolidayPageState extends State<HolidayPage> {
  late List<String> _selectedOvertimeTypes;
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
    _selectedOvertimeTypes = [];
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
                              "Holiday Overtime",
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

  Widget _buildTable() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Holiday').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available yet'));
        } else {
          List<DocumentSnapshot> overtimeDocs = snapshot.data!.docs;
          overtimeDocs = overtimeDocs.where((doc) {
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

          // Sort documents by timestamp in descending order
          overtimeDocs.sort((a, b) {
            Timestamp aTimestamp = a['timeIn'];
            Timestamp bTimestamp = b['timeIn'];
            return bTimestamp.compareTo(aTimestamp);
          });
          // Sort the documents by timestamp in descending order
          overtimeDocs.sort((a, b) =>
              (b['timeIn'] as Timestamp).compareTo(a['timeIn'] as Timestamp));

          const textStyle = TextStyle(fontWeight: FontWeight.bold);
          return Container(
            height: 600,
            child: SingleChildScrollView(
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('#', style: textStyle)),
                  DataColumn(label: Text('Employee ID', style: textStyle)),
                  DataColumn(label: Text('Name', style: textStyle)),
                  DataColumn(label: Text('Department', style: textStyle)),
                  DataColumn(
                      label: Text('Total Hours (h:m)', style: textStyle)),
                  DataColumn(label: Text('Holiday Pay', style: textStyle)),
                  DataColumn(label: Text('Holiday Type', style: textStyle)),
                  DataColumn(label: Text('Action', style: textStyle)),
                ],
                rows: List.generate(overtimeDocs.length, (index) {
                  DocumentSnapshot overtimeDoc = overtimeDocs[index];
                  Map<String, dynamic> overtimeData =
                      overtimeDoc.data() as Map<String, dynamic>;
                  _selectedOvertimeTypes.add('Regular Holiday');
                  Color? rowColor = indexRow % 2 == 0
                      ? Colors.white
                      : Colors.grey[200]; // Alternating row colors
                  indexRow++; //

                  return DataRow(
                      color:
                          MaterialStateColor.resolveWith((states) => rowColor!),
                      cells: [
                        DataCell(Text('#')),
                        DataCell(Text(overtimeDoc.id)),
                        DataCell(Text(
                            overtimeData['userName'] ?? 'Not Available Yet')),
                        DataCell(Text(
                            overtimeData['department'] ?? 'Not Available Yet')),
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
                                        overtimeData['regular_hours']
                                                ?.toString() ??
                                            'Not Available Yet',
                                        style: textStyle,
                                      ),
                                      Text(':'),
                                      Text(
                                        overtimeData['regular_minute']
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
                              .format(overtimeData['holidayPay'] ?? 0.0)),
                        ),
                        DataCell(
                          DropdownButton<String>(
                            value: _selectedOvertimeTypes[index],
                            items: <String>[
                              'Regular Holiday',
                              'Special Holiday',
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) async {
                              if (newValue == 'Special Holiday') {
                                await _showConfirmationDialog(overtimeDoc);
                              }
                              setState(() {
                                _selectedOvertimeTypes[index] = newValue!;
                              });
                              if (newValue == 'Regular Holiday') {
                                await _showConfirmationDialog2(overtimeDoc);
                              }
                              setState(() {
                                _selectedOvertimeTypes[index] = newValue!;
                              });
                            },
                          ),
                        ),
                        DataCell(
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.delete,
                                    color: Colors.red), // Setting color to red
                                onPressed: () async {
                                  await _showConfirmationDialog3(overtimeDoc);
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.visibility,
                                    color: Colors.blue), // Setting color to red
                                onPressed: () async {
                                  await _showConfirmationDialog4(overtimeDoc);
                                },
                              ),
                            ],
                          ),
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

  Future<void> moveRecordToSpecialHoliday(DocumentSnapshot overtimeDoc) async {
    try {
      if (overtimeDoc.exists) {
        Map<String, dynamic> overtimeData = Map<String, dynamic>.from(
            overtimeDoc.data() as Map<String, dynamic>);

        // Check if all required fields are present
        if (overtimeData.containsKey('monthly_salary') &&
            overtimeData.containsKey('regular_minute')) {
          final monthlySalary = overtimeData['monthly_salary'];
          final overtimeMinute = overtimeData['regular_minute'];
          final overtimeRate = 1.0;
          final daysInMonth = 22;

          // Set holidayPay
          overtimeData['holidayPay'] =
              (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);

          // Add to SpecialHoliday collection
          await FirebaseFirestore.instance
              .collection('SpecialHoliday')
              .add(overtimeData);
        } else {
          print('Required fields are missing in the Firestore document');
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

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MMMM dd, yyyy HH:mm:ss').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  Future<void> _showConfirmationDialog(DocumentSnapshot overtimeDoc) async {
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
                await moveRecordToSpecialHoliday(overtimeDoc);
                await deleteRecordFromOvertime(overtimeDoc);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> updateHolidayPay(DocumentSnapshot overtimeDoc) async {
    try {
      if (overtimeDoc.exists) {
        Map<String, dynamic> overtimeData = Map<String, dynamic>.from(
            overtimeDoc.data() as Map<String, dynamic>);

        // Check if all required fields are present
        if (overtimeData.containsKey('monthly_salary') &&
            overtimeData.containsKey('regular_minute')) {
          final monthlySalary = overtimeData['monthly_salary'];
          final overtimeMinute = overtimeData['regular_minute'];
          final overtimeRate = 0.3;
          final daysInMonth = 22;

          // Update holidayPay
          double holidayPay =
              (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);
          await overtimeDoc.reference.update({'holidayPay': holidayPay});
        } else {
          print('Required fields are missing in the Firestore document');
        }
      } else {
        print('Document does not exist');
      }
    } catch (e) {
      print('Error updating holidayPay: $e');
    }
  }

  Future<void> _showConfirmationDialog2(DocumentSnapshot overtimeDoc) async {
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
                await updateHolidayPay(overtimeDoc);
              },
            ),
          ],
        );
      },
    );
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

  Future<void> _showConfirmationDialog4(DocumentSnapshot overtimeDoc) async {
    String userId = overtimeDoc['userId'];
    QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
        .collection('Holiday')
        .where('userId', isEqualTo: userId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Regular Holiday Logs'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Employee ID', userId),
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
        ],
        rows: overtimeDocs.map((overtimeDoc) {
          return DataRow(cells: [
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
          ]);
        }).toList(),
      ),
    );
  }

  String _formatTimestamp2(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MMMM dd, yyyy HH:mm:ss').format(dateTime);
    } else {
      return timestamp.toString();
    }
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label + ':', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }
}
