import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserModel {
  final String uid;
  final String email;
  final String role;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
  });
}

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Auth change user stream
  Stream<UserModel?> get user {
    return _auth.authStateChanges().asyncMap(_userFromFirebaseUser);
  }

  // Convert FirebaseUser to UserModel
  Future<UserModel?> _userFromFirebaseUser(User? user) async {
    if (user != null) {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await _firestore.collection('User').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> userData = userDoc.data()!;
        return UserModel(
          uid: user.uid,
          email: user.email!,
          role: userData['role'] ?? "", // Assuming 'role' is the field in Firestore representing the user's role
        );
      }
    }
    return null;
  }

  // Sign in with email and password
  Future<UserModel?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return await _userFromFirebaseUser(user);
    } catch (error) {
      print(error.toString());
      return null;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (error) {
      print(error.toString());
    }
  }
}
