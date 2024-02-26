import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

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
                          print('Action button pressed for ${data['fname']}');
                        },
                        child: Text('Action'),
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
