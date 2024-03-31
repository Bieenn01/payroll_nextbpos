import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_payroll_nextbpo/frontend/payslip/payslip_page.dart';
import 'package:shimmer/shimmer.dart' as ShimmerPackage;

class PayslipEmployee extends StatefulWidget {
  PayslipEmployee({super.key});

  @override
  State<PayslipEmployee> createState() => _PayslipEmployeeState();
}

class _PayslipEmployeeState extends State<PayslipEmployee> {
  TextEditingController _searchController = TextEditingController();

  int _currentPage = 0;
  bool viewTable = true;
  String selectedDepartment = 'All';
  DateTime? fromDate;
  DateTime? toDate;
  List<PayslipData> payrollData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          color: Colors.teal.shade700,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(15, 5, 15, 15),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                "Payslip",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        _buildDataTable(),
                        const Divider(),
                        const SizedBox(height: 5),
                        Pagination(),
                        const SizedBox(height: 10),
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
                                columns: const [
                                  DataColumn(
                                      label: Text('#',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Employee Id',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Name',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
                                      label: Text('Date Generated',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold))),
                                  DataColumn(
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
                                        Text(fullname ?? 'Not Available Yet'),
                                      ),
                                      DataCell(Text("04-08-2024")),
                                      DataCell(Row(
                                        children: [
                                          IconButton(
                                              icon: Icon(Icons.visibility,
                                                  color: Colors.blue),
                                              onPressed: () {}),
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

  Row Pagination() {
    int pageNum = _currentPage + 1;
    return Row(mainAxisAlignment: MainAxisAlignment.end, children: [
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text('Previous', style: TextStyle(color: Colors.teal[900])),
      ),
      const SizedBox(width: 10),
      Container(
          height: 35,
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade200)),
          child: Text(
            '$pageNum',
          )),
      const SizedBox(width: 10),
      ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text('Next', style: TextStyle(color: Colors.teal[900])),
      ),
    ]);
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
              label: Text('Employee ID',
                  style: TextStyle(fontWeight: FontWeight.bold)),
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
