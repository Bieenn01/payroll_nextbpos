import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_field/date_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class TopBar extends StatefulWidget {
  const TopBar({Key? key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  late StreamSubscription<DocumentSnapshot> _subscription;
  late String _userName = 'Guest';
  late String _role = 'Guest';

  @override
  void initState() {
    super.initState();
    _fetchFirstName();
    _fetchRole();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Future<void> _fetchFirstName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();

      setState(() {
        _userName = docSnapshot['fname'];
      });
    }
  }

  Future<void> _fetchRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();

      setState(() {
        _role = docSnapshot['role'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final DateFormat dayFormatter = DateFormat('EEEE');
    final DateFormat formatter = DateFormat.jm();
    final DateFormat dateFormatter = DateFormat('EEEE, MMM d, ' 'yyyy ');
    final String timeFormat = formatter.format(now);
    final String dayFormat = dayFormatter.format(now);
    final String date = dateFormatter.format(now);

    return Scaffold(
      body: Container(
        color: Colors.teal.shade700,
        child: Expanded(
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
                        fontSize: 18,
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
                )),
                InkWell(
                  onTap: () {
                    showMenu(
                      context: context,
                      position: const RelativeRect.fromLTRB(80, 100, 50, 0),
                      items: const [
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
                    padding: EdgeInsets.fromLTRB(5, 2, 2, 2),
                    decoration: BoxDecoration(
                        border: Border(
                            left: BorderSide(
                                color: Colors.grey.withOpacity(0.5)))),
                    child: MediaQuery.of(context).size.width > 600
                        ? Row(
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
                                    _userName,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    _role,
                                    style: TextStyle(
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_drop_down),
                            ],
                          )
                        : CircleAvatar(
                            child: Icon(
                              Icons.person,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
