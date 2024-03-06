import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class SpecialHoliday extends StatefulWidget {
  const SpecialHoliday({Key? key}) : super(key: key);

  @override
  State<SpecialHoliday> createState() => _SpecialHolidayState();
}

class _SpecialHolidayState extends State<SpecialHoliday> {
  late List<String> _selectedHolidayTypes;

  @override
  void initState() {
    super.initState();
    _selectedHolidayTypes = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Special Holiday'),
      ),
      body: StreamBuilder(
        stream:
            FirebaseFirestore.instance.collection('SpecialHoliday').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available yet'));
          } else {
            List<DocumentSnapshot> holidayDocs = snapshot.data!.docs;
            // Sort the documents by timestamp in descending order
            holidayDocs.sort((a, b) =>
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
                  DataColumn(label: Text('Holiday Type')),
                  DataColumn(label: Text('Action'))
                ],
                rows: List.generate(holidayDocs.length, (index) {
                  DocumentSnapshot holidayDoc = holidayDocs[index];
                  Map<String, dynamic> holidayData =
                      holidayDoc.data() as Map<String, dynamic>;
                  _selectedHolidayTypes.add('Special Holiday');
                  return DataRow(cells: [
                    DataCell(Text(holidayDoc.id)),
                    DataCell(
                        Text(holidayData['userName'] ?? 'Not Available Yet')),
                    DataCell(
                        Text(holidayData['department'] ?? 'Not Available Yet')),
                    DataCell(Text(_formatTimestamp(holidayData['timeIn']))),
                    DataCell(Text(_formatTimestamp(holidayData['timeOut']))),
                    DataCell(Text(holidayData['regular_hours']?.toString() ??
                        'Not Available Yet')),
                    DataCell(Text(holidayData['regular_minute']?.toString() ??
                        'Not Available Yet')),
                    DataCell(
                      Text(
                        holidayData['holidayPay']?.toString() ??
                            'Not Available Yet',
                      ),
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
                      IconButton(
                        icon: Icon(Icons.delete,
                            color: Colors.red), // Setting color to red
                        onPressed: () async {
                          await _showConfirmationDialog3(holidayDoc);
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
}
