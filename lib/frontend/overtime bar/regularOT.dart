import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart' as ShimmerPackage;

class RegularOTPage extends StatefulWidget {
  const RegularOTPage({Key? key}) : super(key: key);

  @override
  State<RegularOTPage> createState() => _RegularOTPageState();
}

class _RegularOTPageState extends State<RegularOTPage> {
  late List<String> _selectedOvertimeTypes;
  TextEditingController _searchController = TextEditingController();
  FocusNode _searchFocusNode = FocusNode();
  bool _showFilterCategory = false;
  String _selectedCategory = 'name';
  int _itemsPerPage = 5;
  int _currentPage = 0;
  int indexRow = 0;
  late String _role = 'Guest';

  @override
  void initState() {
    super.initState();
    _selectedOvertimeTypes = [];
    _searchFocusNode.addListener(() {
      setState(() {
        _showFilterCategory = _searchFocusNode.hasFocus;
      });
    });
    _fetchRole();
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

  DateTime? fromDate;
  DateTime? toDate;
  bool _sortAscending = false;

  bool sortPay = false;
  bool table = false;
  bool filter = false;

  String selectedDepartment = 'All';

  bool endPicked = false;
  bool startPicked = false;

  @override
  Widget build(BuildContext context) {
    var styleFrom = ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      padding: const EdgeInsets.all(5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

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
                                "Regular Overtime",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        dateFilterSearchRow(context, styleFrom),
                        const Divider(),
                        dataTable(),
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

  StreamBuilder<QuerySnapshot<Map<String, dynamic>>> dataTable() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('Overtime').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return _buildShimmerLoading();
        } else if (snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No data available yet'));
        } else {
          List<DocumentSnapshot> overtimeDocs = _role == 'Employee'
              ? snapshot.data!.docs
                  .where((doc) => doc['userId'] == getCurrentUserId())
                  .toList()
              : snapshot.data!.docs;

          List<DocumentSnapshot> filteredDocs = overtimeDocs.where((document) {
            Map<String, dynamic> data = document.data() as Map<String, dynamic>;
            String userName = data['userName'];
            String department = data['department'] ?? '';
            DateTime? timeIn = (data['timeIn'] as Timestamp?)?.toDate();

            String query = _searchController.text.toLowerCase();
            bool matchesSearchQuery = userName.toLowerCase().contains(query);
            bool matchesDepartment =
                selectedDepartment == 'All' || department == selectedDepartment;
            bool isAfterStartDate = fromDate == null ||
                (timeIn != null && timeIn.isAfter(fromDate!));
            bool isBeforeEndDate = toDate == null ||
                (timeIn != null &&
                    timeIn.isBefore(toDate!.add(Duration(days: 1))));

            return matchesSearchQuery &&
                matchesDepartment &&
                isAfterStartDate &&
                isBeforeEndDate;
          }).toList();

          // Filtering based on date range
          overtimeDocs = filteredDocs.where((doc) {
            DateTime timeIn = doc['timeIn'].toDate();
            DateTime timeOut = doc['timeOut'].toDate();
            if (fromDate != null && toDate != null) {
              return timeIn.isAfter(fromDate!) &&
                  timeOut.isBefore(toDate!.add(const Duration(
                      days: 1))); // Adjusted toDate to include end of the day
            } else if (fromDate != null) {
              return timeIn.isAfter(fromDate!);
            } else if (toDate != null) {
              return timeOut.isBefore(toDate!.add(const Duration(
                  days: 1))); // Adjusted toDate to include end of the day
            }
            return true;
          }).toList();

          _sortAscending
              ? filteredDocs.sort((a, b) {
                  double overtimePayA = a['overtimePay'] ?? 0.0;
                  double overtimePayB = b['overtimePay'] ?? 0.0;
                  return overtimePayA.compareTo(overtimePayB);
                })
              : filteredDocs.sort((b, a) {
                  double overtimePayA = a['overtimePay'] ?? 0.0;
                  double overtimePayB = b['overtimePay'] ?? 0.0;
                  return overtimePayA.compareTo(overtimePayB);
                });

          List<DocumentSnapshot> filteredDocuments = filteredDocs;
          if (selectedDepartment != 'All') {
            filteredDocuments = overtimeDocs
                .where((doc) => doc['department'] == selectedDepartment)
                .toList();
            filteredDocuments.sort((a, b) {
              Timestamp aTimestamp = a['timeIn'];
              Timestamp bTimestamp = b['timeIn'];
              return bTimestamp.compareTo(aTimestamp);
            });
          }

          // Sort documents by timestamp in descending order

          const textStyle = TextStyle(fontWeight: FontWeight.bold);

          var dataTable = DataTable(
            columns: [
              const DataColumn(
                  label: Flexible(child: Text('#', style: textStyle))),
              const DataColumn(
                  label: Flexible(
                child: Text('ID', style: textStyle),
              )),
              const DataColumn(
                  label: Flexible(child: Text('Name', style: textStyle))),
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
              const DataColumn(
                label: Flexible(
                  child: Text(
                    'Date',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const DataColumn(
                  label: Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Overtime Hours',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
              DataColumn(
                label: Container(
                  width: 100,
                  padding: const EdgeInsets.all(0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _sortAscending = !_sortAscending;
                      });
                    },
                    child: Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Overtime Pay',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(
                              width:
                                  4), // Add some space between the text and the icon
                          Flexible(
                            child: Icon(
                              _sortAscending
                                  ? Icons.arrow_drop_down
                                  : Icons.arrow_drop_up,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const DataColumn(
                  label: Flexible(
                child: Text('Overtime Type', style: textStyle),
              )),
              const DataColumn(
                  label: Flexible(
                child: Text('Action', style: textStyle),
              )),
            ],
            rows: List.generate(filteredDocuments.length, (index) {
              DocumentSnapshot overtimeDoc = filteredDocuments[index];
              Map<String, dynamic> overtimeData =
                  overtimeDoc.data() as Map<String, dynamic>;
              _selectedOvertimeTypes.add(
                'Regular',
              );

              // Extract timestamps for timeIn and timeOut
              Timestamp? timeInTimestamp = overtimeDoc['timeIn'];
              Timestamp? timeOutTimestamp = overtimeDoc['timeOut'];

              // Calculate the duration between timeIn and timeOut
              Duration totalDuration = const Duration();
              if (timeInTimestamp != null && timeOutTimestamp != null) {
                DateTime timeIn = timeInTimestamp.toDate();
                DateTime timeOut = timeOutTimestamp.toDate();
                totalDuration = timeOut.difference(timeIn);
              }
              // Format the duration to display total hours
              String totalHoursAndMinutes =
                  '${totalDuration.inHours} hrs, ${totalDuration.inMinutes.remainder(60)} mins';

              Color? rowColor = indexRow % 2 == 0
                  ? Colors.grey[200]
                  : Colors.white; // Alternating row colors
              indexRow++; //

              return DataRow(
                  color: MaterialStateColor.resolveWith((states) => rowColor!),
                  cells: [
                    DataCell(Text((index + 1).toString())),
                    DataCell(
                      Text(overtimeData['employeeId'] ?? 'Not Available Yet'),
                    ),
                    DataCell(
                      Text(overtimeData['userName'] ?? 'Not Available Yet'),
                    ),
                    DataCell(
                      Text(overtimeData['department'] ?? 'Not Available Yet'),
                    ),
                    DataCell(
                      Text(_formatDate(
                          overtimeData['timeIn'] ?? 'Not Available Yet')),
                    ),
                    DataCell(
                      Container(
                        width: 100,
                        padding: const EdgeInsets.fromLTRB(5, 2, 2, 5),
                        decoration: BoxDecoration(
                          color: Colors.indigo[50],
                          border: Border.all(color: Colors.indigo.shade900),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(totalHoursAndMinutes),
                            ),
                          ],
                        ),
                      ),
                    ),
                    DataCell(Text(
                        NumberFormat.currency(
                                locale: 'en_PH', symbol: '₱ ', decimalDigits: 2)
                            .format(overtimeData['overtimePay'] ?? 0.0),
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(
                      SizedBox(
                        child: IntrinsicWidth(
                          child: DropdownButton<String>(
                            // style: TextStyle(
                            //     fontSize: 12, fontWeight: FontWeight.bold),
                            value: _selectedOvertimeTypes[index],
                            items: <String>[
                              'Regular',
                              'Special Holiday OT',
                              'Regular Holiday OT',
                              'Rest day OT'
                            ].map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) async {
                              if (newValue == 'Special Holiday OT') {
                                await _showConfirmationDialog(overtimeDoc);
                              }
                              setState(() {
                                _selectedOvertimeTypes[index] = newValue!;
                              });
                              if (newValue == 'Regular Holiday OT') {
                                await _showConfirmationDialog2(overtimeDoc);
                              }
                              setState(() {
                                _selectedOvertimeTypes[index] = newValue!;
                              });
                              if (newValue == 'Rest day OT') {
                                await _showConfirmationDialog3(overtimeDoc);
                              }
                              setState(() {
                                _selectedOvertimeTypes[index] = newValue!;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      Container(
                        width: 80,
                        padding: const EdgeInsets.all(0),
                        child: ElevatedButton(
                          onPressed: () async {
                            await _showConfirmationDialog4(overtimeDoc);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.all(5),
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
                                size: 18,
                              ),
                              Text(
                                'View',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ]);
            }),
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
      },
    );
  }

  Container dateFilterSearchRow(BuildContext context, ButtonStyle styleFrom) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          Flexible(
            child: Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Flexible(
                    child: MediaQuery.of(context).size.width > 600
                        ? Row(
                            children: [
                              const Text('Show entries: '),
                              Container(
                                width: 70,
                                height: 30,
                                padding: const EdgeInsets.only(left: 10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: Colors.grey.shade200)),
                                child: DropdownButton<int>(
                                  padding: const EdgeInsets.all(5),
                                  underline: const SizedBox(),
                                  value: _itemsPerPage,
                                  items: [5, 10, 15, 20, 25]
                                      .map<DropdownMenuItem<int>>(
                                    (int value) {
                                      return DropdownMenuItem<int>(
                                        value: value,
                                        child: Text('$value'),
                                      );
                                    },
                                  ).toList(),
                                  onChanged: (int? newValue) {
                                    setState(() {
                                      _itemsPerPage = newValue!;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                          )
                        : DropdownButton<int>(
                            padding: const EdgeInsets.all(5),
                            underline: const SizedBox(),
                            value: _itemsPerPage,
                            items:
                                [5, 10, 15, 20, 25].map<DropdownMenuItem<int>>(
                              (int value) {
                                return DropdownMenuItem<int>(
                                  value: value,
                                  child: Text('$value'),
                                );
                              },
                            ).toList(),
                            onChanged: (int? newValue) {
                              setState(() {
                                _itemsPerPage = newValue!;
                              });
                            },
                          ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: ElevatedButton(
                            onPressed: () async {
                              await _computeAndAddToOvertimePay();
                            },
                            child:
                                const Text('Compute and Add to Overtime Pay'),
                          ),
                        ),
                        Flexible(
                          child: Container(
                            width: MediaQuery.of(context).size.width > 600
                                ? 400
                                : 100,
                            height: 30,
                            margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                            padding: const EdgeInsets.fromLTRB(3, 0, 0, 0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: Colors.black.withOpacity(0.5)),
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
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                        Flexible(
                          child: Container(
                              width: 130,
                              height: 30,
                              padding: const EdgeInsets.all(0),
                              margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                              decoration: BoxDecoration(
                                  color: Colors.teal,
                                  border: Border.all(
                                      color: Colors.teal.shade900
                                          .withOpacity(0.5)),
                                  borderRadius: BorderRadius.circular(8)),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal,
                                  padding: const EdgeInsets.only(left: 5),
                                ),
                                onPressed: () {
                                  setState(() {
                                    filter = !filter;
                                  });
                                  filtermodal(
                                    context,
                                    styleFrom,
                                  );
                                },
                                child: MediaQuery.of(context).size.width > 800
                                    ? const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.filter_alt_outlined,
                                            color: Colors.white,
                                          ),
                                          Text(
                                            'Filter Date',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                letterSpacing: 1,
                                                color: Colors.white),
                                          ),
                                        ],
                                      )
                                    : const Icon(
                                        Icons.filter_alt_outlined,
                                        color: Colors.white,
                                      ),
                              )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  Future<dynamic> filtermodal(BuildContext context, ButtonStyle styleFrom) {
    return showDialog(
        context: context,
        builder: (_) => Row(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 130,
                    ),
                    AlertDialog(
                      surfaceTintColor: Colors.white,
                      content: SizedBox(
                        height: 200,
                        width: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Filter Date',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    icon: const Icon(Icons.close)),
                              ],
                            ),
                            const Text('From :'),
                            _fromDate(context, styleFrom),
                            const SizedBox(
                              width: 5,
                            ),
                            const Text('To :'),
                            _toDate(context, styleFrom),
                            const SizedBox(
                              height: 5,
                            ),
                            clearDate(context, styleFrom),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ));
  }

  Container clearDate(BuildContext context, ButtonStyle styleFrom) {
    return Container(
      height: 30,
      padding: const EdgeInsets.all(0),
      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.red.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(12)),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white, padding: EdgeInsets.all(3)),
        onPressed: () {
          setState(() {
            toDate = null;
            fromDate = null;
            filter = false;
          });
          Navigator.of(context).pop();
        },
        child: const Text(
          'Reset Date',
          style: TextStyle(
              fontWeight: FontWeight.w400, letterSpacing: 1, color: Colors.red),
        ),
      ),
    );
  }

  Flexible _toDate(BuildContext context, ButtonStyle styleFrom) {
    return Flexible(
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 150 : 50,
        padding: const EdgeInsets.all(2),
        child: ElevatedButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: toDate ?? DateTime.now(),
                firstDate: DateTime(2015, 8),
                lastDate: DateTime(2101),
              );
              if (picked != null && picked != toDate) {
                setState(() {
                  toDate = picked;
                  endPicked = true;
                });
              }
            },
            style: styleFrom,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Text(
                        toDate != null
                            ? DateFormat('yyyy-MM-dd').format(toDate!)
                            : 'Select',
                        style: TextStyle(
                          color: endPicked == !true
                              ? Colors.black
                              : Colors.teal.shade800,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.calendar_month,
                  color: Colors.black,
                  size: 20,
                ),
              ],
            )),
      ),
    );
  }

  Flexible _fromDate(BuildContext context, ButtonStyle styleFrom) {
    return Flexible(
      child: Container(
        width: MediaQuery.of(context).size.width > 600 ? 230 : 80,
        padding: const EdgeInsets.all(2),
        child: ElevatedButton(
            onPressed: () async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: fromDate ?? DateTime.now(),
                firstDate: DateTime(2015, 8),
                lastDate: DateTime(2101),
              );
              if (picked != null && picked != fromDate) {
                setState(() {
                  fromDate = picked;
                  startPicked = true;
                });
              }
            },
            style: styleFrom,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Text(
                        fromDate != null
                            ? DateFormat('yyyy-MM-dd').format(fromDate!)
                            : 'Select',
                        style: TextStyle(
                          color: startPicked == !true
                              ? Colors.black
                              : Colors.teal.shade800,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(width: 3),
                const Icon(
                  Icons.calendar_month,
                  color: Colors.black,
                  size: 20,
                ),
              ],
            )),
      ),
    );
  }

  Future<void> _calculateTotalOvertimePay(DocumentSnapshot overtimeDoc) async {
    String userId = overtimeDoc['userId'];
    QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
        .collection('Overtime')
        .where('userId', isEqualTo: userId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;
  }

  Future<void> _showConfirmationDialog4(DocumentSnapshot overtimeDoc) async {
    String userId = overtimeDoc['userId'];
    QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
        .collection('Overtime')
        .where('userId', isEqualTo: userId)
        .get();

    List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

    userOvertimeDocs.sort((a, b) {
      Timestamp aTimestamp = a['timeIn'];
      Timestamp bTimestamp = b['timeIn'];
      return bTimestamp.compareTo(aTimestamp);
    });

    int totalDays = 0;
    double totalHours = 0.0;
    double totalPays = 0.0;

    // Calculate total days, hours, and pays
    for (var overtimeDoc in userOvertimeDocs) {
      Timestamp? timeInTimestamp = overtimeDoc['timeIn'];
      Timestamp? timeOutTimestamp = overtimeDoc['timeOut'];

      if (timeInTimestamp != null && timeOutTimestamp != null) {
        DateTime timeIn = timeInTimestamp.toDate();
        DateTime timeOut = timeOutTimestamp.toDate();
        Duration totalDuration = timeOut.difference(timeIn);

        totalDays++;
        totalHours += totalDuration.inHours + totalDuration.inMinutes / 60;
        totalPays += (overtimeDoc['overtimePay'] ?? 0.0);
      }
    }

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Regular Overtime Logs',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.close,
                    size: 15,
                  )),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Employee ID',
                            overtimeDoc['employeeId'] ?? 'Not Available'),
                        _buildInfoRow2('Name           ',
                            overtimeDoc['userName'] ?? 'Not Available'),
                        _buildInfoRow('Department ',
                            overtimeDoc['department'] ?? 'Not Available'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildInfoRow3('# of Days', totalDays.toString()),
                        _buildInfoRow3(
                            'Total Hours', totalHours.toStringAsFixed(2)),
                        _buildInfoRow2(
                          'Total Pays',
                          NumberFormat.currency(
                                  locale: 'en_PH',
                                  symbol: '₱ ',
                                  decimalDigits: 2)
                              .format(totalPays ?? 0.0),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(),
                _buildOvertimeTable(userOvertimeDocs),
                const Divider(),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Container(
            width: 100,
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
            decoration: BoxDecoration(border: Border.all(color: Colors.white)),
            child: Text(value)),
      ],
    );
  }

  Widget _buildInfoRow3(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold)),
        Container(
            width: 70,
            padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
            decoration: BoxDecoration(border: Border.all(color: Colors.white)),
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            )),
      ],
    );
  }

  Widget _buildInfoRow2(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        IntrinsicWidth(
          child: Container(
              padding: const EdgeInsets.fromLTRB(5, 2, 5, 0),
              decoration:
                  BoxDecoration(border: Border.all(color: Colors.white)),
              child: Text(value)),
        ),
      ],
    );
  }

