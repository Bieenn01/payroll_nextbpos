<<<<<<< HEAD
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
=======
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> addUser(
  fname,
  mname,
  lname,
  email,
  start_shift,
  end_shift,
  role,
  department,
  type_employee,
) async {
  final docUser = FirebaseFirestore.instance
      .collection('User')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {
    'fname': fname,
    'mname': mname,
    'lname': lname,
    'email': email,
    'start_shift': start_shift,
    'end_shift': end_shift,
    'role': role,
    'department': department,
    'type_employee': type_employee,
  };

  await docUser.set(json);
}
>>>>>>> d44b4ba219fba472f5c52d80e97a4497e50679fd
