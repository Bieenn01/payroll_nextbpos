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
  List<String> selectedRoles = [
    'Employee', // Default choice
    'Admin',
  ];
  String selectedDepartment = 'All'; // Default department
  String selectedRole = 'Employee'; // Default role

  @override
  void initState() {
    super.initState();
    _fetchUserData(selectedDepartment, selectedRole);
  }

  Future<void> _fetchUserData(String department, String role) async {
    try {
      Query query = FirebaseFirestore.instance.collection('User');
      if (department != 'All') {
        query = query.where('department', isEqualTo: department);
      }
      if (role != 'All') {
        query = query.where('role', isEqualTo: role);
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

  Future<void> _exportToExcel() async {
    // Remaining code remains the same
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Export User List',
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
                    _fetchUserData(selectedDepartment, selectedRole);
                  });
                }
              },
            ),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: selectedRole,
              items: selectedRoles.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    selectedRole = newValue;
                    _fetchUserData(selectedDepartment, selectedRole);
                  });
                }
              },
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
                          label: Text('Employee ID',
                              style: TextStyle(fontWeight: FontWeight.bold))),
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
                          label: Text('Role',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Employee Type',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('SSS',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('TIN',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      DataColumn(
                          label: Text('Tax Code',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                    ],
                    rows: _userData
                        .map(
                          (userData) => DataRow(
                            cells: [
                              DataCell(Text(
                                (_userData.indexOf(userData) + 1).toString(),
                              )),
                              DataCell(Text(userData['employeeId'] ?? '')),
                              DataCell(Text(userData['fname'] ?? '')),
                              DataCell(Text(userData['mname'] ?? '')),
                              DataCell(Text(userData['lname'] ?? '')),
                              DataCell(Text(userData['email'] ?? '')),
                              DataCell(Text(userData['role'] ?? '')),
                              DataCell(Text(userData['typeEmployee'] ?? '')),
                              DataCell(Text(userData['sss'] ?? '')),
                              DataCell(Text(userData['tin'] ?? '')),
                              DataCell(Text(userData['taxCode'] ?? '')),
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
