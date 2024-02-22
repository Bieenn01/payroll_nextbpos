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
