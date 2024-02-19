import 'package:flutter/material.dart';

class ScreensView extends StatelessWidget {
  final String menu;
  const ScreensView({Key? key, required this.menu}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (menu) {
      case 'Dashboard':
        page = const Center(
          child: Text(
            "Dashboard Page",
            style: TextStyle(
              color: Color(0xFF171719),
              fontSize: 22,
            ),
          ),
        );
        break;
      case 'Dart':
        page = const Center(
          child: Text(
            "Dart Page",
            style: TextStyle(
              color: Color(0xFF171719),
              fontSize: 22,
            ),
          ),
        );
        break;
      default:
        page = const Center(
          child: Text(
            "Other Page",
            style: TextStyle(
              color: Color(0xFF171719),
              fontSize: 22,
            ),
          ),
        );
    }
    return page;
  }
}
