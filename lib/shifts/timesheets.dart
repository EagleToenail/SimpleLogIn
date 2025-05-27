import 'package:flutter/material.dart';

class MyTimeSheets extends StatefulWidget {
  const MyTimeSheets({Key? key}) : super(key: key);

  @override
  _MyTimeSheetsState createState() => _MyTimeSheetsState();
}

class _MyTimeSheetsState extends State<MyTimeSheets> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Timesheets')),
      body: Center(
        child: Column(
          children: [
            Text(
              'This is the my timesheets page.',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
