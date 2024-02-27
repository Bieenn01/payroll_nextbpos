import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class UserDetails extends StatefulWidget {
  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  late Future<QuerySnapshot> _users;

  @override
  void initState() {
    super.initState();
    _users = _fetchUsers(); // Fetch users when the widget initializes
  }

  Future<QuerySnapshot> _fetchUsers() {
    // Fetch users from Firestore collection 'User'
    return FirebaseFirestore.instance.collection('User').get();
  }

  Future<void> _resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      print('Password reset email sent to $email');
    } catch (e) {
      print('Failed to send password reset email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: FutureBuilder(
          future: _users,
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(); // Show loading indicator
            }
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            return SizedBox(
              width: MediaQuery.of(context).size.width,
              child: DataTable(
                columns: [
                  DataColumn(label: Text('#')),
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Username')),
                  DataColumn(label: Text('Type')),
                  DataColumn(label: Text('Action')),
                ],
                rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  return DataRow(cells: [
                    DataCell(Text(data['#'].toString())),
                    DataCell(Text(data['fname'].toString())),
                    DataCell(Text(data['username'].toString())),
                    DataCell(Text(data['typeEmployee'].toString())),
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          // Implement action for the user
                          if (data['email'] == 'kaizarscore12@gmail.com') {
                            _resetPassword(data['email']);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Password reset not applicable for this user.',
                                ),
                              ),
                            );
                          }
                        },
                        child: Text('Reset Password'),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
