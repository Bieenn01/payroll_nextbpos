import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/main_calendar.dart';
import 'package:project_payroll_nextbpo/backend/jsonfiles/regularHolidayOT.dart';
import 'package:project_payroll_nextbpo/backend/jsonfiles/regularOT.dart';
import 'package:project_payroll_nextbpo/backend/jsonfiles/restDayOT.dart';
import 'package:project_payroll_nextbpo/backend/jsonfiles/specialHolidayOT.dart';
import 'package:project_payroll_nextbpo/frontend/archivesHoliday.dart';
import 'package:project_payroll_nextbpo/frontend/archivesOT.dart';
import 'package:project_payroll_nextbpo/frontend/archivesRegularHOT.dart';
import 'package:project_payroll_nextbpo/frontend/archivesRestdayOT.dart';
import 'package:project_payroll_nextbpo/frontend/archivesSpecialHoliday.dart';
import 'package:project_payroll_nextbpo/frontend/archivesSpecialOT.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/attendace_page.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/dashboardUser.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/dashboard_mobile.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/dashboard_page.dart';
import 'package:project_payroll_nextbpo/frontend/holiday/holiday.dart';
import 'package:project_payroll_nextbpo/frontend/holiday/specialholiday.dart';
import 'package:project_payroll_nextbpo/frontend/leaverecord.dart';
import 'package:project_payroll_nextbpo/frontend/overtime%20bar/regularHolidayOT.dart';
import 'package:project_payroll_nextbpo/frontend/overtime%20bar/restDayOT.dart';
import 'package:project_payroll_nextbpo/frontend/overtime%20bar/specialHolidayOT.dart';
import 'package:project_payroll_nextbpo/backend/dashboardFunc/top_bar.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/pov_user_create.dart';
import 'package:project_payroll_nextbpo/frontend/overtime%20bar/regularOT.dart';
import 'package:project_payroll_nextbpo/frontend/payslip/payslip_page.dart';

class ScreensView extends StatefulWidget {
  final String menu;
  const ScreensView({Key? key, required this.menu}) : super(key: key);

  @override
  State<ScreensView> createState() => _ScreensViewState();
}

class _ScreensViewState extends State<ScreensView> {
  late String _role = 'Guest';
  @override
  void initState() {
    super.initState();
    _fetchRole();
  }

  Future<void> _fetchRole() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('User')
          .doc(user.uid)
          .get();

      setState(() {
        final role = docSnapshot['role'];
        _role = role != null
            ? role
            : 'Guest'; // Default to 'Guest' if role is not specified
      });
    }
  }

  Dashboard() {
    if (_role == 'Employee') {
      return EmployeeDashboard();
    } else if (_role == 'Guest') {
      return Container(
        child: Text('Loading'),
      );
    } else {
      return const DashboardMobile();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (widget.menu) {
      case 'Dashboard':
        page = Container(
          color: Colors.teal.shade700,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                child: Dashboard(),
              ),
            ],
          ),
        );
        /**buildDashboardPage(context) */
        break;
      case 'Overtime':
        page = page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: RegularOTPage(),
              ),
            ],
          ),
        );
        break;
      case 'Regular OT':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: RegularOTPage(),
              ),
            ],
          ),
        );
        break;
      case 'Rest day OT':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: RestDayOTPage(),
              ),
            ],
          ),
        );
        break;
      case 'Special Holiday OT':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: SpecialHolidayOTPage(),
              ),
            ],
          ),
        );
        break;
      case 'Regular Holiday OT':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: RegularHolidayOTPage(),
              ),
            ],
          ),
        );
        break;

      case 'Logs':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: AttendancePage(),
              ),
            ],
          ),
        );
        break;
      // case 'Account List':
      //   page = buildAddAccountPage();
      //   break;
      case 'Calendar':
        page = Container(
          color: Colors.teal.shade700,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: Container(
                    margin: const EdgeInsets.all(15),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white),
                    child: const CalendarPage()),
              ),
            ],
          ),
        );
        break;
      case 'Holiday':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: HolidayPage(),
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
              SizedBox(height: 120, child: TopBar()),
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
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: SpecialHolidayPage(),
              ),
            ],
          ),
        );
        break;

      case 'Payroll':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: PayslipPage(),
              ),
            ],
          ),
        );
        break;
      case 'Leave':
        page = Container(
          color: Colors.teal.shade700,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: UserListScreen(),
              ),
            ],
          ),
        );
        break;

        case 'Archives':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: ArchivesHoliday(),
              ),
            ],
          ),
        );
        break;
        case 'Holiday ':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: ArchivesHoliday(),
              ),
            ],
          ),
        );
        break;
      case 'Overtime ':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: ArchivesOT(),
              ),
            ],
          ),
        );
        break;
        case 'Regular Holiday Overtime':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: ArchivesRegularHOT(),
              ),
            ],
          ),
        );
        break;
        case 'Restday Overtime':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: ArchivesRestdayOT(),
              ),
            ],
          ),
        );
        break;
        case 'Special Holiday':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: ArchivesSpecialHoliday(),
              ),
            ],
          ),
        );
        break;
        case 'Special Holiday Overtime':
        page = Container(
          color: Colors.teal.shade700,
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 120, child: TopBar()),
              Flexible(
                flex: 7,
                child: ArchivesSpecialHOT(),
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
                child: DashboardMobile(),
              ),
            ],
          ),
        );
    }
    return page;
  }

  // Widget buildLogsPage() {
  Widget buildAddAccountPage() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(height: 120, child: TopBar()),
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
        return const Dialog(
          child:
              CalendarPage(), // Replace CalendarPage() with your dialog content
        );
      },
    );
  }
}
