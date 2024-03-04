import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/widgets.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/view_userDetails.dart';
import 'package:project_payroll_nextbpo/backend/jsonfiles/add_users.dart';
import 'package:project_payroll_nextbpo/backend/widgets/toast_widget.dart';
import 'package:project_payroll_nextbpo/frontend/modal.dart';

class User {
  String department;
  String email;
  DateTime endShift;
  String fname;
  DateTime startShift;
  String role;
  String mname;
  String lname;
  String username;
  String typeEmployee;
  String sss;
  String tin;
  String taxCode;
  String employeeId;
  String mobilenum;

  User(
      {required this.department,
      required this.email,
      required this.endShift,
      required this.fname,
      required this.startShift,
      required this.role,
      required this.mname,
      required this.lname,
      required this.username,
      required this.typeEmployee,
      required this.sss,
      required this.tin,
      required this.taxCode,
      required this.employeeId,
      required this.mobilenum});
}

class PovUser2 extends StatefulWidget {
  PovUser2({Key? key}) : super(key: key);

  @override
  State<PovUser2> createState() => _UserState();
}

class _UserState extends State<PovUser2> {
  int _documentLimit = 5;
  int _currentPage = 0;
  int _rowsPerPage = 8;
  DateTime? selectedDate;
  DateTime? selectedTime;
  DateTime? selectedDateTime;
  bool passwordVisible = false;
  int index = 0;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController middleNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController sssController = TextEditingController();
  final TextEditingController tinController = TextEditingController();
  final TextEditingController taxCodeController = TextEditingController();
  final TextEditingController employeeIdController = TextEditingController();
  final TextEditingController mobilenumController = TextEditingController();

  String selectedRole = 'Select Role';
  String selectedDep = 'Select Department';
  String typeEmployee = 'Type of Employee';

  String kaizarscoreEmail = "kaizarscore12@gmail.com";

  @override
  void initState() {
    super.initState();
// Fetch users when the widget initializes
  }

  Future<QuerySnapshot> _fetchUsersWithPagination(
      int limit, DocumentSnapshot? startAfterDocument) async {
    Query query = FirebaseFirestore.instance
        .collection('User')
        .orderBy('email')
        .limit(limit);

    if (startAfterDocument != null) {
      query = query.startAfterDocument(startAfterDocument);
    }

    return await query.get();
  }

  void _nextPage() async {
    DocumentSnapshot? lastVisible = _lastVisibleSnapshot;
    QuerySnapshot snapshot = await _fetchUsersWithPagination(
      _documentLimit,
      lastVisible,
    );

    setState(() {
      _users.addAll(snapshot.docs);
      _lastVisibleSnapshot =
          snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    });
  }

  void _previousPage() async {
    // Ensure we don't navigate to a negative page
    if (_currentPage > 0) {
      // Calculate the startAfter document based on the first document of the current page
      DocumentSnapshot? startAfterDocument =
          _users.isNotEmpty ? _users.first : null;

      // Fetch the previous set of documents
      QuerySnapshot snapshot =
          await _fetchUsersWithPagination(_documentLimit, startAfterDocument);

      setState(() {
        // Clear the current list and add the documents from the previous page
        _users.clear();
        _users.addAll(snapshot.docs);

        // Decrement the current page
        _currentPage--;
      });
    }
  }

  // Initialize _lastVisibleSnapshot as null
  DocumentSnapshot? _lastVisibleSnapshot;

// Initialize _users as an empty list
  List<DocumentSnapshot> _users = [];

