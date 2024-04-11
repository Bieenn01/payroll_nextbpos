import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ArchivesPayslip extends StatefulWidget {
  const ArchivesPayslip({super.key});

  @override
  State<ArchivesPayslip> createState() => _ArchvesPayslipState();
}

TextEditingController _searchController = TextEditingController();

class _ArchvesPayslipState extends State<ArchivesPayslip> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildDataTable());
  }

  Widget _buildDataTable() {
    return StreamBuilder(
      stream:
          FirebaseFirestore.instance.collection('ArchivesPayslip').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No data available yet'));
        } else {
          List<DocumentSnapshot> payslipDocs = snapshot.data!.docs;

          // Filter payrollDocs based on search text
          List<DocumentSnapshot> filteredPayrollDocs = _searchController
                  .text.isNotEmpty
              ? payslipDocs.where((doc) {
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
                  payslipDocs); // Copying the list if no search text to maintain original data

          return SizedBox(
            height: 700,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Flexible(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              DataTable(
                                columns: [
                                  const DataColumn(
                                      label: Text('#',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  const DataColumn(
                                      label: Text('Employee Id',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  const DataColumn(
                                      label: Text('Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  const DataColumn(
                                      label: Text('Department',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  const DataColumn(
                                      label: Text('Action',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                ],
                                rows: List.generate(filteredPayrollDocs.length,
                                    (index) {
                                  DocumentSnapshot payrollDoc =
                                      filteredPayrollDocs[index];
                                  Map<String, dynamic> payrollData =
                                      payrollDoc.data() as Map<String, dynamic>;
                                  final fullname =
                                      '${payrollData['fname']} ${payrollData['mname']} ${payrollData['lname']}';

                                  // Checking if the employeeId exists in _generateClickedList to highlight the row

                                  return DataRow(
                                    cells: [
                                      DataCell(Text('${index + 1}')),
                                      DataCell(
                                        Text(payrollData['employeeId'] ??
                                            'Not Available Yet'),
                                      ),
                                      DataCell(
                                        Text(payrollData['fullname'] ??
                                            'Not Available Yet'),
                                      ),
                                      DataCell(
                                        Text(payrollData['department'] ??
                                            'Not Available Yet'),
                                      ),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.visibility,
                                                color: Colors.blue),
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return AlertDialog(
                                                    title:
                                                        Text('Payroll Details'),
                                                    content:
                                                        SingleChildScrollView(
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Row(
                                                            children: [
                                                              Container(
                                                                child:
                                                                    DataTable(
                                                                  columns: const [
                                                                    DataColumn(
                                                                      label:
                                                                          Text(
                                                                        'EARNINGS',
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                                18,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                            letterSpacing: 1),
                                                                      ),
                                                                    ),
                                                                    DataColumn(
                                                                        label: Text(
                                                                            'Hours')),
                                                                    DataColumn(
                                                                        label: Text(
                                                                            'Amount')),
                                                                  ],
                                                                  rows: [
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Basic Salary')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['monthly_salary'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                          Text(
                                                                              'Night Differential'),
                                                                        ),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['night_differential'] ?? 0)
                                                                              .toString(),
                                                                        )),
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Overtime')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['overAllOTPay'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('RDOT')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['restdayOTPay'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Regular Holiday')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['holidayPay'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Special Holiday')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['specialHPay'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Standy Allowance')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['standy_allowance'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Other PRemium Pay')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['other_prem_pay'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Allowance')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['allowance'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Salary Adjustment')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['salary_adjustment'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('OT Adjustment')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['ot_adjustment'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Referral Bonus')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['referral_bonus'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Signing Bonus')),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['signing_bonus'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(Text(
                                                                            'GROSS PAY',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold))),
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['grossPay'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        10,
                                                                        0),
                                                                height: 700,
                                                                width:
                                                                    1, // Adjust the width as needed
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              Container(
                                                                child:
                                                                    DataTable(
                                                                  columns: const [
                                                                    DataColumn(
                                                                        label:
                                                                            Text(
                                                                      'DEDUCTIONS',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              18,
                                                                          letterSpacing:
                                                                              1),
                                                                    )),
                                                                    DataColumn(
                                                                      label: Text(
                                                                          'Amount'),
                                                                    ),
                                                                  ],
                                                                  rows: [
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('LWOP / Tardiness')),
                                                                        DataCell(
                                                                            Text('0'))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('SSS Contribution')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['sss_contribution'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Pag-ibig Contribution')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['pagibig_contribution'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('PHIC Contribution')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['phic_contribution'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Witholding Tax')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['witholding_tax'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('SSS Loan')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['sss_loan'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Pag-ibig Loan')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['pagibig_loan'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Advances: Eyecrafter')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['advances_eyecrafter'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Advances: Amesco')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['advances_amesco'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Advances: Insular')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['advances_insular'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Vitalab / BMCDC')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['vitalab_bmcdc'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('Other Advances')),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['other_advanaces'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text('')),
                                                                        DataCell(
                                                                            Text(''))
                                                                      ],
                                                                    ),
                                                                    DataRow(
                                                                      cells: [
                                                                        DataCell(Text(
                                                                            'TOTAL DEDUCTIONS',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold))),
                                                                        DataCell(
                                                                            Text(
                                                                          (payrollData['total_deduction'] ?? 0)
                                                                              .toString(),
                                                                        ))
                                                                      ],
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Container(
                                                                margin: EdgeInsets
                                                                    .fromLTRB(
                                                                        10,
                                                                        0,
                                                                        10,
                                                                        0),
                                                                height: 700,
                                                                width:
                                                                    1, // Adjust the width as needed
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              Container(
                                                                width: 250,
                                                                child: Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    SizedBox(
                                                                      height:
                                                                          20,
                                                                    ),
                                                                    Text(
                                                                        'SUMMARY',
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              18,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          letterSpacing:
                                                                              1,
                                                                        )),
                                                                    SizedBox(
                                                                        height:
                                                                            10),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          'Gross Pay: ',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                        Text(
                                                                          (payrollData['grossPay'] ?? 0)
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          'Total Deductions: ',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                        Text(
                                                                          (payrollData['total_deduction'] ?? 0)
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    Divider(),
                                                                    Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Text(
                                                                          'NET PAY: ',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                        Text(
                                                                          (payrollData['netPay'] ?? 0)
                                                                              .toString(),
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                    SizedBox(
                                                                        height:
                                                                            580),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),

                                                          // Add more details as needed
                                                        ],
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: Text('Close'),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                        ],
                                      )),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
      },
    );
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
              surfaceTintColor: Colors.white,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Payslip Details'),
                  IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundImage: data['role'] == 'Admin'
                              ? const AssetImage('assets/images/Admin.jpg')
                              : data['role'] == 'Superadmin'
                                  ? const AssetImage('assets/images/SAdmin.jpg')
                                  : const AssetImage(
                                      'assets/images/Employee.jpg'),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(data['employeeId'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(data['fname'] +
                                " " +
                                data['mname'] +
                                " " +
                                data['lname']),
                            Row(
                              children: [
                                Container(
                                    color: Colors.blue[300],
                                    child: Text(data['department'])),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                    color: Colors.amber[200],
                                    child: Text(data['typeEmployee'])),
                                SizedBox(
                                  width: 5,
                                ),
                                Container(
                                    color: Colors.lime[300],
                                    child: Text(data['role'])),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 400,
                          child: DataTable(
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
                                DataCell(Text(
                                  'GROSS PAY',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )),
                                DataCell(Text('')),
                                DataCell(Text(grossPay.toString())),
                              ]),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          height: 700,
                          width: 1, // Adjust the width as needed
                          color: Colors.black,
                        ),
                        Container(
                          width: 400,
                          child: DataTable(columns: const [
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
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold))),
                              DataCell(Text(totalDeduction.toString())),
                            ]),
                          ]),
                        ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          height: 700,
                          width: 1, // Adjust the width as needed
                          color: Colors.black,
                        ),
                        Container(
                          width: 250,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Text('SUMMARY',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1,
                                  )),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Gross Pay: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    grossPay.toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Total Deductions: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    totalDeduction.toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'NET PAY: ',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    netPay.toString(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              SizedBox(height: 580),
                            ],
                          ),
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
