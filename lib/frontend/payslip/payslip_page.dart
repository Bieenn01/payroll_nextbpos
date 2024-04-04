import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shimmer/shimmer.dart' as ShimmerPackage;
import 'package:intl/intl.dart';
import 'package:project_payroll_nextbpo/frontend/payslip._form.dart';

class PayslipData {
  final DateTime startDate;
  final DateTime endDate;
  final DateTime dateGenerated;
  final double grossPay;
  final double deductions;
  final double netPay;

  PayslipData({
    required this.startDate,
    required this.endDate,
    required this.dateGenerated,
    required this.grossPay,
    required this.deductions,
    required this.netPay,
  });

  Map<String, dynamic> toMap() {
    return {
      'startDate':
          Timestamp.fromDate(startDate), // Convert DateTime to Timestamp
      'endDate': Timestamp.fromDate(endDate), // Convert DateTime to Timestamp
      'dateGenerated':
          Timestamp.fromDate(dateGenerated), // Convert DateTime to Timestamp
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

TextEditingController _searchController = TextEditingController();

class _PayslipPageState extends State<PayslipPage> {
  bool viewTable = true;
  String selectedDepartment = 'All';
  DateTime? fromDate;
  DateTime? toDate;
  List<PayslipData> payrollData = [];
  // Variable to store generated payroll data

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
                      viewTable ? timesheet(context) : _buildDataTable(),
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
        stream: FirebaseFirestore.instance
            .collectionGroup('PayslipDepartment')
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          }

          final List<DocumentSnapshot> documents = snapshot.data!.docs;

          if (documents.isEmpty) {
            return Center(child: Text('No data available'));
          }

          final dataTable = DataTable(
            columns: const [
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
              Map<String, dynamic>? data =
                  doc.data() as Map<String, dynamic>?; // Make data nullable
              if (data == null) return DataRow(cells: []); // Skip null data

              DateFormat dateFormatter = DateFormat('MM/dd/yyyy');
              return DataRow(
                cells: [
                  DataCell(Text(dateFormatter.format(
                      data['startDate']?.toDate() ??
                          DateTime.now()))), // Provide default value if null
                  DataCell(Text(dateFormatter.format(
                      data['endDate']?.toDate() ??
                          DateTime.now()))), // Provide default value if null
                  DataCell(Text(dateFormatter.format(
                      data['dateGenerated']?.toDate() ??
                          DateTime.now()))), // Provide default value if null
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
                        mainAxisAlignment: MainAxisAlignment.center,
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

  Future<void> generatePayroll() async {
    // Initialize an empty list to store generated payroll data
    List<PayslipData> generatedData = [];

    // Simulate generating payroll data for each employee
    // Assuming you have access to fromDate and toDate
    // Generate payroll for each day within the date range
    {
      // Generate a PayslipData instance for each day
      PayslipData payslip = PayslipData(
        // Assuming employeeID and name are constants for all payslips or you have another way to determine them

        startDate: fromDate!,
        endDate: toDate!,
        dateGenerated: DateTime.now(),
        grossPay: 2000 + 100, // Example gross pay calculation
        deductions: 0, // Example deductions
        netPay: 2000 + 100, // Example net pay calculation
      );

      // Add the payslip to the generated data list
      generatedData.add(payslip);
    }

    // Save generated data to Firestore collection
    await saveToFirestore(generatedData);
  }

  Future<void> saveToFirestore(List<PayslipData> generatedData) async {
    CollectionReference payslipCollection =
        FirebaseFirestore.instance.collection('PayslipDepartment');

    // Use batch writes for efficient write operations
    WriteBatch batch = FirebaseFirestore.instance.batch();

    // Iterate over the generated payslip data
    for (var payslip in generatedData) {
      // Create a new document reference for each payslip
      DocumentReference documentRef = payslipCollection.doc();

      // Set the document data
      batch.set(documentRef,
          payslip.toMap()); // Assuming toMap() converts PayslipData to a map
    }

    try {
      // Commit the batch
      await batch.commit();

      // Optionally, you can perform additional actions after batch commit
      // For example, updating UI or triggering other tasks
    } catch (e) {
      // Handle errors
      print("Error saving to Firestore: $e");
      // You can add additional error handling here
    }
  }

  Widget departmentDropdown(
    Function(String?) onChanged,
    String userDepartment,
  ) {
    List<String> departments = ['IT', 'HR', 'ACCOUNTING', 'SERVICING'];

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
                    generatePayroll(); // Call your generatePayroll function here without passing any department
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
  }

  double calculateNetPay(double grossPay, double totalDeductions) {
    return grossPay - totalDeductions;
  }

  Widget _buildDataTable() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('User').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available yet'));
        } else {
          List<DocumentSnapshot> payrollDocs = snapshot.data!.docs;

          // Filter payrollDocs based on search text
          List<DocumentSnapshot> filteredPayrollDocs = _searchController
                  .text.isNotEmpty
              ? payrollDocs.where((doc) {
                  final Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;
                  return (data['employeeId'] != null &&
                          data['employeeId'].toString().toLowerCase().contains(
                              _searchController.text.toLowerCase())) ||
                      (data['fname'] != null &&
                          data['fname'].toString().toLowerCase().contains(
                              _searchController.text.toLowerCase())) ||
                      (data['mname'] != null &&
                          data['mname'].toString().toLowerCase().contains(
                              _searchController.text.toLowerCase())) ||
                      (data['lname'] != null &&
                          data['lname']
                              .toString()
                              .toLowerCase()
                              .contains(_searchController.text.toLowerCase()));
                }).toList()
              : List.from(
                  payrollDocs); // Copying the list if no search text to maintain original data

          if (selectedDepartment != 'All') {
            filteredPayrollDocs = filteredPayrollDocs
                .where((doc) => doc['department'] == selectedDepartment)
                .toList();
          }

          return Column(
            children: [
              AppBar(
                title: Text(''),
                actions: [
                  IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {
                      setState(() {
                        // Reset the status to default in each document
                        for (var payrollDoc in filteredPayrollDocs) {
                          payrollDoc.reference.update({'status': 'Not Done'});
                        }
                      });
                    },
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Employee Id')),
                    DataColumn(label: Text('Name')),
                    DataColumn(
                      label: PopupMenuButton<String>(
                        child: const Row(
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
                    DataColumn(label: Text('Action')),
                    DataColumn(label: Text('Status')),
                  ],
                  rows: List.generate(filteredPayrollDocs.length, (index) {
                    DocumentSnapshot payrollDoc = filteredPayrollDocs[index];
                    Map<String, dynamic> payrollData =
                        payrollDoc.data() as Map<String, dynamic>;
                    final fullname =
                        '${payrollData['fname']} ${payrollData['mname']} ${payrollData['lname']}';

                    // Checking if the employeeId exists in _generateClickedList to highlight the row

                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                              payrollData['employeeId'] ?? 'Not Available Yet'),
                        ),
                        DataCell(
                          Text(fullname ?? 'Not Available Yet'),
                        ),
                        DataCell(
                          Text(
                              payrollData['department'] ?? 'Not Available Yet'),
                        ),
                        DataCell(Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.visibility, color: Colors.blue),
                              onPressed: () {
                                _showPayslipDialog2(context, payrollData);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.payment, color: Colors.blue),
                              onPressed: () {
                                _showPayslipDialog(context, payrollData);
                              },
                            ),
                          ],
                        )),
                        DataCell(
                          Text(payrollData['status'] ?? 'Not Done'),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          );
        }
      },
    );
  }

// Define _generateClickedList to store employeeIds that have generated payslip
  List<String> _generateClickedList = [];

  Future<void> _showPayslipDialog(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      var employeeId = data['employeeId'];
      var overtimeQuerySnapshot = await FirebaseFirestore.instance
          .collection('Overtime')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      var overtimeQuerySnapshot2 = await FirebaseFirestore.instance
          .collection('SpecialHolidayOT')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      var overtimeQuerySnapshot3 = await FirebaseFirestore.instance
          .collection('RestdayOT')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      var overtimeQuerySnapshot4 = await FirebaseFirestore.instance
          .collection('RegularHolidayOT')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      var overtimeQuerySnapshot5 = await FirebaseFirestore.instance
          .collection('SpecialHoliday')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      var overtimeQuerySnapshot6 = await FirebaseFirestore.instance
          .collection('Holiday')
          .where('employeeId', isEqualTo: employeeId)
          .get();
      // Query the User collection to get the user's document
      var userDocSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      if (userDocSnapshot.docs.isNotEmpty) {
        var userData = userDocSnapshot.docs.first.data();
        var monthlySalary = userData['monthly_salary'] ?? 0;
        var regularOTDataQuery = await FirebaseFirestore.instance
            .collection('OvertimePay')
            .where('employeeId', isEqualTo: employeeId)
            .get();

        var specialHOTDataQuery = await FirebaseFirestore.instance
            .collection('SpecialHolidayOTPay')
            .where('employeeId', isEqualTo: employeeId)
            .get();

        var regularHOTDataQuery = await FirebaseFirestore.instance
            .collection('RegularHolidayOTPay')
            .where('employeeId', isEqualTo: employeeId)
            .get();

        var restdayOTDataQuery = await FirebaseFirestore.instance
            .collection('RestdayOTPay')
            .where('employeeId', isEqualTo: employeeId)
            .get();

        var holidayPayDataQuery = await FirebaseFirestore.instance
            .collection('HolidayPay')
            .where('employeeId', isEqualTo: employeeId)
            .get();

        var specialHPayDataQuery = await FirebaseFirestore.instance
            .collection('SpecialHolidayPay')
            .where('employeeId', isEqualTo: employeeId)
            .get();

        var regularOTPay = regularOTDataQuery.docs.isNotEmpty
            ? regularOTDataQuery.docs.first.data()['total_overtimePay'] ?? 0
            : 0;

        var specialHOTPay = specialHOTDataQuery.docs.isNotEmpty
            ? specialHOTDataQuery.docs.first.data()['total_specialOTPay'] ?? 0
            : 0;

        var regularHOTPay = regularHOTDataQuery.docs.isNotEmpty
            ? regularHOTDataQuery.docs.first.data()['total_regularHOTPay'] ?? 0
            : 0;

        var restdayOTPay = restdayOTDataQuery.docs.isNotEmpty
            ? restdayOTDataQuery.docs.first.data()['total_restDayOTPay'] ?? 0
            : 0;

        var holidayPay = holidayPayDataQuery.docs.isNotEmpty
            ? holidayPayDataQuery.docs.first.data()['total_holidayPay'] ?? 0
            : 0;

        var specialHPay = specialHPayDataQuery.docs.isNotEmpty
            ? specialHPayDataQuery.docs.first
                    .data()['total_specialHolidayPay'] ??
                0
            : 0;

        final TextEditingController nightDifferentialController =
            TextEditingController();
        final TextEditingController advancesAmescoController =
            TextEditingController();

        final TextEditingController standyAllowanceController =
            TextEditingController();
        final TextEditingController otherPremiumPayController =
            TextEditingController();
        final TextEditingController allowanceController =
            TextEditingController();
        final TextEditingController salaryAdjustmentController =
            TextEditingController();
        final TextEditingController otAdjustmentController =
            TextEditingController();
        final TextEditingController referralBonusController =
            TextEditingController();
        final TextEditingController signingBonusController =
            TextEditingController();
        final TextEditingController sssContributionController =
            TextEditingController();
        final TextEditingController pagibigContributionController =
            TextEditingController();
        final TextEditingController phicContributionController =
            TextEditingController();
        final TextEditingController witholdingTaxController =
            TextEditingController();
        final TextEditingController sssLoanController = TextEditingController();
        final TextEditingController pagibigLoanController =
            TextEditingController();
        final TextEditingController advancesEyeCrafterController =
            TextEditingController();

        final TextEditingController advancesInsularController =
            TextEditingController();
        final TextEditingController vitalabBMCDCController =
            TextEditingController();
        final TextEditingController otherAdvanceController =
            TextEditingController();

        double calculateGrossPay() {
          double nightDifferential =
              double.tryParse(nightDifferentialController.text) ?? 0.0;
          double standyAllowanace =
              double.tryParse(standyAllowanceController.text) ?? 0.0;
          double otherPremiumPay =
              double.tryParse(otherPremiumPayController.text) ?? 0.0;
          double allowance = double.tryParse(allowanceController.text) ?? 0.0;
          double salaryAdjustment =
              double.tryParse(salaryAdjustmentController.text) ?? 0.0;
          double otAdjustment =
              double.tryParse(otAdjustmentController.text) ?? 0.0;
          double referralBonus =
              double.tryParse(referralBonusController.text) ?? 0.0;
          double signingBonus =
              double.tryParse(signingBonusController.text) ?? 0.0;

          return restdayOTPay +
              regularHOTPay +
              specialHOTPay +
              regularOTPay +
              holidayPay +
              specialHPay +
              monthlySalary +
              nightDifferential +
              standyAllowanace +
              otherPremiumPay +
              allowance +
              salaryAdjustment +
              otAdjustment +
              referralBonus +
              signingBonus;
        }

        double calculateDeductions() {
          double sssContribution =
              double.tryParse(sssContributionController.text) ?? 0.0;
          double pagibigContribution =
              double.tryParse(pagibigContributionController.text) ?? 0.0;
          double phicContribution =
              double.tryParse(phicContributionController.text) ?? 0.0;
          double withholdingTax =
              double.tryParse(witholdingTaxController.text) ?? 0.0;
          double sssLoan = double.tryParse(sssLoanController.text) ?? 0.0;
          double pagibigLoan =
              double.tryParse(pagibigLoanController.text) ?? 0.0;
          double advancesEyeCrafter =
              double.tryParse(advancesEyeCrafterController.text) ?? 0.0;
          double advancesAmesco =
              double.tryParse(advancesAmescoController.text) ?? 0.0;
          double advancesInsular =
              double.tryParse(advancesInsularController.text) ?? 0.0;
          double vitalabBMCDC =
              double.tryParse(vitalabBMCDCController.text) ?? 0.0;
          double otherAdvances =
              double.tryParse(otherAdvanceController.text) ?? 0.0;

          return sssContribution +
              pagibigContribution +
              phicContribution +
              withholdingTax +
              sssLoan +
              pagibigLoan +
              advancesEyeCrafter +
              advancesInsular +
              advancesAmesco +
              vitalabBMCDC +
              otherAdvances;
        }

        double overallOTPay = regularHOTPay + specialHOTPay + regularOTPay;
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (BuildContext context, setState) {
              double grossPay = calculateGrossPay();
              double totalDeduction = calculateDeductions();
              double netPay = calculateNetPay(grossPay, totalDeduction);
              return AlertDialog(
                title: Text('Payslip Details'),
                content: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Employee ID: ', data['employeeId']),
                      SizedBox(
                        width: 50,
                      ),
                      _buildInfoRow('Name: ',
                          data['fname'] + data['mname'] + data['lname']),
                      SizedBox(
                        width: 50,
                      ),
                      _buildInfoRow('Department: ', data['department']),
                      DataTable(
                        columns: const [
                          DataColumn(
                              label: Text('EARNINGS',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1))),
                          DataColumn(label: Text('Hours')),
                          DataColumn(label: Text('Amount')),
                        ],
                        rows: [
                          DataRow(
                            cells: [
                              DataCell(Text('Basic Salary')),
                              DataCell(Text('')),
                              DataCell(Text(monthlySalary.toString())),
                            ],
                          ),
                          DataRow(
                            cells: [
                              DataCell(Text('Night Differential')),
                              DataCell(Text('0')),
                              DataCell(
                                TextField(
                                  style: TextStyle(fontSize: 14),
                                  controller: nightDifferentialController,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                    LengthLimitingTextInputFormatter(11),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      grossPay = calculateGrossPay();
                                      // Recalculate
                                      //the gross pay whenever night differential changes
                                    });
                                  },
                                  decoration: InputDecoration(
                                      border: InputBorder.none, hintText: '0'),
                                ),
                              ),
                            ],
                          ),
                          DataRow(cells: [
                            DataCell(Text('Overtime')),
                            DataCell(Text('')),
                            DataCell(Text(overallOTPay.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('RDOT')),
                            DataCell(Text('')),
                            DataCell(Text(restdayOTPay.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Regular Holiday')),
                            DataCell(Text('')),
                            DataCell(Text(holidayPay.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Special Holiday')),
                            DataCell(Text('')),
                            DataCell(Text(specialHPay.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Standy Allowance')),
                            DataCell(Text('-')),
                            DataCell(TextField(
                              controller: standyAllowanceController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  grossPay = calculateGrossPay();
                                });
                              },
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: '0'),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Other Premium Pay')),
                            DataCell(Text('-')),
                            DataCell(TextField(
                              controller: otherPremiumPayController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  grossPay = calculateGrossPay();
                                });
                              },
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: '0'),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Allowance')),
                            DataCell(Text('-')),
                            DataCell(TextField(
                              controller: allowanceController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  grossPay = calculateGrossPay();
                                });
                              },
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: '0'),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Salary Adjustment')),
                            DataCell(Text('-')),
                            DataCell(TextField(
                              controller: salaryAdjustmentController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  grossPay = calculateGrossPay();
                                });
                              },
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: '0'),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('OT Adjustment')),
                            DataCell(Text('-')),
                            DataCell(TextField(
                              controller: otAdjustmentController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  grossPay = calculateGrossPay();
                                });
                              },
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: '0'),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Referral Bonus')),
                            DataCell(Text('-')),
                            DataCell(TextField(
                              controller: referralBonusController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  grossPay = calculateGrossPay();
                                });
                              },
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: '0'),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Signing Bonus')),
                            DataCell(Text('-')),
                            DataCell(TextField(
                              controller: signingBonusController,
                              onChanged: (value) {
                                setState(() {
                                  grossPay = calculateGrossPay();
                                });
                              },
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                  border: InputBorder.none, hintText: '0'),
                            )),
                          ]),
                          DataRow(cells: [
                            DataCell(Text(
                              'GROSS PAY',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                            DataCell(Text('')),
                            DataCell(Text(
                              grossPay.toString(),
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                          ]),
                        ],
                      ),
                      VerticalDivider(
                        width: 10,
                      ),
                      DataTable(columns: const [
                        DataColumn(
                            label: Text('DEDUCTIONS',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1))),
                        DataColumn(label: Text('Amount')),
                      ], rows: [
                        DataRow(cells: [
                          DataCell(Text('LWOP/ Tardiness')),
                          DataCell(Text('0')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('SSS Contribution')),
                          DataCell(TextField(
                            controller: sssContributionController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            onChanged: (value) {
                              setState(() {
                                totalDeduction = calculateDeductions();
                              });
                            },
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Pag-ibig Contribution')),
                          DataCell(TextField(
                            controller: pagibigContributionController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            onChanged: (value) {
                              setState(() {
                                totalDeduction = calculateDeductions();
                              });
                            },
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('PHIC Contribution')),
                          DataCell(TextField(
                            controller: phicContributionController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            onChanged: (value) {
                              setState(() {
                                totalDeduction = calculateDeductions();
                              });
                            },
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Witholding Tax')),
                          DataCell(TextField(
                            controller: witholdingTaxController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            onChanged: (value) {
                              setState(() {
                                totalDeduction = calculateDeductions();
                              });
                            },
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('SSS Loan')),
                          DataCell(TextField(
                            controller: sssLoanController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            onChanged: (value) {
                              setState(() {
                                totalDeduction = calculateDeductions();
                              });
                            },
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Pag-ibig Loan')),
                          DataCell(TextField(
                            controller: pagibigLoanController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            onChanged: (value) {
                              setState(() {
                                totalDeduction = calculateDeductions();
                              });
                            },
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Advances: Eye Crafter')),
                          DataCell(TextField(
                            controller: advancesEyeCrafterController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            onChanged: (value) {
                              setState(() {
                                totalDeduction = calculateDeductions();
                              });
                            },
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Advances: Amesco')),
                          DataCell(TextField(
                            controller: advancesAmescoController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            onChanged: (value) {
                              setState(() {
                                totalDeduction = calculateDeductions();
                              });
                            },
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Advances: Insular')),
                          DataCell(TextField(
                            controller: advancesInsularController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            onChanged: (value) {
                              setState(() {
                                totalDeduction = calculateDeductions();
                              });
                            },
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                                border: InputBorder.none, hintText: '0'),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Vitalab/ BMCDC')),
                          DataCell(TextField(
                              controller: vitalabBMCDCController,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(11),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  totalDeduction = calculateDeductions();
                                });
                              },
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: '0',
                              ))),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Other Advances')),
                          DataCell(TextField(
                            controller: otherAdvanceController,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                            onChanged: (value) {
                              setState(() {
                                totalDeduction = calculateDeductions();
                              });
                            },
                            style: TextStyle(fontSize: 14),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '0',
                            ),
                          )),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('')),
                          DataCell(Text('')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text(
                            'TOTAL DEDUCTIONS',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                          DataCell(Text(
                            totalDeduction.toString(),
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )),
                        ]),
                      ]),
                      VerticalDivider(
                        width: 40,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SUMMARY',
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1)),
                          SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Gross Pay: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                grossPay.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Deductions: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                totalDeduction.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'NET PAY: ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                              Text(
                                netPay.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Generate Payslip'),
                    onPressed: () async {
                      bool confirmGenerate = await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                title: Text('Confirmation'),
                                content: Text(
                                    'Are you sure you want to generate the payslip?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(true);
                                    },
                                    child: Text('Yes'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop(false);
                                    },
                                    child: Text('No'),
                                  ),
                                ]);
                          });

                      if (confirmGenerate == true) {
                        final String nightDifferentialText =
                            nightDifferentialController.text;

                        final String advancesAmescoText =
                            advancesAmescoController.text;

                        final String standyAllowanceText =
                            standyAllowanceController.text;

                        final String otherPremiumText =
                            otherPremiumPayController.text;

                        final String allowanceText = allowanceController.text;

                        final String salaryAdjustmentText =
                            salaryAdjustmentController.text;

                        final String otAdjustmentText =
                            otAdjustmentController.text;

                        final String referralBonusText =
                            referralBonusController.text;

                        final String signingBonusText =
                            signingBonusController.text;

                        final String sssContributionText =
                            sssContributionController.text;

                        final String pagibigContributionText =
                            pagibigContributionController.text;

                        final String phicContributionText =
                            phicContributionController.text;

                        final String withholdingTaxText =
                            witholdingTaxController.text;

                        final String sssLoanText = sssLoanController.text;

                        final String pagibigLoanText =
                            pagibigLoanController.text;

                        final String advancesEyeCrafterText =
                            advancesEyeCrafterController.text;

                        final String advancesInsularText =
                            advancesInsularController.text;

                        final String vitalabBMCDCText =
                            vitalabBMCDCController.text;
                        final String otherAdvancesText =
                            otherAdvanceController.text;

                        try {
                          final double advanceAmesco =
                              advancesAmescoText.isNotEmpty
                                  ? double.tryParse(advancesAmescoText) ?? 0
                                  : 0;
                          final double nightDifferential =
                              double.tryParse(nightDifferentialText) ?? 0.0;

                          final double standyAllowance =
                              double.tryParse(standyAllowanceText) ?? 0.0;
                          final double otherPremiumPay =
                              double.tryParse(otherPremiumText) ?? 0.0;
                          final double allowance =
                              double.tryParse(allowanceText) ?? 0.0;
                          final double salaryAdjustment =
                              double.tryParse(salaryAdjustmentText) ?? 0.0;
                          final double otAdjustment =
                              double.tryParse(otAdjustmentText) ?? 0.0;
                          final double referralBonus =
                              double.tryParse(referralBonusText) ?? 0.0;
                          final double signingBonus =
                              double.tryParse(signingBonusText) ?? 0.0;
                          final double sssContribution =
                              double.tryParse(sssContributionText) ?? 0.0;
                          final double pagibigContribution =
                              double.tryParse(pagibigContributionText) ?? 0.0;
                          final double phicContribution =
                              double.tryParse(phicContributionText) ?? 0.0;
                          final double withholdingTax =
                              double.tryParse(withholdingTaxText) ?? 0.0;
                          final double sssLoan =
                              double.tryParse(sssLoanText) ?? 0.0;
                          final double pagibigLoan =
                              double.tryParse(pagibigLoanText) ?? 0.0;
                          final double advancesEyeCrafter =
                              double.tryParse(advancesEyeCrafterText) ?? 0.0;
                          final double advancesInsular =
                              double.tryParse(advancesInsularText) ?? 0.0;
                          final double vitalabBMCDC =
                              double.tryParse(vitalabBMCDCText) ?? 0.0;
                          final double otherAdvances =
                              double.tryParse(otherAdvancesText) ?? 0.0;
                          double grossPay = calculateGrossPay();
                          double totalDeduction = calculateDeductions();
                          double netPay =
                              calculateNetPay(grossPay, totalDeduction);

                          var userData = userDocSnapshot.docs.first.data();
                          var monthlySalary = userData['monthly_salary'] ?? 0;
                          final holidayPay = holidayPayDataQuery.docs.isNotEmpty
                              ? holidayPayDataQuery.docs.first
                                      .data()['total_holidayPay'] ??
                                  0
                              : 0;
                          var specialHPay = specialHPayDataQuery.docs.isNotEmpty
                              ? specialHPayDataQuery.docs.first
                                      .data()['total_specialHolidayPay'] ??
                                  0
                              : 0;
                          var restdayOTPay = restdayOTDataQuery.docs.isNotEmpty
                              ? restdayOTDataQuery.docs.first
                                      .data()['total_restDayOTPay'] ??
                                  0
                              : 0;
                          // Assuming employeeId is accessible from the user object
                          final String employeeId = userData[
                              'employeeId']; // Adjust this line according to your actual user object structure

                          // User is authenticated, proceed with adding payslip
                          await addPayslip(
                            advances_amesco: advanceAmesco,
                            employeeId: employeeId,
                            night_differential: nightDifferential,
                            advances_eyecrafter: advancesEyeCrafter,
                            advances_insular: advancesInsular,
                            allowance: allowance,
                            ot_adjustment: otAdjustment,
                            other_advances: otherAdvances,
                            other_prem_pay: otherPremiumPay,
                            overAllOTPay: overallOTPay,
                            pagibig_contribution: pagibigContribution,
                            pagibig_loan: pagibigLoan,
                            phic_contribution: phicContribution,
                            signing_bonus: signingBonus,
                            salary_adjustment: salaryAdjustment,
                            referral_bonus: referralBonus,
                            sss_contribution: sssContribution,
                            sss_loan: sssLoan,
                            standy_allowance: standyAllowance,
                            vitalab_bmcdc: vitalabBMCDC,
                            witholding_tax: withholdingTax,
                            total_deduction: totalDeduction,
                            grossPay: grossPay,
                            netPay: netPay,
                            monthly_salary: monthlySalary,
                            holidayPay: holidayPay,
                            specialHOTPay: specialHOTPay,
                            specialHPay: specialHPay,
                            regularHOTPay: regularHOTPay,
                            regularOTPay: regularOTPay,
                            restdayOTPay: restdayOTPay,

                            // Pass employeeId instead of userId
                          );

                          // Update status to "Done" in Firestore document
                          await userDocSnapshot.docs.first.reference.update({
                            'status': 'Done',
                          });

                          // Add employeeId to _generateClickedList
                          _generateClickedList.add(employeeId);

                          Navigator.of(context).pop();
                        } catch (e) {
                          print('Error generating payslip: $e');
                        }
                        for (var overtimeDoc in overtimeQuerySnapshot.docs) {
                          await moveToArchiveOT(overtimeDoc);
                        }
                        for (var overtimeDoc in overtimeQuerySnapshot2.docs) {
                          await moveToSpecialHOT(overtimeDoc);
                        }
                        for (var overtimeDoc in overtimeQuerySnapshot3.docs) {
                          await moveToRestdayOT(overtimeDoc);
                        }

                        for (var overtimeDoc in overtimeQuerySnapshot4.docs) {
                          await moveToRegularHOT(overtimeDoc);
                        }

                        for (var overtimeDoc in overtimeQuerySnapshot5.docs) {
                          await moveToSpecialH(overtimeDoc);
                        }

                        for (var overtimeDoc in overtimeQuerySnapshot6.docs) {
                          await moveToRegularH(overtimeDoc);
                        }
                      }
                    },
                  ),
                  TextButton(
                    child: Text('Close'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
          },
        );
      }
    } catch (e) {
      print('Error showing payslip dialog: $e');
    }
  }

// Utility function to build info row in the dialog
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(value),
        ],
      ),
    );
  }