  @override
  Widget build(BuildContext context) {
    var styleFrom = ElevatedButton.styleFrom(
      backgroundColor: Colors.teal.shade600,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.all(8.0),
      minimumSize: const Size(200, 50),
      maximumSize: const Size(200, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(7),
      ),
    );

    return Scaffold(
      body: Container(
        color: Colors.teal.shade700,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    children: [
                      Text(
                        "Account List",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width > 600
                                ? 300
                                : 50,
                            height: 30,
                            margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.5)),
                            ),
                            child: const TextField(
                              textAlign: TextAlign.start,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.only(bottom: 15),
                                prefixIcon: Icon(Icons.search),
                                border: InputBorder.none,
                                hintText: 'Search',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          child: Container(
                            height: 30,
                            width: 100,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        Colors.teal.shade900.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(8)),
                            child: ElevatedButton(
                              onPressed: (() {
                                print(MediaQuery.of(context).size.width);
                                createAccount(context);
                              }),
                              style: styleFrom,
                              child: const Text(
                                "+ Add New",
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 1,
                                    color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        Flexible(
                          child: Container(
                            height: 30,
                            width: 100,
                            decoration: BoxDecoration(
                                border: Border.all(
                                    color:
                                        Colors.teal.shade900.withOpacity(0.5)),
                                borderRadius: BorderRadius.circular(8)),
                            child: ElevatedButton(
                                onPressed: (() {}),
                                style: styleFrom,
                                child: const Row(
                                  children: [
                                    Icon(Icons.cloud_download_outlined),
                                    Text(
                                      "  Export",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: 1,
                                          color: Colors.white),
                                    ),
                                  ],
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(),
                  FutureBuilder(
                    future: _fetchUsersWithPagination(
                        _documentLimit, _lastVisibleSnapshot),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Container(
                            width: 50,
                            height: 100,
                            child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      }
                      if (snapshot.data!.docs.isEmpty) {
                        return Text('No users found.');
                      }
                      return DataTable(
                        columns: const [
                          DataColumn(
                              label: Text('#',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('ID',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Name',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Username',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Type',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Department',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Shift',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Status',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(
                              label: Text('Action',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                          // Added column for Status
                        ],
                        rows: snapshot.data!.docs
                            .map((DocumentSnapshot document) {
                          Map<String, dynamic> data =
                              document.data()! as Map<String, dynamic>;
                          DateTime? startShift = data['startShift'] != null
                              ? (data['startShift'] as Timestamp).toDate()
                              : null;
                          String shift = getShiftText(startShift);
                          String userId = document.id;

                          bool isActive = data['isActive'] ??
                              false; // Assuming isActive is the boolean field for account status

                          Color? rowColor = index % 2 == 0
                              ? Colors.white
                              : Colors.grey[200]; // Alternating row colors
                          index++; //

                          return DataRow(
                              color: MaterialStateColor.resolveWith(
                                  (states) => rowColor!),
                              cells: [
                                DataCell(Text(index.toString())),
                                DataCell(Text(data['employeeId'].toString())),
                                DataCell(
                                    Text('${data['fname']} ${data['lname']}')),
                                DataCell(Text(data['username'].toString())),
                                DataCell(Text(data['typeEmployee'].toString())),
                                DataCell(Text(data['department'].toString())),
                                DataCell(Text(shift)),
                                DataCell(
                                  Switch(
                                    value: isActive,
                                    activeColor: Colors.green,
                                    onChanged: (value) {
                                      updateAccountStatus(userId, value);
                                    },
                                  ),
                                ),
                                DataCell(
                                  ElevatedButton(
                                    onPressed: () {
                                      editUserDetails(userId, data);
                                    },
                                    child: Text('Edit'),
                                  ),
                                ),
                              ]);
                        }).toList(),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _previousPage,
                        child: Text('Previous'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: _nextPage,
                        child: Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateAccountStatus(String userId, bool isActive) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('User');

      await users.doc(userId).update({'isActive': isActive});

      setState(() {});
      showSuccess(
          context, 'Status Update', 'Account status updated successfully.');
      print('Account status updated successfully.');
    } catch (e) {
      showError(context, 'Error', 'Error updating account status: $e');
      print('Error updating account status: $e');
    }
  }

  void editUserDetails(String userId, Map<String, dynamic> userData) {
    TextEditingController firstNameController =
        TextEditingController(text: userData['fname']);
    TextEditingController lastNameController =
        TextEditingController(text: userData['lname']);
    TextEditingController usernameController =
        TextEditingController(text: userData['username']);
    TextEditingController typeEmployeeController =
        TextEditingController(text: userData['typeEmployee']);
    TextEditingController departmentController =
        TextEditingController(text: userData['department']);
    DateTime? startShift = userData['startShift'] != null
        ? (userData['startShift'] as Timestamp).toDate()
        : null;
    DateTime? endShift = userData['endShift'] != null
        ? (userData['endShift'] as Timestamp).toDate()
        : null;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? startselectedShift = startShift;
        DateTime? endselectedShift = endShift;
        return AlertDialog(
          title: Text('Edit User Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextFormField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextFormField(
                  controller: usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                TextFormField(
                  controller: typeEmployeeController,
                  decoration: const InputDecoration(labelText: 'Employee Type'),
                ),
                TextFormField(
                  controller: departmentController,
                  decoration: const InputDecoration(labelText: 'Department'),
                ),
                DateTimeField(
                  decoration: const InputDecoration(labelText: 'Start Shift'),
                  initialDate: startselectedShift,
                  mode: DateTimeFieldPickerMode.time,
                  onChanged: (value) {
                    startselectedShift = value;
                  },
                ),
                DateTimeField(
                  decoration: InputDecoration(labelText: 'End Shift'),
                  initialDate: endselectedShift,
                  mode: DateTimeFieldPickerMode.time,
                  onChanged: (value) {
                    endselectedShift = value;
                  },
                ),
              ],
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> updatedUserData = {
                  'fname': firstNameController.text,
                  'lname': lastNameController.text,
                  'username': usernameController.text,
                  'typeEmployee': typeEmployeeController.text,
                  'department': departmentController.text,
                  'startShift': startselectedShift,
                  'endShift': endselectedShift,
                };
                await updateUserDetails(userId, updatedUserData);
                Navigator.of(context).pop();

                setState(() {});
              },
              child: Text('Save'),
            ),
            ElevatedButton(
              onPressed: () {
                resetPassword(userData['email']);
                Navigator.of(context).pop();
              },
              child: Text('Reset Password'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updateUserDetails(
      String userId, Map<String, dynamic> updatedUserData) async {
    try {
      await FirebaseFirestore.instance
          .collection('User')
          .doc(userId)
          .update(updatedUserData);
      Navigator.pop(context);
      showSuccess(context, 'Update', 'User details updated successfully!');
      print('User details updated successfully!');
    } catch (error) {
      print('Error updating user details: $error');
    }
  }

  String getShiftText(DateTime? startShift) {
    if (startShift != null) {
      return startShift.hour < 12 ? 'Morning' : 'Afternoon';
    } else {
      return 'No Shift';
    }
  }

  Future<dynamic> createAccount(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext Context) {
        const textStyle = TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        );
        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          child: Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: SingleChildScrollView(
              child: SizedBox(
                width: 1170,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(Icons.close),
                        )
                      ],
                    ),
                    const Center(
                      child: Text(
                        'Account Form',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                        ),
                      ),
                    ),
                    const Center(
                      child: Text(
                        'Fill out the form carefully',
                        style: TextStyle(fontStyle: FontStyle.italic),
                      ),
                    ),
                    Text(
                      'Personal Information :',
                      style: catergoryStyle(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('First Name'),
                            Container(
                              width: 280,
                              height: 40,
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              decoration: boxdecoration(),
                              child: TextField(
                                controller: firstNameController,
                                decoration: const InputDecoration(
                                    labelText: 'Enter First Name',
                                    border: InputBorder.none),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Last Name'),
                            Container(
                              width: 280,
                              height: 40,
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              decoration: boxdecoration(),
                              child: TextField(
                                controller: lastNameController,
                                decoration: const InputDecoration(
                                    labelText: 'Enter Last Name',
                                    border: InputBorder.none),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Mobile'),
                            Container(
                              width: 280,
                              height: 40,
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              decoration: boxdecoration(),
                              child: TextField(
                                decoration: const InputDecoration(
                                    labelText: 'Enter Mobile',
                                    border: InputBorder.none),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Employee ID'),
                            Container(
                              width: 280,
                              height: 40,
                              padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                              decoration: boxdecoration(),
                              child: TextField(
                                controller: employeeIdController,
                                decoration: const InputDecoration(
                                    labelText: 'Enter Employee ID',
                                    border: InputBorder.none),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Employment Information :',
                      style: catergoryStyle(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Department:', style: textStyle),
                            Container(
                              width: 280,
                              height: 40,
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 25),
                              decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12)),
                              child: DropdownMenu<String>(
                                width: 280,
                                inputDecorationTheme: InputDecorationTheme(
                                  border: InputBorder.none,
                                ),
                                trailingIcon: Icon(Icons.arrow_drop_down),
                                initialSelection: selectedDep,
                                onSelected: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    selectedDep = value!;
                                  });
                                },
                                dropdownMenuEntries: [
                                  'Select Department',
                                  'IT',
                                  'HR',
                                  'Security'
                                ].map<DropdownMenuEntry<String>>(
                                    (String value) {
                                  return DropdownMenuEntry<String>(
                                      value: value, label: value);
                                }).toList(),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Role:',
                              style: textStyle,
                            ),
                            Container(
                              width: 280,
                              height: 40,
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 25),
                              decoration: boxdecoration(),
                              child: DropdownMenu<String>(
                                width: 280,
                                inputDecorationTheme: InputDecorationTheme(
                                  border: InputBorder.none,
                                ),
                                trailingIcon: Icon(Icons.arrow_drop_down),
                                initialSelection: selectedRole,
                                onSelected: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    selectedRole = value!;
                                  });
                                },
                                dropdownMenuEntries: [
                                  'Select Role',
                                  'Admin',
                                  'Employee'
                                ].map<DropdownMenuEntry<String>>(
                                    (String value) {
                                  return DropdownMenuEntry<String>(
                                      value: value, label: value);
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Employee Status:',
                              style: textStyle,
                            ),
                            Container(
                              width: 280,
                              height: 40,
                              padding: const EdgeInsets.fromLTRB(5, 0, 5, 25),
                              decoration: boxdecoration(),
                              child: DropdownMenu<String>(
                                width: 280,
                                inputDecorationTheme: InputDecorationTheme(
                                  border: InputBorder.none,
                                ),
                                trailingIcon: Icon(Icons.arrow_drop_down),
                                initialSelection: typeEmployee,
                                onSelected: (String? value) {
                                  // This is called when the user selects an item.
                                  setState(() {
                                    typeEmployee = value!;
                                  });
                                },
                                dropdownMenuEntries: [
                                  'Type of Employee',
                                  'Regular',
                                  'Contractual'
                                ].map<DropdownMenuEntry<String>>(
                                    (String value) {
                                  return DropdownMenuEntry<String>(
                                      value: value, label: value);
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Shift',
                              style: textStyle,
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 120,
                                  height: 40,
                                  padding: EdgeInsets.all(2),
                                  decoration: boxdecoration(),
                                  child: DateTimeFormField(
                                    decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.only(bottom: 15),
                                        hintText: 'Start',
                                        suffixIcon: Icon(Icons.timer)),
                                    mode: DateTimeFieldPickerMode.time,
                                    onDateSelected: (DateTime value) {
                                      print(value);
                                    },
                                    onChanged: (DateTime? value) {},
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  width: 120,
                                  height: 40,
                                  padding: EdgeInsets.all(2),
                                  decoration: boxdecoration(),
                                  child: DateTimeFormField(
                                    decoration: const InputDecoration(
                                        hintText: 'End',
                                        contentPadding:
                                            EdgeInsets.only(bottom: 15),
                                        border: InputBorder.none,
                                        suffixIcon: Icon(Icons.timer)),
                                    mode: DateTimeFieldPickerMode.time,
                                    onDateSelected: (DateTime value) {
                                      print(value);
                                    },
                                    onChanged: (DateTime? value) {},
                                  ),
                                )
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Tax and Identification Information',
                      style: catergoryStyle(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SSS',
                              style: textStyle,
                            ),
                            Container(
                              width: 280,
                              height: 40,
                              padding: EdgeInsets.all(8),
                              decoration: boxdecoration(),
                              child: TextField(
                                controller: sssController,
                                decoration: const InputDecoration(
                                  labelText: 'Enter SSS',
                                  border: InputBorder.none,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'TIN',
                              style: textStyle,
                            ),
                            Container(
                              width: 280,
                              height: 40,
                              padding: EdgeInsets.all(8),
                              decoration: boxdecoration(),
                              child: TextField(
                                controller: tinController,
                                decoration: const InputDecoration(
                                  labelText: 'Enter TIN',
                                  border: InputBorder.none,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tax Code',
                              style: textStyle,
                            ),
                            Container(
                              width: 280,
                              height: 40,
                              padding: EdgeInsets.all(8),
                              decoration: boxdecoration(),
                              child: TextField(
                                controller: taxCodeController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Enter TaxCode',
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Account Information',
                      style: catergoryStyle(),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Email',
                              style: textStyle,
                            ),
                            Container(
                              width: 280,
                              height: 40,
                              padding: EdgeInsets.all(8),
                              decoration: boxdecoration(),
                              child: TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Enter Email',
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Username',
                              style: textStyle,
                            ),
                            Container(
                              width: 280,
                              height: 40,
                              padding: EdgeInsets.all(8),
                              decoration: boxdecoration(),
                              child: TextField(
                                controller: taxCodeController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Enter Username',
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: textStyle,
                            ),
                            Container(
                              width: 280,
                              height: 40,
                              padding: EdgeInsets.all(2),
                              decoration: boxdecoration(),
                              child: TextField(
                                obscureText: !passwordVisible,
                                controller: passwordController,
                                decoration: InputDecoration(
                                  labelText: '',
                                  border: InputBorder.none,
                                  suffixIcon: IconButton(
                                    icon: Icon(passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () {
                                      setState(() {
                                        passwordVisible = !passwordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: (() {
                            register(context);
                          }),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade800,
                            padding: const EdgeInsets.all(18.0),
                            minimumSize: const Size(200, 50),
                            maximumSize: const Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Create Account",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static TextStyle catergoryStyle() {
    return TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.black12.withOpacity(0.5),
        fontStyle: FontStyle.normal);
  }

  static BoxDecoration boxdecoration() {
    return BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: Colors.white,
        borderRadius: BorderRadius.circular(12));
  }

  DataColumn ColumnInput(String Label) {
    return DataColumn(
        label: Text(
      Label,
      style: const TextStyle(
        fontWeight: FontWeight.w900,
      ),
    ));
  }

  DataRow RowInputs(String num, String name, String username, String password) {
    bool pass = false;
    var pas1ength = password.length;
    return DataRow(cells: [
      DataCell(Text(num)),
      DataCell(Text(name)),
      DataCell(Text(username)),
      DataCell(Row(
        children: [
          Text(passwordVisible ? password : '*' * pas1ength),
          IconButton(
            icon:
                Icon(passwordVisible ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() {
                passwordVisible = !passwordVisible;
              });
            },
          )
        ],
      )),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              //createAccount(context, 'Update Account');
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.delete,
              color: Colors.red,
            ),
            onPressed: () {},
          ),
        ],
      )),
    ]);
  }

  register(context) async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);
      // Create the user object with the entered data
      User newUser = User(
        department: selectedDep,
        fname: firstNameController.text,
        mname: middleNameController.text,
        lname: lastNameController.text,
        email: emailController.text,
        endShift: DateTime.now(), // Change this to selected date
        startShift: DateTime.now(), // Change this to selected date
        role: selectedRole,
        username: usernameController.text,
        typeEmployee: typeEmployee,
        sss: sssController.text,
        tin: tinController.text,
        taxCode: taxCodeController.text,
        employeeId: employeeIdController.text,
        mobilenum: mobilenumController.text,
      );

      await addUser(
        newUser.username,
        newUser.fname,
        newUser.mname,
        newUser.lname,
        newUser.email,
        newUser.startShift,
        newUser.endShift,
        newUser.role,
        newUser.department,
        newUser.typeEmployee,
        newUser.sss,
        newUser.tin,
        newUser.taxCode,
        newUser.employeeId,
        newUser.mobilenum,
      );

      Navigator.pop(context); // Close the dialog or navigate to the next screen
      showSuccess(context, 'Create', 'Account has been created.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast('The account already exists for that email.');
      } else if (e.code == 'invalid-email') {
        showToast('The email address is not valid.');
      } else {
        showToast(e.toString());
      }
    } catch (e) {
      // Handle other exceptions
      print("An error occurred: $e");
      showToast("An error occurred: $e");
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      showToast('Password reset email sent to $email');
    } catch (e) {
      print('Error sending password reset email: $e');
      showToast('Error sending password reset email: $e');
    }
  }
}
