import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class MobileLogin extends StatefulWidget {
  const MobileLogin({super.key});

  @override
  State<MobileLogin> createState() => _MobileLoginState();
}

class _MobileLoginState extends State<MobileLogin> {
  get usernameController => null;

  bool passwordVisible = false;

  get passwordController => null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: SizedBox(
              width: 300,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 15),
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
                        controller: usernameController,
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
                        onPressed: (() {}),
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
}
