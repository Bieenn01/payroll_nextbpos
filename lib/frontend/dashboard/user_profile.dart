import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/dashboard_page.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/pov_dashboard.dart';

Future<dynamic> UserProfile(BuildContext context) {
  return showDialog(
    context: context,
    barrierLabel: '',
    builder: (_) => AlertDialog(
      surfaceTintColor: Colors.white,
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              ' User Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 250),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.close)),
            ),
          ],
        ),
      ),
      content: SizedBox(
        width: 750,
        height: 350,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: Container(
                width: 200,
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: AssetImage('assets/images/Admin.jpg'),
                    ),
                    Text('Dahnica Tedlos',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    Text('Admin', style: TextStyle(fontSize: 15)),
                    SizedBox(
                      height: 8,
                    ),
                    ListTile(
                        leading: Icon(Icons.email),
                        title: Text('dahn@example')),
                    ListTile(
                        leading: Icon(Icons.phone),
                        title: Text('0948-7355-442')),
                  ],
                ),
              ),
            ),
            const Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('EMPLOYEE DETAILS',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  ListTile(
                      leading: Icon(Icons.business),
                      title: Text('Department: Information Technology')),
                  ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Employee Status: Regular')),
                  ListTile(
                      leading: Icon(Icons.access_time),
                      title: Text('Shift: 9:00 am to 6:00 pm')),
                  ListTile(
                      leading: Icon(Icons.credit_card),
                      title: Text('SSS: 123-456-789')),
                  ListTile(
                      leading: Icon(Icons.credit_card),
                      title: Text('TIN: 123-456-789')),
                  ListTile(
                      leading: Icon(Icons.account_balance),
                      title: Text('Tax Code: 123-456-78')),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
