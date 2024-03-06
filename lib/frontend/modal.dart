import 'dart:ui';

import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';

Future<dynamic> showSuccess(BuildContext context, text, text2) {
  return showDialog(
    context: context,
    barrierLabel: '',
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 250),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close)),
            ),
            Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(50)),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 80,
                )),
            SizedBox(
              height: 15,
            ),
            Text(
              text + ' Successfully',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              // ignore: prefer_interpolation_to_compose_strings
              text2,
              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
            )
          ],
        ),
      ),
      content: Container(
        height: 100,
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: (() {
                Navigator.of(context).pop();
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade400,
                padding: const EdgeInsets.all(18.0),
                minimumSize: const Size(250, 50),
                maximumSize: const Size(250, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Continue',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<dynamic> showError(BuildContext context, text, text2) {
  return showDialog(
    context: context,
    barrierLabel: '',
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 250),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close)),
            ),
            Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(50)),
                child: Icon(
                  Icons.error_outlined,
                  color: Colors.red,
                  size: 80,
                )),
            SizedBox(
              height: 15,
            ),
            Text(
              text + ' Failed',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              // ignore: prefer_interpolation_to_compose_strings
              text2,
              style: TextStyle(fontSize: 15, fontStyle: FontStyle.italic),
            )
          ],
        ),
      ),
      content: Container(
        height: 100,
        child: Column(
          children: [
            const SizedBox(
              height: 30,
            ),
            ElevatedButton(
              onPressed: (() {
                Navigator.of(context).pop();
              }),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.all(18.0),
                minimumSize: const Size(250, 50),
                maximumSize: const Size(250, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: Text(
                'Try Again',
                style: TextStyle(fontSize: 18, color: Colors.orange.shade400),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<dynamic> passwordVerification(BuildContext context) {
  return showDialog(
    context: context,
    barrierLabel: '',
    builder: (_) => AlertDialog(
      backgroundColor: Colors.white,
      title: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 250),
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: Icon(Icons.close)),
            ),
            Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(50)),
                child: const Icon(
                  Icons.info_rounded,
                  color: Colors.blue,
                  size: 80,
                )),
            const SizedBox(
              height: 15,
            ),
            const Text(
              'Verification',
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              'Please enter the password to',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontStyle: FontStyle.italic),
            ),
            Text(
              ' proceed with deactivating an account',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 12,
                  fontStyle: FontStyle.italic),
            )
          ],
        ),
      ),
      content: Container(
        height: 180,
        width: 280,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            Container(
              height: 50,
              width: 300,
              padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
              decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black.withOpacity(0.5)),
                  borderRadius: BorderRadius.circular(10)),
              child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none, hintText: 'Enter Password'),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: (() {
                    Navigator.of(context).pop();
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    padding: const EdgeInsets.all(18.0),
                    minimumSize: const Size(150, 50),
                    maximumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: (() {
                    Navigator.of(context).pop();
                  }),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.all(18.0),
                    minimumSize: const Size(150, 50),
                    maximumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Deactivate',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}