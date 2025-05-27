import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_login/const.dart';
import 'package:simple_login/schedules.dart';
import 'package:simple_login/store.dart';
import 'dart:convert';
import 'package:simple_login/toast.dart';
import 'package:http/http.dart' as http;

class ShiftDetailsPage extends StatefulWidget {
  final bool approved;
  const ShiftDetailsPage({super.key, this.approved = true});

  @override
  State<ShiftDetailsPage> createState() => _ShiftDetailsPageState();
}

class _ShiftDetailsPageState extends State<ShiftDetailsPage> {
  // Sample initial values

  String id = '';
  String teamMemberInitials = '';
  String teamMemberName = '';
  String areaName = '';
  String areaSubtitle = 'Greenwich Mean Time';
  String areaRole = 'Guard';

  String userID = '';
  String locationID = '';

  DateTime selectedDate = DateTime.now();
  DateTime stTime = DateTime.now();
  DateTime enTime = DateTime.now();
  TimeOfDay startTime = TimeOfDay(hour: 12, minute: 0);
  TimeOfDay endTime = TimeOfDay(hour: 22, minute: 0);

  int restBreaks = 0;
  int mealBreaks = 1;
  int mealBreakMinutes = 30;

  String notes = "Eg. Don't forget to order cake.";

  late VoidCallback listener;

  @override
  void initState() {
    super.initState();

    // Add listener to myAppKey to monitor changes to the schedule
    final appStore = context.read<AppStore>();

    // Add listener to AppStore to monitor changes to the schedule
    appStore.addListener(_scheduleChanged);

    // Initialize with the current schedule
    _loadScheduleData(appStore);
  }

  void dispose() {
    // Remove the listener when the page is disposed
    final appStore = context.read<AppStore>();
    appStore.removeListener(_scheduleChanged);

    super.dispose();
  }

  // Function to load schedule data into state
  void _loadScheduleData(AppStore appStore) {
    final schedule = appStore.schedule;

    if (schedule != null) {
      final user = schedule['user'];
      final location = schedule['locationID'];

      setState(() {
        id = schedule['id'] ?? '';

        userID = user != null ? user['id'] ?? '' : '';
        locationID = location != null ? location['id'] ?? '' : '';

        teamMemberName = user != null ? user['preferredName'] ?? '' : '';
        teamMemberInitials = teamMemberName.isNotEmpty ? teamMemberName[0] : '';
        areaName = location != null ? location['area'] ?? '' : '';

        stTime =
            schedule['startTime'] is DateTime
                ? schedule['startTime']
                : DateTime.parse(schedule['startTime']);
        enTime =
            schedule['endTime'] is DateTime
                ? schedule['endTime']
                : DateTime.parse(schedule['endTime']);

        selectedDate = stTime;
        startTime = TimeOfDay.fromDateTime(stTime);
        endTime = TimeOfDay.fromDateTime(enTime);
      });
    }
  }

  // Listener that gets triggered when the schedule changes
  void _scheduleChanged() {
    final appStore = context.read<AppStore>();

    if (appStore != null) {
      // Ensure that you can only load schedule data when the appStore is available
      _loadScheduleData(appStore);
    } else {
      print("Error: myAppKey.currentState is null. Can't load schedule data.");
    }
  }

  bool operator ==(Object other) {
    // TODO: implement ==
    return super == other;
  }

  // Helper to format TimeOfDay
  String formatTimeOfDay(TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(tod, alwaysUse24HourFormat: false);
  }

