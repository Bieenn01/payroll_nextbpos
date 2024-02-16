import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> signin(
  username,
  
) async {
  final docUser = FirebaseFirestore.instance
      .collection('SU Admin')
      .doc(FirebaseAuth.instance.currentUser!.uid);

  final json = {
    'username': username,
  };
  await docUser.set(json);
}
