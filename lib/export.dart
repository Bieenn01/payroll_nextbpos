import 'dart:async';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import 'dart:typed_data';

class ReportGenerationPage extends StatefulWidget {
  @override
  _ReportGenerationPageState createState() => _ReportGenerationPageState();
}

class _ReportGenerationPageState extends State<ReportGenerationPage> {
  List<Map<String, String>> _userData = [];
  List<String> selectedDepartments = [
    'All',
    'IT',
    'HR',
    'ACCOUNTING',
    'SERVICING'
  ]; // Include 'All' option
  String selectedDepartment = 'All'; // Default department

  @override
  void initState() {
    super.initState();
    _fetchUserData(selectedDepartment);
  }

  Future<void> _fetchUserData(String department) async {
    try {
      Query query = FirebaseFirestore.instance.collection('User');
      if (department != 'All') {
        query = query.where('department', isEqualTo: department);
      }
      final QuerySnapshot querySnapshot = await query.get();

      final List<Map<String, String>> userData = querySnapshot.docs
          .map((doc) => {
                'fname': doc['fname'] as String,
                'mname': doc['mname'] as String,
                'lname': doc['lname'] as String,
                'email': doc['email'] as String,
                'role': doc['role'] as String,
                  'typeEmployee': doc['typeEmployee'] as String,
                     'sss': doc['sss'] as String,
                'tin': doc['tin'] as String,
                 'taxCode': doc['taxCode'] as String,
                'employeeId': doc['employeeId'] as String,
                
              })
          .toList();

      setState(() {
        _userData = userData;
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _exportToPDF() async {
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      build: (context) {
        return pw.Column(
          children: _userData
              .map((user) => pw.Row(
                    children: [
                      pw.Text(user['fname'] ?? ''),
                      pw.Text(user['mname'] ?? ''),
                      pw.Text(user['lname'] ?? ''),
                      pw.Text(user['email'] ?? ''),
                      pw.Text(user['role'] ?? ''),
                        pw.Text(user['typeEmployee'] ?? ''),
                       pw.Text(user['sss'] ?? ''),
                      pw.Text(user['tin'] ?? ''),
   pw.Text(user['taxCode'] ?? ''),
                      pw.Text(user['employeeId'] ?? ''),
                    ],
                  ))
              .toList(),
        );
      },
    ));
    final pdfBytes = await pdf.save();

    if (kIsWeb) {
      final pdfBlob = html.Blob([Uint8List.fromList(pdfBytes)]);
      final pdfUrl = html.Url.createObjectUrlFromBlob(pdfBlob);
      html.AnchorElement(href: pdfUrl)
        ..setAttribute("download", "User_Report.pdf")
        ..click();
      html.Url.revokeObjectUrl(pdfUrl);
    } else {
      final String directoryPath =
          (await getExternalStorageDirectory())?.path ?? '';
      final String filePath = '$directoryPath/User_Report.pdf';
      final File file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      OpenFile.open(filePath);
    }
  }

  Future<void> _exportToExcel() async {
    final xlsio.Workbook workbook = xlsio.Workbook();
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    int rowIndex = 1;
    for (final userData in _userData) {
      sheet.getRangeByIndex(rowIndex, 1).setText(userData['fname'] ?? '');
      sheet.getRangeByIndex(rowIndex, 2).setText(userData['mname'] ?? '');
      sheet.getRangeByIndex(rowIndex, 3).setText(userData['lname'] ?? '');
      sheet.getRangeByIndex(rowIndex, 3).setText(userData['email'] ?? '');
      sheet.getRangeByIndex(rowIndex, 7).setText(userData['role'] ?? '');

      sheet.getRangeByIndex(rowIndex, 8).setText(userData['typeEmployee'] ?? '');
      sheet.getRangeByIndex(rowIndex, 9).setText(userData['sss'] ?? '');
      sheet.getRangeByIndex(rowIndex, 10).setText(userData['tin'] ?? '');
        sheet.getRangeByIndex(rowIndex, 11).setText(userData['taxCode'] ?? '');
      sheet.getRangeByIndex(rowIndex, 12).setText(userData['employeeId'] ?? '');
      rowIndex++;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Export'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: selectedDepartment,
              items: selectedDepartments.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedDepartment = newValue;
                    _fetchUserData(selectedDepartment);
                  });
                }
              },
            ),
            ElevatedButton(
              onPressed: () {
                _exportToPDF();
              },
              child: Text('Export to PDF'),
            ),
            ElevatedButton(
              onPressed: () {
                _exportToExcel();
              },
              child: Text('Export to Excel'),
            ),
            _userData.isNotEmpty
                ? DataTable(
                    columns: [
                      DataColumn(
                        label: Text(
                          'First Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Middle Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Last Name',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'Email',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      DataColumn(
                          label: Text(
                          'Role',
                         style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Employee Type', style: TextStyle(fontWeight: FontWeight.bold))),
                            DataColumn(label: Text('SSS', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('TIN', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Tax Code', style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(label: Text('Employee ID', style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    
                    rows: _userData
                        .map(
                          (userData) => DataRow(
                            cells: [
                              DataCell(Text(userData['fname'] ?? '')),
                              DataCell(Text(userData['mname'] ?? '')),
                              DataCell(Text(userData['lname'] ?? '')),
                              DataCell(Text(userData['email'] ?? '')),
                              DataCell(Text(userData['role'] ?? '')),
                                     DataCell(Text(userData['typeEmployee'] ?? '')),
                                            DataCell(Text(userData['sss'] ?? '')),
                              DataCell(Text(userData['tin'] ?? '')),
                                   DataCell(Text(userData['taxCode'] ?? '')),
                              DataCell(Text(userData['employeeId'] ?? '')),
                            ],
                          ),
                        )
                        .toList(),
                  )
                : Container(
                    padding: EdgeInsets.all(20),
                    child: Text('No data available'),
                  ),
          ],
        ),
      ),
    );
  }
}
