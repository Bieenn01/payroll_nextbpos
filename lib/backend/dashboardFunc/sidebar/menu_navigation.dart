import 'package:flutter/material.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/main_calendar.dart';

class ScreensView extends StatelessWidget {
  final String menu;
  const ScreensView({Key? key, required this.menu}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (menu) {
case 'Dashboard':
        page = Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Dashboard Page",
                style: TextStyle(
                  color: Color(0xFF171719),
                  fontSize: 22,
                ),
              ),
              SizedBox(height: 20),
              Expanded(
                child: CalendarPage(),
              ),
            ],
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
