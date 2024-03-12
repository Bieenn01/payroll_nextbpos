import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

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
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserRecords();
  }

  Future<void> _fetchUserRecords() async {
    _userRecordsFuture = FirebaseFirestore.instance
        .collection('Records')
        .orderBy('timeIn', descending: true)
        .get()
        .then((querySnapshot) => querySnapshot.docs);
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
                            "Attendace Overview",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            ),
                          ),
                          Flexible(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Flexible(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width > 600
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
                                        contentPadding:
                                            EdgeInsets.only(bottom: 15),
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
                                    width:
                                        MediaQuery.of(context).size.width > 600
                                            ? 150
                                            : 80,
                                    padding: EdgeInsets.all(2),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _startDate ?? DateTime.now(),
                                          firstDate: DateTime(2015, 8),
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
                                      child: MediaQuery.of(context).size.width >
                                              600
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'From: ',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      _startDate != null
                                                          ? DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(
                                                                  _startDate!)
                                                          : 'Select Date',
                                                      style: TextStyle(
                                                          color: startPicked ==
                                                                  !true
                                                              ? Colors.black
                                                              : Colors.teal
                                                                  .shade800),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
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
                                            ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Flexible(
                                  child: Container(
                                    width:
                                        MediaQuery.of(context).size.width > 600
                                            ? 150
                                            : 50,
                                    padding: EdgeInsets.all(2),
                                    child: ElevatedButton(
                                      onPressed: () async {
                                        final DateTime? picked =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              _endDate ?? DateTime.now(),
                                          firstDate: DateTime(2015, 8),
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
                                      child: MediaQuery.of(context).size.width >
                                              600
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      'To: ',
                                                      style: TextStyle(
                                                          color: Colors.black,
                                                          fontWeight:
                                                              FontWeight.bold),
                                                    ),
                                                    Text(
                                                      _endDate != null
                                                          ? DateFormat(
                                                                  'yyyy-MM-dd')
                                                              .format(_endDate!)
                                                          : 'Select Date',
                                                      style: TextStyle(
                                                          color: endPicked ==
                                                                  !true
                                                              ? Colors.black
                                                              : Colors.teal
                                                                  .shade800),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(
                                                  width: 3,
                                                ),
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
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Divider(),
                    Expanded(
                      child: FutureBuilder<List<DocumentSnapshot>>(
                        future: _userRecordsFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                          if (snapshot.hasError) {
                            return Center(
                              child: Text('Error: ${snapshot.error}'),
                            );
                          }
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Text('No user records available.'),
                            );
                          }

                          var filteredDocs = snapshot.data!.where((document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            String userName = data['userName'];
                            String query = _searchController.text.toLowerCase();
                            String department = data['department'] ?? '';
                            DateTime? timeIn =
                                (data['timeIn'] as Timestamp?)?.toDate();
                            return userName.toLowerCase().contains(query) &&
                                (_selectedDepartment.isEmpty ||
                                    department == _selectedDepartment) &&
                                (_startDate == null ||
                                    timeIn!.isAfter(_startDate!)) &&
                                (_endDate == null ||
                                    timeIn!.isBefore(
                                        _endDate!.add(Duration(days: 1))));
                          }).toList();

                          int startIndex = _currentPage * _itemsPerPage;
                          int endIndex = startIndex + _itemsPerPage;
                          if (endIndex > filteredDocs.length) {
                            endIndex = filteredDocs.length;
                          }

                          int _pagenumber = _currentPage + 1;

                          List<DocumentSnapshot> pageItems =
                              filteredDocs.sublist(startIndex, endIndex);

                          return ListView.builder(
                            itemCount:
                                (pageItems.length / _itemsPerPage).ceil() + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return SizedBox(
                                  height: 0,
                                );
                              } else {
                                int startIndex = (index - 1) * _itemsPerPage;
                                int endIndex = startIndex + _itemsPerPage;
                                if (endIndex > pageItems.length) {
                                  endIndex = pageItems.length;
                                }
                                return Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    DataTable(
                                      columns: [
                                        ColumnInput('#'),
                                        ColumnInput('Name'),
                                        ColumnInput('Time in'),
                                        ColumnInput('Time out'),
                                        ColumnInput('Department')
                                      ],
                                      rows: List<DataRow>.generate(
                                          endIndex - startIndex, (i) {
                                        int dataIndex = startIndex + i;
                                        Map<String, dynamic> data =
                                            pageItems[dataIndex].data()
                                                as Map<String, dynamic>;
                                        Color? rowColor = index % 2 == 0
                                            ? Colors.white
                                            : Colors.grey[
                                                200]; // Alternating row colors
                                        index++; //
                                        return DataRow(
                                            color:
                                                MaterialStateColor.resolveWith(
                                                    (states) => rowColor!),
                                            cells: [
                                              DataCell(Text(
                                                  (dataIndex + 1).toString())),
                                              DataCell(Container(
                                                width: 100,
                                                child: Text(data['userName'] ??
                                                    'Unknown'),
                                              )),
                                              DataCell(Container(
                                                width: 150,
                                                child: Text(_formatTimestamp(
                                                    data['timeIn'])),
                                              )),
                                              DataCell(Container(
                                                width: 150,
                                                child: Text(_formatTimestamp(
                                                    data['timeOut'])),
                                              )),
                                              DataCell(Container(
                                                width: 100,
                                                child: Text(
                                                    data['department'] ??
                                                        'Unknown'),
                                              )),
                                            ]);
                                      }),
                                    ),
                                    Divider(),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              _startDate = null;
                                              _endDate = null;
                                            });
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            'Previous',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        SizedBox(width: 10),
                                        Container(
                                            height: 35,
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                    color:
                                                        Colors.grey.shade200)),
                                            child: Text('$_pagenumber')),
                                        SizedBox(width: 10),
                                        ElevatedButton(
                                          onPressed: () {
                                            if (_currentPage <
                                                (filteredDocs.length /
                                                            _itemsPerPage)
                                                        .ceil() -
                                                    1) {
                                              setState(() {
                                                _currentPage++;
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: Text(
                                            'Next',
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                );
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
