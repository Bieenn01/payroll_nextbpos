import 'dart:async';
import 'dart:io';
import 'dart:js_interop';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:open_file/open_file.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:intl/intl.dart';
import 'dart:typed_data';

class LogsReportGenerationPage extends StatefulWidget {
  @override
  _LogsReportGenerationPageState createState() =>
      _LogsReportGenerationPageState();
}

class _LogsReportGenerationPageState extends State<LogsReportGenerationPage> {
  List<Map<String, dynamic>> _userData = [];
  late String _userName = 'Guest';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  DateTime _now = DateTime.now();

  String now(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = DateTime.now();
      return DateFormat('MMMM dd, yyyy').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserData();
    _fetchFirstName();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _fetchFirstName() async {
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

  Future<void> _fetchUserData() async {
    try {
      final QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('Records').get();

      final List<Map<String, dynamic>> userData = querySnapshot.docs
          .map((doc) => {
                'userName': doc['userName'] as String,
                'department': doc['department'] as String,
                'timeIn': doc['timeIn'] != null
                    ? _formatTimestamp(doc['timeIn'])
                    : null,
                'timeOut': doc['timeOut'] != null
                    ? _formatTimestamp(doc['timeOut'])
                    : null,
              })
          .where((data) => data['timeIn'] != null && data['timeOut'] != null)
          .toList();

      // Sort the userData list based on the 'timeIn' in descending order
      userData.sort((a, b) => DateFormat('yyyy-MM-dd HH:mm:ss')
          .parse(b['timeIn'])
          .compareTo(DateFormat('yyyy-MM-dd HH:mm:ss').parse(a['timeIn'])));

      setState(() {
        _userData = userData;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    return timestamp != null
        ? DateFormat('yyyy-MM-dd HH:mm:ss').format(timestamp.toDate())
        : '';
  }

  Future<void> _exportToExcel() async {
    final List<Map<String, dynamic>> filteredUserData = _userData
        .where((userData) =>
            userData['timeIn'] != null &&
            userData['timeOut'] != null &&
            (DateFormat('yyyy-MM-dd HH:mm:ss')
                    .parse(userData['timeIn'])
                    .isAfter(_startDate.subtract(Duration(days: 1))) &&
                DateFormat('yyyy-MM-dd HH:mm:ss')
                    .parse(userData['timeOut'])
                    .isBefore(_endDate.add(Duration(days: 1)))))
        .toList();

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
    sheet.getRangeByIndex(4, 6).setText(now(_now));

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
    for (final userData in filteredUserData) {
      sheet.getRangeByIndex(rowIndex, 1).setText(count.toString());
      sheet.getRangeByIndex(rowIndex, 2).setText(userData['userName'] ?? '');
      sheet.getRangeByIndex(rowIndex, 3).setText(userData['department'] ?? '');
      sheet.getRangeByIndex(rowIndex, 4).setText(userData['timeIn'] ?? '');
      sheet.getRangeByIndex(rowIndex, 5).setText(userData['timeOut'] ?? '');
      sheet.getRangeByIndex(rowIndex, 6).setText(_calculateTotalHours(
          userData['timeIn'] ?? '', userData['timeOut'] ?? ''));

      rowIndex++;
      count++;
    }

    final List<int> bytes = workbook.saveAsStream();

    if (kIsWeb) {
      final html.Blob blob = html.Blob([Uint8List.fromList(bytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", "User_Report.xlsx")
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final String directoryPath =
          (await getExternalStorageDirectory())?.path ?? '';
      final String filePath = '$directoryPath/User_Report.xlsx';
      final File file = File(filePath);
      await file.writeAsBytes(bytes);
      OpenFile.open(filePath);
    }

    workbook.dispose();
  }

  void _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2015, 8),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStart ? _startDate : _endDate)) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _calculateTotalHours(String timeIn, String timeOut) {
    if (timeIn.isEmpty || timeOut.isEmpty) return '';

    try {
      final DateTime startTime = timeIn.isNotEmpty
          ? DateFormat('yyyy-MM-dd HH:mm:ss').parse(timeIn)
          : DateTime.now();
      final DateTime endTime = timeOut.isNotEmpty
          ? DateFormat('yyyy-MM-dd HH:mm:ss').parse(timeOut)
          : DateTime.now();
      final Duration difference = endTime.difference(startTime);

      final int hours = difference.inHours;
      final int minutes = difference.inMinutes.remainder(60);

      return '$hours hours $minutes minutes';
    } catch (e) {
      print('Error calculating total hours: $e');
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Export Logs List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _selectDate(context, true);
                  },
                  child: Text(
                    'Select Start Date',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                    'Selected Start Date: ${DateFormat('yyyy-MM-dd').format(_startDate)}'),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    _selectDate(context, false);
                  },
                  child: Text(
                    'Select End Date',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Text(
                    'Selected End Date: ${DateFormat('yyyy-MM-dd').format(_endDate)}'),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _exportToExcel();
              },
              child: Text(
                'Export to Excel',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            SizedBox(height: 20),
            _userData.isNotEmpty
                ? DataTable(
                    columns: [
                      DataColumn(
                        label: Text('#',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      DataColumn(
                        label: Text(
                          'User name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Deparment',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Time In',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Time Out',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Total Hours',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    rows: _userData
                        .where((userData) =>
                            userData['timeIn'] != null &&
                            userData['timeOut'] != null &&
                            (DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .parse(userData['timeIn'])
                                    .isAfter(_startDate
                                        .subtract(Duration(days: 1))) &&
                                DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .parse(userData['timeOut'])
                                    .isBefore(_endDate.add(Duration(days: 1)))))
                        .map(
                          (userData) => DataRow(
                            cells: [
                              DataCell(Text((_userData.indexOf(userData) + 1)
                                  .toString())),
                              DataCell(Text(userData['userName'] ?? '')),
                              DataCell(Text(userData['department'] ?? '')),
                              DataCell(Text(userData['timeIn'] ?? '')),
                              DataCell(Text(userData['timeOut'] ?? '')),
                              DataCell(Text(_calculateTotalHours(
                                  userData['timeIn'] ?? '',
                                  userData['timeOut'] ?? ''))),
                            ],
                          ),
                        )
                        .toList(),
                  )
                : Container(
                    padding: EdgeInsets.all(20),
                    child: Text(
                      'No data available',
                      style: TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
