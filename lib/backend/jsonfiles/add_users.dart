
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
Future<void> addUser(
  String username,
  String fname,
  String mname,
  String lname,
  String email,
  DateTime startShift,
  DateTime endShift,
  String role,
  String department,
  String typeEmployee,
  String sss,
  String tin,
  String taxCode,
  String employeeId,
  String mobilenum, 
) async {
  try {
    // Add user to Firestore collection
    await FirebaseFirestore.instance.collection('User').add({
      'username': username,
      'fname': fname,
      'mname': mname,
      'lname': lname,
      'email': email,
      'mobilenum': mobilenum,
      'startShift': startShift,
      'endShift': endShift,
      'role': role,
      'department': department,
      'typeEmployee': typeEmployee,
      'sss': sss,
      'tin': tin,
      'taxCode': taxCode,
      'employeeId': employeeId,
      'isActive': true, // Add this field with value true
    });
  } catch (e) {
    print("An error occurred while adding user: $e");
    throw e; // Rethrow the error to handle it where addUser is called
  }
}