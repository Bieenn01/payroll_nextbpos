import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_payroll_nextbpo/frontend/payslip/payslip._form.dart';

class PayslipPage extends StatefulWidget {
  const PayslipPage({super.key});

  @override
  State<PayslipPage> createState() => _PayslipPageState();
}

class _PayslipPageState extends State<PayslipPage> {
  bool viewTable = true;
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
                      viewTable ? timesheet() : payroll(),
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

  SizedBox timesheet() {
    var dataTable = DataTable(columns: const [
      DataColumn(
          label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Department',
              style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Date Start',
              style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label:
              Text('Date End', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Date Generated',
              style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
    ], rows: [
      DataRow(cells: [
        const DataCell(Text('1')),
        const DataCell(Text('IT_Feb1-15')),
        const DataCell(Text('IT')),
        const DataCell(Text('02-01-2024')),
        const DataCell(Text('02-15-2024')),
        const DataCell(Text('02-16-2024')),
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
      ])
    ]);
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

  SizedBox payroll() {
    var dataTable = DataTable(columns: const [
      DataColumn(
          label: Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Employee ID',
              style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label:
              Text('Gross Pay', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Deductions',
              style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label:
              Text('Net Pay', style: TextStyle(fontWeight: FontWeight.bold))),
      DataColumn(
          label: Text('Action', style: TextStyle(fontWeight: FontWeight.bold))),
    ], rows: [
      DataRow(cells: [
        const DataCell(Text('1')),
        const DataCell(Text('354632')),
        const DataCell(Text('Dahnica J. Tedlos')),
        const DataCell(Text('21,000.00')),
        const DataCell(Text('0.00')),
        const DataCell(Text('0.00')),
        DataCell(
          ElevatedButton(
            onPressed: () {
              setState(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PayslipForm()),
                );
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
      ]),
      DataRow(cells: [
        const DataCell(Text('2')),
        const DataCell(Text('520942')),
        const DataCell(Text('Caezzy Makilan')),
        const DataCell(Text('21,000.00')),
        const DataCell(Text('0.00')),
        const DataCell(Text('0.00')),
        DataCell(
          ElevatedButton(
            onPressed: () {
              setState(() {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PayslipForm()),
                );
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
      ])
    ]);
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
}
