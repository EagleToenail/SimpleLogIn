import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:simple_login/const.dart';
import 'package:simple_login/store.dart';
import 'package:simple_login/shift_detail.dart';
import 'package:simple_login/new_timesheet.dart';

class TimeSheetPage extends StatefulWidget {
  const TimeSheetPage({super.key});

  @override
  State<TimeSheetPage> createState() => _TimeSheetPageState();
}

class _TimeSheetPageState extends State<TimeSheetPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  List<Map<String, dynamic>> approvedLeaves = [];

  List<Map<String, dynamic>> pendingLeaves = [];

  @override
  void initState() {
    super.initState();
    fetchTimesheets();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _onAddPressed() {
    // Add functionality here
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => NewTimesheetPage()),
    );
  }

  void fetchTimesheets() async {
    final loggedInUser =
        Provider.of<AppStore>(context, listen: false).loggedInUser;
    final userID = loggedInUser?.userID;

    final requestBody = {'userID': userID};
    final url = Uri.parse(GET_TIMESHEETS_LIST_URL);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      print("🧾 Timesheets length: ${data['timesheets'].length}");

      setState(() {
        approvedLeaves =
            (data['timesheets'] as List)
                .where((t) => t['payApproved'] == true)
                .map((t) => t as Map<String, dynamic>)
                .toList();

        pendingLeaves =
            (data['timesheets'] as List)
                .where((t) => t['payApproved'] != true)
                .map((t) => t as Map<String, dynamic>)
                .toList();
      });

      print("✅ Shift fetch success");
    } else {
      print('❌ Error: ${response.statusCode}');
    }
  }

  Widget _buildLeaveCard(Map<String, dynamic> leave, {bool approved = false}) {
    final startTime = DateTime.parse(leave['startTime']);
    final endTime = DateTime.parse(leave['endTime']);

    final dateStr = DateFormat('EEE, MMM d, yyyy').format(startTime);

    final startStr = DateFormat.jm().format(startTime); // e.g. 8:00 AM
    final endStr = DateFormat.jm().format(endTime); // e.g. 5:00 PM

    final area = leave['locationID']?['area'] ?? 'Unknown area';
    final location = leave['locationID']?['name']?.trim() ?? 'Unknown location';

    final duration = endTime.difference(startTime);
    final durationStr =
        '${duration.inHours}h ${(duration.inMinutes % 60).toString().padLeft(2, '0')}m';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Material(
        color:
            approved
                ? Colors.green[50]
                : Colors.grey[200], // Light grey background
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ShiftDetailsPage()),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dateStr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color:
                              approved
                                  ? Colors.green[800]
                                  : Colors
                                      .grey[800], // Dark grey for unapproved
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: Colors.grey[600], // Grey for icon
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$startStr - $endStr  ($durationStr)",
                            style: const TextStyle(
                              color: Colors.black87, // Dark text color
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.assignment_ind,
                            size: 16,
                            color: Colors.grey[600], // Grey for icon
                          ),
                          const SizedBox(width: 4),
                          Text(
                            area,
                            style: const TextStyle(
                              color: Colors.black87, // Dark text color
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 16,
                            color: Colors.grey[600], // Grey for icon
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              location,
                              style: const TextStyle(
                                color: Colors.black54, // Lighter text color
                                fontSize: 12,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (approved)
                  Icon(
                    Icons.verified,
                    color: Colors.green[600], // Green for verified icon
                    size: 28,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          child: SafeArea(
            child: TabBar(
              controller: _tabController,
              tabs: const [Tab(text: "PENDING"), Tab(text: "APPROVED")],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pending Tab
          ListView.builder(
            itemCount: pendingLeaves.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [_buildLeaveCard(pendingLeaves[index])],
              );
            },
          ),

          // Approved Tab
          ListView.builder(
            itemCount: approvedLeaves.length,
            itemBuilder: (context, index) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLeaveCard(approvedLeaves[index], approved: true),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
