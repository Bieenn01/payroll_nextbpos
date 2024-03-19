import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart' as ShimmerPackage;

class RegularHolidayOTPage extends StatefulWidget {
  const RegularHolidayOTPage({Key? key}) : super(key: key);

  @override
  State<RegularHolidayOTPage> createState() => _RegularHolidayOTPage();
}

class _RegularHolidayOTPage extends State<RegularHolidayOTPage> {
  late List<String> _selectedOvertimeTypes;
  TextEditingController _searchController = TextEditingController();
  int _itemsPerPage = 5;
  int _currentPage = 0;
  int indexRow = 0;
  bool _sortAscending = false;

  bool sortPay = false;
  bool table = false;

  String selectedDepartment = 'All';

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
                                "Regular Holiday Overtime",
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

  Widget _buildTable() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('RegularHolidayOT').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return _buildShimmerLoading();
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
          if (_searchController.text.isNotEmpty) {
            String searchText = _searchController.text.toLowerCase();
            overtimeDocs = overtimeDocs.where((doc) {
              String employeeId = doc['employeeId'].toString().toLowerCase();
              String userName = doc['userName'].toString().toLowerCase();
              return employeeId.contains(searchText) ||
                  userName.contains(searchText);
            }).toList();
          }
          _sortAscending
              ? overtimeDocs.sort((a, b) {
                  double overtimePayA = a['overtimePay'] ?? 0.0;
                  double overtimePayB = b['overtimePay'] ?? 0.0;
                  return overtimePayA.compareTo(overtimePayB);
                })
              : overtimeDocs.sort((b, a) {
                  double overtimePayA = a['overtimePay'] ?? 0.0;
                  double overtimePayB = b['overtimePay'] ?? 0.0;
                  return overtimePayA.compareTo(overtimePayB);
                });

          List<DocumentSnapshot> filteredDocuments = overtimeDocs;
          if (selectedDepartment != 'All') {
            filteredDocuments = overtimeDocs
                .where((doc) => doc['department'] == selectedDepartment)
                .toList();
            filteredDocuments.sort((a, b) {
              Timestamp aTimestamp = a['timeIn'];
              Timestamp bTimestamp = b['timeIn'];
              return bTimestamp.compareTo(aTimestamp);
            });
          }

