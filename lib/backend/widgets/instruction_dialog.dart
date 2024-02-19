import 'package:flutter/material.dart';

class InstructionsDialog extends StatelessWidget {
  const InstructionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Instructions'),
      content: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Welcome to the SK App!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Here are some instructions on how to use the app:'),
            SizedBox(height: 10),
            Text('1. Step one instruction goes here.'),
            Text('2. Step two instruction goes here.'),
            Text('3. Step three instruction goes here.'),
            Text('4. Step four instruction goes here.'),
            SizedBox(height: 10),
            Text(
              'Enjoy using the app!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            // Close the dialog when "Close" is pressed.
            Navigator.of(context).pop();
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
