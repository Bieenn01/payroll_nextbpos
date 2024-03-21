import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> addtotalOTPay(
  double totalOvertimePay,
  double total_regularHOTPay,
  double total_restdayOTPay,
  double total_specialHOTPay,
  String employeeId,
) async {
  try {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final userDoc =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();
    final userData = userDoc.data() as Map<String, dynamic>;

    final json = {
      'total_overtimePay': totalOvertimePay,
      'total_regularHOTPay': total_regularHOTPay, // Set to 0
      'total_restdayOTPay': total_restdayOTPay,
      'total_specialHOTPay': total_specialHOTPay, // Set to 0
      'userId': userId,
      'employeeId': employeeId,
      'userName':
          '${userData['fname']} ${userData['mname']} ${userData['lname']}'
    };
    await FirebaseFirestore.instance
        .collection('OvertimePay')
        .doc(userId)
        .set(json); // Use userId as document ID
  } catch (e) {
    print('Error adding records:$e');
  }
}
