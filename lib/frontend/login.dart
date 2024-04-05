import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/pov_dashboard.dart';
import 'package:project_payroll_nextbpo/backend/widgets/toast_widget.dart';
import 'package:project_payroll_nextbpo/frontend/mobileHomeScreen.dart';

class Login extends StatefulWidget {
  Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  FocusNode myFocusNode = FocusNode();
  bool passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: const Color(0x7f588157),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MediaQuery.of(context).size.width > 1300
                ? Expanded(
                    flex: 2,
                    child: Container(
                      child: const Image(
                        image: AssetImage('assets/images/nextbpo.png'),
                        fit: BoxFit.fill,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                  )
                : Container(),
            MediaQuery.of(context).size.width > 1300
                ? Expanded(
                    flex: 1,
                    child: Container(
                      width: 500,
                      constraints: const BoxConstraints(maxWidth: 100),
                      padding: const EdgeInsets.symmetric(horizontal: 80),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: EdgeInsets.all(10),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12)),
                            child: Image.asset(
                              'assets/images/nextbpologo-removebg.png',
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Divider(),
                          const SizedBox(
                            height: 20,
                          ),
                          const Positioned(
                            left: 950,
                            top: 259,
                            child: Text(
                              'Welcome User',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  decoration: TextDecoration.none,
                                  fontSize: 25,
                                  color: Color(0xff000000),
                                  fontFamily: 'Roboto',
                                  fontWeight: FontWeight.bold),
                              maxLines: 9999,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            child: Text(
                              'Login to access your account',
                              style: TextStyle(fontStyle: FontStyle.italic),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: TextField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Username',
                                  labelStyle: TextStyle(
                                      color: myFocusNode.hasFocus
                                          ? Colors.blue
                                          : Colors.black)),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12)),
                            child: TextFormField(
                              obscureText: !passwordVisible,
                              controller: passwordController,
                              onFieldSubmitted: (_) {
                                // Call the login function when the user submits the password field
                                login(context);
                              },
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Password',
                                labelStyle: TextStyle(
                                    color: myFocusNode.hasFocus
                                        ? Colors.blue
                                        : Colors.black),
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
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              login(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 25, 49, 33),
                              padding: const EdgeInsets.all(18.0),
                              minimumSize: const Size(200, 50),
                              maximumSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              "LOG IN",
                              style: TextStyle(
                                color: Colors
                                    .white, // Change the text color to white
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(
                    width: MediaQuery.of(context).size.width > 800 ? 400 : 380,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12)),
                          child: Image.asset(
                            'assets/images/nextbpologo-removebg.png',
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        const Divider(),
                        const SizedBox(
                          height: 20,
                        ),
                        const Positioned(
                          left: 950,
                          top: 259,
                          child: Text(
                            'Welcome User !',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                fontSize: 25,
                                color: Color(0xff000000),
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold),
                            maxLines: 9999,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          child: Text(
                            'Login to access your account',
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: TextField(
                            controller: usernameController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Username',
                                labelStyle: TextStyle(
                                    color: myFocusNode.hasFocus
                                        ? Colors.blue
                                        : Colors.black)),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Container(
                          height: 50,
                          padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12)),
                          child: TextFormField(
                            obscureText: !passwordVisible,
                            controller: passwordController,
                            onFieldSubmitted: (_) {
                              // Call the login function when the user submits the password field
                              login(context);
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Password',
                              labelStyle: TextStyle(
                                  color: myFocusNode.hasFocus
                                      ? Colors.blue
                                      : Colors.black),
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
                          height: 10,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            login(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 25, 49, 33),
                            padding: const EdgeInsets.all(18.0),
                            minimumSize: const Size(200, 50),
                            maximumSize: const Size(200, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "LOG IN",
                            style: TextStyle(
                              color: Colors
                                  .white, // Change the text color to white
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  login(BuildContext context) async {
    try {
      // Query the users collection to find the user with the provided username
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('User')
          .where('username', isEqualTo: usernameController.text)
          .where('isActive', isEqualTo: true) // Add this condition
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Assuming username is unique, there should be only one document
        String email =
            querySnapshot.docs.first['email']; // Fetch email from Firestore
        String password =
            passwordController.text; // Get password from the user input

        // Sign in the user with fetched email and the provided password
        UserCredential userCredential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        // Get the user from the userCredential
        User? user = userCredential.user;

        if (user != null) {
          // Navigate to the PovDashboard with only the userID
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) => PovDashboard(
              userId: user.uid,
            ),
          ));
        }
      } else {
        showToast("No user found with that username.");
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
    // You can perform additional actions with the token if needed
  }
}
