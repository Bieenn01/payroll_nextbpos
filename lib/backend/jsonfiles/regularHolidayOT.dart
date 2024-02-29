import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RegularHolidayOT extends StatefulWidget {
  const RegularHolidayOT({Key? key}) : super(key: key);

  @override
  State<RegularHolidayOT> createState() => _RegularHolidayOT();
}

class _RegularHolidayOT extends State<RegularHolidayOT> {
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
        title: Text('Regular Holiday Overtime'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('RegularHolidayOT')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available yet'));
          } else {
            List<DocumentSnapshot> overtimeDocs = snapshot.data!.docs;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Time in')),
                  DataColumn(label: Text('Time Out')),
                  DataColumn(label: Text('Overtime Hours')),
                  DataColumn(label: Text('Overtime Minute')),
                  DataColumn(label: Text('Overtime Pay')),
                  DataColumn(label: Text('Overtime Type')),
                ],
                rows: List.generate(overtimeDocs.length, (index) {
                  DocumentSnapshot overtimeDoc = overtimeDocs[index];
                  Map<String, dynamic> overtimeData =
                      overtimeDoc.data() as Map<String, dynamic>;
                  _selectedOvertimeTypes.add('Regular');
                  FutureBuilder<double>(
                    future: calculateRegularHolidayOT(
                      overtimeData['userId'],
                      Duration(
                        hours: overtimeData['hours_overtime'],
                        minutes: overtimeData['minute_overtime'],
                      ),
                    ),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                            'Calculating...'); // Or any loading indicator
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        double overtimePay = snapshot.data ??
                            0; // Use snapshot.data, default to 0 if null
                        return Text(overtimePay.toStringAsFixed(2));
                      }
                    },
                  );

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
                          'Not Available'),
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
                          if (newValue == 'Regular') {
                            await moveRecordToRegularOT(overtimeDoc);
                            await deleteRecordFromSpecialOT(overtimeDoc);
                          }
                          setState(() {
                            _selectedOvertimeTypes[index] = newValue!;
                          });
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

  Future<double> calculateRegularHolidayOT(
    String userId,
    Duration duration,
  ) async {
    final daysInMonth = 22;
    final overTimeRate = 1.95;

    final daysWorked = duration.inDays;
    final overtimeHours = duration.inMinutes - 1 - (daysWorked * 8);

    try {
      var userData =
          await FirebaseFirestore.instance.collection('User').doc(userId).get();
      double? monthlySalary = userData.data()?['monthly_salary'];

      if (monthlySalary == null) {
        // Return 0 if monthlySalary is null
        return 0;
      }

      double specialHolidayOTPay = 0;

      if (duration.inMinutes > 1) {
        specialHolidayOTPay =
            (monthlySalary / daysInMonth / 8 * overtimeHours * overTimeRate);
      }

      return specialHolidayOTPay;
    } catch (error) {
      print('Error retrieving monthly salary: $error');
      return 0;
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

  Future<void> moveRecordToRegularOT(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      final monthlySalary = overtimeData['monthly_salary'];
      final overtimeMinute = overtimeData['minute_overtime'];
      final overtimeRate = 1.25;
      final daysInMonth = 22;

      // Set overtimePay to null
      overtimeData['overtimePay'] =
          (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);
      //dri ibutang ang formula para mapasa dayon didto paglahos
      // Add to SpecialHolidayOT collection
      await FirebaseFirestore.instance.collection('Overtime').add(overtimeData);
    } catch (e) {
      print('Error moving record to SpecialHolidayOT collection: $e');
    }
  }

  Future<void> deleteRecordFromSpecialOT(DocumentSnapshot overtimeDoc) async {
    try {
      await overtimeDoc.reference.delete();
    } catch (e) {
      print('Error deleting record from Overtime collection: $e');
    }
  }
}
