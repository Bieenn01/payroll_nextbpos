import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ArchivesHoliday extends StatefulWidget {
  const ArchivesHoliday({Key? key}) : super(key: key);

  @override
  State<ArchivesHoliday> createState() => _ArchivesHoliday();
}

class _ArchivesHoliday extends State<ArchivesHoliday> {
  late List<String> _selectedOvertimeTypes;
  TextEditingController _searchController = TextEditingController();
  int _itemsPerPage = 5;
  int _currentPage = 0;
  int indexRow = 0;
  int _totalPages = 1;
  
  bool _sortAscending = false;

  bool sortPay = false;
  bool table = false;
  bool filter = false;

  DateTime? fromDate;
  DateTime? toDate;
  bool endPicked = false;
  bool startPicked = false;
  late String _role = 'Guest';

  @override
  void initState() {
    super.initState();
    _selectedOvertimeTypes = [];
     _itemsPerPage = 5;
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
                              "Archives  Holiday",
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
            )
          ],
        ),
      ),
    ));
  }

Row pagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        ElevatedButton(
          onPressed:
              _currentPage > 1 ? () => _changePage(_currentPage - 1) : null,
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
          onPressed: _currentPage < _totalPages
              ? () => _changePage(_currentPage + 1)
              : null,
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text('Next'),
        ),
      ],
    );
  }

  void _changePage(int page) {
    setState(() {
      _currentPage = page;
    });
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
                                  border:
                                      Border.all(color: Colors.grey.shade200),
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
                            width: MediaQuery.of(context).size.width > 600
                                ? 400
                                : 100,
                            height: 30,
                            margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
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
                        Flexible(
                          child: Container(
                              width: 130,
                              height: 30,
                              padding: const EdgeInsets.all(0),
                              margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                              decoration: BoxDecoration(
                                  color: Colors.teal,
                                  border: Border.all(
                                      color: Colors.teal.shade900
                                          .withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(8)),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: const EdgeInsets.only(left: 5),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                                    : const Icon(
                                        Icons.filter_alt_outlined,
                                        color: Colors.white,
                                      ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
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
                    const SizedBox(
                      height: 130,
                    ),
                    AlertDialog(
                      surfaceTintColor: Colors.white,
                      content: SizedBox(
                        height: 200,
                        width: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
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
                            const Text('From :'),
                            _fromDate(context, styleFrom),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text('To :'),
                            _toDate(context, styleFrom),
                            const SizedBox(
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

  Container clearDate(BuildContext context, ButtonStyle styleFrom) {
    return Container(
      height: 30,
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.red.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12)),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, padding: EdgeInsets.all(3)),
        onPressed: () {
          setState(() {
            toDate = null;
            fromDate = null;
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

  Flexible _toDate(BuildContext context, ButtonStyle styleFrom) {
    return Flexible(
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 150 : 50,
        padding: const EdgeInsets.all(2),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Text(
                        toDate != null
                            ? DateFormat('yyyy-MM-dd').format(toDate!)
                            : 'Select',
                        style: TextStyle(
                          color: endPicked == !true
                              ? Colors.black
                              : Colors.teal.shade800,
                        ),
                      )
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
            )),
      ),
    );
  }

  Flexible _fromDate(BuildContext context, ButtonStyle styleFrom) {
    return Flexible(
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 230 : 80,
        padding: const EdgeInsets.all(2),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Text(
                        fromDate != null
                            ? DateFormat('yyyy-MM-dd').format(fromDate!)
                            : 'Select',
                        style: TextStyle(
                          color: startPicked == !true
                              ? Colors.black
                              : Colors.teal.shade800,
                        ),
                      )
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
            )),
      ),
    );
  }

  Widget _buildTable() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('ArchivesRegularH').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available yet'));
        } else {
          List<DocumentSnapshot> overtimeDocs = snapshot.data!.docs;
          _totalPages = (overtimeDocs.length / _itemsPerPage).ceil();

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
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('#', style: textStyle)),
                  DataColumn(label: Text('Employee ID', style: textStyle)),
                  DataColumn(label: Text('Name', style: textStyle)),
                  DataColumn(label: Text('Department', style: textStyle)),
                  DataColumn(label: Text('Date', style: textStyle)),
                  DataColumn(label: Text('Total Hours', style: textStyle)),
                  DataColumn(label: Text('Holiday Pay', style: textStyle)),
                  DataColumn(label: Text('Action', style: textStyle)),
                ],
                rows: List.generate(overtimeDocs.length.clamp(0, _itemsPerPage),
                    (index) {
                      
                  DocumentSnapshot overtimeDoc = overtimeDocs[index];
                  Map<String, dynamic> overtimeData =
                      overtimeDoc.data() as Map<String, dynamic>;
                  _selectedOvertimeTypes.add('Regular');

                  Timestamp? timeInTimestamp = overtimeDoc['timeIn'];
                  Timestamp? timeOutTimestamp = overtimeDoc['timeOut'];

                  // Calculate the duration between timeIn and timeOut
                  Duration totalDuration = const Duration();
                  if (timeInTimestamp != null && timeOutTimestamp != null) {
                    DateTime timeIn = timeInTimestamp.toDate();
                    DateTime timeOut = timeOutTimestamp.toDate();
                    totalDuration = timeOut.difference(timeIn);
                  }
                  // Format the duration to display total hours
                  String totalHoursAndMinutes =
                      '${totalDuration.inHours} hrs, ${totalDuration.inMinutes.remainder(60)} mins';

                  Color? rowColor = indexRow % 2 == 0
                      ? Colors.white
                      : Colors.grey[200]; // Alternating row colors
                  indexRow++; //

                  return DataRow(
                      color:
                          MaterialStateColor.resolveWith((states) => rowColor!),
                      cells: [
                        DataCell(Text('${index + 1}')),
                        DataCell(Text(overtimeData['employeeId'])),
                        DataCell(
                          Text(overtimeData['userName'] ?? 'Not Available Yet'),
                        ),
                        DataCell(
                          Text(overtimeData['department'] ??
                              'Not Available Yet'),
                        ),
                        DataCell(
                          Text(_formatDate(
                              overtimeData['timeIn'] ?? 'Not Available Yet')),
                        ),
                        DataCell(
                          Container(
                            width: 100,
                            padding: const EdgeInsets.fromLTRB(5, 2, 2, 5),
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
                          Text(NumberFormat.currency(
                                  locale: 'en_PH',
                                  symbol: '₱ ',
                                  decimalDigits: 2)
                              .format(overtimeData['holidayPay'] ?? 0.0)),
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
                                    size: 18,
                                  ),
                                  Text(
                                    'View',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.blue),
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
          );
        }
      },
    );
  }

  Future<QuerySnapshot> _showConfirmationDialog4(
      DocumentSnapshot overtimeDoc) async {
    Completer<QuerySnapshot> completer = Completer<QuerySnapshot>();

    String userId = overtimeDoc['userId'];
    QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
        .collection('ArchivesRegularH')
        .where('userId', isEqualTo: userId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;
    userOvertimeDocs.sort((a, b) {
      Timestamp aTimestamp = a['timeIn'];
      Timestamp bTimestamp = b['timeIn'];
      return bTimestamp.compareTo(aTimestamp);
    });

    int totalDays = 0;
    double totalHours = 0.0;
    double totalPays = 0.0;

    // Calculate total days, hours, and pays
    for (var overtimeDoc in userOvertimeDocs) {
      Timestamp? timeInTimestamp = overtimeDoc['timeIn'];
      Timestamp? timeOutTimestamp = overtimeDoc['timeOut'];

      if (timeInTimestamp != null && timeOutTimestamp != null) {
        DateTime timeIn = timeInTimestamp.toDate();
        DateTime timeOut = timeOutTimestamp.toDate();
        Duration totalDuration = timeOut.difference(timeIn);

        totalDays++;
        totalHours += totalDuration.inHours + totalDuration.inMinutes / 60;
        totalPays += (overtimeDoc['holidayPay'] ?? 0.0);
      }
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Archives Holiday Logs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(
                  Icons.close,
                  size: 15,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Employee ID',
                            overtimeDoc['employeeId'] ?? 'Not Available'),
                        _buildInfoRow2('Name           ',
                            overtimeDoc['userName'] ?? 'Not Available'),
                        _buildInfoRow('Department ',
                            overtimeDoc['department'] ?? 'Not Available'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildInfoRow3('# of Days', totalDays.toString()),
                        _buildInfoRow3(
                            'Total Hours', totalHours.toStringAsFixed(2)),
                        _buildInfoRow2(
                          'Total Pays',
                          NumberFormat.currency(
                                  locale: 'en_PH',
                                  symbol: '₱ ',
                                  decimalDigits: 2)
                              .format(totalPays ?? 0.0),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                _buildOvertimeTable(userOvertimeDocs),
                const Divider(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
                completer.complete(overtimeSnapshot);
              },
            ),
          ],
        );
      },
    );

    return completer.future;
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
            width: 100,
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
            decoration: BoxDecoration(border: Border.all(color: Colors.white)),
            child: Text(value)),
      ],
    );
  }

  Widget _buildInfoRow3(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
            width: 70,
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
            decoration: BoxDecoration(border: Border.all(color: Colors.white)),
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            )),
      ],
    );
  }

  Widget _buildInfoRow2(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        IntrinsicWidth(
          child: Container(
              padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Text(value)),
        ),
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

    var dataTable = DataTable(
      columns: const [
        DataColumn(
            label: Text(
          '#',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
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
          label: Text('Holiday Hours',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text('Holiday Pay',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
      rows: overtimeDocs.map((overtimeDoc) {
        Color? rowColor = index % 2 == 0
            ? Colors.grey[200]
            : Colors.transparent; // Alternating row colors
        index++; //

        Timestamp? timeInTimestamp = overtimeDoc['timeIn'];
        Timestamp? timeOutTimestamp = overtimeDoc['timeOut'];

        // Calculate the duration between timeIn and timeOut
        Duration totalDuration = const Duration();
        if (timeInTimestamp != null && timeOutTimestamp != null) {
          DateTime timeIn = timeInTimestamp.toDate();
          DateTime timeOut = timeOutTimestamp.toDate();
          totalDuration = timeOut.difference(timeIn);
        }

        // Format the duration to display total hours
        String totalHoursAndMinutes =
            '${totalDuration.inHours} hrs, ${totalDuration.inMinutes.remainder(60)} mins';

        return DataRow(
            color: MaterialStateColor.resolveWith((states) => rowColor!),
            cells: [
              DataCell(Text('$index')),
              DataCell(Text(_formatDate(overtimeDoc['timeIn']))),
              DataCell(Text(_formatTime(overtimeDoc['timeIn']))),
              DataCell(Text(_formatTime(overtimeDoc['timeOut']))),
              DataCell(
                Container(
                    padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                    decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal.shade900)),
                    child: Text(totalHoursAndMinutes)),
              ),
              DataCell(
                Text(
                  NumberFormat.currency(
                          locale: 'en_PH', symbol: '₱ ', decimalDigits: 2)
                      .format(overtimeDoc['holidayPay'] ?? 0.0),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ]);
      }).toList(),
    );
    return MediaQuery.of(context).size.width > 1000
        ? SizedBox(height: 300, child: SingleChildScrollView(child: dataTable))
        : SizedBox(
            height: 300,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(child: dataTable)));
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

  Future<void> deleteRecordFromRestdayOT(DocumentSnapshot overtimeDoc) async {
    try {
      await overtimeDoc.reference.delete();
    } catch (e) {
      print('Error deleting record from Overtime collection: $e');
    }
  }
}
