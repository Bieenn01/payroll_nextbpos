import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RegularOT extends StatefulWidget {
  const RegularOT({Key? key}) : super(key: key);

  @override
  State<RegularOT> createState() => _RegularOTState();
}

class _RegularOTState extends State<RegularOT> {
  late List<String> _selectedOvertimeTypes;
  DateTime? fromDate;
  DateTime? toDate;

  @override
  void initState() {
    super.initState();
    _selectedOvertimeTypes = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Regular Overtime'),
      ),
      body: Column(
        children: [
          _buildDateFilter(),
          Expanded(child: _buildOvertimeDataTable()),
        ],
      ),
    );
  }

  Widget _buildDateFilter() {
    return Row(
      children: [
        ElevatedButton(
          onPressed: () => _selectDate(context, true),
          child: Text(fromDate != null
              ? DateFormat('yyyy-MM-dd').format(fromDate!)
              : 'From'),
        ),
        ElevatedButton(
          onPressed: () => _selectDate(context, false),
          child: Text(
              toDate != null ? DateFormat('yyyy-MM-dd').format(toDate!) : 'To'),
        ),
        ElevatedButton(
          onPressed: () => setState(() {
            fromDate = null;
            toDate = null;
          }),
          child: Text('Show All'),
        ),
      ],
    );
  }

  Widget _buildOvertimeDataTable() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Overtime').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available yet'));
        } else {
          List<DocumentSnapshot> overtimeDocs = snapshot.data!.docs;

          // Filtering based on date range
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

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text('ID')),
                DataColumn(label: Text('Name')),
                DataColumn(label: Text('Department')),
                DataColumn(label: Text('Time In')),
                DataColumn(label: Text('Time Out')),
                DataColumn(label: Text('Overtime Hours')),
                DataColumn(label: Text('Overtime Minute')),
                DataColumn(label: Text('Overtime Pay')),
                DataColumn(label: Text('Overtime Type')),
                DataColumn(label: Text('Action')),
              ],
              rows: List.generate(overtimeDocs.length, (index) {
                DocumentSnapshot overtimeDoc = overtimeDocs[index];
                Map<String, dynamic> overtimeData =
                    overtimeDoc.data() as Map<String, dynamic>;
                _selectedOvertimeTypes.add('Regular');
                return DataRow(cells: [
                  DataCell(Text(overtimeDoc.id)),
                  DataCell(
                    Text(overtimeData['userName'] ?? 'Not Available Yet'),
                  ),
                  DataCell(
                    Text(overtimeData['department'] ?? 'Not Available Yet'),
                  ),
                  DataCell(
                    Text((_formatTimestamp(overtimeData['timeIn']))),
                  ),
                  DataCell(
                    Text((_formatTimestamp(overtimeData['timeOut']))),
                  ),
                  DataCell(
                    Text(overtimeData['hours_overtime']?.toString() ??
                        'Not Available Yet'),
                  ),
                  DataCell(
                    Text(overtimeData['minute_overtime']?.toString() ??
                        'Not Available Yet'),
                  ),
                  DataCell(
                    Text(overtimeData['overtimePay']?.toString() ??
                        'Not Available Yet'),
                  ),
                  DataCell(
                    DropdownButton<String>(
                      value: _selectedOvertimeTypes[index],
                      items: <String>[
                        'Regular',
                        'Special Holiday OT',
                        'Regular Holiday OT',
                        'Rest day OT'
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) async {
                        if (newValue == 'Special Holiday OT') {
                          await _showConfirmationDialog(overtimeDoc);
                        }
                        setState(() {
                          _selectedOvertimeTypes[index] = newValue!;
                        });
                        if (newValue == 'Regular Holiday OT') {
                          await _showConfirmationDialog2(overtimeDoc);
                        }
                        setState(() {
                          _selectedOvertimeTypes[index] = newValue!;
                        });
                        if (newValue == 'Rest day OT') {
                          await _showConfirmationDialog3(overtimeDoc);
                        }
                        setState(() {
                          _selectedOvertimeTypes[index] = newValue!;
                        });
                      },
                    ),
                  ),
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.visibility,
                          color: Colors.blue), // Setting color to red
                      onPressed: () async {
                        await _showConfirmationDialog4(overtimeDoc);
                      },
                    ),
                  ),
                ]);
              }),
            ),
          );
        }
      },
    );
  }

  Future<void> moveRecordToSpecialHolidayOT(
      DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      final monthlySalary = overtimeData['monthly_salary'];
      final overtimeMinute = overtimeData['minute_overtime'];
      final overtimeRate = 1.95;
      final daysInMonth = 22;

      // Set overtimePay to null
      overtimeData['overtimePay'] =
          (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);
      //dri ibutang ang formula para mapasa dayon didto paglahos
      // Add to SpecialHolidayOT collection
      await FirebaseFirestore.instance
          .collection('SpecialHolidayOT')
          .add(overtimeData);
    } catch (e) {
      print('Error moving record to SpecialHolidayOT collection: $e');
    }
  }

  Future<void> moveRecordToRegularHolidayOT(
      DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      final monthlySalary = overtimeData['monthly_salary'];
      final overtimeMinute = overtimeData['minute_overtime'];
      final overtimeRate = 2.6;
      final daysInMonth = 22;

      // Set overtimePay to null
      overtimeData['overtimePay'] =
          (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);
      //dri ibutang ang formula para mapasa dayon didto paglahos
      // Add to SpecialHolidayOT collection
      await FirebaseFirestore.instance
          .collection('RegularHolidayOT')
          .add(overtimeData);
    } catch (e) {
      print('Error moving record to SpecialHolidayOT collection: $e');
    }
  }

  Future<void> moveRecordToRestdayOT(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      final monthlySalary = overtimeData['monthly_salary'];
      final overtimeMinute = overtimeData['minute_overtime'];
      final overtimeRate = 1.69;
      final daysInMonth = 22;

      // Set overtimePay to null
      overtimeData['overtimePay'] =
          (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);
      //dri ibutang ang formula para mapasa dayon didto paglahos
      // Add to SpecialHolidayOT collection
      await FirebaseFirestore.instance
          .collection('RestdayOT')
          .add(overtimeData);
    } catch (e) {
      print('Error moving record to SpecialHolidayOT collection: $e');
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
                await moveRecordToSpecialHolidayOT(overtimeDoc);
                await deleteRecordFromOvertime(overtimeDoc);
              },
            ),
          ],
        );
      },
    );
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
                await moveRecordToRegularHolidayOT(overtimeDoc);
                await deleteRecordFromOvertime(overtimeDoc);
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
                await moveRecordToRestdayOT(overtimeDoc);
                await deleteRecordFromOvertime(overtimeDoc);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context, bool isFromDate) async {
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
        .collection('Overtime')
        .where('userId', isEqualTo: userId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Regular Overtime Logs'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('ID', userId),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label + ':', style: TextStyle(fontWeight: FontWeight.bold)),
        Text(value),
      ],
    );
  }

  Widget _buildOvertimeTable(List<DocumentSnapshot> overtimeDocs) {
    // Sort documents by timestamp in descending order
    overtimeDocs.sort((a, b) {
      Timestamp aTimestamp = a['timeIn'];
      Timestamp bTimestamp = b['timeIn'];
      return bTimestamp.compareTo(aTimestamp);
    });

    return DataTable(
      columns: [
        DataColumn(label: Text('Date')),
        DataColumn(label: Text('Time In')),
        DataColumn(label: Text('Time Out')),
        DataColumn(label: Text('Overtime Hours')),
        DataColumn(label: Text('Overtime Minutes')),
      ],
      rows: overtimeDocs.map((overtimeDoc) {
        return DataRow(cells: [
          DataCell(Text(_formatDate(overtimeDoc['timeIn']))),
          DataCell(Text(_formatTime(overtimeDoc['timeIn']))),
          DataCell(Text(_formatTime(overtimeDoc['timeOut']))),
          DataCell(Text(overtimeDoc['hours_overtime']?.toString() ??
              'Not Available Yet')),
          DataCell(Text(overtimeDoc['minute_overtime']?.toString() ??
              'Not Available Yet')),
        ]);
      }).toList(),
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
}
