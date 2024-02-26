
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> addRecords(
  String timeIn,
  String timeOut,
  String role,
  String department,
) async {
  try {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();
    final userData = userDoc.data() as Map<String, dynamic>;

    final json = {
      'department': department,
      'role': role,
      'timeIn': timeIn,
      'timeOut': timeOut,
      'id': userDoc.id,
      'userId': userId,
      'userName':
          '${userData['fname']} ${userData['mname']} ${userData['lname']}',
    };

    await FirebaseFirestore.instance.collection('Records').doc().set(json);
  } catch (e) {
    print('Error adding records: $e');
  }
}
