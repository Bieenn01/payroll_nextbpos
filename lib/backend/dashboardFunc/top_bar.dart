import 'dart:ui';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

class TopBar extends StatefulWidget {
  const TopBar({super.key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateFormat Dayformatter = DateFormat('EEEE');
    final DateFormat formatter = DateFormat.jm();
    final DateFormat dformatter = DateFormat('EEEE, MMM d, ' 'yyyy ');
    final String timeFormat = formatter.format(now);
    final String DayFormat = Dayformatter.format(now);
    final String date = dformatter.format(now);

    return Scaffold(
      body: Container(
        color: Colors.teal.shade700,
        child: Container(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      timeFormat,
                      style: const TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: () {
                  showMenu(
                    context: context,
                    position: const RelativeRect.fromLTRB(80, 100, 50, 0),
                    items: const [
                      PopupMenuItem(
                        child: Text('Account List'),
                        value: 'account_list',
                      ),
                      PopupMenuItem(
                        child: Text('Log out'),
                        value: 'log_out',
                      ),
                    ],
                    elevation: 8.0,
                  ).then((value) {
                    if (value == 'account_list') {
                      // Handle account list selection
                    } else if (value == 'log_out') {
                      // Handle log out selection
                    }
                  });
                },
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      border: Border(
                          left:
                              BorderSide(color: Colors.grey.withOpacity(0.5)))),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        child: Icon(
                          Icons.person,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dahnica Tedlos',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Super Admin'),
                        ],
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
