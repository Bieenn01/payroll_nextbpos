import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RegularOTPage extends StatefulWidget {
  const RegularOTPage({Key? key}) : super(key: key);

  @override
  State<RegularOTPage> createState() => _RegularOTPageState();
}

class _RegularOTPageState extends State<RegularOTPage> {
  late List<String> _selectedOvertimeTypes;
  TextEditingController _searchController = TextEditingController();
  int _itemsPerPage = 5;
  int _currentPage = 0;
  int indexRow = 0;

  @override
  void initState() {
    super.initState();
    _selectedOvertimeTypes = [];
  }

  DateTime? fromDate;
  DateTime? toDate;

  bool endPicked = false;
  bool startPicked = false;

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
                                "Regular Overtime",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        searchFilter(context, styleFrom),
                        Divider(),
                        dataTable(),
                        SizedBox(height: 10),
                        Divider(),
                        SizedBox(height: 5),
                        Pagination(),
                        SizedBox(height: 20),
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

  Row Pagination() {
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

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> dataTable() {
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
          const textStyle = TextStyle(fontWeight: FontWeight.bold);

          return SizedBox(
            height: 600,
            child: SingleChildScrollView(
              child: Flexible(
                child: DataTable(
                  columns: const [
                    DataColumn(
                        label: Flexible(child: Text('#', style: textStyle))),
                    DataColumn(
                        label: Flexible(
                      child: Text('Employee ID', style: textStyle),
                    )),
                    DataColumn(
                        label: Flexible(child: Text('Name', style: textStyle))),
                    DataColumn(
                        label: Flexible(
                      child: Text('Department', style: textStyle),
                    )),
                    DataColumn(
                        label: Flexible(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text('Overtime Hours',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                          Text('(h:m)',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    )),
                    DataColumn(
                        label: Flexible(
                      child: Text('Overtime Pay', style: textStyle),
                    )),
                    DataColumn(
                        label: Flexible(
                      child: Text('Overtime Type', style: textStyle),
                    )),
                    DataColumn(
                        label: Flexible(
                      child: Text('Action', style: textStyle),
                    )),
                  ],
                  rows: List.generate(overtimeDocs.length, (index) {
                    DocumentSnapshot overtimeDoc = overtimeDocs[index];
                    Map<String, dynamic> overtimeData =
                        overtimeDoc.data() as Map<String, dynamic>;
                    _selectedOvertimeTypes.add(
                      'Regular',
                    );

                    Color? rowColor = indexRow % 2 == 0
                        ? Colors.white
                        : Colors.grey[200]; // Alternating row colors
                    indexRow++; //

                    return DataRow(
                        color: MaterialStateColor.resolveWith(
                            (states) => rowColor!),
                        cells: [
                          DataCell(
                            Text('#'),
                          ),
                          DataCell(
                            Text(overtimeData['employeeId'] ??
                                'Not Available Yet'),
                          ),
                          DataCell(
                            Text(overtimeData['userName'] ??
                                'Not Available Yet'),
                          ),
                          DataCell(
                            Text(overtimeData['department'] ??
                                'Not Available Yet'),
                          ),
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
                                          overtimeData['hours_overtime']
                                                  ?.toString() ??
                                              'Not Available Yet',
                                          style: textStyle,
                                        ),
                                        Text(':'),
                                        Text(
                                          overtimeData['minute_overtime']
                                                  ?.toString() ??
                                              'Not Available Yet',
                                          style: textStyle,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          DataCell(Text(NumberFormat.currency(
                                  locale: 'en_PH',
                                  symbol: '₱ ',
                                  decimalDigits: 2)
                              .format(overtimeData['overtimePay'] ?? 0.0))),
                          DataCell(
                            SizedBox(
                              width: 100,
                              height: 40,
                              child: FittedBox(
                                fit: BoxFit.fill,
                                child: DropdownButton<String>(
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                  value: _selectedOvertimeTypes[index],
                                  items: <String>[
                                    'Regular',
                                    'Special Holiday OT',
                                    'Regular Holiday OT',
                                    'Rest day OT'
                                  ].map<DropdownMenuItem<String>>(
                                      (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) async {
                                    if (newValue == 'Special Holiday OT') {
                                      await _showConfirmationDialog(
                                          overtimeDoc);
                                    }
                                    setState(() {
                                      _selectedOvertimeTypes[index] = newValue!;
                                    });
                                    if (newValue == 'Regular Holiday OT') {
                                      await _showConfirmationDialog2(
                                          overtimeDoc);
                                    }
                                    setState(() {
                                      _selectedOvertimeTypes[index] = newValue!;
                                    });
                                    if (newValue == 'Rest day OT') {
                                      await _showConfirmationDialog3(
                                          overtimeDoc);
                                    }
                                    setState(() {
                                      _selectedOvertimeTypes[index] = newValue!;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              width: 100,
                              padding: EdgeInsets.all(0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await _showConfirmationDialog4(overtimeDoc);
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.all(5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Icon(
                                      Icons.visibility,
                                      color: Colors.blue,
                                      size: 15,
                                    ),
                                    Text(
                                      'View Logs',
                                      style: TextStyle(
                                          fontSize: 10, color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]);
                  }),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Container searchFilter(BuildContext context, ButtonStyle styleFrom) {
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
                          child: ElevatedButton(
                            onPressed: () async {
                              await _computeAndAddToOvertimePay();
                            },
                            child: Text('Compute and Add to Overtime Pay'),
                          ),
                        ),
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

  Future<void> _calculateTotalOvertimePay(DocumentSnapshot overtimeDoc) async {
    String userId = overtimeDoc['userId'];
    QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
        .collection('Overtime')
        .where('userId', isEqualTo: userId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;
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
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Regular Overtime Logs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(
                    Icons.close,
                    size: 15,
                  )),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Employee ID', userId),
                _buildInfoRow(
                    'Name', overtimeDoc['userName'] ?? 'Not Available'),
                _buildInfoRow(
                    'Department', overtimeDoc['department'] ?? 'Not Available'),
                Divider(),
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
    int index = 0;

    return DataTable(
      columns: const [
        DataColumn(
            label: Text(
          'Date',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label:
                Text('Time In', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Time Out',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
          label: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Total Hours',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Center(child: Text('(h:m)'))
            ],
          ),
        ),
        DataColumn(
          label: Text('Overtime Pay'),
        ),
      ],
      rows: overtimeDocs.map((overtimeDoc) {
        Color? rowColor = index % 2 == 0
            ? Colors.grey[200]
            : Colors.transparent; // Alternating row colors
        index++; //
        return DataRow(
            color: MaterialStateColor.resolveWith((states) => rowColor!),
            cells: [
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
                            overtimeDoc['hours_overtime']?.toString() ??
                                'Not Available Yet',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(':'),
                        Text(
                            overtimeDoc['minute_overtime']?.toString() ??
                                'Not Available Yet',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                ],
              )),
              DataCell(
                Text(overtimeDoc['overtimePay'].toString()),
              ),
            ]);
      }).toList(),
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

  Future<void> _computeAndAddToOvertimePay() async {
    try {
      // Get the list of all users from Firestore
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('User').get();

      // Loop through each user
      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;

        // Fetch all overtime records for the current user
        QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
            .collection('Overtime')
            .where('userId', isEqualTo: userId)
            .get();

        // List to store overtime documents
        List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

        // Calculate total overtime pay for the current user
        double totalOvertimePay = 0;
        for (var overtimeDoc in userOvertimeDocs) {
          if (overtimeDoc['overtimePay'] != null) {
            totalOvertimePay += overtimeDoc['overtimePay'];
          }
        }

        // Get user details
        final userData = userDoc.data() as Map<String, dynamic>;

        // Update total_overtimePay in the OvertimePay collection
        DocumentReference userOvertimeDocRef =
            FirebaseFirestore.instance.collection('OvertimePay').doc(userId);

        // Check if the document exists
        var docSnapshot = await userOvertimeDocRef.get();
        if (docSnapshot.exists) {
          // If the document exists, update it
          await userOvertimeDocRef.update({
            'total_overtimePay': totalOvertimePay,
            'employeeId': userData['employeeId'],
            'userName':
                '${userData['fname']} ${userData['mname']} ${userData['lname']}',
            'department': userData['department'],
          });
        } else {
          // If the document doesn't exist, create a new one
          await userOvertimeDocRef.set({
            'total_overtimePay': totalOvertimePay,
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
