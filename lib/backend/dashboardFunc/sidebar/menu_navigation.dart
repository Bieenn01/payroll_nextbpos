import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/main_calendar.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/check_in_out_logs.dart';
import 'package:project_payroll_nextbpo/frontend/overtime%20bar/holiday_overtime.dart';
import 'package:project_payroll_nextbpo/frontend/overtime%20bar/restday_overtime.dart';
import 'package:project_payroll_nextbpo/frontend/overtime%20bar/restspecial_overtime.dart';
import 'package:project_payroll_nextbpo/frontend/overtime%20bar/specialh_overtime.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/top_bar.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/pov_user_create.dart';
import 'package:project_payroll_nextbpo/frontend/mobileHomeScreen.dart';
import 'package:project_payroll_nextbpo/frontend/userTimeInToday.dart';
import 'package:project_payroll_nextbpo/frontend/overtime%20bar/regular_overtime.dart';

class ScreensView extends StatelessWidget {
  final String menu;
  const ScreensView({Key? key, required this.menu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (menu) {
      case 'Dashboard':
        page = buildDashboardPage(context);
        break;
      case 'Overtime':
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
      case 'Regular (OT)':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: TopBar(),
              ),
              Flexible(
                flex: 7,
                child: RegularOvertimePage(),
              ),
            ],
          ),
        );
        break;
      case 'Rest day':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: TopBar(),
              ),
              Flexible(
                flex: 7,
                child: RestdayOvertimePage(),
              ),
            ],
          ),
        );
        break;
      case 'Special Holiday (SH)':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: TopBar(),
              ),
              Flexible(
                flex: 7,
                child: SpecialHolidayOvertimePage(),
              ),
            ],
          ),
        );
        break;
      case 'Regular Holiday (RH)':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: TopBar(),
              ),
              Flexible(
                flex: 7,
                child: RHolidayOvertimePage(),
              ),
            ],
          ),
        );
        break;
      case 'SH/Rest day':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: TopBar(),
              ),
              Flexible(
                flex: 7,
                child: RestSpecialOvertimePage(),
              ),
            ],
          ),
        );
        break;
      case 'Logs':
        page = buildLogsPage();
        break;
      case 'Add Account':
        page = buildAddAccountPage();
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

  Widget buildDashboardPage(BuildContext context) {
    return Container(
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
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 20,
                ), // Add spacing between MobileHomeScreen and CalendarPage
                Expanded(
                  flex: 2, // Adjust flex factor as needed
                  child: GestureDetector(
                    onTap: () {
                      _navigateToCalendarPageWithDialog(context);
                    },
                    child: CalendarPage(),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: UserTimedInToday(),
          ),
        ],
      ),
    );
  }

  Widget buildLogsPage() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 20),
          Expanded(
            child: Logs(),
          ),
        ],
      ),
    );
  }

  Widget buildAddAccountPage() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Add Account",
            style: TextStyle(
              color: Color(0xFF171719),
              fontSize: 22,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            child: PovUser(),
          ),
        ],
      ),
    );
  }

  void _navigateToCalendarPageWithDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child:
              CalendarPage(), // Replace CalendarPage() with your dialog content
        );
      },
    );
  }
}