  Widget _buildOvertimeTable(List<DocumentSnapshot> overtimeDocs) {
    // Sort documents by timestamp in descending order
    overtimeDocs.sort((a, b) {
      Timestamp aTimestamp = a['timeIn'];
      Timestamp bTimestamp = b['timeIn'];
      return bTimestamp.compareTo(aTimestamp);
    });
    int index = 0;

    var dataTable = DataTable(
      columns: const [
        DataColumn(
            label: Text(
          '#',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label: Text(
          'Date',
          style: TextStyle(fontWeight: FontWeight.bold),
        )),
        DataColumn(
            label:
                Text('Time In', style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
            label: Text('Time Out',
                style: TextStyle(fontWeight: FontWeight.bold))),
        DataColumn(
          label: Text('Overtime Hours',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        DataColumn(
          label: Text('Overtime Pay',
              style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
      rows: overtimeDocs.map((overtimeDoc) {
        Color? rowColor = index % 2 == 0
            ? Colors.grey[200]
            : Colors.transparent; // Alternating row colors
        index++; //

        Timestamp? timeInTimestamp = overtimeDoc['timeIn'];
        Timestamp? timeOutTimestamp = overtimeDoc['timeOut'];

        // Calculate the duration between timeIn and timeOut
        Duration totalDuration = const Duration();
        if (timeInTimestamp != null && timeOutTimestamp != null) {
          DateTime timeIn = timeInTimestamp.toDate();
          DateTime timeOut = timeOutTimestamp.toDate();
          totalDuration = timeOut.difference(timeIn);
        }

        // Format the duration to display total hours
        String totalHoursAndMinutes =
            '${totalDuration.inHours} hrs, ${totalDuration.inMinutes.remainder(60)} mins';

        return DataRow(
            color: MaterialStateColor.resolveWith((states) => rowColor!),
            cells: [
              DataCell(Text('$index')),
              DataCell(Text(_formatDate(overtimeDoc['timeIn']))),
              DataCell(Text(_formatTime(overtimeDoc['timeIn']))),
              DataCell(Text(_formatTime(overtimeDoc['timeOut']))),
              DataCell(
                Container(
                    padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                    decoration: BoxDecoration(
                        color: Colors.teal[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.teal.shade900)),
                    child: Text(totalHoursAndMinutes)),
              ),
              DataCell(
                Text(
                  NumberFormat.currency(
                          locale: 'en_PH', symbol: '₱ ', decimalDigits: 2)
                      .format(overtimeDoc['overtimePay'] ?? 0.0),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ]);
      }).toList(),
    );
    return MediaQuery.of(context).size.width > 1000
        ? SizedBox(height: 300, child: SingleChildScrollView(child: dataTable))
        : SizedBox(
            height: 300,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(child: dataTable)));
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MMMM dd, yyyy').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  String _formatTime(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('HH:mm a').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  Future<void> moveRecordToSpecialHolidayOT(
      DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      final monthlySalary = overtimeData['monthly_salary'];
      final overtimeMinute = overtimeData['minute_overtime'];
      final overtimeRate = 1.95;
      final daysInMonth = 22;

      // Set overtimePay to null
      overtimeData['overtimePay'] =
          (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);
      //dri ibutang ang formula para mapasa dayon didto paglahos
      // Add to SpecialHolidayOT collection
      await FirebaseFirestore.instance
          .collection('SpecialHolidayOT')
          .add(overtimeData);
    } catch (e) {
      print('Error moving record to SpecialHolidayOT collection: $e');
    }
  }

  Future<void> moveRecordToRegularHolidayOT(
      DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      final monthlySalary = overtimeData['monthly_salary'];
      final overtimeMinute = overtimeData['minute_overtime'];
      final overtimeRate = 2.6;
      final daysInMonth = 22;

      // Set overtimePay to null
      overtimeData['overtimePay'] =
          (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);
      //dri ibutang ang formula para mapasa dayon didto paglahos
      // Add to SpecialHolidayOT collection
      await FirebaseFirestore.instance
          .collection('RegularHolidayOT')
          .add(overtimeData);
    } catch (e) {
      print('Error moving record to SpecialHolidayOT collection: $e');
    }
  }

  Future<void> moveRecordToRestdayOT(DocumentSnapshot overtimeDoc) async {
    try {
      Map<String, dynamic> overtimeData =
          Map<String, dynamic>.from(overtimeDoc.data() as Map<String, dynamic>);

      final monthlySalary = overtimeData['monthly_salary'];
      final overtimeMinute = overtimeData['minute_overtime'];
      final overtimeRate = 1.69;
      final daysInMonth = 22;

      // Set overtimePay to null
      overtimeData['overtimePay'] =
          (monthlySalary / daysInMonth / 8 * overtimeMinute * overtimeRate);
      //dri ibutang ang formula para mapasa dayon didto paglahos
      // Add to SpecialHolidayOT collection
      await FirebaseFirestore.instance
          .collection('RestdayOT')
          .add(overtimeData);
    } catch (e) {
      print('Error moving record to SpecialHolidayOT collection: $e');
    }
  }

  Future<void> deleteRecordFromOvertime(DocumentSnapshot overtimeDoc) async {
    try {
      await overtimeDoc.reference.delete();
    } catch (e) {
      print('Error deleting record from Overtime collection: $e');
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('MMMM dd, yyyy HH:mm:ss').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  Future<void> _showConfirmationDialog(DocumentSnapshot overtimeDoc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          title: const Text('Confirmation'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to proceed?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                await moveRecordToSpecialHolidayOT(overtimeDoc);
                await deleteRecordFromOvertime(overtimeDoc);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmationDialog2(DocumentSnapshot overtimeDoc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to proceed?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                await moveRecordToRegularHolidayOT(overtimeDoc);
                await deleteRecordFromOvertime(overtimeDoc);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showConfirmationDialog3(DocumentSnapshot overtimeDoc) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmation'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to proceed?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Confirm'),
              onPressed: () async {
                Navigator.of(context).pop();
                await moveRecordToRestdayOT(overtimeDoc);
                await deleteRecordFromOvertime(overtimeDoc);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _computeAndAddToOvertimePay() async {
    try {
      // Get the list of all users from Firestore
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('User').get();

      // Loop through each user
      for (var userDoc in usersSnapshot.docs) {
        String userId = userDoc.id;

        // Fetch all overtime records for the current user
        QuerySnapshot overtimeSnapshot = await FirebaseFirestore.instance
            .collection('Overtime')
            .where('userId', isEqualTo: userId)
            .get();

        // List to store overtime documents
        List<DocumentSnapshot> userOvertimeDocs = overtimeSnapshot.docs;

        // Calculate total overtime pay for the current user
        double totalOvertimePay = 0;
        for (var overtimeDoc in userOvertimeDocs) {
          if (overtimeDoc['overtimePay'] != null) {
            totalOvertimePay += overtimeDoc['overtimePay'];
          }
        }

        // Get user details
        final userData = userDoc.data() as Map<String, dynamic>;

        // Update total_overtimePay in the OvertimePay collection
        DocumentReference userOvertimeDocRef =
            FirebaseFirestore.instance.collection('OvertimePay').doc(userId);

        // Check if the document exists
        var docSnapshot = await userOvertimeDocRef.get();
        if (docSnapshot.exists) {
          // If the document exists, update it
          await userOvertimeDocRef.update({
            'total_overtimePay': totalOvertimePay,
            'employeeId': userData['employeeId'],
            'userName':
                '${userData['fname']} ${userData['mname']} ${userData['lname']}',
            'department': userData['department'],
          });
        } else {
          // If the document doesn't exist, create a new one
          await userOvertimeDocRef.set({
            'total_overtimePay': totalOvertimePay,
            'userId': userId,
            'employeeId': userData['employeeId'],
            'userName':
                '${userData['fname']} ${userData['mname']} ${userData['lname']}',
            'department': userData['department'],
          });
        }
      }
      // Show a success message
      print('Total overtime pay computed and added to OvertimePay collection');
    } catch (e) {
      // Handle any errors
      print('Error computing and adding to OvertimePay collection: $e');
    }
  }
}

String _formatDate(dynamic timestamp) {
  if (timestamp == null) return '-------';

  if (timestamp is Timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MM/dd/yy').format(dateTime);
  } else {
    return timestamp.toString();
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
            label: Text('Employee ID',
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('Name', style: TextStyle(fontWeight: FontWeight.bold)),
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
