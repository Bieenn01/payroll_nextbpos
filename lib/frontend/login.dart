import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
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
  final passwordController = TextEditingController();

  @override
  bool passwordVisible = false;

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

login(context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: emailController.text, password: passwordController.text);

      // Get the user data from Firebase
      User? user = userCredential.user;
      if (user != null) {
        // Retrieve additional user data from Firestore
        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('User')
                .doc(user.uid)
                .get();

        // Check if the document exists and contains data
        if (userData.exists) {
          // Retrieve data fields from the document
          String id = userData['id'];
          String username = userData['username'];
          String department = userData['department'];
          String email = userData['email'];

          // Store the user ID for access
          String userId = user.uid;

          // Perform additional actions like getting token
          await getToken();

          // Navigate to the home screen after successful login
          SchedulerBinding.instance.addPostFrameCallback((_) {
            // Pass necessary data to PovDashboard if needed
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => PovDashboard(
                      userId: userId,
                      id: id,
                      username: username,
                      department: department, 
                      email: email,
                    )));
          });
        } else {
          // Handle case where user data is missing
          showToast("User data not found.");
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

  Future<void> getToken() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    // You can perform additional actions with the token if needed
  }
}
