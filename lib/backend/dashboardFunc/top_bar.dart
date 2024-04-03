import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/pov_user_create.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/user_profile.dart';
import 'package:project_payroll_nextbpo/frontend/login.dart'; // Import your login page file

class TopBar extends StatefulWidget {
  const TopBar({Key? key});

  @override
  State<TopBar> createState() => _TopBarState();
}

class _TopBarState extends State<TopBar> {
  late StreamSubscription<DocumentSnapshot> _subscription;
  late String _userName = 'Guest';
  late String currentTime;
  late String _role = 'Guest';
  late Timer timer;
  late String _advice = '';

  @override
  void initState() {
    super.initState();
    currentTime = _getCurrentTime();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = _getCurrentTime();
      });
    });
    _fetchFirstName();
    _fetchRole();
    _fetchAdvice(); // Initial call to fetch advice
    Timer.periodic(Duration(seconds: 30), (timer) {
      _fetchAdvice(); // Fetch advice every 10 seconds
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    timer.cancel();
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
        final role = docSnapshot['role'];
        _role = role != null
            ? role
            : 'Guest'; // Default to 'Guest' if role is not specified
      });
    }
  }

  Future<void> _fetchAdvice() async {
    fetchAdvice().then((advice) {
      setState(() {
        _advice = advice;
      });
    }).catchError((error) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error'),
          content: Text('Failed to fetch advice'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    });
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
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: currentTime,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    Text(
                      date,
                      style: const TextStyle(
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        fetchAdvice().then((advice) {
                          setState(() {
                            _advice = advice;
                          });
                        }).catchError((error) {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Error'),
                              content: Text('Failed to fetch advice'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('OK'),
                                ),
                              ],
                            ),
                          );
                        });
                      },
                      icon: Icon(Icons.lightbulb_outline),
                    ),

                    // Display the advice immediately
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        _advice,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showMenu(
                          context: context,
                          position: const RelativeRect.fromLTRB(80, 100, 50, 0),
                          items: _role ==
                                  'Superadmin' // Conditionally render the menu items based on the role
                              ? [
                                  PopupMenuItem(
                                    value: 'user_profile',
                                    child: Text('User Profile'),
                                  ),
                                  PopupMenuItem(
                                    value: 'account_list',
                                    child: Text('Account List'),
                                  ),
                                  PopupMenuItem(
                                    value: 'log_out',
                                    child: Text('Log out'),
                                  ),
                                ]
                              : [
                                  PopupMenuItem(
                                    value: 'user_profile',
                                    child: Text('User Profile'),
                                  ),
                                  PopupMenuItem(
                                    value: 'log_out',
                                    child: Text('Log out'),
                                  ),
                                ],
                          elevation: 8.0,
                        ).then((value) {
                          if (value == 'log_out') {
                            // Handle log out selection
                            FirebaseAuth.instance.signOut(); // Sign out the user
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      Login()), // Navigate back to the login page
                              (route) =>
                                  false, // Remove all existing routes from the navigation stack
                            );
                          } else if (value == 'user_profile') {
                            UserProfile(context);
                          } else if (value == 'account_list') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => PovUser()),
                            );
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(5, 2, 2, 2),
                        decoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(
                              color: Colors.grey.withOpacity(0.5),
                            ),
                          ),
                        ),
                        child: MediaQuery.of(context).size.width > 600
                            ? Row(
                                children: [
                                  CircleAvatar(
                                    backgroundImage: _role == 'Admin'
                                        ? AssetImage('assets/images/Admin.jpg')
                                        : _role == 'Superadmin'
                                            ? AssetImage('assets/images/SAdmin.jpg')
                                            : AssetImage(
                                                'assets/images/Employee.jpg'),
                                    // Change image path based on role
                                    radius:
                                        20, // Adjust the radius as per your requirement
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _userName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        _role,
                                        style: const TextStyle(
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_drop_down),
                                ],
                              )
                            : CircleAvatar(
                                backgroundImage: _role == 'Admin'
                                    ? const AssetImage('assets/images/Admin.jpg')
                                    : _role == 'Superadmin'
                                        ? const AssetImage(
                                            'assets/images/SAdmin.jpg')
                                        : const AssetImage(
                                            'assets/images/Employee.jpg'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Method to fetch advice from the API
  Future<String> fetchAdvice() async {
    final response =
        await http.get(Uri.parse('https://api.adviceslip.com/advice'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String advice = data['slip']['advice'];
      return advice;
    } else {
      throw Exception('Failed to load advice');
    }
  }

  String _getCurrentTime() {
    return DateFormat('hh:mm a').format(DateTime.now());
  }
}