// Placeholder function, replace this with actual implementation
  Future<void> addPayslip({
    required double advances_amesco,
    required String employeeId,
    required double night_differential,
    required double advances_eyecrafter,
    required double advances_insular,
    required double allowance,
    required double ot_adjustment,
    required double other_advances,
    required double other_prem_pay,
    required double overAllOTPay,
    required double pagibig_contribution,
    required double pagibig_loan,
    required double phic_contribution,
    required double signing_bonus,
    required double salary_adjustment,
    required double referral_bonus,
    required double sss_contribution,
    required double sss_loan,
    required double standy_allowance,
    required double vitalab_bmcdc,
    required double witholding_tax,
    required double total_deduction,
    required double grossPay,
    required double netPay,
    required double monthly_salary,
    required double holidayPay,
    required double specialHPay,
    required double restdayOTPay,
    required double regularHOTPay,
    required double specialHOTPay,
    required double regularOTPay,
  }) async {
    try {
      final json = {
        'employeeId': employeeId,
        'advances_amesco': advances_amesco,
        'advances_eyecrafter': advances_eyecrafter,
        'advances_insular': advances_insular,
        'allowance': allowance,
        'holidayPay': holidayPay,
        'specialHPay': specialHPay,
        'restdayOTPay': restdayOTPay,
        'monthly_salary': monthly_salary,
        'grossPay': grossPay,
        'netPay': netPay,
        'night_differential': night_differential,
        'ot_adjustment': ot_adjustment,
        'other_advances': other_advances,
        'other_prem_pay': other_prem_pay,
        'overAllOTPay': overAllOTPay,
        'pagibig_contribution': pagibig_contribution,
        'pagibig_loan': pagibig_loan,
        'phic_contribution': phic_contribution,
        'referral_bonus': referral_bonus,
        'signing_bonus': signing_bonus,
        'salary_adjustment': salary_adjustment,
        'sss_contribution': sss_contribution,
        'sss_loan': sss_loan,
        'standy_allowance': standy_allowance,
        'vitalab_bmcdc': vitalab_bmcdc,
        'witholding_tax': witholding_tax,
        'total_deduction': total_deduction,
        'specialHOTPay': specialHOTPay,
        'regularHOTPay': regularHOTPay,
        'regularOTPay': regularOTPay,

        // Using employeeId as the document ID when adding to the Payslip collection
      };

      // Using employeeId as the document ID when adding to the Payslip collection
      await FirebaseFirestore.instance
          .collection('Payslip')
          .doc(employeeId)
          .set(json);

      print('Payslip added successfully for employee $employeeId');
    } catch (e) {
      print('Error adding payslip data: $e');
    }
  }

  Future<void> moveToArchiveOT(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      String employeeId = overtimeData['employeeId'];
      QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
          .collection('Overtime')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

      // Loop through documents and move each one to ArchivesOvertime collection
      for (DocumentSnapshot doc in userOvertimeDocs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          await FirebaseFirestore.instance
              .collection('ArchivesOvertime')
              .add(data); // Adding document data to ArchivesOvertime collection
        }
        await doc.reference
            .delete(); // Delete the document from the original collection
      }
    } catch (e) {
      print('Error moving record to ArchivesOvertime collection: $e');
    }
  }

  Future<void> _showPayslipDialog2(
      BuildContext context, Map<String, dynamic> data) async {
    try {
      var employeeId = data['employeeId'];
      var userDocSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('employeeId', isEqualTo: employeeId)
          .get();
      var userData = userDocSnapshot.docs.first.data();
      var monthlySalary = userData['monthly_salary'] ?? 0;

      var paySlipDataQuery = await FirebaseFirestore.instance
          .collection('Payslip')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      var nightDifferential = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['night_differential'] ?? 0
          : 0;

      var overallOTPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['overAllOTPay'] ?? 0
          : 0;

      var restdayOTPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['restdayOTPay'] ?? 0
          : 0;

      var holidayPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['holidayPay'] ?? 0
          : 0;

      var specialHPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['specialHPay'] ?? 0
          : 0;

      var standyAllowance = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['standy_allowance'] ?? 0
          : 0;

      var otherPremiumPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['other_prem_pay'] ?? 0
          : 0;

      var allowance = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['allowance'] ?? 0
          : 0;
      var salaryAdjustment = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['salary_adjustment'] ?? 0
          : 0;

      var otAdjustment = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['ot_adjustment'] ?? 0
          : 0;

      var referralBonus = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['referral_bonus'] ?? 0
          : 0;

      var signingBonus = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['signing_bonus'] ?? 0
          : 0;

      var grossPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['grossPay'] ?? 0
          : 0;

      var sssContribution = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['sss_contribution'] ?? 0
          : 0;

      var pagibigContribution = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['pagibig_contribution'] ?? 0
          : 0;
      var phicContribution = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['phic_contribution'] ?? 0
          : 0;
      var withHoldingTax = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['witholding_tax'] ?? 0
          : 0;

      var sssLoan = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['sss_loan'] ?? 0
          : 0;

      var pagibigLoan = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['pagibig_loan'] ?? 0
          : 0;

      var advancesEyeCrafter = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['advances_eyecrafter'] ?? 0
          : 0;

      var advancesAmesco = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['advances_amesco'] ?? 0
          : 0;

      var advancesInsular = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['advances_insular'] ?? 0
          : 0;
      var vitalabBMCDC = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['vitalab_bmcdc'] ?? 0
          : 0;

      var otherAdvances = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['other_advances'] ?? 0
          : 0;

      var totalDeduction = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['total_deduction'] ?? 0
          : 0;

      var netPay = paySlipDataQuery.docs.isNotEmpty
          ? paySlipDataQuery.docs.first.data()['netPay'] ?? 0
          : 0;
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (BuildContext context, setSTate) {
              return AlertDialog(
                title: Text('Payslip Details'),
                content: SingleChildScrollView(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Employee ID: ', data['employeeId']),
                      SizedBox(
                        width: 50,
                      ),
                      _buildInfoRow('Name: ',
                          data['fname'] + data['mname'] + data['lname']),
                      SizedBox(
                        width: 50,
                      ),
                      _buildInfoRow('Department: ', data['department']),
                      DataTable(
                        columns: const [
                          DataColumn(
                              label: Text('EARNINGS',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1))),
                          DataColumn(label: Text('Hours')),
                          DataColumn(label: Text('Amount')),
                        ],
                        rows: [
                          DataRow(cells: [
                            DataCell(Text('Basic Salary')),
                            DataCell(Text('')),
                            DataCell(Text(monthlySalary.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Night Differential')),
                            DataCell(Text('')),
                            DataCell(Text(nightDifferential.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Overtime')),
                            DataCell(Text('')),
                            DataCell(Text(overallOTPay.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('RDOT')),
                            DataCell(Text('')),
                            DataCell(Text(restdayOTPay.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Regular Holiday')),
                            DataCell(Text('')),
                            DataCell(Text(holidayPay.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Special Holiday')),
                            DataCell(Text('')),
                            DataCell(Text(specialHPay.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Standy Allowance')),
                            DataCell(Text('')),
                            DataCell(Text(standyAllowance.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Other Premium Pay')),
                            DataCell(Text('')),
                            DataCell(Text(otherPremiumPay.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Allowance  ')),
                            DataCell(Text('')),
                            DataCell(Text(allowance.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Salary Adjustment  ')),
                            DataCell(Text('')),
                            DataCell(Text(salaryAdjustment.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('OT Adjustment')),
                            DataCell(Text('')),
                            DataCell(Text(otAdjustment.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Referral Bonus')),
                            DataCell(Text('')),
                            DataCell(Text(referralBonus.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('Signing Bonus')),
                            DataCell(Text('')),
                            DataCell(Text(signingBonus.toString())),
                          ]),
                          DataRow(cells: [
                            DataCell(Text('GROSS PAY')),
                            DataCell(Text('')),
                            DataCell(Text(grossPay.toString())),
                          ]),
                        ],
                      ),
                      VerticalDivider(
                        width: 10,
                      ),
                      DataTable(columns: const [
                        DataColumn(
                          label: Text(
                            'DEDUCTIONS',
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1),
                          ),
                        ),
                        DataColumn(
                          label: Text('Amount'),
                        ),
                      ], rows: [
                        DataRow(cells: [
                          DataCell(Text('LWOP/ Tardiness')),
                          DataCell(Text('0')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('SSS Contribution')),
                          DataCell(Text(sssContribution.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Pag-ibig Contribution')),
                          DataCell(Text(pagibigContribution.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('PHIC Contribution')),
                          DataCell(Text(phicContribution.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Witholding Tax')),
                          DataCell(Text(withHoldingTax.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('SSS Loan')),
                          DataCell(Text(sssLoan.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Pag-ibig Loan')),
                          DataCell(Text(pagibigLoan.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Advances: Eye Crafter')),
                          DataCell(Text(advancesEyeCrafter.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Advances: Amesco')),
                          DataCell(Text(advancesAmesco.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Advances: Insular')),
                          DataCell(Text(advancesInsular.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Vitalab / BMCDC')),
                          DataCell(Text(vitalabBMCDC.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('Other Advances')),
                          DataCell(Text(otherAdvances.toString())),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('')),
                          DataCell(Text('')),
                        ]),
                        DataRow(cells: [
                          DataCell(Text('TOTAL DEDUCTIONS',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                          DataCell(Text(totalDeduction.toString())),
                        ]),
                      ]),
                      VerticalDivider(width: 40),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('SUMMARY',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              )),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Gross Pay: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                grossPay.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total Deductions: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                totalDeduction.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'NET PAY: ',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                netPay.toString(),
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          SizedBox(height: 580),
                          TextButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            });
          });
    } catch (e) {}
  }

  Future<void> moveToRestdayOT(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      String employeeId = overtimeData['employeeId'];
      QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
          .collection('RegularHolidayOT')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

      // Loop through documents and move each one to ArchivesOvertime collection
      for (DocumentSnapshot doc in userOvertimeDocs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          await FirebaseFirestore.instance
              .collection('ArchivesRegularHOT')
              .add(data); // Adding document data to ArchivesOvertime collection
        }
        await doc.reference
            .delete(); // Delete the document from the original collection
      }
    } catch (e) {
      print('Error moving record to ArchivesOvertime collection: $e');
    }
  }

  Future<void> moveToSpecialHOT(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      String employeeId = overtimeData['employeeId'];
      QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
          .collection('SpecialHolidayOT')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

      // Loop through documents and move each one to ArchivesOvertime collection
      for (DocumentSnapshot doc in userOvertimeDocs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          await FirebaseFirestore.instance
              .collection('ArchivesSpecialHOT')
              .add(data); // Adding document data to ArchivesOvertime collection
        }
        await doc.reference
            .delete(); // Delete the document from the original collection
      }
    } catch (e) {
      print('Error moving record to ArchivesOvertime collection: $e');
    }
  }

  Future<void> moveToRegularHOT(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      String employeeId = overtimeData['employeeId'];
      QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
          .collection('RegularHolidayOT')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

      // Loop through documents and move each one to ArchivesOvertime collection
      for (DocumentSnapshot doc in userOvertimeDocs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          await FirebaseFirestore.instance
              .collection('ArchivesRegularHOT')
              .add(data); // Adding document data to ArchivesOvertime collection
        }
        await doc.reference
            .delete(); // Delete the document from the original collection
      }
    } catch (e) {
      print('Error moving record to ArchivesOvertime collection: $e');
    }
  }

  Future<void> moveToRegularH(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      String employeeId = overtimeData['employeeId'];
      QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
          .collection('Holiday')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

      // Loop through documents and move each one to ArchivesOvertime collection
      for (DocumentSnapshot doc in userOvertimeDocs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          await FirebaseFirestore.instance
              .collection('ArchivesRegularH')
              .add(data); // Adding document data to ArchivesOvertime collection
        }
        await doc.reference
            .delete(); // Delete the document from the original collection
      }
    } catch (e) {
      print('Error moving record to ArchivesOvertime collection: $e');
    }
  }

  Future<void> moveToSpecialH(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      String employeeId = overtimeData['employeeId'];
      QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
          .collection('SpecialHoliday')
          .where('employeeId', isEqualTo: employeeId)
          .get();

      List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

      // Loop through documents and move each one to ArchivesOvertime collection
      for (DocumentSnapshot doc in userOvertimeDocs) {
        Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          await FirebaseFirestore.instance
              .collection('ArchivesSpecialH')
              .add(data); // Adding document data to ArchivesOvertime collection
        }
        await doc.reference
            .delete(); // Delete the document from the original collection
      }
    } catch (e) {
      print('Error moving record to ArchivesOvertime collection: $e');
    }
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
              label: Text('Department',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Total Hours (h:m)',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Overtime Pay',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label: Text('Overtime Type',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            DataColumn(
              label:
                  Text('Action', style: TextStyle(fontWeight: FontWeight.bold)),
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
            ]),
          ),
        ),
      ),
    );
  }
}