          const textStyle = TextStyle(fontWeight: FontWeight.bold);
          var dataTable = DataTable(
            columns: [
              const DataColumn(
                  label: Flexible(child: Text('#', style: textStyle))),
              const DataColumn(
                  label: Flexible(
                child: Text('Employee ID', style: textStyle),
              )),
              const DataColumn(
                  label: Flexible(child: Text('Name', style: textStyle))),
              DataColumn(
                label: PopupMenuButton<String>(
                  child: const Row(
                    children: [
                      Text(
                        'Department',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_drop_down)
                    ],
                  ),
                  onSelected: (String value) {
                    setState(() {
                      selectedDepartment = value;
                    });
                  },
                  itemBuilder: (BuildContext context) => [
                    'All', // Default option
                    'IT',
                    'HR',
                    'ACCOUNTING',
                    'SERVICING',
                  ].map((String value) {
                    return PopupMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              const DataColumn(
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
                label: Container(
                  width: 100,
                  padding: EdgeInsets.all(0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                    },
                    child: Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Overtime Pay',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(
                              width:
                                  4), // Add some space between the text and the icon
                          Flexible(
                            child: Icon(
                              _sortAscending
                                  ? Icons.arrow_drop_down
                                  : Icons.arrow_drop_up,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const DataColumn(
                  label: Flexible(
                child: Text('Overtime Type', style: textStyle),
              )),
              const DataColumn(
                  label: Flexible(
                child: Text('Action', style: textStyle),
              )),
            ],
            rows: List.generate(filteredDocuments.length, (index) {
              DocumentSnapshot overtimeDoc = filteredDocuments[index];
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
                    return Text('Calculating...'); // Or any loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    double overtimePay = snapshot.data ??
                        0; // Use snapshot.data, default to 0 if null
                    return Text(overtimePay.toStringAsFixed(2));
                  }
                },
              );
              Color? rowColor = indexRow % 2 == 0
                  ? Colors.white
                  : Colors.grey[200]; // Alternating row colors
              indexRow++; //

              return DataRow(
                  color: MaterialStateColor.resolveWith((states) => rowColor!),
                  cells: [
                    DataCell(Text('#')),
                    DataCell(Text(
                        overtimeData['employeeId'] ?? 'Not Available Yet')),
                    DataCell(
                      Text(overtimeData['userName'] ?? 'Not Available Yet'),
                    ),
                    DataCell(
                      Text(overtimeData['department'] ?? 'Not Available Yet'),
                    ),
                    DataCell(
                      Container(
                        width: 100,
                        decoration: BoxDecoration(color: Colors.amber.shade200),
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
                    DataCell(
                      Text(NumberFormat.currency(
                              locale: 'en_PH', symbol: '₱ ', decimalDigits: 2)
                          .format(overtimeData['overtimePay'] ?? 0.0)),
                    ),
                    DataCell(
                      DropdownButton<String>(
                        value: _selectedOvertimeTypes[index],
                        items: <String>[
                          'Regular',
                        ].map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) async {
                          if (newValue == 'Regular') {
                            await _showConfirmationDialog(overtimeDoc);
                          }
                          setState(() {
                            _selectedOvertimeTypes[index] = newValue!;
                          });
                        },
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Icon(
                                Icons.visibility,
                                color: Colors.blue,
                                size: 15,
                              ),
                              Text(
                                'View Logs',
                                style:
                                    TextStyle(fontSize: 10, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]);
            }),
          );
          return MediaQuery.of(context).size.width > 1500
              ? SizedBox(
                  height: 600,
                  child: SingleChildScrollView(
                    child: Flexible(
                      child: dataTable,
                    ),
                  ),
                )
              : SizedBox(
                  height: 600,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Flexible(
                        child: dataTable,
                      ),
                    ),
                  ),
                );
        }
      },
    );
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
                    child: MediaQuery.of(context).size.width > 600
                        ? Row(
                            children: [
                              Text('Show entries: '),
                              Container(
                                width: 70,
                                height: 30,
                                padding: EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey.shade200)),
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
                          )
                        : DropdownButton<int>(
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
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () async {
                              await _computeAndAddToOvertimePay();
                            },
                            child: Text('Compute and Add to RegularHOT Pay'),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width > 600
                                ? 400
                                : 100,
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
                                ? 230
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
                              child: MediaQuery.of(context).size.width > 800
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Row(
                                            children: [
                                              Text(
                                                'From: ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      1100
                                                  ? Text(
                                                      fromDate != null
                                                          ? DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(fromDate!)
                                                          : 'Select',
                                                      style: TextStyle(
                                                        color:
                                                            startPicked == !true
                                                                ? Colors.black
                                                                : Colors.teal
                                                                    .shade800,
                                                      ),
                                                    )
                                                  : Text(
                                                      fromDate != null
                                                          ? DateFormat('MM-dd')
                                                              .format(fromDate!)
                                                          : '',
                                                      style: TextStyle(
                                                        color:
                                                            startPicked == !true
                                                                ? Colors.black
                                                                : Colors.teal
                                                                    .shade800,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 3),
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
                                      size: 20,
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
                              child: MediaQuery.of(context).size.width > 800
                                  ? Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Flexible(
                                          child: Row(
                                            children: [
                                              Text(
                                                'To: ',
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              MediaQuery.of(context)
                                                          .size
                                                          .width >
                                                      1100
                                                  ? Text(
                                                      toDate != null
                                                          ? DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(toDate!)
                                                          : 'Select',
                                                      style: TextStyle(
                                                        color:
                                                            endPicked == !true
                                                                ? Colors.black
                                                                : Colors.teal
                                                                    .shade800,
                                                      ),
                                                    )
                                                  : Text(
                                                      toDate != null
                                                          ? DateFormat('MM-dd')
                                                              .format(toDate!)
                                                          : '',
                                                      style: TextStyle(
                                                        color:
                                                            endPicked == !true
                                                                ? Colors.black
                                                                : Colors.teal
                                                                    .shade800,
                                                      ),
                                                    ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 3),
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
                                      size: 20,
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
                await moveRecordToRegularOT(overtimeDoc);
                await deleteRecordFromSpecialOT(overtimeDoc);
              },
            ),
          ],
        );
      },
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

  Future<void> _showConfirmationDialog4(DocumentSnapshot overtimeDoc) async {
    String userId = overtimeDoc['userId'];
    QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
        .collection('RegularHolidayOT')
        .where('userId', isEqualTo: userId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Regular Holiday Overtime Logs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 15,
                  )),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Employee ID', overtimeDoc['employeeId']),
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
              child: Text('Total Overtime Pay'),
              onPressed: () async {
                try {
                  // Show a loading indicator
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );

                  // Delay Firestore operations by a very short duration
                  await Future.delayed(Duration(milliseconds: 10));

                  // Calculate total overtime pay
                  double totalHOTPay = 0;
                  for (var overtimeDoc in userOvertimeDocs) {
                    if (overtimeDoc['overtimePay'] != null) {
                      totalHOTPay += overtimeDoc['overtimePay'];
                    }
                  }

                  // Update total_overtimePay in the Overtime collection
                  // Update total_overtimePay in the Overtime collection
                  DocumentReference userOvertimeDocRef = FirebaseFirestore
                      .instance
                      .collection('RegularHolidayOTPay')
                      .doc(userId);

// Get user details
                  final userDoc = await FirebaseFirestore.instance
                      .collection('User')
                      .doc(userId)
                      .get();
                  final userData = userDoc.data() as Map<String, dynamic>;

// Check if the document exists
                  var docSnapshot = await userOvertimeDocRef.get();
                  if (docSnapshot.exists) {
                    // If the document exists, update it
                    await userOvertimeDocRef.update({
                      'total_regularHOTPay': totalHOTPay,
                      'employeeId': userData['employeeId'],
                      'userName':
                          '${userData['fname']} ${userData['mname']} ${userData['lname']}',
                      'department': userData['department'],
                    });
                  } else {
                    // If the document doesn't exist, create a new one
                    await userOvertimeDocRef.set({
                      'total_regularHOTPay': totalHOTPay,
                      'userId': userId,
                      'employeeId': userData['employeeId'],
                      'userName':
                          '${userData['fname']} ${userData['mname']} ${userData['lname']}',
                      'department': userData['department'],
                    });
                  }

                  // Dismiss the loading indicator
                  Navigator.of(context).pop();

                  // Dismiss the dialog
                  Navigator.of(context).pop();
                } catch (e) {
                  // Handle any errors
                  print('Error updating total overtime pay: $e');
                  // Dismiss the loading indicator
                  Navigator.of(context).pop();
                  // Show an error message
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Error'),
                        content: Text(
                            'Failed to update total overtime pay. Please try again.'),
                        actions: [
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              },
            ),
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

    return Container(
      height: 300,
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(8)),
      child: SingleChildScrollView(
        child: DataTable(
          columns: const [
            DataColumn(
                label:
                    Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
            DataColumn(
                label: Text('Date',
                    style: TextStyle(fontWeight: FontWeight.bold))),
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
              label: Text('Overtime Pay',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
                    Text(NumberFormat.currency(
                            locale: 'en_PH', symbol: '₱ ', decimalDigits: 2)
                        .format(overtimeDoc['overtimePay'] ?? 0.0)),
                  ),
                ]);
          }).toList(),
        ),
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
            .collection('RegularHolidayOT')
            .where('userId', isEqualTo: userId)
            .get();

        // List to store overtime documents
        List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

        // Calculate total overtime pay for the current user
        double totalHOTPay = 0;
        for (var overtimeDoc in userOvertimeDocs) {
          if (overtimeDoc['overtimePay'] != null) {
            totalHOTPay += overtimeDoc['overtimePay'];
          }
        }

        // Get user details
        final userData = userDoc.data() as Map<String, dynamic>;

        // Update total_overtimePay in the OvertimePay collection
        DocumentReference userOvertimeDocRef = FirebaseFirestore.instance
            .collection('RegularHolidayOTPay')
            .doc(userId);

        // Check if the document exists
        var docSnapshot = await userOvertimeDocRef.get();
        if (docSnapshot.exists) {
          // If the document exists, update it
          await userOvertimeDocRef.update({
            'total_regularHOTPay': totalHOTPay,
            'employeeId': userData['employeeId'],
            'userName':
                '${userData['fname']} ${userData['mname']} ${userData['lname']}',
            'department': userData['department'],
          });
        } else {
          // If the document doesn't exist, create a new one
          await userOvertimeDocRef.set({
            'total_regularHOTPay': totalHOTPay,
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

Widget _buildShimmerLoading() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: ShimmerPackage.Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: DataTable(
        columns: const [
          DataColumn(
            label: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Employee ID',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Department',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Total Hours (h:m)',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Overtime Pay',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Overtime Type',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label:
                Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          // Added column for Status
        ],
        rows: List.generate(
          10, // You can change this to the number of shimmer rows you want
          (index) => DataRow(cells: [
            DataCell(Container(width: 40, height: 16, color: Colors.white)),
            DataCell(Container(width: 60, height: 16, color: Colors.white)),
            DataCell(Container(width: 120, height: 16, color: Colors.white)),
            DataCell(Container(width: 80, height: 16, color: Colors.white)),
            DataCell(Container(width: 80, height: 16, color: Colors.white)),
            DataCell(Container(width: 100, height: 16, color: Colors.white)),
            DataCell(Container(width: 60, height: 16, color: Colors.white)),
            DataCell(Container(width: 60, height: 16, color: Colors.white)),
          ]),
        ),
      ),
    ),
  );
}
