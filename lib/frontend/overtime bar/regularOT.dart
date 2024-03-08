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

  @override
  void initState() {
    super.initState();
    _selectedOvertimeTypes = [];
  }

  DateTime? _startDate;
  DateTime? _endDate;

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
                      Container(
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
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade200)),
                                            child: DropdownButton<int>(
                                              padding: EdgeInsets.all(5),
                                              underline: SizedBox(),
                                              value: _itemsPerPage,
                                              items: [5, 10, 15, 20, 25]
                                                  .map<DropdownMenuItem<int>>(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      600
                                                  ? 400
                                                  : 50,
                                              height: 30,
                                              margin: EdgeInsets.fromLTRB(
                                                  5, 0, 0, 0),
                                              padding: EdgeInsets.fromLTRB(
                                                  3, 0, 0, 0),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color: Colors.black
                                                        .withOpacity(0.5)),
                                              ),
                                              child: TextField(
                                                controller: _searchController,
                                                textAlign: TextAlign.start,
                                                decoration:
                                                    const InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.only(
                                                          bottom: 15),
                                                  prefixIcon:
                                                      Icon(Icons.search),
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
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      600
                                                  ? 150
                                                  : 80,
                                              padding: EdgeInsets.all(2),
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  final DateTime? picked =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: _startDate ??
                                                        DateTime.now(),
                                                    firstDate:
                                                        DateTime(2015, 8),
                                                    lastDate: DateTime(2101),
                                                  );
                                                  if (picked != null &&
                                                      picked != _startDate) {
                                                    setState(() {
                                                      _startDate = picked;
                                                      startPicked = true;
                                                    });
                                                  }
                                                },
                                                style: styleFrom,
                                                child:
                                                    MediaQuery.of(context)
                                                                .size
                                                                .width >
                                                            600
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  const Text(
                                                                    'From: ',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  Text(
                                                                    _startDate !=
                                                                            null
                                                                        ? DateFormat('yyyy-MM-dd')
                                                                            .format(_startDate!)
                                                                        : 'Select Date',
                                                                    style: TextStyle(
                                                                        color: startPicked ==
                                                                                !true
                                                                            ? Colors.black
                                                                            : Colors.teal.shade800),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                width: 3,
                                                              ),
                                                              const Icon(
                                                                Icons
                                                                    .calendar_month,
                                                                color: Colors
                                                                    .black,
                                                                size: 20,
                                                              ),
                                                            ],
                                                          )
                                                        : const Icon(
                                                            Icons
                                                                .calendar_month,
                                                            color: Colors.black,
                                                          ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Flexible(
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      600
                                                  ? 150
                                                  : 50,
                                              padding: EdgeInsets.all(2),
                                              child: ElevatedButton(
                                                onPressed: () async {
                                                  final DateTime? picked =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: _endDate ??
                                                        DateTime.now(),
                                                    firstDate:
                                                        DateTime(2015, 8),
                                                    lastDate: DateTime(2101),
                                                  );
                                                  if (picked != null &&
                                                      picked != _endDate) {
                                                    setState(() {
                                                      _endDate = picked;
                                                      endPicked = true;
                                                    });
                                                  }
                                                },
                                                style: styleFrom,
                                                child:
                                                    MediaQuery.of(context)
                                                                .size
                                                                .width >
                                                            600
                                                        ? Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  const Text(
                                                                    'To: ',
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  ),
                                                                  Text(
                                                                    _endDate !=
                                                                            null
                                                                        ? DateFormat('yyyy-MM-dd')
                                                                            .format(_endDate!)
                                                                        : 'Select Date',
                                                                    style: TextStyle(
                                                                        color: endPicked ==
                                                                                !true
                                                                            ? Colors.black
                                                                            : Colors.teal.shade800),
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                width: 3,
                                                              ),
                                                              const Icon(
                                                                Icons
                                                                    .calendar_month,
                                                                color: Colors
                                                                    .black,
                                                                size: 20,
                                                              ),
                                                            ],
                                                          )
                                                        : const Icon(
                                                            Icons
                                                                .calendar_month,
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
                      ),
                      Divider(),
                      StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('Overtime')
                            .snapshots(),
                        builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (!snapshot.hasData) {
                            return Center(child: CircularProgressIndicator());
                          } else if (snapshot.data!.docs.isEmpty) {
                            return Center(child: Text('No data available yet'));
                          } else {
                            List<DocumentSnapshot> overtimeDocs =
                                snapshot.data!.docs;
                            // Sort documents by timestamp in descending order
                            overtimeDocs.sort((a, b) {
                              Timestamp aTimestamp = a['timeIn'];
                              Timestamp bTimestamp = b['timeIn'];
                              return bTimestamp.compareTo(aTimestamp);
                            });

                            const textStyle =
                                TextStyle(fontWeight: FontWeight.bold);

                            return SizedBox(
                              height: 600,
                              child: SingleChildScrollView(
                                child: DataTable(
                                  columns: const [
                                    DataColumn(
                                        label: Text('Employee ID',
                                            style: textStyle)),
                                    DataColumn(
                                        label: Text('Name', style: textStyle)),
                                    DataColumn(
                                        label: Text('Department',
                                            style: textStyle)),
                                    DataColumn(
                                        label: Text('Overtime Hours (h:m)',
                                            style: textStyle)),
                                    DataColumn(
                                        label: Text('Overtime Pay',
                                            style: textStyle)),
                                    DataColumn(
                                        label: Text('Overtime Type',
                                            style: textStyle)),
                                  ],
                                  rows: List.generate(overtimeDocs.length,
                                      (index) {
                                    DocumentSnapshot overtimeDoc =
                                        overtimeDocs[index];
                                    Map<String, dynamic> overtimeData =
                                        overtimeDoc.data()
                                            as Map<String, dynamic>;
                                    _selectedOvertimeTypes.add(
                                      'Regular',
                                    );
                                    return DataRow(cells: [
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
                                        Row(
                                          children: [
                                            Text(overtimeData['hours_overtime']
                                                    ?.toString() ??
                                                'Not Available Yet'),
                                            Text(':'),
                                            Text(overtimeData['minute_overtime']
                                                    ?.toString() ??
                                                'Not Available Yet'),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(NumberFormat.currency(
                                              locale: 'en_PH',
                                              symbol: '₱ ',
                                              decimalDigits: 2)
                                          .format(overtimeData['overtimePay'] ??
                                              0.0))),
                                      DataCell(
                                        DropdownButton<String>(
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
                                            if (newValue ==
                                                'Special Holiday OT') {
                                              await _showConfirmationDialog(
                                                  overtimeDoc);
                                            }
                                            setState(() {
                                              _selectedOvertimeTypes[index] =
                                                  newValue!;
                                            });
                                            if (newValue ==
                                                'Regular Holiday OT') {
                                              await _showConfirmationDialog2(
                                                  overtimeDoc);
                                            }
                                            setState(() {
                                              _selectedOvertimeTypes[index] =
                                                  newValue!;
                                            });
                                            if (newValue == 'Rest day OT') {
                                              await _showConfirmationDialog3(
                                                  overtimeDoc);
                                            }
                                            setState(() {
                                              _selectedOvertimeTypes[index] =
                                                  newValue!;
                                            });
                                          },
                                        ),
                                      ),
                                    ]);
                                  }),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(height: 10),
                      Divider(),
                      SizedBox(height: 5),
                      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                                border:
                                    Border.all(color: Colors.grey.shade200)),
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
                      ]),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
}
