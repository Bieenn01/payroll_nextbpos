import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:date_field/date_field.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/view_userDetails.dart';
import 'package:project_payroll_nextbpo/backend/jsonfiles/add_users.dart';
import 'package:project_payroll_nextbpo/backend/widgets/toast_widget.dart';

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

  User({
    required this.department,
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
  });
}

class PovUser extends StatefulWidget {
  PovUser({Key? key}) : super(key: key);

  @override
  State<PovUser> createState() => _UserState();
}

class _UserState extends State<PovUser> {
  int _documentLimit = 8;
  int _currentPage = 0;
  int _rowsPerPage = 8;
  DateTime? selectedDate;
  DateTime? selectedTime;
  DateTime? selectedDateTime;
  bool passwordVisible = false;

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

  String selectedRole = 'Select Role';
  String selectedDep = '--Select--';
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
    return Scaffold(
      body: Row(children: [
        const Expanded(
          child: Text(""),
        ),
        Expanded(
          flex: 100,
          child: Container(
            color: Colors.green.shade50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 8, 20, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Users Account List",
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      Flexible(
                        child: Container(
                          child: ElevatedButton(
                            onPressed: (() {
                              createAccount(context);
                            }),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal.shade400,
                              padding: const EdgeInsets.all(18.0),
                              minimumSize: const Size(200, 50),
                              maximumSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "+ Create Account",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(20),
                  width: 200,
                  height: 80,
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Flexible(
                              fit: FlexFit.tight,
                              child: TextField(
                                controller: passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Search',
                                  suffixIcon: IconButton(
                                    icon: Icon(Icons.search),
                                    onPressed: () {},
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              width: 15,
                            ),
                            Flexible(
                              child: Container(
                                width: 150,
                                child: ElevatedButton(
                                  onPressed: (() {}),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal.shade400,
                                    padding: const EdgeInsets.all(18.0),
                                    minimumSize: const Size(200, 50),
                                    maximumSize: const Size(200, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.file_download),
                                      Text(
                                        " Export List",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FutureBuilder(
                          future: _fetchUsersWithPagination(
                              _documentLimit, _lastVisibleSnapshot),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            if (snapshot.data!.docs.isEmpty) {
                              return Text('No users found.');
                            }
                            return DataTable(
                              columns: [
                                DataColumn(label: Text('#')),
                                DataColumn(label: Text('Name')),
                                DataColumn(label: Text('Username')),
                                DataColumn(label: Text('Type')),
                                DataColumn(label: Text('Department')),
                                DataColumn(label: Text('Shift')),
                                DataColumn(label: Text('Action')),
                                DataColumn(
                                    label: Text(
                                        'Status')), // Added column for Status
                              ],
                              rows: snapshot.data!.docs
                                  .map((DocumentSnapshot document) {
                                Map<String, dynamic> data =
                                    document.data()! as Map<String, dynamic>;
                                DateTime? startShift = data['startShift'] !=
                                        null
                                    ? (data['startShift'] as Timestamp).toDate()
                                    : null;
                                String shift = getShiftText(startShift);
                                String userId = document.id;
                                bool isActive = data['isActive'] ??
                                    false; // Assuming isActive is the boolean field for account status

                                return DataRow(cells: [
                                  DataCell(Text(data['employeeId'].toString())),
                                  DataCell(Text(
                                      '${data['fname']} ${data['lname']}')),
                                  DataCell(Text(data['username'].toString())),
                                  DataCell(
                                      Text(data['typeEmployee'].toString())),
                                  DataCell(Text(data['department'].toString())),
                                  DataCell(Text(shift)),
                                  DataCell(
                                    ElevatedButton(
                                      onPressed: () {
                                        editUserDetails(userId, data);
                                      },
                                      child: Text('Edit'),
                                    ),
                                  ),
                                  DataCell(
                                    Switch(
                                      value: isActive,
                                      onChanged: (value) {
                                        updateAccountStatus(userId, value);
                                      },
                                    ),
                                  ),
                                ]);
                              }).toList(),
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _previousPage,
                              child: Text('Previous'),
                            ),
                            SizedBox(width: 20),
                            ElevatedButton(
                              onPressed: _nextPage,
                              child: Text('Next'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        )
      ]),
    );
  }

  Future<void> updateAccountStatus(String userId, bool isActive) async {
    try {
      CollectionReference users = FirebaseFirestore.instance.collection('User');

      await users.doc(userId).update({'isActive': isActive});

      setState(() {});
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
                  decoration: InputDecoration(labelText: 'First Name'),
                ),
                TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(labelText: 'Last Name'),
                ),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextFormField(
                  controller: typeEmployeeController,
                  decoration: InputDecoration(labelText: 'Employee Type'),
                ),
                TextFormField(
                  controller: departmentController,
                  decoration: InputDecoration(labelText: 'Department'),
                ),
                DateTimeField(
                  decoration: InputDecoration(labelText: 'Start Shift'),
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
          child: Container(
            margin: EdgeInsets.all(10),
            padding: EdgeInsets.all(10),
            child: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width / 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                          fontSize: 30,
                        ),
                      ),
                    ),
                    const Text(
                      'Fill out the form carefully',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    Row(
                      children: [
                        const Text(
                          'Name:  ',
                          style: textStyle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: TextField(
                            controller: firstNameController,
                            decoration: const InputDecoration(
                              labelText: 'First Name',
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: TextField(
                            controller: lastNameController,
                            decoration: const InputDecoration(
                              labelText: 'Last Name',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Text('Department:', style: textStyle),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: DropdownMenu<String>(
                            initialSelection: selectedDep,
                            onSelected: (String? value) {
                              // This is called when the user selects an item.
                              setState(() {
                                selectedDep = value!;
                              });
                            },
                            dropdownMenuEntries: [
                              '--Select--',
                              'IT',
                              'HR',
                              'Security'
                            ].map<DropdownMenuEntry<String>>((String value) {
                              return DropdownMenuEntry<String>(
                                  value: value, label: value);
                            }).toList(),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Role:',
                          style: textStyle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: DropdownMenu<String>(
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
                            ].map<DropdownMenuEntry<String>>((String value) {
                              return DropdownMenuEntry<String>(
                                  value: value, label: value);
                            }).toList(),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Employee Status:',
                          style: textStyle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: DropdownMenu<String>(
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
                            ].map<DropdownMenuEntry<String>>((String value) {
                              return DropdownMenuEntry<String>(
                                  value: value, label: value);
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          'Start Shift:',
                          style: textStyle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: DateTimeFormField(
                            decoration:
                                const InputDecoration(labelText: 'HH:MM'),
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
                        const Text(
                          'End Shift:',
                          style: textStyle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: DateTimeFormField(
                            decoration:
                                const InputDecoration(labelText: 'HH:MM'),
                            mode: DateTimeFieldPickerMode.time,
                            onDateSelected: (DateTime value) {
                              print(value);
                            },
                            onChanged: (DateTime? value) {},
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Username:',
                          style: textStyle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: TextField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: '',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Email:',
                          style: textStyle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: TextField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: '',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'SSS:',
                          style: textStyle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: TextField(
                            controller: sssController,
                            decoration: const InputDecoration(
                              labelText: 'SSS',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'TIN:',
                          style: textStyle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: TextField(
                            controller: tinController,
                            decoration: const InputDecoration(
                              labelText: 'TIN',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Tax Code:',
                          style: textStyle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: TextField(
                            controller: taxCodeController,
                            decoration: const InputDecoration(
                              labelText: 'Tax Code',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Employee ID:',
                          style: textStyle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: TextField(
                            controller: employeeIdController,
                            decoration: const InputDecoration(
                              labelText: 'Employee ID',
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10,
                        ),
                        const Text(
                          'Password',
                          style: textStyle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          child: TextField(
                            obscureText: !passwordVisible,
                            controller: passwordController,
                            decoration: InputDecoration(
                              labelText: '',
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
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    ElevatedButton(
                      onPressed: (() {
                        register(context);
                      }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 51, 203, 185),
                        padding: const EdgeInsets.all(18.0),
                        minimumSize: const Size(200, 50),
                        maximumSize: const Size(200, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "+ Create Account",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
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
      );

      Navigator.pop(context); // Close the dialog or navigate to the next screen
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
