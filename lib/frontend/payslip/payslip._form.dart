import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class PayslipForm extends StatefulWidget {
  PayslipForm({super.key});

  @override
  State<PayslipForm> createState() => _PayslipFormState();
}

class _PayslipFormState extends State<PayslipForm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text('Payslip Form'),
          ],
        ),
      ),
      body: Container(
        color: Colors.teal.shade300,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.width > 700 ? 110 : 140,
                margin: const EdgeInsets.fromLTRB(15, 10, 15, 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: MediaQuery.of(context).size.width > 700
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: userInfo()), // Wrap userInfo with Expanded
                          taxInfo(),
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            userInfo(),
                            Row(
                              children: [
                                SizedBox(width: 100),
                                Expanded(
                                    child:
                                        taxInfo()), // Wrap taxInfo with Expanded
                              ],
                            ),
                          ],
                        ),
                      ),
              ),
              Container(
                  height: 750,
                  margin: const EdgeInsets.fromLTRB(15, 0, 15, 15),
                  padding: const EdgeInsets.all(0),
                  child: MediaQuery.of(context).size.width > 1000
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Flexible(
                              flex: 3,
                              child: Container(
                                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                padding: const EdgeInsets.all(0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Flexible(
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: earningsTable(),
                                        ),
                                      ),
                                      VerticalDivider(),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.all(10),
                                          child: deductionsTable(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Flexible(
                                flex: 1,
                                child: Container(
                                  margin:
                                      const EdgeInsets.fromLTRB(15, 0, 0, 0),
                                  padding: const EdgeInsets.only(top: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(20),
                                      child: summaryTable(),
                                    ),
                                  ),
                                )),
                          ],
                        )
                      : Column(
                          children: [
                            SizedBox(
                              height: 570,
                              child: SingleChildScrollView(
                                child: MediaQuery.of(context).size.width > 700
                                    ? Flexible(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: earningsTable(),
                                                ),
                                              ),
                                              VerticalDivider(),
                                              Expanded(
                                                child: Container(
                                                  padding: EdgeInsets.all(10),
                                                  child: deductionsTable(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    : Flexible(
                                        child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: earningsTable()),
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: deductionsTable()),
                                              ],
                                            )),
                                      ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 10, 0, 5),
                                  padding: EdgeInsets.fromLTRB(10, 15, 10, 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: summaryTable()),
                            )
                          ],
                        )),
            ],
          ),
        ),
      ),
    );
  }

  Column summaryTable() {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SUMMARY',
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1)),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Gross Pay',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '21,000.00',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total Deductions',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              '0.00',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'NET PAY',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              '21,000.00',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            )
          ],
        ),
      ],
    );
  }

  DataTable earningsTable() {
    return DataTable(
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
      rows: const [
        DataRow(cells: [
          DataCell(Text('Basic Salary')),
          DataCell(Text('')),
          DataCell(Text('18,000.00')),
        ]),
        DataRow(cells: [
          DataCell(Text('Night Differential')),
          DataCell(Text('-')),
          DataCell(Text('-')),
        ]),
        DataRow(cells: [
          DataCell(Text('Overtime')),
          DataCell(Text('2')),
          DataCell(Text('2,000.00')),
        ]),
        DataRow(cells: [
          DataCell(Text('RDOT')),
          DataCell(Text('1')),
          DataCell(Text('1,000.00')),
        ]),
        DataRow(cells: [
          DataCell(Text('Regular Holiday')),
          DataCell(Text('-')),
          DataCell(Text('0.00')),
        ]),
        DataRow(cells: [
          DataCell(Text('Special Holiday')),
          DataCell(Text('-')),
          DataCell(Text('0.00')),
        ]),
        DataRow(cells: [
          DataCell(Text('Standy Allowance')),
          DataCell(Text('-')),
          DataCell(TextField(
            style: TextStyle(fontSize: 14),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '-'),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text('Other Premium Pay')),
          DataCell(Text('-')),
          DataCell(TextField(
            style: TextStyle(fontSize: 14),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '-'),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text('Allowance')),
          DataCell(Text('-')),
          DataCell(TextField(
            style: TextStyle(fontSize: 14),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '-'),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text('Salary Adjustment')),
          DataCell(Text('-')),
          DataCell(TextField(
            style: TextStyle(fontSize: 14),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '-'),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text('OT Adjustment')),
          DataCell(Text('-')),
          DataCell(TextField(
            style: TextStyle(fontSize: 14),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '-'),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text('Referral Bonus')),
          DataCell(Text('-')),
          DataCell(TextField(
            style: TextStyle(fontSize: 14),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '-'),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text('Signing Bonus')),
          DataCell(Text('-')),
          DataCell(TextField(
            style: TextStyle(fontSize: 14),
            decoration:
                InputDecoration(border: InputBorder.none, hintText: '-'),
          )),
        ]),
        DataRow(cells: [
          DataCell(Text(
            'GROSS PAY',
            style: TextStyle(fontWeight: FontWeight.bold),
          )),
          DataCell(Text('')),
          DataCell(Text(
            '21,000.00',
            style: TextStyle(fontWeight: FontWeight.bold),
          ))
        ]),
      ],
    );
  }

  DataTable deductionsTable() {
    return DataTable(columns: const [
      DataColumn(
          label: Text('DEDUCTIONS',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1))),
      DataColumn(label: Text('Amount')),
    ], rows: const [
      DataRow(cells: [
        DataCell(Text('LWOP/ Tardiness')),
        DataCell(TextField(
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(border: InputBorder.none, hintText: '-'),
        )),
      ]),
      DataRow(cells: [
        DataCell(Text('SSS Contribution')),
        DataCell(TextField(
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(border: InputBorder.none, hintText: '-'),
        )),
      ]),
      DataRow(cells: [
        DataCell(Text('Pag-ibig Contribution')),
        DataCell(TextField(
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(border: InputBorder.none, hintText: '-'),
        )),
      ]),
      DataRow(cells: [
        DataCell(Text('PHIC Contribution')),
        DataCell(TextField(
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(border: InputBorder.none, hintText: '-'),
        )),
      ]),
      DataRow(cells: [
        DataCell(Text('Witholding Tax')),
        DataCell(TextField(
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(border: InputBorder.none, hintText: '-'),
        )),
      ]),
      DataRow(cells: [
        DataCell(Text('SSS Loan')),
        DataCell(TextField(
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(border: InputBorder.none, hintText: '-'),
        )),
      ]),
      DataRow(cells: [
        DataCell(Text('Pag-ibig Loan')),
        DataCell(TextField(
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(border: InputBorder.none, hintText: '-'),
        )),
      ]),
      DataRow(cells: [
        DataCell(Text('Advances: Eye Crafter')),
        DataCell(TextField(
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(border: InputBorder.none, hintText: '-'),
        )),
      ]),
      DataRow(cells: [
        DataCell(Text('Advances: Amesco')),
        DataCell(TextField(
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(border: InputBorder.none, hintText: '-'),
        )),
      ]),
      DataRow(cells: [
        DataCell(Text('Advances: Insular')),
        DataCell(TextField(
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(border: InputBorder.none, hintText: '-'),
        )),
      ]),
      DataRow(cells: [
        DataCell(Text('Vitalab/ BMCDC')),
        DataCell(TextField(
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(border: InputBorder.none, hintText: '-'),
        )),
      ]),
      DataRow(cells: [
        DataCell(Text('Other Advances')),
        DataCell(TextField(
          style: TextStyle(fontSize: 14),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '-',
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
          '0.00',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
      ]),
    ]);
  }

  Row taxInfo() {
    return const Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pay Period',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'SSS',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'Tax Code',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'TIN',
              style: TextStyle(fontWeight: FontWeight.bold),
            )
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ': February 15-30, 2024',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              ': 334 -6465465-64',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              ': 54-6545646-56',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              ': 654546-654',
              style: TextStyle(fontWeight: FontWeight.w500),
            )
          ],
        ),
      ],
    );
  }

  Row userInfo() {
    return Row(
      children: [
        Container(
          width: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: FittedBox(
            fit: BoxFit.fill,
            child: Image.asset(
              'assets/images/Employee.jpg',
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '546465',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Taylor Swift',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  //Department
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade200,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'IT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  //Role
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.yellow.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Employee',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  //Employee Status
                  Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.green.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: const Text(
                      'Regular',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
