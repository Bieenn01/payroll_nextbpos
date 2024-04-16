import 'dart:math';
import 'dart:async';
import 'dart:io';
import 'dart:js_interop';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:project_payroll_nextbpo/backend/jsonfiles/add_users.dart';
import 'package:project_payroll_nextbpo/backend/widgets/toast_widget.dart';
import 'package:project_payroll_nextbpo/frontend/modal.dart';
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

class User {
  String department;
  String email;
  DateTime endShift;
  String fname;
  DateTime startShift;
  String role;
  String mname;
  String lname;
  String genderEmployee;
  String username;
  String typeEmployee;
  String sss;
  String tin;
  String taxCode;
  String employeeId;
  String mobilenum;
  // ignore: non_constant_identifier_names
  double monthly_salary;
  bool isActive;
  bool isATM;
  User(
      {required this.department,
      required this.email,
      // ignore: non_constant_identifier_names
      required this.monthly_salary,
      required this.endShift,
      required this.fname,
      required this.startShift,
      required this.role,
      required this.mname,
      required this.lname,
      required this.genderEmployee,
      required this.username,
      required this.typeEmployee,
      required this.sss,
      required this.tin,
      required this.taxCode,
      required this.employeeId,
      required this.mobilenum,
      required this.isActive,
      required this.isATM});
}

class UsernameGenerator {
  static String generateUsername(
      String firstName, String lastName, String contactNumber) {
    String firstNamePart =
        firstName.substring(0, min(4, firstName.length)).toLowerCase();
    String lastNamePart =
        lastName.substring(0, min(3, lastName.length)).toLowerCase();
    String lastThreeDigits =
        contactNumber.substring(max(0, contactNumber.length - 3));
    String specialCharacter =
        ['!', '@', '#', '%', '^', '&', '*'][Random().nextInt(8)];

    return '$firstNamePart$lastNamePart$lastThreeDigits$specialCharacter';
  }
}

class PovUser extends StatefulWidget {
  PovUser({Key? key}) : super(key: key);

  @override
  State<PovUser> createState() => _UserState();
}

class _UserState extends State<PovUser> {
  int _currentPage = 1;
  int _pageSize = 5; // Default page size

  late Future<void> Function(int, DocumentSnapshot?) _fetchUsersWithPagination;
  List<List<dynamic>> excelData = [];

  DateTime? selectedDate;
  DateTime? selectedTime;
  DateTime? selectedDateTime;
  bool passwordVisible = false;
  int index = 0;

  List<DocumentSnapshot> _allDocs = []; // Store all fetched documents
  List<DocumentSnapshot> _displayedDocs =
      []; // Documents to display on the current page

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController salaryController = TextEditingController();
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

  String selectedSort = "";
  String selectedDepartment = 'All';
  String selectedrole = 'All';
  String selectedType = 'All';
  String selectedStatus = "All";
  String selectedShift = 'All';
  String selectedRole = 'Select Role';
  String selectedDep = 'Select Department';
  String typeEmployee = 'Type of Employee';
  String genderEmployee = 'Select Gender';
  late String _role = 'Guest';
  late String _userName = 'Guest';
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchRole();
    _fetchUsersWithPagination = _fetchUsers;
    _fetchUsersWithPagination(_pageSize, null);
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

  Future<QuerySnapshot> _fetchUsers(
    int pageSize,
    DocumentSnapshot? startAfterDocument,
  ) async {
    try {
      Query query = FirebaseFirestore.instance.collection('User');

      return await query.get();
    } catch (e) {
      // Handle errors gracefully
      throw Exception('Failed to fetch users: $e');
    }
  }

