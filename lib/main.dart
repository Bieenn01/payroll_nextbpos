import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/pov_dashboard.dart';
import 'package:project_payroll_nextbpo/frontend/loginScreen.dart';

import 'firebase_options.dart';

import 'dart:ui_web' as ui;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb)
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyBaS9eujBHEvyXw9X25wnzjXvlHGeEcPFU",
        appId: "1:432371963345:web:d3451d00e5e5f556aa7cf0",
        messagingSenderId: "432371963345",
        projectId: "nbsstorage-ba8de",
      ),
    );
  else
  await Firebase.initializeApp(
    name: 'nbsstorage-ba8de',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Check if the user is logged in or not
      home: FirebaseAuth.instance.currentUser != null
          ? PovDashboard(userId: '', id: '', username: '', department: '', email: '',) // If logged in, direct to PovDashboard
          : LoginScreen(), // Otherwise, direct to LoginScreen
      debugShowCheckedModeBanner: false,
    );
  }
}
