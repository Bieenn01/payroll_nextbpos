import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/dashboard_page.dart';
import 'package:project_payroll_nextbpo/frontend/dashboard/pov_dashboard.dart';

Future<dynamic> UserProfile(BuildContext context) {
  return showDialog(
    context: context,
    barrierLabel: '',
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              ' User Profile',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 250),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close)),
            ),
          ],
        ),
      ),
      content: Container(
        width: 800,
        child: Column(
          children: [],
        ),
      ),
    ),
  );
}
