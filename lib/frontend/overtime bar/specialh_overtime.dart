import 'dart:ui';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class SpecialHolidayOvertimePage extends StatefulWidget {
  const SpecialHolidayOvertimePage({super.key});

  @override
  State<SpecialHolidayOvertimePage> createState() =>
      _SpecialHolidayOvertimePageState();
}

class _SpecialHolidayOvertimePageState
    extends State<SpecialHolidayOvertimePage> {
  int _documentLimit = 8;
  int _currentPage = 0;
  int _rowsPerPage = 8;
  DateTime? selectedDate;
  DateTime? selectedTime;
  DateTime? selectedDateTime;
  bool passwordVisible = false;
  bool showDropdown = false;

  String selectedRole = 'Select Role';
  String selectedDep = '--Select--';
  String typeEmployee = 'Type of Employee';

  get searchController => null;

  get colorController => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.teal.shade700,
        child: Column(
          children: [
            Flexible(
              child: Container(
                margin: EdgeInsets.fromLTRB(15, 5, 15, 15),
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Special Holiday Overtime',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              const Text('From:'),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width > 600
                                    ? 170
                                    : 50,
                                height: 30,
                                padding: EdgeInsets.fromLTRB(8, 0, 0, 0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(8)),
                                child: DateTimeFormField(
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.only(bottom: 15),
                                      hintText: 'Select Date',
                                      suffixIcon: Icon(Icons.calendar_month)),
                                  mode: DateTimeFieldPickerMode.date,
                                  onSaved: (DateTime? value) {},
                                  onChanged: (DateTime? value) {},
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              const Text('To:'),
                              const SizedBox(
                                width: 5,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width > 600
                                    ? 170
                                    : 50,
                                height: 30,
                                padding: EdgeInsets.only(left: 8),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.black.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(8)),
                                child: DateTimeFormField(
                                  decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      contentPadding:
                                          EdgeInsets.only(bottom: 15),
                                      hintText: 'Select Date',
                                      suffixIcon: Icon(Icons.calendar_month)),
                                  mode: DateTimeFieldPickerMode.date,
                                  onSaved: (DateTime? value) {},
                                  onChanged: (DateTime? value) {},
                                ),
                              ),
                              Container(
                                child: InkWell(
                                    onTap: () {},
                                    child: Container(
                                      margin: EdgeInsets.only(left: 5),
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          color: Colors.teal.shade900),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Icon(
                                            Icons.filter_list,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                            width: 5,
                                          ),
                                          Text(
                                            'Filter',
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        ],
                                      ),
                                    )),
                              ),
                            ],
                          ),
                          Flexible(
                            child: Container(
                              width: MediaQuery.of(context).size.width > 600
                                  ? 300
                                  : 50,
                              height: 30,
                              margin: EdgeInsets.fromLTRB(5, 0, 0, 0),
                              padding: EdgeInsets.fromLTRB(3, 0, 0, 0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: Colors.black.withOpacity(0.5)),
                              ),
                              child: TextField(
                                controller: searchController,
                                textAlign: TextAlign.start,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(bottom: 15),
                                  prefixIcon: Icon(Icons.search),
                                  border: InputBorder.none,
                                  hintText: 'Search',
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Divider(),
                    Expanded(
                        child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: DataTable(columns: [
                        ColumnInput('#'),
                        ColumnInput('ID'),
                        ColumnInput('Name'),
                        DataColumn(
                            label: Center(
                          child: DropdownButton<String>(
                            elevation: 8,
                            underline: Container(),
                            dropdownColor: Colors.teal.shade100,
                            items: <String>['IT', 'HR'].map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {},
                            hint: const Text(
                              'Department',
                              style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 15,
                                  color: Colors.black),
                            ),
                            value: null,
                          ),
                        )),
                        ColumnInput('OT Hrs'),
                        ColumnInput('OT Pay'),
                        ColumnInput('Action'),
                      ], rows: const [
                        DataRow(cells: [
                          DataCell(Text('1')),
                          DataCell(Text('1')),
                          DataCell(Text('1')),
                          DataCell(Text('1')),
                          DataCell(Text('1')),
                          DataCell(Text('1')),
                          DataCell(Text('View Logs')),
                        ])
                      ]),
                    ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

DataColumn ColumnInput(Label) {
  return DataColumn(
      label: Text(
    Label,
    style: const TextStyle(
      fontWeight: FontWeight.w900,
    ),
  ));
}
