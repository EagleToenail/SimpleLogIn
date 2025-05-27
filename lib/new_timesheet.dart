import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'break_summary.dart';

class NewTimesheetPage extends StatefulWidget {
  const NewTimesheetPage({super.key});

  @override
  State<NewTimesheetPage> createState() => _NewTimesheetPageState();
}

class _NewTimesheetPageState extends State<NewTimesheetPage> {
  String area = 'Select Area';
  String areaSubtitle = '';
  String teamMembers = 'Select Team Member';
  DateTime selectedDate = DateTime.now();
  TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 17, minute: 0);
  int restBreaks = 0;
  int mealBreaks = 1;
  int mealBreakMinutes = 30;
  int restBreakMinutes = 0; // Initialize restBreakMinutes
  TextEditingController commentsController =
      TextEditingController(); // Add this line

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectArea() async {
    final result = await Navigator.push<Area>(
      context,
      MaterialPageRoute(builder: (_) => const SelectAreaPage()),
    );
    if (result != null) {
      setState(() {
        area = result.name;
        areaSubtitle = result.subtitle;
      });
    }
  }

  Future<void> _selectTeamMembers() async {
    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(builder: (_) => const SelectTeamMemberPage()),
    );
    if (result != null) {
      setState(() {
        teamMembers = result.join(', ');
      });
    }
  }

  Future<void> _selectBreaks() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder:
            (_) => BreaksSummaryPage(
              mealBreaks: mealBreaks,
              mealBreakMinutes: mealBreakMinutes,
              restBreaks: restBreaks,
              restBreakMinutes: restBreakMinutes,
            ),
      ),
    );
    if (result != null) {
      setState(() {
        mealBreaks = result['mealBreaks'];
        mealBreakMinutes = result['mealBreakMinutes'];
        restBreaks = result['restBreaks'];
        restBreakMinutes = result['restBreakMinutes'];
      });
    }
  }

  String formatTimeOfDay(BuildContext context, TimeOfDay tod) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, tod.hour, tod.minute);
    return MaterialLocalizations.of(
      context,
    ).formatTimeOfDay(tod, alwaysUse24HourFormat: false);
  }

  @override
  Widget build(BuildContext context) {
    final dateString = DateFormat('EEE, MMM d, yyyy').format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'New Timesheet',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 28),
            onPressed: () {
              // TODO: Handle save/confirm
            },
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView(
        children: [
          // Area
          InkWell(
            onTap: _selectArea,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.work_outline, color: Colors.grey[600], size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          area,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          areaSubtitle,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
                ],
              ),
            ),
          ),
          const Divider(height: 0),
          // Team members
          InkWell(
            onTap: _selectTeamMembers,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.person_outline, color: Colors.grey[600], size: 28),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Team member(s)',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          teamMembers,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
                ],
              ),
            ),
          ),
          const Divider(height: 0),
          // Date
          InkWell(
            onTap: () => _selectDate(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    color: Colors.grey[600],
                    size: 28,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Date',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          dateString,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 0),
          // Start and End Time
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Start',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        formatTimeOfDay(context, startTime),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Finish',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        formatTimeOfDay(context, endTime),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          // Breaks
          InkWell(
            onTap: _selectBreaks,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Breaks Taken',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  Text(
                    '$restBreaks Rest Break (tot. $restBreakMinutes min.)\n'
                    '$mealBreaks Meal Break (tot. $mealBreakMinutes min.)',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 0),
          // Comments field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.comment,
                  color: Colors.grey[600],
                  size: 28,
                ), // Add the icon
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Comments',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      TextFormField(
                        controller: commentsController,
                        decoration: const InputDecoration(
                          hintText: 'Enter comments here',
                          border: InputBorder.none, // Remove the border
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 0),
        ],
      ),
    );
  }
}

class SelectTeamMemberPage extends StatelessWidget {
  const SelectTeamMemberPage({super.key});

  @override
  Widget build(BuildContext context) {
    final members = [
      TeamMember(name: 'Jack Rice', initials: 'JR'),
      TeamMember(name: 'Andrew Pileckis', initials: 'AP'),
      TeamMember(name: 'Ashnoy Colaco', initials: 'AC'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Team Member')),
      body: ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: CircleAvatar(child: Text(members[index].initials)),
            title: Text(members[index].name),
            onTap: () {
              Navigator.pop(context, [
                members[index].name,
              ]); // Return list of names
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
    final areas = [
      Area(
        name: 'Fortunestown Supervalu Tallaght',
        subtitle: 'Greenwich Mean Time',
      ),
      Area(
        name: 'Aylesbury Supervalu Tallaght',
        subtitle: 'Greenwich Mean Time',
      ),
      Area(
        name: 'Killinarden Centra Tallaght',
        subtitle: 'Greenwich Mean Time',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Select Area')),
      body: ListView.builder(
        itemCount: areas.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(areas[index].name),
            subtitle: Text(areas[index].subtitle),
            onTap: () {
              Navigator.pop(context, areas[index]);
            },
          );
        },
      ),
    );
  }
}

class TeamMember {
  final String name;
  final String initials;

  TeamMember({required this.name, required this.initials});
}

class Area {
  final String name;
  final String subtitle;

  Area({required this.name, required this.subtitle});
}
