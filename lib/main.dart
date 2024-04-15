import 'dart:math';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:project_payroll_nextbpo/export-Logs.dart';
import 'package:project_payroll_nextbpo/export-USER.dart';

import 'package:project_payroll_nextbpo/frontend/dashboard/pov_dashboard.dart';
import 'package:project_payroll_nextbpo/frontend/leaverecord.dart';
import 'package:project_payroll_nextbpo/frontend/login.dart';
import 'package:project_payroll_nextbpo/frontend/mobileHomeScreen.dart';

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

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    _initNotifications();
  }

  Future<void> _initNotifications() async {
    if (!kIsWeb) {
      await _messaging.requestPermission();
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
    }
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          importance: NotificationImportance.High,
        ),
        NotificationChannel(
          channelKey: 'basic_channel_muted',
          channelName: 'Basic muted notifications',
          channelDescription: 'Notification channel for muted basic tests',
          importance: NotificationImportance.High,
          playSound: false,
        ),
      ],
    );
  }

  Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    if (message.notification != null) {
      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: Random().nextInt(9999),
          channelKey: 'basic_channel_muted',
          title: '${message.notification!.title}',
          body: '${message.notification!.body}',
          notificationLayout: NotificationLayout.BigText,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // scrollBehavior: const MaterialScrollBehavior().copyWith(
      //   dragDevices: {PointerDeviceKind.mouse},
      // ),
      title: 'NPBOs Payroll',
      home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return PovDashboard(
                userId: '',
              );
            } else {
              return Login();
            }
          }),
    );
  }
}
