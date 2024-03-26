import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<dynamic> UserProfile(BuildContext context) async {
  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return '-------';

    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return DateFormat('HH:mm a').format(dateTime);
    } else {
      return timestamp.toString();
    }
  }

  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    DocumentSnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('User').doc(user.uid).get();
    Map<String, dynamic> userData = snapshot.data() ?? {};

    Timestamp start = userData['startShift'];
    Timestamp end = userData['endShift'];

    String startTime = _formatTimestamp(start);
    String endTime = _formatTimestamp(end);

    return showDialog(
      context: context,
      barrierLabel: '',
      builder: (_) => AlertDialog(
          surfaceTintColor: Colors.white,
          title: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  ' User Profile',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    icon: const Icon(Icons.close)),
              ],
            ),
          ),
          content: MediaQuery.of(context).size.width > 600
              ? SizedBox(
                  width: 750,
                  height: 350,
                  child: details(userData, startTime, endTime),
                )
              : SizedBox(
                  width: 750,
                  height: 500,
                  child: SingleChildScrollView(
                      child: Flexible(
                          child: details2(userData, startTime, endTime))),
                )),
    );
  } else {
    // Handle case where user is not authenticated
    return showDialog(
      context: context,
      barrierLabel: '',
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text('User not authenticated.'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}

Row details(Map<String, dynamic> userData, String startTime, String endTime) {
  return Row(
    children: [
      Expanded(
        flex: 1,
        child: Container(
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 70,
                backgroundImage: userData['role'] == 'Admin'
                    ? AssetImage('assets/images/Admin.jpg')
                    : userData['role'] == 'Superadmin'
                        ? AssetImage('assets/images/SAdmin.jpg')
                        : AssetImage('assets/images/Employee.jpg'),
              ),
              Text(
                  "${(userData['fname']) ?? ''} ${userData['mname'] ?? ''} ${userData['lname'] ?? ''}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text('${userData['role']}', style: TextStyle(fontSize: 15)),
              SizedBox(
                height: 8,
              ),
              ListTile(
                  leading: Icon(Icons.email),
                  title: Text(userData['email'] ?? '')),
              ListTile(
                  leading: Icon(Icons.phone),
                  title: Text(userData['mobilenum'] ?? '')),
            ],
          ),
        ),
      ),
      Expanded(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('EMPLOYEE DETAILS',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            ListTile(
                leading: Icon(Icons.business),
                title: Text('Department: ${userData['department'] ?? ''}')),
            ListTile(
                leading: Icon(Icons.person),
                title:
                    Text('Employee Status: ${userData['typeEmployee'] ?? ''}')),
            ListTile(
              leading: Icon(Icons.access_time),
              title: Text('Shift: $startTime to $endTime'),
            ),
            ListTile(
                leading: Icon(Icons.credit_card),
                title: Text('SSS: ${userData['sss'] ?? ''}')),
            ListTile(
                leading: Icon(Icons.credit_card),
                title: Text('TIN: ${userData['tin'] ?? ''}')),
            ListTile(
                leading: Icon(Icons.account_balance),
                title: Text('Tax Code: ${userData['taxCode'] ?? ''}')),
          ],
        ),
      ),
    ],
  );
}

Column details2(
    Map<String, dynamic> userData, String startTime, String endTime) {
  return Column(
    children: [
      Container(
        width: 200,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 70,
                backgroundImage: userData['role'] == 'Admin'
                    ? AssetImage('assets/images/Admin.jpg')
                    : userData['role'] == 'Superadmin'
                        ? AssetImage('assets/images/SAdmin.jpg')
                        : AssetImage('assets/images/Employee.jpg'),
              ),
            ),
            Center(
              child: Text(
                  "${(userData['fname']) ?? ''} ${userData['mname'] ?? ''} ${userData['lname'] ?? ''}",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Center(
                child: Text('${userData['role']}',
                    style: TextStyle(fontSize: 15))),
            SizedBox(
              height: 8,
            ),
          ],
        ),
      ),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
              leading: Icon(Icons.email), title: Text(userData['email'] ?? '')),
          ListTile(
              leading: Icon(Icons.phone),
              title: Text(userData['mobilenum'] ?? '')),
          Text('EMPLOYEE DETAILS',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ListTile(
              leading: Icon(Icons.business),
              title: Text('Department: ${userData['department'] ?? ''}')),
          ListTile(
              leading: Icon(Icons.person),
              title:
                  Text('Employee Status: ${userData['typeEmployee'] ?? ''}')),
          ListTile(
            leading: Icon(Icons.access_time),
            title: Text('Shift: $startTime to $endTime'),
          ),
          ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('SSS: ${userData['sss'] ?? ''}')),
          ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('TIN: ${userData['tin'] ?? ''}')),
          ListTile(
              leading: Icon(Icons.account_balance),
              title: Text('Tax Code: ${userData['taxCode'] ?? ''}')),
        ],
      ),
    ],
  );
}
