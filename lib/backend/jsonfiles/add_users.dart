
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> addUser(
  username,
  fname,
  mname,
  lname,
  email,
  startShift,
  endShift,
  role,
  department,
  typeEmployee, 
) async {
  final docUser = FirebaseFirestore.instance
      .collection('User')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {
    'username': username,
    'fname': fname,
    'mname': mname,
    'lname': lname,
    'email': email,
    'startShift': startShift,
    'endShift': endShift,
    'role': role,
    'department': department,
    'typeEmployee': typeEmployee,
  };

  await docUser.set(json);
}
