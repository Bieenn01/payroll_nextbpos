import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> addUser(
  double salary, 
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
  bool isActive,
  bool isATM,
  
) async {
  try {
    // Use the current user's UID as the document ID
    final docUser = FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseAuth.instance.currentUser!.uid);

    // Set user data to Firestore document
    await docUser.set({
      'salary': salary, // Parse salary as an integer
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
      'isActive': isActive,
      'isATM': isATM,
    });
  } catch (e) {
    print("An error occurred while adding user: $e");
    throw e; // Rethrow the error to handle it where addUser is called
  }
}
