import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart' as ShimmerPackage;

class AttendancePage extends StatefulWidget {
  const AttendancePage({Key? key}) : super(key: key);

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  late Future<List<DocumentSnapshot>> _userRecordsFuture;
  TextEditingController _searchController = TextEditingController();
  String _selectedDepartment = '';
  int _itemsPerPage = 5;
  int _currentPage = 1;
  int index = 0;
  String selectedDepartment = 'All';
  bool filter = false;

  @override
  void initState() {
    super.initState();
    _fetchUserRecords(_itemsPerPage);
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

          List<DocumentSnapshot> userRecords = snapshot.data!.docs;

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
            ],
            rows: List.generate(filteredDocuments.length, (index) {
              DocumentSnapshot document = filteredDocuments[index];
              Map<String, dynamic> data =
                  document.data() as Map<String, dynamic>;
              Color? rowColor =
                  index % 2 == 0 ? Colors.grey[200] : Colors.white;
              index++;
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
                    child: Text(_formatTimestamp(data['timeIn'])),
                  )),
                  DataCell(Container(
                    width: 150,
                    child: Text(_formatTimestamp(data['timeOut'])),
                  )),
                  DataCell(Container(
                    width: 150,
                    child: Text('TOTAL HOURS'),
                  )),
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
                        400, // or use MediaQuery.of(context).size.width > 600 ? 400 : 50
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
                filter ? fromDate(context, styleFrom) : Container(),
                filter ? toDate(context, styleFrom) : Container(),
                filter ? clearDate(context, styleFrom) : Container(),
                Flexible(
                  child: Container(
                    width: 100,
                    height: 30,
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        color: Colors.teal,
                        border: Border.all(
                            color: Colors.teal.shade900.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8)),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: filter
                              ? Colors.teal.shade200
                              : Colors.teal.shade700,
                          padding: EdgeInsets.all(5),
                          shape: RoundedRectangleBorder(),
                        ),
                        onPressed: () {
                          setState(() {
                            filter = !filter;
                          });
                        },
                        child: Text('Filter Date')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Flexible clearDate(BuildContext context, ButtonStyle styleFrom) {
    return Flexible(
        child: Container(
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            _startDate = null;
            _endDate = null;
          });
        },
        child: Text('Clear filter'),
      ),
    ));
  }

  Flexible toDate(BuildContext context, ButtonStyle styleFrom) {
    return Flexible(
      child: Container(
        width: MediaQuery.of(context).size.width > 600
            ? 150
            : 50, // or use MediaQuery.of(context).size.width > 600 ? 150 : 50
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
            }
          },
          style: styleFrom,
          child: MediaQuery.of(context).size.width > 800
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'To: ',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        MediaQuery.of(context).size.width > 1100
                            ? Text(
                                _endDate != null
                                    ? DateFormat('yyyy-MM-dd').format(_endDate!)
                                    : 'Select Date',
                                style: TextStyle(
                                    color: endPicked == !true
                                        ? Colors.black
                                        : Colors.teal.shade800),
                              )
                            : Text(
                                _endDate != null
                                    ? DateFormat('MM-dd').format(_endDate!)
                                    : '',
                                style: TextStyle(
                                    color: endPicked == !true
                                        ? Colors.black
                                        : Colors.teal.shade800),
                              ),
                      ],
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.calendar_month,
                      color: Colors.black,
                      size: 20,
                    ),
                  ],
                )
              : Icon(
                  Icons.calendar_month,
                  color: Colors.black,
                  size: 20,
                ),
        ),
      ),
    );
  }

  Flexible fromDate(BuildContext context, ButtonStyle styleFrom) {
    return Flexible(
      child: Container(
        width: MediaQuery.of(context).size.width > 600
            ? 230
            : 80, // or use MediaQuery.of(context).size.width > 600 ? 150 : 80
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
          child: MediaQuery.of(context).size.width > 800
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'From: ',
                          style: TextStyle(
                              color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                        MediaQuery.of(context).size.width > 1100
                            ? Text(
                                _startDate != null
                                    ? DateFormat('yyyy-MM-dd')
                                        .format(_startDate!)
                                    : 'Select Date',
                                style: TextStyle(
                                    color: startPicked == !true
                                        ? Colors.black
                                        : Colors.teal.shade800),
                              )
                            : Text(
                                _startDate != null
                                    ? DateFormat('MM-dd').format(_startDate!)
                                    : '',
                                style: TextStyle(
                                    color: startPicked == !true
                                        ? Colors.black
                                        : Colors.teal.shade800),
                              ),
                      ],
                    ),
                    SizedBox(width: 3),
                    Icon(
                      Icons.calendar_month,
                      color: Colors.black,
                      size: 20,
                    ),
                  ],
                )
              : Icon(
                  Icons.calendar_month,
                  color: Colors.black,
                  size: 20,
                ),
        ),
      ),
    );
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
            label: Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label:
                Text('Username', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Department',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Shift', style: TextStyle(fontWeight: FontWeight.bold)),
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
