import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:project_payroll_nextbpo/frontend/login.dart';

class Userdisplay extends StatelessWidget {
  final StreamController<DateTime> _timeController = StreamController<DateTime>();

  Userdisplay() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      _timeController.add(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ClipRRect(
        borderRadius: BorderRadius.circular(20.0),
        child: Container(
          color: Color.fromARGB(255, 255, 255, 255),
          child: Column(
            children: [
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseAuth.instance.authStateChanges(),
                  builder: (BuildContext context, AsyncSnapshot<User?> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 20.0)));
                    } else if (snapshot.data == null) {
                      return Center(child: Text('No user logged in', style: TextStyle(fontSize: 20.0)));
                    } else {
                      User? user = snapshot.data;
                      return StreamBuilder(
                        stream: FirebaseFirestore.instance
                            .collection('User')
                            .doc(user!.uid)
                            .snapshots(),
                        builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                          if (userSnapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          } else if (userSnapshot.hasError) {
                            return Center(child: Text('Error: ${userSnapshot.error}', style: TextStyle(fontSize: 20.0)));
                          } else {
                            Map<String, dynamic>? userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                            String username = userData?['username'] ?? '';
                            String role = userData?['role'] ?? '';
                            return Padding(
                              padding: EdgeInsets.all(20.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      SizedBox(width: 10.0), 
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          StreamBuilder<DateTime>(
                                            stream: _timeController.stream,
                                            builder: (context, snapshot) {
                                              return Text(
                                                '${snapshot.data!.hour}:${snapshot.data!.minute.toString().padLeft(2, '0')} ${snapshot.data!.hour < 12 ? 'AM' : 'PM'}',
                                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                                              );
                                            }
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            'Realtime Insight',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                                          ),
                                        ],
                                      ),
                                      SizedBox(width: 10.0), 
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Today:',
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(DateFormat('d MMMM y').format(DateTime.now()), style: TextStyle(fontSize: 14.0))
                                        ],
                                      ),
                                      SizedBox(width: 1200.0), // Reduce the width of SizedBox
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            username,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                                          ),
                                          SizedBox(height: 8.0),
                                          Text(
                                            role,
                                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                                          ),
                                        ],
                                      ), 
                                      
                                  DropdownButton<String>(
                                        items: [
                                          DropdownMenuItem<String>(
                                            value: 'account',
                                            child: Text('Account'),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'logout',
                                            child: Text('Logout'),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          // Handle dropdown item selection
                                          if (value == 'account') {
                                            // Handle account option
                                            // Example: Navigate to account settings page
                                          } else if (value == 'logout') {
                                            FirebaseAuth.instance.signOut();
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(builder: (context) => Login()), // Replace LoginScreen with your actual login screen widget
                                            );
                                          }
                                        },
                                        // Remove the underline
                                        underline: Container(),
                                        // Add an icon next to the name and position
                                        icon: Icon(Icons.arrow_drop_down),
                                      ),
                                       SizedBox(width: 20.0),
                                    ],
                                  ),
                                  SizedBox(height: 20.0),
                                ],
                              ),
                            );
                          }
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
