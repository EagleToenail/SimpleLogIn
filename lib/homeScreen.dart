// lib/screens/homescreenPage.dart
import 'dart:convert';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

import 'package:simple_login/home.dart';
import 'package:simple_login/const.dart';
import 'package:simple_login/shifts/clock.dart';
import 'package:simple_login/store.dart';
import 'package:simple_login/task/task.dart';
import 'package:simple_login/timeoff/leave.dart';
import 'package:simple_login/timeoff/unavailable.dart';
import 'package:simple_login/shifts/upcoming_shifts.dart';
import 'package:simple_login/shifts/available_shifts.dart';

class HomeScreenPage extends StatefulWidget {
  const HomeScreenPage({super.key});

  @override
  State<HomeScreenPage> createState() => _HomeScreenPageState();
}

class _HomeScreenPageState extends State<HomeScreenPage> {
  List<ScheduleItem> shifts = [];
  List<Map<String, dynamic>> noworks = [];
  List<Map<String, dynamic>> timesheets = [];

  @override
  void initState() {
    super.initState();
    fetchShifts();
  }

  Future<void> fetchShifts() async {
    final loggedInUser =
        Provider.of<AppStore>(context, listen: false).loggedInUser;
    final userID = loggedInUser?.userID;

    final requestBody = {'userID': userID};
    final url = Uri.parse(GET_SHIFT_LIST_URL);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      setState(() {
        shifts =
            (data['shifts'] as List<dynamic>)
                .map<ScheduleItem>((item) => ScheduleItem.fromJson(item))
                .toList();
        noworks = List<Map<String, dynamic>>.from(
          (data['noworks'] ?? []).map((item) {
            final newItem = Map<String, dynamic>.from(item);

            // Replace userID with user
            if (newItem.containsKey('userID')) {
              newItem['user'] =
                  newItem['userID']; // Replace with actual user object if available
              newItem.remove('userID');
            }

            // Replace locationID with location
            if (newItem.containsKey('locationID')) {
              newItem['location'] =
                  newItem['locationID']; // Replace with actual location object if available
              newItem.remove('locationID');
            }

            return newItem;
          }),
        );

        timesheets = List<Map<String, dynamic>>.from(data['timesheets'] ?? []);
      });

      print("✅ Shift fetch success");
    } else {
      print('❌ Error: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    Color pastel(Color color) => color.withOpacity(0.15);

    return Container(
      width: double.infinity,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Current Time Card
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: Colors.blue[50],
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32,
                      horizontal: 18,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFFF4F4F6),
                      ), // subtle border
                      // Optional: soft shadow
                      // boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [ServerTimeClock()],
                    ),
                  ),
                ],
              ),
            ),

            // Shifts Card
            _DashboardCard(
              icon: Icons.calendar_today,
              iconBg: Colors.green[700]!,
              iconBgPastel: pastel(Colors.green[700]!),
              title: 'Shifts',
              items: [
                _DashboardListItem(
                  label: 'All Upcoming Shifts',
                  count: shifts.length,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UpcomingShifts(shifts: shifts),
                      ),
                    );
                  },
                ),
                _DashboardListItem(
                  label: 'Available Shifts',
                  count: noworks.length,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                AvailablePage(availableShifts: noworks),
                      ),
                    );
                  },
                ),
                _DashboardListItem(
                  label: 'Timesheets',
                  count: timesheets.length,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HomePage(currentTabIndex: 3),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Time Off Card
            _DashboardCard(
              icon: Icons.beach_access,
              iconBg: Colors.purple[700]!,
              iconBgPastel: pastel(Colors.purple[700]!),
              title: 'Time Off',
              items: [
                _DashboardListItem(
                  label: 'Leave',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LeaveListPage()),
                    );
                  },
                ),
                _DashboardListItem(
                  label: 'Unavailability',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UnavailableListPage(),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Tasks Card
            _DashboardCard(
              icon: Icons.check_rounded,
              iconBg: Colors.blue[900]!,
              iconBgPastel: pastel(Colors.blue[900]!),
              title: 'Tasks',
              items: [
                _DashboardListItem(
                  label: 'All Tasks',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaskMainPage()),
                    );
                  },
                ),
                _DashboardListItem(
                  label: 'My Tasks',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaskMainPage()),
                    );
                  },
                ),
                _DashboardListItem(
                  label: 'Assigned Tasks',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TaskMainPage()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
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

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconBgPastel;
  final String title;
  final List<_DashboardListItem> items;

  const _DashboardCard({
    required this.icon,
    required this.iconBg,
    required this.iconBgPastel,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconBgPastel,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconBg, size: 26),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
            ...items.map((item) => item),
          ],
        ),
      ),
    );
  }
}

// List Item with optional badge
class _DashboardListItem extends StatelessWidget {
  final String label;
  final int? count;
  final VoidCallback onTap;

  const _DashboardListItem({
    required this.label,
    this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 2),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          if (count != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.blueGrey,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),

      onTap: onTap,
    );
  }
}
