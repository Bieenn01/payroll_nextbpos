import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegularOT extends StatefulWidget {
  const RegularOT({Key? key}) : super(key: key);

  @override
  State<RegularOT> createState() => _RegularOTState();
}

class _RegularOTState extends State<RegularOT> {
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
        title: Text('Regular Overtime'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('Overtime').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available yet'));
          } else {
            List<DocumentSnapshot> overtimeDocs = snapshot.data!.docs;
            return SingleChildScrollView(
              // Wrap with SingleChildScrollView
              scrollDirection: Axis.horizontal, // Allowing horizontal scroll
              child: DataTable(
                columns: [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Department')),
                  DataColumn(label: Text('Overtime Minute')),
                  DataColumn(label: Text('Overtime Hours')),
                  DataColumn(label: Text('Overtime Pay')),
                  DataColumn(label: Text('Overtime Type')),
                ],
                rows: List.generate(overtimeDocs.length, (index) {
                  DocumentSnapshot overtimeDoc = overtimeDocs[index];
                  Map<String, dynamic> overtimeData =
                      overtimeDoc.data() as Map<String, dynamic>;
                  _selectedOvertimeTypes
                      .add('Regular'); // Initialize with 'Regular'
                  return DataRow(cells: [
                    DataCell(Text(overtimeDoc.id)),
                    DataCell(
                      Text(overtimeData['userName'] ?? 'Not Available Yet'),
                    ),
                    DataCell(
                      Text(overtimeData['department'] ?? 'Not Available Yet'),
                    ),
                    DataCell(
                      Text(overtimeData['hours_overtime']?.toString() ??
                          'Not Available Yet'),
                    ),
                    DataCell(
                      Text(overtimeData['hours_minute']?.toString() ??
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
                            // Move to SpecialHolidayOT collection
                            await moveRecordToSpecialHolidayOT(overtimeDoc);
                            // Delete from Overtime collection
                            await deleteRecordFromOvertime(overtimeDoc);
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

  Future<void> moveRecordToSpecialHolidayOT(
      DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          overtimeDoc.data() as Map<String, dynamic>;
      // Add to SpecialHolidayOT collection
      await FirebaseFirestore.instance
          .collection('SpecialHolidayOT')
          .add(overtimeData);
    } catch (e) {
      print('Error moving record to SpecialHolidayOT collection: $e');
    }
  }

  Future<void> deleteRecordFromOvertime(DocumentSnapshot overtimeDoc) async {
    try {
      // Delete from Overtime collection
      await overtimeDoc.reference.delete();
    } catch (e) {
      print('Error deleting record from Overtime collection: $e');
    }
  }
}
