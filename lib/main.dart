import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/pov_dashboard.dart';
import 'package:project_payroll_nextbpo/frontend/loginScreen.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'nbsstorage-ba8de',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PovDashboard(),
      debugShowCheckedModeBanner: false,
    );
  }
}
