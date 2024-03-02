import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> addRegularHoliOT(
  overtimePay,
  department,
  hours_overtime,
  minute_overtime,
  timeIn,
  timeOut,
  regular_hours,
  regular_minute,
  monthly_salary,
) async {
  try {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    final userDoc =
        await FirebaseFirestore.instance.collection('User').doc(userId).get();
    final userData = userDoc.data() as Map<String, dynamic>;

    final json = {
      'overtimePay': overtimePay,
      'department': department,
      'hours_overtime': hours_overtime,
      'minute_overtime': minute_overtime,
      'timeIn': timeIn,
      'userId': userId,
      'regular_hours': regular_hours,
      'regular_minute': regular_minute,
      'monthly_salary': monthly_salary,
      'userName':
          '${userData['fname']} ${userData['mname']} ${userData['lname']}'
    };
    await FirebaseFirestore.instance
        .collection('RegularHolidayOT')
        .doc()
        .set(json);
  } catch (e) {
    print('Error adding records: $e');
  }
}
