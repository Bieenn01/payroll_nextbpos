import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/widgets.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/view_userDetails.dart';
import 'package:project_payroll_nextbpo/backend/jsonfiles/add_users.dart';
import 'package:project_payroll_nextbpo/backend/widgets/shimmer.dart';
import 'package:project_payroll_nextbpo/backend/widgets/toast_widget.dart';
import 'package:project_payroll_nextbpo/frontend/modal.dart';
import 'package:shimmer/shimmer.dart' as ShimmerPackage;

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

class PovUser extends StatefulWidget {
  PovUser({Key? key}) : super(key: key);

  @override
  State<PovUser> createState() => _UserState();
}

class _UserState extends State<PovUser> {
  int _currentPage = 1;
  int _pageSize = 5; // Default page size

  late int _totalUsers;
  late Future<void> Function(int, DocumentSnapshot?) _fetchUsersWithPagination;
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
    _fetchUsersWithPagination = _fetchUsers;
    _fetchUsersWithPagination(_pageSize, null);
  }

  Future<QuerySnapshot> _fetchUsers(
    int limit,
    DocumentSnapshot? startAfterDocument,
  ) async {
    try {
      Query query = FirebaseFirestore.instance
          .collection('User')
          .orderBy('email')
          .limit(limit);

      if (startAfterDocument != null) {
        query = query.startAfterDocument(startAfterDocument);
      }

      return await query.get();
    } catch (e) {
      // Handle errors gracefully
      throw Exception('Failed to fetch users: $e');
    }
  }

  void _nextPage() {
    setState(() {
      _currentPage++;
      // Call your function to fetch users with pagination for the next page
      _fetchUsersWithPagination(_pageSize, _lastVisibleSnapshot);
    });
  }

  void _previousPage() {
    setState(() {
      if (_currentPage > 1) {
        _currentPage--;
        // Call your function to fetch users with pagination for the previous page
        _fetchUsersWithPagination(_pageSize, _lastVisibleSnapshot);
      }
    });
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
      body: Center(
        child: Container(
          color: Colors.teal.shade700,
          padding: EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Text(
                                "Account List",
                                style: TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        Row(children: [
                          Text('Show: '),
                          DropdownButton<int>(
                            value: _pageSize,
                            items: [5, 10, 15, 25].map((value) {
                              return DropdownMenuItem<int>(
                                value: value,
                                child: Text(value.toString()),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _pageSize = newValue!;
                                _currentPage =
                                    1; // Reset page number when changing page size
                                _fetchUsersWithPagination(_pageSize, null);
                              });
                            },
                          ),
                        ]),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Flexible(
                                child: Container(
                                  height: 30,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: Colors.black.withOpacity(0.5),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 5.0),
                                        child: Icon(Icons.search),
                                      ),
                                      Expanded(
                                        child: TextField(
                                          textAlign: TextAlign.start,
                                          decoration: InputDecoration(
                                            contentPadding: EdgeInsets.only(
                                                bottom: 15, left: 5),
                                            border: InputBorder.none,
                                            hintText: 'Search',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Container(
                                height: 30,
                                decoration: BoxDecoration(
                                    color: Colors.teal,
                                    border: Border.all(
                                        color: Colors.teal.shade900
                                            .withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(8)),
                                child: ElevatedButton(
                                  onPressed: (() {
                                    print(MediaQuery.of(context).size.width);
                                    createAccount(context);
                                  }),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                  ),
                                  child: Text(
                                    "+ Add New",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              SizedBox(width: 5),
                              Container(
                                height: 30,
                                decoration: BoxDecoration(
                                    color: Colors.teal,
                                    border: Border.all(
                                        color: Colors.teal.shade900
                                            .withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(8)),
                                child: ElevatedButton(
                                    onPressed: (() {}),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.teal,
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.cloud_download_outlined,
                                          color: Colors.white,
                                        ),
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
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        Divider(),
                        FutureBuilder(
                          future: _fetchUsers(_pageSize, _lastVisibleSnapshot),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                snapshot.data == null) {
                              return _buildShimmerLoading(); // Show shimmer loading while waiting for data
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.data!.docs.isEmpty) {
                              return Text('No users found.');
                            }
                            return SizedBox(
                              height: 500,
                              child: Expanded(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.vertical,
                                  child: SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: DataTable(
                                      columns: const [
                                        DataColumn(
                                          label: Text('#',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        DataColumn(
                                          label: Text('ID',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        DataColumn(
                                          label: Text('Name',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        DataColumn(
                                          label: Text('Username',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        DataColumn(
                                          label: Text('Type',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        DataColumn(
                                          label: Text('Department',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        DataColumn(
                                          label: Text('Shift',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),

                                        DataColumn(
                                          label: Text('Active Status',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        DataColumn(
                                          label: Text('Action',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        // Added column for Status
                                      ],
                                      rows: snapshot.data!.docs
                                          .map((DocumentSnapshot document) {
                                        Map<String, dynamic> data = document
                                            .data()! as Map<String, dynamic>;
                                        DateTime? startShift =
                                            data['startShift'] != null
                                                ? (data['startShift']
                                                        as Timestamp)
                                                    .toDate()
                                                : null;
                                        String shift = getShiftText(startShift);
                                        String userId = document.id;
                                        bool isActive =
                                            data['isActive'] ?? false;

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
                                              DataCell(Text(index.toString())),
                                              DataCell(Text(data['employeeId']
                                                  .toString())),
                                              DataCell(Text(
                                                  '${data['fname']} ${data['lname']}')),
                                              DataCell(Text(
                                                  data['username'].toString())),
                                              DataCell(Text(data['typeEmployee']
                                                  .toString())),
                                              DataCell(Text(data['department']
                                                  .toString())),
                                              DataCell(Text(shift)),
                                              DataCell(
                                                Switch(
                                                  activeColor: Colors.green,
                                                  value: isActive,
                                                  onChanged: (value) {
                                                    updateAccountStatus(
                                                        userId, value);
                                                  },
                                                ),
                                              ),
                                              DataCell(
                                                Container(
                                                  width: 100,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      editUserDetails(
                                                          userId, data);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Icon(
                                                          Icons.edit_document,
                                                          color: Colors.blue,
                                                          size: 18,
                                                        ),
                                                        Text(
                                                          'Edit',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.blue),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ]);
                                      }).toList(),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        Divider(),
                        SizedBox(height: 20),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _previousPage,
                                child: Text('Previous'),
                              ),
                              SizedBox(width: 10),
                              Text('Page $_currentPage'),
                              SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: _nextPage,
                                child: Text('Next'),
                              ),
                            ]),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
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
            5, // You can change this to the number of shimmer rows you want
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

  Future<void> updateAccountStatus(String userId, bool isActive) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('User');

      await users.doc(userId).update({'isActive': isActive});

      setState(() {});

      // showSuccess(
      //     context, 'Status Update', 'Account status updated successfully.');
      passwordVerification(context);
      print('Account status updated successfully.');
    } catch (e) {
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
                child: Flexible(
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
      showSuccess(context, 'Create', 'Account has been created successfully.');
      showToast("Registered Successfully!");
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
