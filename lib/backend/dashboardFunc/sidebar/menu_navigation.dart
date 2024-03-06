import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/main_calendar.dart';
import 'package:project_payroll_nextbpo/backend/jsonfiles/regularHolidayOT.dart';
import 'package:project_payroll_nextbpo/backend/jsonfiles/regularOT.dart';
import 'package:project_payroll_nextbpo/backend/jsonfiles/restDayOT.dart';
import 'package:project_payroll_nextbpo/backend/jsonfiles/specialHolidayOT.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/attendace_page.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/dashboard_page.dart';
import 'package:project_payroll_nextbpo/frontend/holiday/holiday.dart';
import 'package:project_payroll_nextbpo/frontend/holiday/specialholiday.dart';

import 'package:project_payroll_nextbpo/frontend/overtime%20bar/restday_overtime.dart';
import 'package:project_payroll_nextbpo/frontend/overtime%20bar/restspecial_overtime.dart';
import 'package:project_payroll_nextbpo/frontend/overtime%20bar/specialh_overtime.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/top_bar.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/pov_user_create.dart';

import 'package:project_payroll_nextbpo/frontend/overtime%20bar/regular_overtime.dart';

class ScreensView extends StatelessWidget {
  final String menu;
  const ScreensView({Key? key, required this.menu}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (menu) {
      case 'Dashboard':
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
                child: Dashboard(),
              ),
            ],
          ),
        );
        /**buildDashboardPage(context) */
        break;
      case 'Overtime':
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
                child: Dashboard(),
              ),
            ],
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
                child: RegularHolidayOT(),
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
        page = Container(
          color: Colors.teal.shade700,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: TopBar(),
              ),
              Flexible(
                flex: 7,
                child: AttendancePage(),
              ),
            ],
          ),
        );
        break;
      case 'Add Account':
        page = buildAddAccountPage();
        break;
      case 'Calendar':
        page = Container(
          color: Colors.teal.shade700,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                child: TopBar(),
              ),
              Flexible(
                flex: 7,
                child: Container(
                    margin: EdgeInsets.all(15),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white),
                    child: CalendarPage()),
              ),
            ],
          ),
        );
        break;
      case 'Regular':
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
                child: HolidayPage(),
              ),
            ],
          ),
        );
        break;
      case 'Special':
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
                child: SpecialholidayPage(),
              ),
            ],
          ),
        );
        break;
      case 'Settings':
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
                flex: 2,
                child: RegularOT(),
              ),
              Flexible(
                flex: 2,
                child: SpecialHolidayOT(),
              ),
              Flexible(
                flex: 2,
                child: RestDayOT(),
              ),
            ],
          ),
        );
        break;
      default:
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
                child: Dashboard(),
              ),
            ],
          ),
        );
    }
    return page;
  }

  // Widget buildLogsPage() {
  //   return Container(
  //      color: Colors.transparent,
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Flexible(
  //           child: Logs(),
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget buildAddAccountPage() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Flexible(
            flex: 1,
            child: TopBar(),
          ),
          Flexible(
            flex: 7,
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
