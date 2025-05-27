import 'package:flutter/material.dart';
import 'package:simple_login/homeScreen.dart';
import 'package:simple_login/peoples.dart';
import 'package:simple_login/schedules.dart';
import 'package:simple_login/timesheet.dart';
import 'package:simple_login/newsfeed.dart';
import 'drawer.dart';

class HomePage extends StatefulWidget {
  final int? currentTabIndex; // Nullable parameter

  // Constructor with optional parameter
  HomePage({this.currentTabIndex});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // List of pages to navigate to
  final List<Widget> _pages = [
    HomeScreen(),
    NewsFeedScreen(),
    ScheduleScreen(),
    TimesheetsScreen(),
    PeopleScreen(),
  ];

  List<String> titles = ['Home', 'News Feed', 'Schedules', 'Timesheets'];

  @override
  void initState() {
    super.initState();
    // Check if currentTabIndex is passed; if not, use default 0
    if (widget.currentTabIndex != null) {
      print("✨ Current tab index: ${widget.currentTabIndex}");
      _selectedIndex = widget.currentTabIndex!;
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titles[_selectedIndex])),
      drawer: AppDrawer(),
      body: _pages[_selectedIndex],
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor:
              Colors.white, // Background color of the BottomNavigationBar
          selectedItemColor:
              Colors.lightBlue, // Color when the item is selected
          unselectedItemColor:
              Colors.grey[700], // Color when the item is not selected
          elevation: 1, // Shadow under the BottomNavigationBar
          showUnselectedLabels: true, // Show labels when not selected
          selectedFontSize: 14, // Font size for selected label
          unselectedFontSize: 12, // Font size for unselected label
          type: BottomNavigationBarType.fixed,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
              icon: Icon(Icons.feed), // More modern for "News Feed"
              label: 'News Feed',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month), // Clearer for "Schedule"
              label: 'Schedule',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long), // Better for "Timesheets"
              label: 'Timesheets',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return HomeScreenPage();
  }
}

class NewsFeedScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return NewsFeedPage();
  }
}

class ScheduleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SchedulesPage();
  }
}

class TimesheetsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TimeSheetPage();
  }
}

class PeopleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PeoplesPage();
  }
}

class MyElevatedButton extends StatelessWidget {
  final String buttonText; // Variable to hold the text for the button

  // Constructor to pass the text dynamically
  MyElevatedButton({required this.buttonText});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Action to perform when the button is pressed
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      },
      child: Text(
        buttonText, // Use the variable for the button's text
        style: TextStyle(
          color: Colors.green, // Text color
          fontSize: 16, // Font size
          fontWeight: FontWeight.bold, // Bold text
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromARGB(
          255,
          218,
          255,
          221,
        ), // Background color (use backgroundColor instead of primary)
        elevation: 0, // Shadow elevation
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // Rounded corners
        ),
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Padding
      ),
    );
  }
}
