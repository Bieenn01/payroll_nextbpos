import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class Holiday extends StatefulWidget {
  const Holiday({Key? key}) : super(key: key);

  @override
  State<Holiday> createState() => _HolidayState();
}

class _HolidayState extends State<Holiday> {
  late List<String> _selectedOvertimeTypes;

  @override
  void initState() {
    super.initState();
    _selectedOvertimeTypes = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Regular Holiday'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Holiday').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available yet'));
          } else {
            List<DocumentSnapshot> overtimeDocs = snapshot.data!.docs;
            // Sort the documents by timestamp in descending order
            overtimeDocs.sort((a, b) =>
                (b['timeIn'] as Timestamp).compareTo(a['timeIn'] as Timestamp));
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Time In')),
                  DataColumn(label: Text('Time Out')),
                  DataColumn(label: Text('Hours')),
                  DataColumn(label: Text('Minute')),
                  DataColumn(label: Text('Holiday Pay')),
                  DataColumn(label: Text('Overtime Type')),
                  DataColumn(label: Text('Action')),
                ],
                rows: List.generate(overtimeDocs.length, (index) {
                  DocumentSnapshot overtimeDoc = overtimeDocs[index];
                  Map<String, dynamic> overtimeData =
                      overtimeDoc.data() as Map<String, dynamic>;
                  _selectedOvertimeTypes.add('Regular Holiday');
                  return DataRow(cells: [
                    DataCell(Text(overtimeDoc.id)),
                    DataCell(
                        Text(overtimeData['userName'] ?? 'Not Available Yet')),
                    DataCell(Text(
                        overtimeData['department'] ?? 'Not Available Yet')),
                    DataCell(Text(_formatTimestamp(overtimeData['timeIn']))),
                    DataCell(Text(_formatTimestamp(overtimeData['timeOut']))),
                    DataCell(Text(overtimeData['regular_hours']?.toString() ??
                        'Not Available Yet')),
                    DataCell(Text(overtimeData['regular_minute']?.toString() ??
                        'Not Available Yet')),
                    DataCell(
                      Text(
                        overtimeData['holidayPay']?.toString() ??
                            'Not Available Yet',
                      ),
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
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: Colors.red), // Setting color to red
                        onPressed: () async {
                          await _showConfirmationDialog3(overtimeDoc);
                        },
                      ),
                    ),
                  ]);
                }),
              ),
            );
          }
        },
      ),
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
}