  void _nextPage() {
    setState(() {
      if (_currentPage <= _pageSize) {
        _currentPage++;
        // Call your function to fetch users with pagination for the previous page
        _fetchUsersWithPagination(_pageSize, _lastVisibleSnapshot);
      }
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

// Initialize _lastVisibleSnapshot as null
  DocumentSnapshot? _lastVisibleSnapshot;

// Initialize _users as an empty list

  void updateUsername() {
    String firstName = firstNameController.text;
    String lastName = lastNameController.text;
    String num = mobilenumController.text;
    String generatedUsername =
        UsernameGenerator.generateUsername(firstName, lastName, num);
    usernameController.text = generatedUsername;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.teal.shade700,
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.arrow_back),
                      ),
                      const Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                              "Account List",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 7,
                child: SingleChildScrollView(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(15, 5, 15, 15),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        searchFilter(context),
                        const Divider(),
                        dataTable(),
                        const Divider(),
                        const SizedBox(height: 5),
                        pagination(),
                        const SizedBox(height: 20),
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

  Row pagination() {
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
              border: Border.all(color: Colors.grey.shade200)),
          child: Text('$_currentPage')),
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
    ]);
  }

  FutureBuilder<QuerySnapshot<Object?>> dataTable() {
    return FutureBuilder(
      future: _fetchUsers(_pageSize, _lastVisibleSnapshot),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting ||
            snapshot.data == null) {
          return _buildShimmerLoading(); // Show shimmer loading while waiting for data
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        if (snapshot.data!.docs.isEmpty) {
          return Text('No users found.');
        }

        if (snapshot.data != null && snapshot.data!.docs != null) {
          _allDocs = snapshot.data!.docs;

          int startIndex = (_currentPage - 1) * _pageSize;
          int endIndex = startIndex + _pageSize;

          // Ensure endIndex does not exceed the length of _allDocs
          if (endIndex > _allDocs.length) {
            endIndex = _allDocs.length;
          }

          //Sort Alpha Name
          if (selectedSort == 'az') {
            _allDocs.sort((a, b) {
              Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
              Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;
              String firstNameA = dataA['fname'].toLowerCase();
              String firstNameB = dataB['fname'].toLowerCase();
              return firstNameA.compareTo(firstNameB);
            });
          } else if (selectedSort == 'za') {
            _allDocs.sort((a, b) {
              Map<String, dynamic> dataA = a.data() as Map<String, dynamic>;
              Map<String, dynamic> dataB = b.data() as Map<String, dynamic>;
              String firstNameA = dataA['fname'].toLowerCase();
              String firstNameB = dataB['fname'].toLowerCase();
              return firstNameB.compareTo(firstNameA);
            });
          }
          List<DocumentSnapshot> userRecords = _role == 'Employee'
              ? snapshot.data!.docs
                  .where((doc) => doc['userId'] == getCurrentUserId())
                  .toList()
              : snapshot.data!.docs;

          List<DocumentSnapshot> filteredDocs = userRecords.where((document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String employeeId = data['employeeId'];
            String fname = data['fname'];
            String mname = data['mname'];
            String lname = data['lname'];
            String query = _searchController.text.toLowerCase();
            bool matchesSearchQuery =
                employeeId.toLowerCase().contains(query) ||
                    fname.toLowerCase().contains(query) ||
                    mname.toLowerCase().contains(query) ||
                    lname.toLowerCase().contains(query);
            return matchesSearchQuery;
          }).toList();

          List<DocumentSnapshot> filteredDocuments = filteredDocs;
          if (selectedDepartment != 'All') {
            filteredDocuments = filteredDocuments
                .where((doc) => doc['department'] == selectedDepartment)
                .toList();
          }
          if (selectedrole != 'All') {
            filteredDocuments = filteredDocuments
                .where((doc) => doc['role'] == selectedrole)
                .toList();
          }
          if (selectedType != 'All') {
            filteredDocuments = filteredDocuments
                .where((doc) => doc['typeEmployee'] == selectedType)
                .toList();
          }

          if (endIndex > filteredDocs.length) {
            endIndex = filteredDocs.length;
          }

          // Ensure startIndex is within the bounds of _allDocs
          if (startIndex >= 0 &&
              endIndex >= 0 &&
              startIndex < filteredDocuments.length &&
              endIndex <= filteredDocuments.length) {
            _displayedDocs = filteredDocuments.sublist(startIndex, endIndex);
          } else {
            // Handle invalid index range
            print("Invalid index range");
          }
        } else {
          // Handle null data or null docs
          print("Snapshot data or docs is null");
        }

        excelData = [];

        var dataTable = DataTable(
          columns: [
            const DataColumn(
              label: Flexible(
                child: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const DataColumn(
              label: Flexible(
                child:
                    Text('ID', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            DataColumn(
              label: Container(
                width: 180,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
                    PopupMenuButton<String>(
                        child: Icon(Icons.more_vert),
                        onSelected: (String value) {
                          setState(() {
                            selectedSort = value;
                          });
                        },
                        itemBuilder: (BuildContext context) => [
                              const PopupMenuItem<String>(
                                value: 'az',
                                child: Row(
                                  children: [
                                    Text('Alphabetical A-Z'),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_downward),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'za',
                                child: Row(
                                  children: [
                                    Text('Alphabetical Z-A'),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_upward),
                                  ],
                                ),
                              ),
                              const PopupMenuItem<String>(
                                value: 'None',
                                child: Row(
                                  children: [
                                    Text('None'),
                                    SizedBox(width: 8),
                                  ],
                                ),
                              ),
                            ]),
                  ],
                ),
              ),
            ),
            const DataColumn(
              label: Flexible(
                child: Text('Username',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            DataColumn(
              label: Flexible(
                child: PopupMenuButton<String>(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Type',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_drop_down)
                    ],
                  ),
                  onSelected: (String value) {
                    setState(() {
                      selectedType = value;
                    });
                  },
                  itemBuilder: (BuildContext context) => [
                    'All', // Default option
                    'Regular',
                    'Contractual',
                  ].map((String value) {
                    return PopupMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
            DataColumn(
              label: PopupMenuButton<String>(
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
            DataColumn(
              label: Flexible(
                child: Text(
                  'Shift',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            DataColumn(
              label: Flexible(
                child: PopupMenuButton<String>(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Role',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_drop_down)
                    ],
                  ),
                  onSelected: (String value) {
                    setState(() {
                      selectedrole = value;
                    });
                  },
                  itemBuilder: (BuildContext context) => [
                    'All', // Default option
                    'Admin',
                    'Employee',
                    'Superadmin',
                  ].map((String value) {
                    return PopupMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),

            DataColumn(
              label: Flexible(
                child: PopupMenuButton<String>(
                    child: Row(
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('Active',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Status',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        Icon(Icons.arrow_drop_down)
                      ],
                    ),
                    onSelected: (String value) {
                      setState(() {
                        selectedStatus = value;
                      });
                    },
                    itemBuilder: (BuildContext context) => [
                          const PopupMenuItem<String>(
                            value: 'true',
                            child: Row(
                              children: [
                                Text('Active'),
                              ],
                            ),
                          ),
                          const PopupMenuItem<String>(
                            value: 'false',
                            child: Row(
                              children: [
                                Text('Deactive'),
                              ],
                            ),
                          ),
                        ]),
              ),
            ),
            const DataColumn(
              label: Flexible(
                child:
                    Text('ATM', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const DataColumn(
              label: Flexible(
                child: Text('Action',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            // Added column for Status
          ],
          rows: List.generate(
            _displayedDocs.length,
            (index) {
              DocumentSnapshot document = _displayedDocs[index];
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              DateTime? startShift = data['startShift'] != null
                  ? (data['startShift'] as Timestamp).toDate()
                  : null;
              String shift = getShiftText(startShift);
              String userId = document.id;
              bool isActive = data['isActive'] ?? false;
              bool isATM = data['isATM'] ?? false;

              // Calculate the real index based on the current page and page size
              int realIndex = index + 1;

              Color? rowColor =
                  realIndex % 2 == 0 ? Colors.white : Colors.grey[200];

              excelData.add([
                (index).toString(),
                data['employeeID'] ?? 'Unknown',
                data['fname'] ?? 'Unknown',
                data['mname'] ?? 'Unknown',
                data['lname'] ?? 'Unknown',
                data['username'] ?? 'Unknown',
                data['email'] ?? 'Unknown',
                data['typeEmployee'] ?? 'Unknown',
                data['department'] ?? 'Unknown',
                shift,
                data['role'] ?? 'Unknown',
                data['isActive'] ?? 'Unknown',
                data['isATM'] ?? 'Unknown',
              ]);

              return DataRow(
                color: MaterialStateColor.resolveWith((states) => rowColor!),
                cells: [
                  DataCell(Text(realIndex.toString())),
                  DataCell(Text(data['employeeId'].toString())),
                  DataCell(Text(
                      '${data['fname']} ${data['mname']} ${data['lname']}')),
                  DataCell(Text(data['username'].toString())),
                  DataCell(Text(data['typeEmployee'].toString())),
                  DataCell(Text(data['department'].toString())),
                  DataCell(Text(shift)),
                  DataCell(Text(data['role'].toString())),
                  DataCell(
                    SizedBox(
                      width: 50,
                      height: 30,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Switch(
                          value: isActive,
                          activeColor: Colors.green,
                          onChanged: (value) async {
                            if (!value) {
                              bool verificationResult =
                                  await passwordVerification(context);
                              if (verificationResult) {
                                updateAccountStatus(userId, value);
                                showToast("User Deactivated");
                              } else {
                                // Handle unsuccessful or canceled verification
                              }
                            } else {
                              updateAccountStatus(userId, value);
                              showToast("User Activated");
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    SizedBox(
                      width: 50,
                      height: 30,
                      child: FittedBox(
                        fit: BoxFit.fill,
                        child: Switch(
                          value: isATM,
                          activeColor: Colors.blue,
                          onChanged: (value) async {
                            if (!value) {
                              bool verificationResult =
                                  await passwordVerification(context);
                              if (verificationResult) {
                                updateATM(userId, value);
                                showToast("User Deactivated");
                              } else {
                                // Handle unsuccessful or canceled verification
                              }
                            } else {
                              updateATM(userId, value);
                              showToast("User Activated");
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      width: 100,
                      child: ElevatedButton(
                        onPressed: () {
                          editUserDetails(userId, data);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Icon(
                              Icons.edit_document,
                              color: Colors.blue,
                              size: 18,
                            ),
                            Text(
                              'Edit',
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
        return MediaQuery.of(context).size.width > 1300
            ? SizedBox(
                height: 650,
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: dataTable,
                ))
            : SizedBox(
                height: 650,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: dataTable,
                  ),
                ));
      },
    );
  }

  Container searchFilter(BuildContext context) {
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
                          value: _pageSize,
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
                                  _pageSize = newValue;
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
                    value: _pageSize,
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
                            _pageSize = newValue;
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Flexible(
                        child: Container(
                          width: 400,
                          height: 30,
                          margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                          padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.black.withOpacity(0.5),
                            ),
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
                              setState(() {
                                // Trigger user fetching with pagination
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10),
                Flexible(
                  child: Container(
                    width: 130,
                    height: 30,
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        color: Colors.teal,
                        border: Border.all(
                            color: Colors.teal.shade900.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8)),
                    child: ElevatedButton(
                      onPressed: (() {
                        print(MediaQuery.of(context).size.width);
                        createAccount(context);
                      }),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          padding: EdgeInsets.all(3)),
                      child: MediaQuery.of(context).size.width > 800
                          ? const Text(
                              "+ Add New",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1,
                                  color: Colors.white),
                            )
                          : const Text(
                              '+',
                              style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 1,
                                  color: Colors.white),
                            ),
                    ),
                  ),
                ),
                SizedBox(width: 5),
                Flexible(
                  child: Container(
                    width: MediaQuery.of(context).size.width > 600
                        ? 150
                        : 50, // or use MediaQuery.of(context).size.width > 600 ? 150 : 50
                    height: 30,
                    padding: EdgeInsets.all(0),
                    margin: EdgeInsets.all(0),
                    decoration: BoxDecoration(
                        color: Colors.teal,
                        border: Border.all(
                            color: Colors.teal.shade900.withOpacity(0.5)),
                        borderRadius: BorderRadius.circular(8)),
                    child: ElevatedButton(
                        onPressed: (() {
                          _exportToExcel();
                        }),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            padding: EdgeInsets.all(3)),
                        child: MediaQuery.of(context).size.width > 800
                            ? const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                              )
                            : const Icon(
                                Icons.cloud_download_outlined,
                                color: Colors.white,
                              )),
                  ),
                ),
              ],
            ),
          ),
        ],
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

  Future<void> updateAccountStatus(String userId, bool isActive) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('User');

      users.doc(userId).update({'isActive': isActive});

      setState(() {});

      // showSuccess(
      //     context, 'Status Update', 'Account status updated successfully.');

      print('Account status updated successfully.');
    } catch (e) {
      print('Error updating account status: $e');
    }
  }

  Future<void> updateATM(String userId, bool isATM) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('User');

      users.doc(userId).update({'isATM': isATM});

      setState(() {});

      // showSuccess(
      //     context, 'Status Update', 'Account status updated successfully.');

      print('Account status updated successfully.');
    } catch (e) {
      print('Error updating account status: $e');
    }
  }

  void editUserDetails(String userId, Map<String, dynamic> userData) {
    TextEditingController firstNameController =
        TextEditingController(text: userData['fname'].toString());
    TextEditingController middleNameController =
        TextEditingController(text: userData['mname'].toString());
    TextEditingController lastNameController =
        TextEditingController(text: userData['lname'].toString());
    TextEditingController usernameController =
        TextEditingController(text: userData['username'].toString());
    TextEditingController emailController =
        TextEditingController(text: userData['email'].toString());
    TextEditingController mobilenumController =
        TextEditingController(text: userData['mobilenum'].toString());
    TextEditingController employeeIdController =
        TextEditingController(text: userData['employeeId'].toString());
    TextEditingController tinController =
        TextEditingController(text: userData['tin'].toString());
    TextEditingController sssController =
        TextEditingController(text: userData['sss'].toString());
    TextEditingController taxCodeController =
        TextEditingController(text: userData['taxCode'].toString());
    TextEditingController salaryController =
        TextEditingController(text: userData['monthly_salary'].toString());
    DateTime? startShift = userData['startShift'] != null
        ? (userData['startShift'] as Timestamp).toDate()
        : null;
    DateTime? endShift = userData['endShift'] != null
        ? (userData['endShift'] as Timestamp).toDate()
        : null;

    List<String> departmentChoices = ['IT', 'HR', 'ACCOUNTING', 'SERVICING'];
    List<String> roleChoices = ['Employee', 'Admin', 'Superadmin'];
    List<String> employeeTypeChoices = ['Regular', 'Contractual'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? startselectedShift = startShift;
        DateTime? endselectedShift = endShift;
        String selectedDepartment = userData['department'] ?? '';
        String selectedRole = userData['role'] ?? '';
        String selectedEmployeeType = userData['typeEmployee'] ?? '';

        if (!departmentChoices.contains(selectedDepartment)) {
          selectedDepartment = departmentChoices.first;
        }

        if (!roleChoices.contains(selectedRole)) {
          selectedRole = roleChoices.first;
        }

        if (!employeeTypeChoices.contains(selectedEmployeeType)) {
          selectedEmployeeType = employeeTypeChoices.first;
        }

        return AlertDialog(
          surfaceTintColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Edit User Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                ),
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close),
              )
            ],
          ),
          content: SingleChildScrollView(
            child: Container(
              width: 900,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(8)),
              child: Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('First Name'),
                              Container(
                                width: 280,
                                height: 40,
                                padding: EdgeInsets.only(left: 5),
                                decoration: boxdecoration(),
                                child: TextFormField(
                                  controller: firstNameController,
                                  onChanged: (_) {
                                    updateUsername();
                                  },
                                  decoration: const InputDecoration(
                                      hintText: 'Enter First Name',
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Middle Name'),
                              Container(
                                width: 280,
                                height: 40,
                                decoration: boxdecoration(),
                                padding: EdgeInsets.only(left: 5),
                                child: TextFormField(
                                  controller: middleNameController,
                                  onChanged: (_) {
                                    updateUsername();
                                  },
                                  decoration: const InputDecoration(
                                      hintText: 'Enter Middle Name',
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Last Name'),
                              Container(
                                width: 280,
                                height: 40,
                                decoration: boxdecoration(),
                                padding: EdgeInsets.only(left: 5),
                                child: TextFormField(
                                  controller: lastNameController,
                                  onChanged: (_) {
                                    updateUsername();
                                  },
                                  decoration: const InputDecoration(
                                      hintText: 'Enter Last Name',
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Mobile Number'),
                              Container(
                                width: 280,
                                height: 40,
                                padding: EdgeInsets.only(left: 5),
                                decoration: boxdecoration(),
                                child: TextFormField(
                                  controller: mobilenumController,
                                  onChanged: (_) {
                                    updateUsername();
                                  },
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                        11), // Limit to 10 digits
                                    TextInputFormatter.withFunction(
                                        (oldValue, newValue) {
                                      if (newValue.text.isEmpty) {
                                        return newValue.copyWith(text: '');
                                      }
                                      final int textLength =
                                          newValue.text.length;
                                      String newText = '';
                                      for (int i = 0; i < textLength; i++) {
                                        if (i == 0) {
                                          newText += '(' + newValue.text[i];
                                        } else if (i == 3) {
                                          newText += ') ' + newValue.text[i];
                                        } else if (i == 7) {
                                          newText += ' ' + newValue.text[i];
                                        } else {
                                          newText += newValue.text[i];
                                        }
                                      }
                                      return newValue.copyWith(
                                        text: newText,
                                        selection: TextSelection.collapsed(
                                            offset: newText.length),
                                      );
                                    }),
                                  ],
                                  decoration: const InputDecoration(
                                      hintText: 'Enter Mobile Number',
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Gender:',
                              ),
                              Container(
                                width: 280,
                                height: 40,
                                padding: const EdgeInsets.only(left: 10),
                                decoration: boxdecoration(),
                                child: DropdownMenu<String>(
                                  width: MediaQuery.of(context).size.width > 800
                                      ? 280
                                      : 150,
                                  inputDecorationTheme:
                                      const InputDecorationTheme(
                                    contentPadding:
                                        const EdgeInsets.only(bottom: 5),
                                    border: InputBorder.none,
                                  ),
                                  hintText: 'Select Gender',
                                  trailingIcon: Icon(Icons.arrow_drop_down),
                                  initialSelection: typeEmployee,
                                  onSelected: (String? value) {
                                    // This is called when the user selects an item.
                                    setState(() {
                                      genderEmployee = value!;
                                    });
                                  },
                                  dropdownMenuEntries: ['Male', 'Female']
                                      .map<DropdownMenuEntry<String>>(
                                          (String value) {
                                    return DropdownMenuEntry<String>(
                                        value: value, label: value);
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    Text(
                      'Employment Information :',
                      style: catergoryStyle(),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Employee ID'),
                              Container(
                                width: 280,
                                height: 40,
                                decoration: boxdecoration(),
                                padding: EdgeInsets.only(left: 5),
                                child: TextFormField(
                                  controller: employeeIdController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(
                                        6), // Limit to 10 digits
                                    TextInputFormatter.withFunction(
                                        (oldValue, newValue) {
                                      if (newValue.text.isEmpty) {
                                        return newValue.copyWith(text: '');
                                      }
                                      final int textLength =
                                          newValue.text.length;
                                      String newText = '';
                                      for (int i = 0; i < textLength; i++) {
                                        if (i == 0) {
                                          newText += '(' + newValue.text[i];
                                        } else if (i == 2) {
                                          newText += ') ' + newValue.text[i];
                                        } else {
                                          newText += newValue.text[i];
                                        }
                                      }
                                      return newValue.copyWith(
                                        text: newText,
                                        selection: TextSelection.collapsed(
                                            offset: newText.length),
                                      );
                                    }),
                                  ],
                                  decoration: const InputDecoration(
                                      hintText: 'Enter Employee ID',
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Salary'),
                              Container(
                                width: 280,
                                height: 40,
                                padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                decoration: boxdecoration(),
                                child: TextField(
                                  controller: salaryController,
                                  keyboardType: TextInputType.numberWithOptions(
                                      decimal:
                                          true), // Set keyboard type to number
                                  inputFormatters: <TextInputFormatter>[
                                    FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.]')),
                                    // Accept only digits
                                  ],
                                  decoration: const InputDecoration(
                                    hintText: 'Enter Salary',
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Department'),
                              Container(
                                width: 280,
                                height: 40,
                                decoration: boxdecoration(),
                                padding: EdgeInsets.only(left: 5),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    hintText: 'Select Department',
                                    border: InputBorder.none,
                                  ),
                                  value: selectedDepartment,
                                  items: departmentChoices.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    selectedDepartment = newValue!;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    SizedBox(height: 10),

                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),

                        // Role Dropdown
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Role'),
                              Container(
                                width: 280,
                                height: 40,
                                decoration: boxdecoration(),
                                padding: EdgeInsets.only(left: 5),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    hintText: 'Select Role',
                                    border: InputBorder.none,
                                  ),
                                  value: selectedRole,
                                  items: roleChoices.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    selectedRole = newValue!;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        // Employee Type Dropdown
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Employee Type'),
                              Container(
                                width: 280,
                                height: 40,
                                decoration: boxdecoration(),
                                padding: EdgeInsets.only(left: 5),
                                child: DropdownButtonFormField<String>(
                                  decoration: InputDecoration(
                                    hintText: 'Enter Employee Type',
                                    border: InputBorder.none,
                                  ),
                                  value: selectedEmployeeType,
                                  items:
                                      employeeTypeChoices.map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(value),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    selectedEmployeeType = newValue!;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Start Shift'),
                                    Container(
                                      width: 280,
                                      height: 40,
                                      padding: EdgeInsets.only(left: 5),
                                      decoration: boxdecoration(),
                                      child: DateTimeField(
                                        decoration: const InputDecoration(
                                            suffixIcon: Icon(Icons.timer),
                                            border: InputBorder.none,
                                            hintText: 'Start Shift'),
                                        initialDate:
                                            startselectedShift, // Assign initial value here
                                        mode: DateTimeFieldPickerMode.time,
                                        onChanged: (value) {
                                          startselectedShift = value;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Flexible(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('End Shift'),
                                    Container(
                                      width: 280,
                                      height: 40,
                                      padding: EdgeInsets.only(left: 5),
                                      decoration: boxdecoration(),
                                      child: DateTimeField(
                                        decoration: InputDecoration(
                                            suffixIcon: Icon(Icons.timer),
                                            border: InputBorder.none,
                                            hintText: 'End Shift'),
                                        initialDate:
                                            endselectedShift, // Assign initial value here
                                        mode: DateTimeFieldPickerMode.time,
                                        onChanged: (value) {
                                          endselectedShift = value;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 10,
                    ),
                    // Department Dropdown
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
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SSS'),
                              Container(
                                width: 280,
                                height: 40,
                                padding: EdgeInsets.only(left: 5),
                                decoration: boxdecoration(),
                                child: TextFormField(
                                  controller: sssController,
                                  decoration: const InputDecoration(
                                      hintText: 'SSS',
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Tax Code'),
                              Container(
                                width: 280,
                                height: 40,
                                padding: EdgeInsets.only(left: 5),
                                decoration: boxdecoration(),
                                child: TextFormField(
                                  controller: taxCodeController,
                                  decoration: const InputDecoration(
                                      hintText: 'Tax Code',
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('TIN'),
                              Container(
                                width: 280,
                                height: 40,
                                padding: EdgeInsets.only(left: 5),
                                decoration: boxdecoration(),
                                child: TextFormField(
                                  controller: tinController,
                                  decoration: const InputDecoration(
                                      hintText: 'TIN',
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
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
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Username'),
                              Container(
                                width: 280,
                                height: 40,
                                padding: EdgeInsets.only(left: 5),
                                decoration: boxdecoration(),
                                child: TextFormField(
                                  controller: usernameController,
                                  decoration: const InputDecoration(
                                      hintText: 'Username',
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Email'),
                              Container(
                                width: 280,
                                height: 40,
                                padding: EdgeInsets.only(left: 5),
                                decoration: boxdecoration(),
                                child: TextFormField(
                                  controller: emailController,
                                  decoration: const InputDecoration(
                                      hintText: 'Email',
                                      border: InputBorder.none),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Map<String, dynamic> updatedUserData = {
                  'fname': firstNameController.text,
                  'mname': middleNameController.text,
                  'lname': lastNameController.text,
                  'monthly_salary': salaryController.text,
                  'username': usernameController.text,
                  'email': emailController.text,
                  'mobilenum': mobilenumController.text,
                  'employeeId': employeeIdController.text,
                  'sss': sssController.text,
                  'tin': tinController.text,
                  'taxCode': taxCodeController.text,
                  'role': selectedRole,
                  'typeEmployee': selectedEmployeeType,
                  'department': selectedDepartment,
                  'startShift': startselectedShift,
                  'endShift': endselectedShift,
                };
                await updateUserDetails(userId, updatedUserData);
                Navigator.of(context).pop();
                showSuccess(context, 'Updated', '');
                setState(() {});
              },
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
                'Save',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                resetPassword(userData['email']);
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal.shade300,
                padding: const EdgeInsets.all(18.0),
                minimumSize: const Size(200, 50),
                maximumSize: const Size(200, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Reset Password',
                style: TextStyle(letterSpacing: 1, color: Colors.white),
              ),
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

  bool _passwordVisible = false;
  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  Future<dynamic> createAccount(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext Context) {
        const textStyle = TextStyle(
          letterSpacing: 0.5,
        );

        final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

        return Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          child: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: SingleChildScrollView(
              child: SizedBox(
                width: 900,
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
                            icon: const Icon(Icons.close),
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
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('First Name'),
                                Container(
                                  width: 280,
                                  height: 40,
                                  padding:
                                      const EdgeInsets.fromLTRB(8, 5, 5, 5),
                                  decoration: boxdecoration(),
                                  child: TextField(
                                    controller: firstNameController,
                                    onChanged: (_) {
                                      updateUsername();
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[a-zA-Z]')),
                                    ],
                                    decoration: const InputDecoration(
                                        hintText: 'Enter First Name',
                                        border: InputBorder.none),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Middle Name'),
                                Container(
                                  width: 280,
                                  height: 40,
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                  decoration: boxdecoration(),
                                  child: TextField(
                                    controller: middleNameController,
                                    onChanged: (_) {
                                      updateUsername();
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[a-zA-Z]')),
                                    ],
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Middle Name',
                                        border: InputBorder.none),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Last Name'),
                                Container(
                                  width: 280,
                                  height: 40,
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                  decoration: boxdecoration(),
                                  child: TextField(
                                    controller: lastNameController,
                                    onChanged: (_) {
                                      updateUsername();
                                    },
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                          RegExp('[a-zA-Z]')),
                                    ],
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Last Name',
                                        border: InputBorder.none),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Mobile'),
                                Container(
                                  width: 280,
                                  height: 40,
                                  padding:
                                      const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                  decoration: boxdecoration(),
                                  child: TextField(
                                    controller: mobilenumController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(
                                          11), // Limit to 10 digits
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        if (newValue.text.isEmpty) {
                                          return newValue.copyWith(text: '');
                                        }
                                        final int textLength =
                                            newValue.text.length;
                                        String newText = '';
                                        for (int i = 0; i < textLength; i++) {
                                          if (i == 0) {
                                            newText += '(' + newValue.text[i];
                                          } else if (i == 3) {
                                            newText += ') ' + newValue.text[i];
                                          } else if (i == 7) {
                                            newText += ' ' + newValue.text[i];
                                          } else {
                                            newText += newValue.text[i];
                                          }
                                        }
                                        return newValue.copyWith(
                                          text: newText,
                                          selection: TextSelection.collapsed(
                                              offset: newText.length),
                                        );
                                      }),
                                    ],
                                    onChanged: (_) {
                                      updateUsername();
                                    },
                                    decoration: const InputDecoration(
                                        hintText: 'Enter Mobile',
                                        border: InputBorder.none),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Gender:',
                                  style: textStyle,
                                ),
                                Container(
                                  width: 280,
                                  height: 40,
                                  padding: const EdgeInsets.only(left: 10),
                                  decoration: boxdecoration(),
                                  child: DropdownMenu<String>(
                                    width:
                                        MediaQuery.of(context).size.width > 800
                                            ? 280
                                            : 150,
                                    inputDecorationTheme:
                                        const InputDecorationTheme(
                                      contentPadding:
                                          const EdgeInsets.only(bottom: 5),
                                      border: InputBorder.none,
                                    ),
                                    hintText: 'Select Gender',
                                    trailingIcon: Icon(Icons.arrow_drop_down),
                                    initialSelection: genderEmployee,
                                    onSelected: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        genderEmployee = value!;
                                      });
                                    },
                                    dropdownMenuEntries: ['Male', 'Female']
                                        .map<DropdownMenuEntry<String>>(
                                            (String value) {
                                      return DropdownMenuEntry<String>(
                                          value: value, label: value);
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Employee ID'),
                                  Container(
                                    width: 280,
                                    height: 40,
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    decoration: boxdecoration(),
                                    child: TextField(
                                      controller: employeeIdController,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        LengthLimitingTextInputFormatter(
                                            6), // Limit to 10 digits
                                        TextInputFormatter.withFunction(
                                            (oldValue, newValue) {
                                          if (newValue.text.isEmpty) {
                                            return newValue.copyWith(text: '');
                                          }
                                          final int textLength =
                                              newValue.text.length;
                                          String newText = '';
                                          for (int i = 0; i < textLength; i++) {
                                            if (i == 0) {
                                              newText += '(' + newValue.text[i];
                                            } else if (i == 2) {
                                              newText +=
                                                  ') ' + newValue.text[i];
                                            } else {
                                              newText += newValue.text[i];
                                            }
                                          }
                                          return newValue.copyWith(
                                            text: newText,
                                            selection: TextSelection.collapsed(
                                                offset: newText.length),
                                          );
                                        }),
                                      ],
                                      decoration: const InputDecoration(
                                          hintText: 'Enter Employee ID',
                                          border: InputBorder.none),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Salary'),
                                  Container(
                                    width: 280,
                                    height: 40,
                                    padding:
                                        const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                    decoration: boxdecoration(),
                                    child: TextField(
                                      controller: salaryController,
                                      keyboardType: TextInputType.numberWithOptions(
                                          decimal:
                                              true), // Set keyboard type to number
                                      inputFormatters: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                            RegExp(r'[0-9.]')),
                                        // Accept only digits
                                      ],
                                      decoration: const InputDecoration(
                                        hintText: 'Enter Salary',
                                        border: InputBorder.none,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Flexible(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Department:', style: textStyle),
                                  Container(
                                    width: 280,
                                    height: 40,
                                    padding: const EdgeInsets.only(left: 5),
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    child: DropdownMenu<String>(
                                      width: 280,
                                      inputDecorationTheme:
                                          const InputDecorationTheme(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.only(bottom: 5)),
                                      hintText: 'Select Department',
                                      trailingIcon:
                                          const Icon(Icons.arrow_drop_down),
                                      initialSelection: selectedDep,
                                      onSelected: (String? value) {
                                        // This is called when the user selects an item.
                                        setState(() {
                                          selectedDep = value!;
                                        });
                                      },
                                      dropdownMenuEntries: [
                                        'IT',
                                        'HR',
                                        'ACCOUNTING',
                                        'SERVICING'
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
                            ),
                          ]),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
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
                                  padding: const EdgeInsets.only(left: 10),
                                  decoration: boxdecoration(),
                                  child: DropdownMenu<String>(
                                    width: 250,
                                    inputDecorationTheme:
                                        const InputDecorationTheme(
                                      contentPadding:
                                          EdgeInsets.only(bottom: 5),
                                      border: InputBorder.none,
                                    ),
                                    trailingIcon: Icon(Icons.arrow_drop_down),
                                    initialSelection: selectedRole,
                                    hintText: 'Select Role',
                                    onSelected: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        selectedRole = value!;
                                      });
                                    },
                                    dropdownMenuEntries: [
                                      'Employee',
                                      'Admin',
                                      'Superadmin'
                                    ].map<DropdownMenuEntry<String>>(
                                        (String value) {
                                      return DropdownMenuEntry<String>(
                                          value: value, label: value);
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
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
                                  padding: const EdgeInsets.only(left: 10),
                                  decoration: boxdecoration(),
                                  child: DropdownMenu<String>(
                                    width:
                                        MediaQuery.of(context).size.width > 800
                                            ? 280
                                            : 150,
                                    inputDecorationTheme:
                                        const InputDecorationTheme(
                                      contentPadding:
                                          const EdgeInsets.only(bottom: 5),
                                      border: InputBorder.none,
                                    ),
                                    hintText: 'Select Status',
                                    trailingIcon: Icon(Icons.arrow_drop_down),
                                    initialSelection: typeEmployee,
                                    onSelected: (String? value) {
                                      // This is called when the user selects an item.
                                      setState(() {
                                        typeEmployee = value!;
                                      });
                                    },
                                    dropdownMenuEntries: [
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
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Row(
                              children: [
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Start Shift',
                                        style: textStyle,
                                      ),
                                      Container(
                                        width: 280,
                                        height: 40,
                                        padding: EdgeInsets.all(2),
                                        decoration: boxdecoration(),
                                        child: DateTimeFormField(
                                          decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      8, 0, 0, 10),
                                              hintText: 'Select Time',
                                              suffixIcon: Icon(Icons.timer)),
                                          mode: DateTimeFieldPickerMode.time,
                                          onDateSelected: (DateTime value) {
                                            print(value);
                                          },
                                          onChanged: (DateTime? value) {},
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Flexible(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'End Shift',
                                        style: textStyle,
                                      ),
                                      Container(
                                        width: 280,
                                        height: 40,
                                        padding: EdgeInsets.all(2),
                                        decoration: boxdecoration(),
                                        child: DateTimeFormField(
                                          decoration: const InputDecoration(
                                              hintText: 'Select Time',
                                              contentPadding:
                                                  EdgeInsets.fromLTRB(
                                                      8, 0, 0, 10),
                                              border: InputBorder.none,
                                              suffixIcon: Icon(Icons.timer)),
                                          mode: DateTimeFieldPickerMode.time,
                                          onDateSelected: (DateTime value) {
                                            print(value);
                                          },
                                          onChanged: (DateTime? value) {},
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: 10,
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
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
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
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(
                                          10), // Limit to 10 digits
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        if (newValue.text.isEmpty) {
                                          return newValue.copyWith(text: '');
                                        }
                                        final int textLength =
                                            newValue.text.length;
                                        String newText = '';
                                        for (int i = 0; i < textLength; i++) {
                                          if (i == 2 || i == 9) {
                                            newText += '-';
                                          }
                                          newText += newValue.text[i];
                                        }
                                        return newValue.copyWith(
                                          text: newText,
                                          selection: TextSelection.collapsed(
                                              offset: newText.length),
                                        );
                                      }),
                                    ],
                                    decoration: const InputDecoration(
                                      hintText: 'Enter SSS',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
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
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(
                                          12), // Limit to 12 digits
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        if (newValue.text.isEmpty) {
                                          return newValue.copyWith(text: '');
                                        }
                                        final int textLength =
                                            newValue.text.length;
                                        String newText = '';
                                        for (int i = 0; i < textLength; i++) {
                                          if (i == 3 || i == 7 || i == 11) {
                                            newText += '-';
                                          }
                                          newText += newValue.text[i];
                                        }
                                        return newValue.copyWith(
                                          text: newText,
                                          selection: TextSelection.collapsed(
                                              offset: newText.length),
                                        );
                                      }),
                                    ],
                                    decoration: const InputDecoration(
                                      hintText: 'Enter TIN',
                                      border: InputBorder.none,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
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
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(
                                          9), // Limit to 9 digits
                                      TextInputFormatter.withFunction(
                                          (oldValue, newValue) {
                                        if (newValue.text.isEmpty) {
                                          return newValue.copyWith(text: '');
                                        }
                                        final int textLength =
                                            newValue.text.length;
                                        String newText = '';
                                        for (int i = 0; i < textLength; i++) {
                                          if (i == 3 || i == 7) {
                                            newText += '-';
                                          }
                                          newText += newValue.text[i];
                                        }
                                        return newValue.copyWith(
                                          text: newText,
                                          selection: TextSelection.collapsed(
                                              offset: newText.length),
                                        );
                                      }),
                                    ],
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter TaxCode',
                                    ),
                                  ),
                                )
                              ],
                            ),
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
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
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
                                      hintText: 'Enter Email',
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Username',
                                  style: textStyle,
                                ),
                                Container(
                                  width: 280,
                                  height: 40,
                                  padding: EdgeInsets.all(8),
                                  decoration: boxdecoration(),
                                  child: TextField(
                                    controller: usernameController,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Enter Username',
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Flexible(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Password',
                                  style: textStyle,
                                ),
                                Container(
                                  width: 280,
                                  height: 40,
                                  padding: const EdgeInsets.all(2),
                                  decoration: boxdecoration(),
                                  child: TextField(
                                    obscureText: !_passwordVisible,
                                    controller: passwordController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter Password',
                                      border: InputBorder.none,
                                      suffixIcon: IconButton(
                                        icon: Icon(_passwordVisible
                                            ? Icons.visibility
                                            : Icons.visibility_off),
                                        onPressed: _togglePasswordVisibility,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
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

  register(BuildContext context) async {
    // Validate fields before attempting registration
    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        middleNameController.text.isEmpty ||
        lastNameController.text.isEmpty ||
        mobilenumController.text.isEmpty ||
        employeeIdController.text.isEmpty ||
        salaryController.text.isEmpty ||
        selectedDep.isEmpty ||
        selectedRole.isEmpty ||
        typeEmployee.isEmpty ||
        genderEmployee.isEmpty ||
        sssController.text.isEmpty ||
        tinController.text.isEmpty ||
        taxCodeController.text.isEmpty ||
        usernameController.text.isEmpty) {
      showToast('Please fill in all fields.');
      return; // Exit registration process if any field is empty
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Create the user object with the entered data
      User newUser = User(
        monthly_salary: double.parse(salaryController.text),
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
        genderEmployee: genderEmployee,
        sss: sssController.text,
        tin: tinController.text,
        taxCode: taxCodeController.text,
        employeeId: employeeIdController.text,
        mobilenum: mobilenumController.text,
        isActive: true,
        isATM: false,
      );

      await addUser(
        newUser.monthly_salary,
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
        newUser.genderEmployee,
        newUser.sss,
        newUser.tin,
        newUser.taxCode,
        newUser.employeeId,
        newUser.mobilenum,
        newUser.isActive,
        newUser.isATM,
      );

      Navigator.pop(context); // Close the dialog or navigate to the next screen
      showSuccess(context, 'Create', 'Account has been created successfully.');
      showToast("Registered Successfully!");
      // Clear text fields after successful registration
      firstNameController.text = '';
      middleNameController.text = '';
      lastNameController.text = '';
      mobilenumController.text = '';
      employeeIdController.text = '';
      salaryController.text = '';
      selectedDep = '';
      selectedRole = '';
      typeEmployee = '';

      sssController.text = '';
      tinController.text = '';
      taxCodeController.text = '';
      emailController.text = '';
      usernameController.text = '';
      passwordController.text = '';
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
    sheet.getRangeByName('A2:H2').merge();
    sheet.getRangeByName('A1:F1').rowHeight = 100;
    sheet.getRangeByName('A5').columnWidth = 4.82;
    sheet.getRangeByName('B5').columnWidth = 30;
    sheet.getRangeByName('C5').columnWidth = 20;
    sheet.getRangeByName('D5').columnWidth = 20;
    sheet.getRangeByName('E5').columnWidth = 20;
    sheet.getRangeByName('F5').columnWidth = 20;
    sheet.getRangeByName('G5').columnWidth = 15;
    sheet.getRangeByName('A5:H5').cellStyle.backColor = '#A5D6A7';

    sheet.getRangeByName('A2:H2').setText('Account List Report');
    sheet.getRangeByName('A2:H2').cellStyle.bold = true;
    sheet.getRangeByName('A2:H2').cellStyle.hAlign = xlsio.HAlignType.center;

    sheet.getRangeByIndex(3, 7).setText('Generated by :');
    sheet.getRangeByIndex(3, 8).setText(_userName);
    sheet.getRangeByIndex(4, 7).setText('Date Generated :');
    sheet.getRangeByIndex(4, 8).setText(now());

    sheet.getRangeByIndex(5, 1).setText('#');
    sheet.getRangeByIndex(5, 2).setText('Full Name');
    sheet.getRangeByIndex(5, 3).setText('Username');
    sheet.getRangeByIndex(5, 4).setText('Email');
    sheet.getRangeByIndex(5, 5).setText('Type');
    sheet.getRangeByIndex(5, 6).setText('Department');
    sheet.getRangeByIndex(5, 7).setText('Shift');
    sheet.getRangeByIndex(5, 8).setText('Role');

    sheet.getRangeByName('A5:H5').cellStyle.bold = true;
    sheet.getRangeByName('A5:H5').cellStyle.fontSize = 12;

    int rowIndex = 6; // Start from the second row for data
    int count = 1; // Initialize counter
    for (final userData in excelData) {
      sheet.getRangeByIndex(rowIndex, 1).setText(count.toString());
      sheet.getRangeByIndex(rowIndex, 2).setText(
          "${userData[2].toString()} ${userData[3].toString()} ${userData[4].toString()}");
      sheet.getRangeByIndex(rowIndex, 3).setText(userData[5].toString() ?? '');
      sheet.getRangeByIndex(rowIndex, 4).setText(userData[6].toString() ?? '');
      sheet.getRangeByIndex(rowIndex, 5).setText(userData[7].toString() ?? '');
      sheet.getRangeByIndex(rowIndex, 6).setText(userData[8].toString());
      sheet.getRangeByIndex(rowIndex, 7).setText(userData[9].toString());
      sheet.getRangeByIndex(rowIndex, 8).setText(userData[10].toString());

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
