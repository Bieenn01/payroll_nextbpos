import 'dart:async';
import 'dart:io';
import 'dart:js_interop';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:project_payroll_nextbpo/export-Logs.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart' as ShimmerPackage;
import 'package:http/http.dart' as http;
import 'package:open_file/open_file.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  List<List<dynamic>> excelData = [];

  TextEditingController _searchController = TextEditingController();
  late String _userName = 'Guest';
  DateTime _now = DateTime.now();

  String _selectedDepartment = '';
  int _itemsPerPage = 5;
  int _currentPage = 1;
  int index = 0;
  String selectedDepartment = 'All';
  bool filter = false;
  late String _role = 'Guest';

  @override
  void initState() {
    super.initState();
    _fetchUserRecords(_itemsPerPage);
    _fetchRole();
    _fetchName();
  }

  Future<void> _fetchName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();

      setState(() {
        _userName = docSnapshot['fname'] +
            " " +
            docSnapshot['mname'] +
            " " +
            docSnapshot['lname'];
      });
    }
  }

  String now() {
    DateTime dateTime = DateTime.now();
    return DateFormat('MMMM dd, yyyy').format(dateTime);
  }

  Future<void> _fetchRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();

      setState(() {
        final role = docSnapshot['role'];
        _role = role != null
            ? role
            : 'Guest'; // Default to 'Guest' if role is not specified
      });
    }
  }

  String? getCurrentUserId() {
    final user = FirebaseAuth.instance.currentUser;
    return user?.uid;
  }

  void _nextPage() {
    setState(() {
      if (_currentPage <= _itemsPerPage) {
        _currentPage++;
        // Call your function to fetch users with pagination for the next page
        _fetchUserRecords(_itemsPerPage);
      }
    });
  }

  void _previousPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
        // Call your function to fetch users with pagination for the previous page
        _fetchUserRecords(_itemsPerPage);
      }
    });
  }

  Future<QuerySnapshot> _fetchUserRecords(int itemsPerPage) async {
    QuerySnapshot userRecordsSnapshot = await FirebaseFirestore.instance
        .collection('Records')
        .orderBy('timeIn', descending: true)
        .get();

    return userRecordsSnapshot;
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
      body: Container(
        color: Colors.teal.shade700,
        child: Column(
          children: [
            Expanded(
              child: Container(
                margin: EdgeInsets.fromLTRB(15, 5, 15, 15),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "Attendance Overview",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    searchFilter(context, styleFrom),
                    const SizedBox(
                      height: 5,
                    ),
                    Divider(),
                    datatable(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Expanded datatable() {
    return Expanded(
      child: FutureBuilder(
        future: _fetchUserRecords(_itemsPerPage),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData) {
            return Center(
              child: Text('No user records available.'),
            );
          }

          List<DocumentSnapshot> userRecords = _role == 'Employee'
              ? snapshot.data!.docs
                  .where((doc) => doc['userId'] == getCurrentUserId())
                  .toList()
              : snapshot.data!.docs;

          List<DocumentSnapshot> filteredDocs = userRecords.where((document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String userName = data['userName'];
            String department = data['department'] ?? '';
            DateTime? timeIn = (data['timeIn'] as Timestamp?)?.toDate();

            String query = _searchController.text.toLowerCase();
            bool matchesSearchQuery = userName.toLowerCase().contains(query);
            bool matchesDepartment = _selectedDepartment.isEmpty ||
                department == _selectedDepartment;
            bool isAfterStartDate = _startDate == null ||
                (timeIn != null && timeIn.isAfter(_startDate!));
            bool isBeforeEndDate = _endDate == null ||
                (timeIn != null &&
                    timeIn.isBefore(_endDate!.add(Duration(days: 1))));

            return matchesSearchQuery &&
                matchesDepartment &&
                isAfterStartDate &&
                isBeforeEndDate;
          }).toList();

          List<DocumentSnapshot> filteredDocuments = filteredDocs;
          if (selectedDepartment != 'All') {
            filteredDocuments = userRecords
                .where((doc) => doc['department'] == selectedDepartment)
                .toList();
            filteredDocuments.sort((a, b) {
              Timestamp aTimestamp = a['timeIn'];
              Timestamp bTimestamp = b['timeIn'];
              return bTimestamp.compareTo(aTimestamp);
            });
          }

          // Pagination logic
          int startIndex = (_currentPage - 1) * _itemsPerPage;
          int endIndex = startIndex + _itemsPerPage;

          // Ensure endIndex does not exceed the length of filteredDocs
          if (endIndex > filteredDocs.length) {
            endIndex = filteredDocs.length;
          }

          // Ensure startIndex is within the bounds of filteredDocs
          if (startIndex >= 0 &&
              endIndex >= 0 &&
              startIndex < filteredDocuments.length &&
              endIndex <= filteredDocuments.length) {
            filteredDocuments = filteredDocuments.sublist(startIndex, endIndex);
          } else {
            // Handle invalid index range
            print("Invalid index range");
          }
          excelData = [];
          var dataTable = DataTable(
            headingRowHeight: 50,
            columns: [
              const DataColumn(
                  label:
                      Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(
                  label: Text('Name',
                      style: TextStyle(fontWeight: FontWeight.bold))),
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
                  label: Text('Time in',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(
                  label: Text('Time out',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(
                  label: Text('Total Hours',
                      style: TextStyle(fontWeight: FontWeight.bold))),
              const DataColumn(
                  label: Text('Holiday',
                      style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: List.generate(filteredDocuments.length, (index) {
              DocumentSnapshot document = filteredDocuments[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              Color? rowColor =
                  index % 2 == 0 ? Colors.grey[200] : Colors.white;
              index++;

              // Extract timestamps for timeIn and timeOut

              Timestamp? timeInTimestamp = data['timeIn'];
              Timestamp? timeOutTimestamp = data['timeOut'];

              // Calculate the duration between timeIn and timeOut
              Duration totalDuration = Duration();
              if (timeInTimestamp != null && timeOutTimestamp != null) {
                DateTime timeIn = timeInTimestamp.toDate();
                DateTime timeOut = timeOutTimestamp.toDate();
                totalDuration = timeOut.difference(timeIn);
              }

              // Format the duration to display total hours
              String totalHoursAndMinutes =
                  '${totalDuration.inHours} hrs, ${totalDuration.inMinutes.remainder(60)} mins';

              // Add the data to the excelData list
              excelData.add([
                (index).toString(),
                data['userName'] ?? 'Unknown',
                data['department'] ?? 'Unknown',
                _formatTimestamp(timeInTimestamp),
                _formatTimestamp(timeOutTimestamp),
                totalHoursAndMinutes,
                _getHolidayName(
                    timeInTimestamp), // Assuming _getHolidayName returns a Future<String>
              ]);

              return DataRow(
                color: MaterialStateColor.resolveWith((states) => rowColor!),
                cells: [
                  DataCell(Text((index).toString())),
                  DataCell(Container(
                    width: 100,
                    child: Text(data['userName'] ?? 'Unknown'),
                  )),
                  DataCell(Container(
                    width: 100,
                    child: Text(data['department'] ?? 'Unknown'),
                  )),
                  DataCell(Container(
                    width: 150,
                    child: Text(_formatTimestamp(timeInTimestamp)),
                  )),
                  DataCell(Container(
                    width: 150,
                    child: Text(_formatTimestamp(timeOutTimestamp)),
                  )),
                  DataCell(
                    Container(
                      width: 100,
                      padding: EdgeInsets.fromLTRB(5, 2, 2, 5),
                      decoration: BoxDecoration(
                        color: Colors.indigo[50],
                        border: Border.all(color: Colors.indigo.shade900),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            child: Text(totalHoursAndMinutes),
                          ),
                        ],
                      ),
                    ),
                  ),
                  DataCell(
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: FutureBuilder<String?>(
                        future: _getHolidayName(timeInTimestamp),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.active) {
                            return Text(
                              'Fetching holiday information...',
                              style: TextStyle(color: Colors.grey),
                            );
                          } else if (snapshot.hasError) {
                            return Text(
                              'Error: ${snapshot.error}',
                              style: TextStyle(color: Colors.red),
                            );
                          } else {
                            String? holidayName = snapshot.data;
                            if (holidayName != null) {
                              return Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors
                                      .green, // Background color for holidays
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  holidayName,
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            } else {
                              return Text(
                                'No holiday',
                                style: TextStyle(color: Colors.black),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  ),
                ],
              );
            }),
          );
          var row = Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: _previousPage,
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
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Text('$_currentPage'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text('Next'),
              ),
            ],
          );
          return MediaQuery.of(context).size.width > 1000
              ? SizedBox(
                  height: 600,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        dataTable,
                        Divider(),
                        SizedBox(height: 5),
                        row,
                      ],
                    ),
                  ),
                )
              : SizedBox(
                  height: 600,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        children: [
                          dataTable,
                          Divider(),
                          SizedBox(height: 5),
                          row,
                        ],
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  Container searchFilter(BuildContext context, ButtonStyle styleFrom) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: DropdownButton<int>(
                          padding: EdgeInsets.all(5),
                          underline: SizedBox(),
                          value: _itemsPerPage,
                          items: [5, 10, 15, 25].map((_pageSize) {
                            return DropdownMenuItem<int>(
                              value: _pageSize,
                              child: Text(_pageSize.toString()),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            if (newValue != null) {
                              if ([5, 10, 15, 25].contains(newValue)) {
                                setState(() {
                                  _itemsPerPage = newValue;
                                });
                              } else {
                                // Handle case where the selected value is not in the predefined range
                                // For example, you can show a dialog, display a message, or perform any appropriate action.
                                print(
                                    "Selected value is not in the predefined range.");
                              }
                            }
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
                    items: [5, 10, 15, 25].map((_pageSize) {
                      return DropdownMenuItem<int>(
                        value: _pageSize,
                        child: Text(_pageSize.toString()),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      if (newValue != null) {
                        if ([5, 10, 15, 25].contains(newValue)) {
                          setState(() {
                            _itemsPerPage = newValue;
                          });
                        } else {
                          // Handle case where the selected value is not in the predefined range
                          // For example, you can show a dialog, display a message, or perform any appropriate action.
                          print(
                              "Selected value is not in the predefined range.");
                        }
                      }
                    },
                  ),
          ),
          Flexible(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    width:
                        500, // or use MediaQuery.of(context).size.width > 600 ? 400 : 50
                    height: 30,
                    margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                    padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black.withOpacity(0.5)),
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
                Flexible(
                  child: Container(
                      width: 130,
                      height: 30,
                      padding: EdgeInsets.all(0),
                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      decoration: BoxDecoration(
                          color: Colors.teal,
                          border: Border.all(
                              color: Colors.teal.shade900.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(8)),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.only(left: 5),
                        ),
                        onPressed: () {
                          setState(() {
                            filter = !filter;
                          });
                          filtermodal(
                            context,
                            styleFrom,
                          );
                        },
                        child: MediaQuery.of(context).size.width > 800
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.filter_alt_outlined,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    'Filter Date',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1,
                                        color: Colors.white),
                                  ),
                                ],
                              )
                            : Icon(
                                Icons.filter_alt_outlined,
                                color: Colors.white,
                              ),
                      )),
                ),
                Flexible(
                  child: Container(
                      width: 130,
                      height: 30,
                      padding: EdgeInsets.all(0),
                      margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                      decoration: BoxDecoration(
                          color: Colors.teal,
                          border: Border.all(
                              color: Colors.teal.shade900.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(8)),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.only(left: 5),
                        ),
                        onPressed: () {
                          _exportToExcel();
                        },
                        child: MediaQuery.of(context).size.width > 800
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.cloud_download_outlined,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    ' Export',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1,
                                        color: Colors.white),
                                  ),
                                ],
                              )
                            : const Icon(
                                Icons.cloud_download_outlined,
                                color: Colors.white,
                              ),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<dynamic> filtermodal(BuildContext context, ButtonStyle styleFrom) {
    return showDialog(
        context: context,
        builder: (_) => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 130,
                    ),
                    AlertDialog(
                      surfaceTintColor: Colors.white,
                      content: Container(
                        height: 200,
                        width: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Filter Date',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(Icons.close)),
                              ],
                            ),
                            Text('From :'),
                            fromDate(context, styleFrom),
                            SizedBox(
                              width: 5,
                            ),
                            Text('To :'),
                            toDate(context, styleFrom),
                            SizedBox(
                              height: 5,
                            ),
                            clearDate(context, styleFrom),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ));
  }

  Container toDate(BuildContext context, ButtonStyle styleFrom) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
      width: 150, // or use MediaQuery.of(context).size.width > 600 ? 150 : 80
      padding: EdgeInsets.all(2),
      child: ElevatedButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _endDate ?? DateTime.now(),
              firstDate: DateTime(2015, 8),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != _endDate) {
              setState(() {
                _endDate = picked;
                endPicked = true;
              });
              Navigator.of(context).pop();
            }
          },
          style: styleFrom,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _endDate != null
                        ? DateFormat('yyyy-MM-dd').format(_endDate!)
                        : 'Select Date',
                    style: TextStyle(
                        color: endPicked == !true
                            ? Colors.black
                            : Colors.teal.shade800),
                  )
                ],
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.calendar_month,
                color: Colors.black,
                size: 20,
              ),
            ],
          )),
    );
  }

  Container fromDate(BuildContext context, ButtonStyle styleFrom) {
    return Container(
      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
      width: 150, // or use MediaQuery.of(context).size.width > 600 ? 150 : 80
      padding: EdgeInsets.all(2),
      child: ElevatedButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _startDate ?? DateTime.now(),
              firstDate: DateTime(2015, 8),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != _startDate) {
              setState(() {
                _startDate = picked;
                startPicked = true;
              });
            }
          },
          style: styleFrom,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    _startDate != null
                        ? DateFormat('yyyy-MM-dd').format(_startDate!)
                        : 'Select Date',
                    style: TextStyle(
                        color: startPicked == !true
                            ? Colors.black
                            : Colors.teal.shade800),
                  )
                ],
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.calendar_month,
                color: Colors.black,
                size: 20,
              ),
            ],
          )),
    );
  }

  Future<String?> _getHolidayName(Timestamp? date) async {
    if (date == null) return null;

    DateTime dateOnly =
        DateTime(date.toDate().year, date.toDate().month, date.toDate().day);

    String formattedDate =
        '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cachedHoliday = prefs.getString(formattedDate);
    if (cachedHoliday != null) {
      return cachedHoliday;
    }

    String url =
        'https://www.googleapis.com/calendar/v3/calendars/en.philippines%23holiday%40group.v.calendar.google.com/events?key=AIzaSyBaS9eujBHEvyXw9X25wnzjXvlHGeEcPFU';

    http.Response response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      for (Map<String, dynamic> event in data['items']) {
        String eventDate = event['start']['date'];
        if (eventDate == formattedDate) {
          String holidayName = event['summary'];
          prefs.setString(formattedDate, holidayName);
          return holidayName;
        }
      }
    } else {
      print('Failed to fetch holidays: ${response.statusCode}');
    }
    return null;
  }

  Container clearDate(BuildContext context, ButtonStyle styleFrom) {
    return Container(
      height: 30,
      padding: EdgeInsets.all(0),
      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.red.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12)),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, padding: EdgeInsets.all(3)),
        onPressed: () {
          setState(() {
            _startDate = null;
            _endDate = null;
            filter = false;
          });
          Navigator.of(context).pop();
        },
        child: const Text(
          'Reset Date',
          style: TextStyle(
              fontWeight: FontWeight.w400, letterSpacing: 1, color: Colors.red),
        ),
      ),
    );
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
              label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label:
                  Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Username',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label:
                  Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Department',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label:
                  Text('Shift', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label:
                  Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label:
                  Text('Status', style: TextStyle(fontWeight: FontWeight.bold)),
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
              DataCell(Container(width: 60, height: 16, color: Colors.white)),
            ]),
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MMMM dd, yyyy HH:mm:ss:a').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  DataColumn ColumnInput(String label) {
    return DataColumn(
        label: Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
      ),
    ));
  }

  Future<void> _exportToExcel() async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];

    // Adding a picture
    final List<int> bytespic = await rootBundle
        .load('assets/images/nextbpologo-removebg.png')
        .then((data) => data.buffer.asUint8List());
    final xlsio.Picture picture = sheet.pictures.addStream(1, 1, bytespic);
    picture.height = 100;
    picture.width = 300;

    // Rest of your code for Excel formatting and data
    sheet.getRangeByName('A2:F2').merge();
    sheet.getRangeByName('A1:F1').rowHeight = 100;
    sheet.getRangeByName('A5').columnWidth = 4.82;
    sheet.getRangeByName('B5').columnWidth = 30;
    sheet.getRangeByName('C5').columnWidth = 20;
    sheet.getRangeByName('D5').columnWidth = 20;
    sheet.getRangeByName('E5').columnWidth = 20;
    sheet.getRangeByName('F5').columnWidth = 20;
    sheet.getRangeByName('G5').columnWidth = 15;
    sheet.getRangeByName('A5:F5').cellStyle.backColor = '#A5D6A7';

    sheet.getRangeByName('A2:F2').setText('Daily Time Record Report');
    sheet.getRangeByName('A2:F2').cellStyle.bold = true;
    sheet.getRangeByName('A2:F2').cellStyle.hAlign = xlsio.HAlignType.center;

    sheet.getRangeByIndex(3, 5).setText('Generated by :');
    sheet.getRangeByIndex(3, 6).setText(_userName);
    sheet.getRangeByIndex(4, 5).setText('Date Generated :');
    sheet.getRangeByIndex(4, 6).setText(now());

    sheet.getRangeByIndex(5, 1).setText('#');
    sheet.getRangeByIndex(5, 2).setText('User Name');
    sheet.getRangeByIndex(5, 3).setText('Department');
    sheet.getRangeByIndex(5, 4).setText('Time In');
    sheet.getRangeByIndex(5, 5).setText('Time Out');
    sheet.getRangeByIndex(5, 6).setText('Total Hours');

    sheet.getRangeByName('A5:F5').cellStyle.bold = true;
    sheet.getRangeByName('A5:F5').cellStyle.fontSize = 12;

    int rowIndex = 6; // Start from the second row for data
    int count = 1; // Initialize counter
    for (final userData in excelData) {
      sheet.getRangeByIndex(rowIndex, 1).setText(count.toString());
      sheet.getRangeByIndex(rowIndex, 2).setText(userData[1].toString() ?? '');
      sheet.getRangeByIndex(rowIndex, 3).setText(userData[2].toString() ?? '');
      sheet.getRangeByIndex(rowIndex, 4).setText(userData[3].toString() ?? '');
      sheet.getRangeByIndex(rowIndex, 5).setText(userData[4].toString() ?? '');
      sheet.getRangeByIndex(rowIndex, 6).setText(userData[5].toString());

      rowIndex++;
      count++;
    }

    final List<int> bytes = workbook.saveAsStream();

    if (kIsWeb) {
      final html.Blob blob = html.Blob([Uint8List.fromList(bytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "DTR_Report.xlsx")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final String directoryPath =
          (await getExternalStorageDirectory())?.path ?? '';
      final String filePath = '$directoryPath/DTR_Report.xlsx';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      OpenFile.open(filePath);
    }

    workbook.dispose();
    setState(() {
      excelData = [];
    });
  }
}
