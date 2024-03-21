import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> addtotalRDOTPay(
  double totalRDOTPay,
  String employeeId,
) async {
  try {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final userDoc =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();
    final userData = userDoc.data() as Map<String, dynamic>;

    final json = {
      'total_restDayOTPay': totalRDOTPay,
      'userId': userId,
      'employeeId': employeeId,
      'department': userData['department'],
      'userName':
          '${userData['fname']} ${userData['mname']} ${userData['lname']}'
    };
    await FirebaseFirestore.instance
        .collection('RestdayOTPay')
        .doc(userId)
        .set(json); // Use userId as document ID
  } catch (e) {
    print('Error adding records:$e');
  }
}
