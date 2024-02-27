import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:project_payroll_nextbpo/backend/widgets/toast_widget.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/pov_dashboard.dart';

class Login extends StatefulWidget {
  Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {


  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Expanded(
            child: SizedBox(
              width: 100,
              child: Container(
                width: 300,
                constraints: const BoxConstraints(maxWidth: 10),
                padding: const EdgeInsets.symmetric(horizontal: 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.asset(
                      'assets/images/nextbpologo.png',
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.black,
                        fontSize: 25,
                      ),
                    ),
                    Container(
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                        ),
                      ),
                    ),
                    Container(
                      child: TextField(
                        obscureText: !passwordVisible,
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible
                                ? Icons.visibility
                                : Icons.visibility_off),
                            onPressed: () {
                              setState(() {
                                passwordVisible = !passwordVisible;
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Container(
                      child: ElevatedButton(
                        onPressed: (() {
                          login(context);
                        }),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade400,
                          padding: const EdgeInsets.all(18.0),
                          minimumSize: const Size(200, 50),
                          maximumSize: const Size(200, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("LOGIN"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
login(BuildContext context) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(
            email: emailController.text, password: passwordController.text);

    // Get the user from the userCredential
    User? user = userCredential.user;

    if (user != null) {
      // Check if the user is active
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();

      bool isActive = snapshot.exists && snapshot.get('isActive');

      if (isActive) {
        // Navigate to the PovDashboard with only the userID
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => PovDashboard(userId: user.uid),
        ));
      } else {
        // User is not active
        showToast("User account is not activated.");
      }
    }
  } on FirebaseAuthException catch (e) {
    // Handle authentication exceptions
    if (e.code == 'user-not-found') {
      showToast("No user found with that email.");
    } else if (e.code == 'wrong-password') {
      showToast("Wrong password provided for that user.");
    } else if (e.code == 'invalid-email') {
      showToast("Invalid email provided.");
    } else if (e.code == 'user-disabled') {
      showToast("User account has been disabled.");
    } else {
      showToast("An error occurred: ${e.message}");
    }
  } on Exception catch (e) {
    // Handle other exceptions
    showToast("An error occurred: $e");
  }
}
}