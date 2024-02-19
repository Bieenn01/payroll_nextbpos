import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> signup(
  fname,
  mname,
  lname,
  sex,
  age,
  birthdate,
  email,
  number,
  address,
  purok,
  civilstatus,
  youthclass,
  school,
  work,
  voter,
  profile,
  residency,
) async {
  final docUser = FirebaseFirestore.instance
      .collection('Users')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {
    'fname': fname,
    'mname': mname,
    'lname': lname,
    'sex': sex,
    'age': age,
    'birthdate': birthdate,
    'email': email,
    'number': number,
    'address': address,
    'purok': purok,
    'civilstatus': civilstatus,
    'youthclass': youthclass,
    'school': school,
    'work': work,
    'voter': voter,
    'isActive': false,
    'role': 'User',
    'id': docUser.id,
    'profile': profile,
    'residency': residency,
    'dateTime': DateTime.now(),
    'editTime': DateTime.now(),
  };

  await docUser.set(json);
}
