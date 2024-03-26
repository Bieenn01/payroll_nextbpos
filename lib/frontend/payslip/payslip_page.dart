import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_payroll_nextbpo/frontend/payslip/payslip._form.dart';

class PayslipData {
  final String employeeID;
  final String name;
  final String department;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime dateGenerated;
  final double grossPay;
  final double deductions;
  final double netPay;

  PayslipData({
    required this.employeeID,
    required this.name,
    required this.department,
    required this.startDate,
    required this.endDate,
    required this.dateGenerated,
    required this.grossPay,
    required this.deductions,
    required this.netPay,
  });

  Map<String, dynamic> toMap() {
    return {
      'employeeID': employeeID,
      'name': name,
      'department': department,
      'startDate': startDate,
      'endDate': endDate,
      'dateGenerated': dateGenerated,
      'grossPay': grossPay,
      'deductions': deductions,
      'netPay': netPay,
    };
  }
}

class PayslipPage extends StatefulWidget {
  const PayslipPage({Key? key}) : super(key: key);

  @override
  State<PayslipPage> createState() => _PayslipPageState();
}

class _PayslipPageState extends State<PayslipPage> {
  bool viewTable = true;
  String selectedDepartment = 'All Departments'; // Default selection
  DateTime? fromDate;
  DateTime? toDate;
  List<PayslipData> payrollData =
      []; // Variable to store generated payroll data

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                      borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      viewTable
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        viewTable = true;
                                      });
                                    },
                                    child: Text(
                                      "Generate Payroll",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () {
                                    showGeneratePayrollDialog(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Color.fromARGB(255, 68, 166, 100),
                                    padding: const EdgeInsets.all(18.0),
                                    minimumSize: const Size(200, 50),
                                    maximumSize: const Size(200, 50),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: const Text(
                                    "+ Add new",
                                    style: TextStyle(
                                      color: Colors
                                          .white, // Change the text color to white
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        viewTable = true;
                                      });
                                    },
                                    child: Text(
                                      "Generate Payroll >",
                                      style: TextStyle(
                                          color: Colors.grey.shade200,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      viewTable = false;
                                    });
                                  },
                                  child: const Text(
                                    "Payroll",
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(
                        height: 5,
                      ),
                      Divider(),
                      viewTable ? timesheet(context) : payroll(),
                      const Divider(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SizedBox timesheet(BuildContext context) {
    return SizedBox(
      height: 600,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collectionGroup('Employees').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return Text('No data available');
          }

          final dataTable = DataTable(
            columns: const [
              DataColumn(
                label: Text('#', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label:
                    Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Department',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Date Start',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Date End',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Date Generated',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              DataColumn(
                label: Text('Action',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
            rows: documents.map<DataRow>((doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              return DataRow(
                cells: [
                  DataCell(Text(data['employeeID'])),
                  DataCell(Text(data['name'])),
                  DataCell(Text(data['department'])),
                  DataCell(Text(data['startDate'].toDate().toString())),
                  DataCell(Text(data['endDate'].toDate().toString())),
                  DataCell(Text(data['dateGenerated'].toDate().toString())),
                  DataCell(
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          viewTable = false;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Icon(
                            Icons.visibility,
                            color: Colors.blue,
                            size: 15,
                          ),
                          Text(
                            'View',
                            style: TextStyle(fontSize: 10, color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          );

          return MediaQuery.of(context).size.width > 1500
              ? SizedBox(
                  height: 600,
                  child: SingleChildScrollView(
                    child: Flexible(
                      child: dataTable,
                    ),
                  ),
                )
              : SizedBox(
                  height: 600,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Flexible(
                        child: dataTable,
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  void viewDetails(PayslipData payslip) {
    // Add your logic to handle viewing details of the payslip
    print('Viewing details for employee ${payslip.employeeID}');
  }

  SizedBox payroll() {
    var dataTable = DataTable(
      columns: const [
        DataColumn(
            label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Employee ID',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Gross Pay',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Deductions',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label:
                Text('Net Pay', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label:
                Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
      ],
      rows: payrollData.map<DataRow>((employee) {
        return DataRow(cells: [
          DataCell(Text(employee.employeeID)),
          DataCell(Text(employee.name)),
          DataCell(Text(employee.grossPay.toString())),
          DataCell(Text(employee.deductions.toString())),
          DataCell(Text(employee.netPay.toString())),
          DataCell(
            ElevatedButton(
              onPressed: () {
                // Handle action button click
                editPayslip(employee);
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Icon(
                    Icons.edit_document,
                    color: Colors.blue,
                    size: 15,
                  ),
                  Text(
                    'Edit Payslip',
                    style: TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ),
        ]);
      }).toList(),
    );

    return MediaQuery.of(context).size.width > 1500
        ? SizedBox(
            height: 600,
            child: SingleChildScrollView(
              child: Flexible(
                child: dataTable,
              ),
            ),
          )
        : SizedBox(
            height: 600,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Flexible(
                  child: dataTable,
                ),
              ),
            ),
          );
  }

  void editPayslip(PayslipData payslip) {
    // Add your logic to handle editing the payslip
    print('Editing payslip for employee ${payslip.employeeID}');
  }

  Future<void> generatePayroll(String userDepartment) async {
    // Initialize an empty list to store generated payroll data
    List<PayslipData> generatedData = [];

    // Fetch the count of users from the Firestore collection based on the selected department
    QuerySnapshot querySnapshot;
    if (userDepartment == 'All Departments') {
      querySnapshot = await FirebaseFirestore.instance.collection('User').get();
    } else {
      querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('department', isEqualTo: userDepartment)
          .get();
    }

    // Get the count of users
    int userCount = querySnapshot.size;

    // Simulate generating payroll data for each employee
    // Here, you can replace this logic with your actual payroll generation algorithm
    for (int i = 1; i <= userCount; i++) {
      PayslipData payslip = PayslipData(
        employeeID: 'EMP00$i',
        name: 'Employee $i',
        department: userDepartment, // Use user's department
        startDate: fromDate!,
        endDate: toDate!,
        dateGenerated: DateTime.now(),
        grossPay: 2000 + i * 100,
        deductions: 0,
        netPay: 2000 + i * 100,
      );
      generatedData.add(payslip);
    }

    // Save generated data to Firestore collection
    await saveToFirestore(generatedData, userDepartment);
  }

  Future<void> saveToFirestore(
      List<PayslipData> generatedData, String userDepartment) async {
    CollectionReference payslipCollection =
        FirebaseFirestore.instance.collection('PayslipDepartment');

    // Clear existing documents for the department
    await payslipCollection.doc(userDepartment).delete();

    // Save new documents
    for (var payslip in generatedData) {
      await payslipCollection
          .doc(userDepartment)
          .collection('Employees')
          .add(payslip.toMap());
    }

    // Update UI with the generated data
    setState(() {
      payrollData = generatedData;
    });
  }

  Widget departmentDropdown(
    Function(String?) onChanged,
    String userDepartment,
  ) {
    List<String> departments = [
      'All Departments',
      'IT',
      'HR',
      'ACCOUNTING',
      'SERVICING'
    ];

    // Check if the user's department is included in the departments list
    if (!departments.contains(userDepartment)) {
      // If not included, add it to the departments list
      departments.insert(1, userDepartment);
    }

    return DropdownButton<String>(
      value: userDepartment,
      onChanged: (newValue) {
        // Update selectedDepartment only if newValue is not null
        if (newValue != null) {
          // Update selectedDepartment only if it's a valid department
          if (departments.contains(newValue)) {
            // Call the provided onChanged function
            onChanged(newValue);
          }
        }
      },
      items: departments.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }

  void showGeneratePayrollDialog(BuildContext context) async {
    DateTime? fromDateLocal = fromDate;
    DateTime? toDateLocal = toDate;

    User? user = FirebaseAuth.instance.currentUser;
    String? userUid = user?.uid;

    if (userUid != null) {
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(userUid)
          .get();

      String userDepartment = userSnapshot.get('department');

      await showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Generate Payroll'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select Department:'),
                    departmentDropdown((newValue) {
                      setState(() {
                        userDepartment = newValue!;
                      });
                    }, userDepartment),
                    SizedBox(height: 10),
                    Text('Select Date Range:'),
                    ElevatedButton(
                      onPressed: () async {
                        final DateTimeRange? picked = await showDateRangePicker(
                          context: context,
                          firstDate: DateTime(DateTime.now().year - 1),
                          lastDate: DateTime(DateTime.now().year + 1),
                          initialDateRange:
                              fromDateLocal != null && toDateLocal != null
                                  ? DateTimeRange(
                                      start: fromDateLocal!,
                                      end: toDateLocal!,
                                    )
                                  : null,
                        );

                        if (picked != null) {
                          setState(() {
                            fromDateLocal = picked.start;
                            toDateLocal = picked.end;
                          });
                        }
                      },
                      child: Text(
                        'Select Date Range',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        fromDate = fromDateLocal;
                        toDate = toDateLocal;
                      });
                      generatePayroll(userDepartment); // Pass user's department
                      Navigator.pop(context);
                    },
                    child: Text('Generate'),
                  ),
                ],
              );
            },
          );
        },
      );
    } else {
      // Handle when user is not authenticated
      print('User not authenticated.');
    }
  }
}