  // Navigate to select team member page
  Future<void> _selectTeamMember() async {
    // TODO: Replace with your actual team member selection page
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const SelectTeamMemberPage()),
    );
    if (result != null) {
      setState(() {
        final data = result as Map<String, dynamic>;
        teamMemberInitials =
            data['preferredName'].substring(0, 2).toUpperCase();
        teamMemberName = data['preferredName'];
        userID = data['id'];
        print("✨ Return From SelectTeamMemberPage: $data");
      });
    }
  }

  // Navigate to select area page
  Future<void> _selectArea() async {
    // TODO: Replace with your actual area selection page
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(builder: (_) => const SelectAreaPage()),
    );
    if (result != null) {
      final data = result as Map<String, dynamic>;
      setState(() {
        areaName = data['area'];
        locationID = data['id'];
        areaRole = 'Guard'; // example
      });
    }
  }

  // Pick date
  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;

        // Update stTime and enTime by combining picked date + existing TimeOfDay
        stTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          startTime.hour,
          startTime.minute,
        );

        enTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          endTime.hour,
          endTime.minute,
        );
      });
    }
  }

  // Pick start time
  Future<void> _pickStartTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: startTime,
    );
    if (picked != null && picked != startTime) {
      setState(() {
        startTime = picked;

        // Update stTime with selectedDate and new startTime
        stTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          startTime.hour,
          startTime.minute,
        );
      });
    }
  }

  // Pick end time
  Future<void> _pickEndTime() async {
    final picked = await showTimePicker(context: context, initialTime: endTime);
    if (picked != null && picked != endTime) {
      setState(() {
        endTime = picked;

        // Update stTime with selectedDate and new startTime
        enTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          endTime.hour,
          endTime.minute,
        );
      });
    }
  }

  // Navigate to break selection page
  Future<void> _selectBreak() async {
    final result = await Navigator.push<Map<String, int>>(
      context,
      MaterialPageRoute(builder: (_) => const BreakSelectionPage()),
    );
    if (result != null) {
      setState(() {
        restBreaks = result['restBreaks'] ?? restBreaks;
        mealBreaks = result['mealBreaks'] ?? mealBreaks;
        mealBreakMinutes = result['mealBreakMinutes'] ?? mealBreakMinutes;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        "${MaterialLocalizations.of(context).formatFullDate(selectedDate)}";
    final formattedStart = formatTimeOfDay(startTime);
    final formattedEnd = formatTimeOfDay(endTime);

    // Soft icon color
    final iconColor = Colors.blueGrey[400];

    // Card style for sections
    BoxDecoration cardDecoration = BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(16),
    );

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(),
        title: const Text(
          'Timesheet Details',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (widget.approved)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Approved',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.green[700],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green[700],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Area
          Container(
            decoration: cardDecoration,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.apartment_rounded, color: iconColor),
              title: Text('Area at $areaName'),
              subtitle: Text(
                areaRole,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // Date
          Container(
            decoration: cardDecoration,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.event_rounded, color: iconColor),
              title: const Text('Date'),
              subtitle: Text(formattedDate),
            ),
          ),
          // Start and Finish Time
          Container(
            decoration: cardDecoration,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Start time picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start', style: TextStyle(color: Colors.grey)),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          color: iconColor,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedStart,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
                // End time picker
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Finish', style: TextStyle(color: Colors.grey)),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_filled_rounded,
                          color: iconColor,
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          formattedEnd,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Break
          Container(
            decoration: cardDecoration,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: Icon(Icons.coffee_rounded, color: iconColor),
              title: const Text('Break'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$restBreaks Rest Break (tot. 0 min.)'),
                  Text('$mealBreaks Meal Break (tot. $mealBreakMinutes min.)'),
                ],
              ),
            ),
          ),
          // Total time
          Container(
            decoration: cardDecoration,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('Total time', style: TextStyle(color: Colors.grey)),
                Text(
                  _calculateTotalTime(),
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
          // Notes
          Container(
            decoration: cardDecoration,
            margin: const EdgeInsets.only(bottom: 70),
            child: ListTile(
              leading: Icon(Icons.sticky_note_2_rounded, color: iconColor),
              title: const Text('Notes'),
              subtitle: Text(notes),
              onTap: () {
                // Optional: edit notes
              },
            ),
          ),
        ],
      ),
    );
  }

  String _calculateTotalTime() {
    final startMinutes = startTime.hour * 60 + startTime.minute;
    final endMinutes = endTime.hour * 60 + endTime.minute;
    int diff = endMinutes - startMinutes;
    if (diff < 0) diff += 24 * 60; // handle overnight shifts

    // Subtract break time (meal break minutes only for example)
    diff -= mealBreakMinutes;

    final hours = diff ~/ 60;
    final minutes = diff % 60;
    return '$hours hrs $minutes mins';
  }
}

// Dummy placeholder pages for navigation

class SelectTeamMemberPage extends StatelessWidget {
  const SelectTeamMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<PeopleItem> people = Provider.of<AppStore>(context).people;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Team Member')),
      body: ListView.builder(
        itemCount: people.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(people[index].preferredName),
            onTap: () async {
              await Future.delayed(Duration(milliseconds: 50));
              Navigator.pop(context, {
                'preferredName': people[index].preferredName,
                'id': people[index].id,
              });
            },
          );
        },
      ),
    );
  }
}

class SelectAreaPage extends StatelessWidget {
  const SelectAreaPage({super.key});

  @override
  Widget build(BuildContext context) {
    List<LocationItem> locations = Provider.of<AppStore>(context).locations;

    return Scaffold(
      appBar: AppBar(title: const Text('Select Area')),
      body: ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(locations[index].area),
            onTap: () async {
              await Future.delayed(Duration(milliseconds: 50)); // short wait
              Navigator.pop(context, {
                'area': locations[index].name,
                'id': locations[index].id,
              });
            },
          );
        },
      ),
    );
  }
}

class BreakSelectionPage extends StatefulWidget {
  const BreakSelectionPage({super.key});

  @override
  State<BreakSelectionPage> createState() => _BreakSelectionPageState();
}

class _BreakSelectionPageState extends State<BreakSelectionPage> {
  int restBreaks = 0;
  int mealBreaks = 1;
  int mealBreakMinutes = 30;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Break')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Rest Break
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rest Break (unpaid)'),
                DropdownButton<int>(
                  value: restBreaks,
                  items:
                      List.generate(6, (i) => i).map((e) {
                        return DropdownMenuItem(value: e, child: Text('$e'));
                      }).toList(),
                  onChanged: (val) {
                    setState(() {
                      restBreaks = val ?? restBreaks;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Meal Break
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Meal Break (paid)'),
                DropdownButton<int>(
                  value: mealBreaks,
                  items:
                      List.generate(6, (i) => i).map((e) {
                        return DropdownMenuItem(value: e, child: Text('$e'));
                      }).toList(),
                  onChanged: (val) {
                    setState(() {
                      mealBreaks = val ?? mealBreaks;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Meal Break Minutes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Meal Break Minutes'),
                DropdownButton<int>(
                  value: mealBreakMinutes,
                  items:
                      [0, 15, 30, 45, 60].map((e) {
                        return DropdownMenuItem(value: e, child: Text('$e'));
                      }).toList(),
                  onChanged: (val) {
                    setState(() {
                      mealBreakMinutes = val ?? mealBreakMinutes;
                    });
                  },
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, {
                  'restBreaks': restBreaks,
                  'mealBreaks': mealBreaks,
                  'mealBreakMinutes': mealBreakMinutes,
                });
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
