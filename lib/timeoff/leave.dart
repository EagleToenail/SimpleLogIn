import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:simple_login/const.dart';
import 'package:provider/provider.dart';
import 'package:simple_login/store.dart';
import 'package:simple_login/toast.dart';
import 'package:simple_login/shift_detail.dart';
import 'dart:convert';

void main() => runApp(MaterialApp(home: LeaveListPage()));

class LeaveListPage extends StatefulWidget {
  @override
  _LeaveListPageState createState() => _LeaveListPageState();
}

class _LeaveListPageState extends State<LeaveListPage> {
  List<Map<String, dynamic>> leaves = [];

  @override
  void initState() {
    super.initState();
    fetchLeaves();
  }

  void reloadPage() {
    fetchLeaves();
  }

  void fetchLeaves() async {
    print("📫 fetching leaves... ");

    final loggedInUser = context.read<AppStore>().loggedInUser;

    final reqData = {'userID': loggedInUser?.userID};

    final url = Uri.parse(GET_LEAVE_URL);

    final response = await http.post(
      url,
      body: jsonEncode(reqData),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      print("🎢 Receive Data from server: $data");
      if (data['success'] == true) {
        setState(() {
          leaves = List<Map<String, dynamic>>.from(data['leaves']);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Leave Requests')),
      body:
          leaves.isEmpty
              ? Center(child: Text('No leave requests yet.'))
              : ListView.builder(
                itemCount: leaves.length,
                itemBuilder: (context, index) {
                  final leave = leaves[index];

                  // Parse and format dates
                  final start = DateTime.parse(leave['startTime']);
                  final end = DateTime.parse(leave['endTime']);
                  final dateFormat = DateFormat("yyyy-MM-dd");
                  final timeFormat = DateFormat("hh:mm a");
                  final startFormatted = dateFormat.format(start);
                  final endFormatted = dateFormat.format(end);
                  final startTimeFormatted = timeFormat.format(start);
                  final endTimeFormatted = timeFormat.format(end);

                  // Status color
                  Color statusColor;
                  switch ((leave['status'] as String).toUpperCase()) {
                    case 'APPROVED':
                      statusColor = Colors.green;
                      break;
                    case 'PENDING':
                      statusColor = Colors.orange;
                      break;
                    default:
                      statusColor = Colors.grey;
                  }

                  final isPending =
                      (leave['status'] as String).toUpperCase() == 'PENDING';

                  return IntrinsicHeight(
                    child: Material(
                      color: Colors.transparent, // Needed for ripple to show
                      child: InkWell(
                        onTap:
                            isPending
                                ? () async {
                                  final result = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => LeaveUpdatePage(
                                            leaveID: leave['_id'],
                                            leaveReason: leave['reason'],
                                            selectedLeaveType: leave['type'],
                                            startDateTime: start,
                                            endDateTime: end,
                                          ),
                                    ),
                                  );

                                  if (result != null && result == 'reload') {
                                    reloadPage();
                                  }
                                }
                                : null,
                        splashColor: Colors.orange.withOpacity(0.2),
                        highlightColor: Colors.orange.withOpacity(0.1),
                        child: Container(
                          margin: EdgeInsets.symmetric(
                            vertical: 0,
                            horizontal: 0,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Colored status bar
                              Container(
                                width: 4,
                                decoration: BoxDecoration(
                                  color: statusColor,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              // Main content
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(left: 8),
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade300,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Main info
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Date
                                            Row(
                                              children: [
                                                Text(
                                                  '$startFormatted',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width: 8,
                                                ), // space between date and status
                                                Text(
                                                  (leave['status'] as String)
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 14,
                                                    color: statusColor,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            SizedBox(height: 4),
                                            // Time range
                                            Text(
                                              '$startTimeFormatted - $endTimeFormatted',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w500,
                                                fontSize: 12,
                                              ),
                                            ),
                                            SizedBox(height: 4),
                                            // Leave Type
                                            Text(
                                              leave['type'] ?? '',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                            // Hours
                                            Text(
                                              '${leave['duration']} hrs',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 13,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlue, // Stylish color
        foregroundColor: Colors.white, // Icon color
        elevation: 4, // Subtle shadow
        shape: const CircleBorder(), // Ensures round shape
        child: const Icon(
          Icons.add,
          size: 28, // Slightly larger icon
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LeaveAddPage()),
          );
          if (result != null && result == 'reload') {
            reloadPage();
          }
        },
      ),
    );
  }
}

class LeaveAddPage extends StatefulWidget {
  @override
  _LeaveAddPageState createState() => _LeaveAddPageState();
}

class _LeaveAddPageState extends State<LeaveAddPage> {
  String? leaveReason;
  String? selectedLeaveType;
  DateTime? startDateTime;
  DateTime? endDateTime;
  bool enableAllDay = false;
  final _formKey = GlobalKey<FormState>();

  Duration get leaveDuration =>
      endDateTime != null && startDateTime != null
          ? endDateTime!.difference(startDateTime!)
          : Duration.zero;

  bool get isStartBeforeEnd =>
      startDateTime != null &&
      endDateTime != null &&
      startDateTime!.isBefore(endDateTime!);

  bool get isFormValid =>
      leaveReason?.isNotEmpty == true &&
      selectedLeaveType != null &&
      selectedLeaveType != 'Unspecified' &&
      startDateTime != null &&
      endDateTime != null &&
      isStartBeforeEnd;

  Future<void> pickStartDateTime() async {
    final picked = await pickDateTime(context, startDateTime);
    if (picked != null) {
      setState(() => startDateTime = picked);
    }
  }

  Future<void> pickEndDateTime() async {
    final picked = await pickDateTime(context, endDateTime);
    if (picked != null) {
      setState(() => endDateTime = picked);
    }
  }

  Future<DateTime?> pickDateTime(
    BuildContext context,
    DateTime? initialDate,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime:
          initialDate != null
              ? TimeOfDay.fromDateTime(initialDate)
              : TimeOfDay.now(),
    );
    if (time == null) return null;

    return date.add(Duration(hours: time.hour, minutes: time.minute));
  }

  void saveLeave(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      final loggedInUser = context.read<AppStore>().loggedInUser;

      final reqData = {
        'userID': loggedInUser?.userID,
        'leaveReason': leaveReason!,
        'leaveType': selectedLeaveType!,
        'start': startDateTime!.toIso8601String(),
        'end': endDateTime!.toIso8601String(),
        'duration': leaveDuration.inHours.toString(),
      };

      final url = Uri.parse(ADD_LEAVE_URL);
      final response = await http.post(
        url,
        body: jsonEncode(reqData),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        Toast.show(context, data['message'], type: ToastType.success);
        Navigator.pop(context, 'reload');
      } else if (response.statusCode == 409) {
        Toast.show(context, data['message'], type: ToastType.error);
      }
    }
  }

  void updateLeaveReason(String value) => setState(() => leaveReason = value);

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.grey[800],
    );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[100], // Light grey background for inputs
      labelStyle: TextStyle(color: Colors.grey[700]), // Label color
      prefixIconColor: Colors.grey[500], // Prefix icon color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // Rounded corners
        borderSide: BorderSide.none, // Remove the border
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ), // Padding inside the fields
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Leave Request',
          style: TextStyle(color: Colors.grey[800]), // Title style
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[700]),
        elevation: 0.5,
      ),
      backgroundColor:
          Colors.grey[50], // Light grey background for the whole page
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                onChanged: updateLeaveReason,
                decoration: inputDecoration.copyWith(
                  labelText: 'Leave Reason',
                  prefixIcon: Icon(Icons.description),
                ),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              SizedBox(height: 20),
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: inputDecoration.copyWith(
                    labelText: 'Leave Type',
                    prefixIcon: Icon(Icons.event),
                  ),
                  value: selectedLeaveType,
                  validator:
                      (value) =>
                          value == null || value == 'Unspecified'
                              ? 'Required field'
                              : null,
                  onChanged: (String? newValue) {
                    setState(() => selectedLeaveType = newValue);
                  },
                  isExpanded:
                      true, // Make dropdown button expand to available width
                  items:
                      [
                        'Unspecified',
                        'Annual Leave (Vacation)',
                        'Unpaid Leave - Leave',
                        'Bereavement (Compassionate) Leave',
                        'Community Service Leave',
                        'Long Service Leave',
                        'Time off in Lieu',
                        'Other Paid Leave',
                      ].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        );
                      }).toList(),
                ),
              ),

              SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: !enableAllDay ? pickStartDateTime : null,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: inputDecoration.copyWith(
                            labelText: 'Start Time',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text:
                                startDateTime != null
                                    ? DateFormat(
                                      'yyyy-MM-dd HH:mm',
                                    ).format(startDateTime!)
                                    : '',
                          ),
                          validator:
                              (value) =>
                                  startDateTime == null
                                      ? 'Required field'
                                      : null,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'to',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: !enableAllDay ? pickEndDateTime : null,
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: inputDecoration.copyWith(
                            labelText: 'End Time',
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          controller: TextEditingController(
                            text:
                                endDateTime != null
                                    ? DateFormat(
                                      'yyyy-MM-dd HH:mm',
                                    ).format(endDateTime!)
                                    : '',
                          ),
                          validator:
                              (value) =>
                                  endDateTime == null ? 'Required field' : null,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              if (!isStartBeforeEnd)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '⚠ Start time must be before end time!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              SizedBox(height: 20),
              Text(
                textAlign: TextAlign.center,
                'Duration: ${leaveDuration.inHours} hours (${leaveDuration.inMinutes.remainder(60)} minutes)',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.blueGrey[700],
                ),
              ),
              SizedBox(height: 20),

              Align(
                alignment: Alignment.center,
                child: ElevatedButton.icon(
                  onPressed: isFormValid ? () => saveLeave(context) : null,
                  icon: Icon(Icons.save),
                  label: Text('Save Leave Request'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[400],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    textStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: Colors.grey[300],
                    disabledForegroundColor: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeaveUpdatePage extends StatefulWidget {
  final String? leaveID;
  final String? leaveReason;
  final String? selectedLeaveType;
  final DateTime? startDateTime;
  final DateTime? endDateTime;

  LeaveUpdatePage({
    this.leaveID,
    this.leaveReason,
    this.selectedLeaveType,
    this.startDateTime,
    this.endDateTime,
  });

  @override
  _LeaveUpdatePageState createState() => _LeaveUpdatePageState();
}

class _LeaveUpdatePageState extends State<LeaveUpdatePage> {
  String? leaveID;
  String? leaveReason;
  String? selectedLeaveType;
  DateTime? startDateTime;
  DateTime? endDateTime;
  bool enableAllDay = false;
  late TextEditingController _leaveReasonController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    leaveID = widget.leaveID;
    leaveReason = widget.leaveReason;
    selectedLeaveType = widget.selectedLeaveType;
    startDateTime = widget.startDateTime;
    endDateTime = widget.endDateTime;

    _leaveReasonController = TextEditingController(text: leaveReason ?? '');
  }

  Duration get leaveDuration =>
      endDateTime != null && startDateTime != null
          ? endDateTime!.difference(startDateTime!)
          : Duration.zero;

  bool get isStartBeforeEnd =>
      startDateTime != null &&
      endDateTime != null &&
      startDateTime!.isBefore(endDateTime!);

  bool get isFormValid =>
      leaveReason?.isNotEmpty == true &&
      selectedLeaveType != null &&
      selectedLeaveType != 'Unspecified' &&
      startDateTime != null &&
      endDateTime != null &&
      isStartBeforeEnd;

  Future<void> pickStartDateTime() async {
    final picked = await pickDateTime(context, startDateTime);
    if (picked != null) {
      setState(() => startDateTime = picked);
    }
  }

  Future<void> pickEndDateTime() async {
    final picked = await pickDateTime(context, endDateTime);
    if (picked != null) {
      setState(() => endDateTime = picked);
    }
  }

  Future<DateTime?> pickDateTime(
    BuildContext context,
    DateTime? initialDate,
  ) async {
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime:
          initialDate != null
              ? TimeOfDay.fromDateTime(initialDate)
              : TimeOfDay.now(),
    );
    if (time == null) return null;

    return date.add(Duration(hours: time.hour, minutes: time.minute));
  }

  void saveLeave(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      // Implement save logic

      final reqData = {
        'reason': leaveReason!,
        'type': selectedLeaveType!,
        'startTime': startDateTime!.toIso8601String(),
        'endTime': endDateTime!.toIso8601String(),
        'duration': leaveDuration.inHours.toString(),
      };

      final url = Uri.parse("$UPDATE_LEAVE_URL/$leaveID");

      final response = await http.put(
        url,
        body: jsonEncode(reqData),
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['success'] == true) {
          Toast.show(context, data['message'], type: ToastType.success);
        }
        Navigator.pop(context, 'reload');
        setState(() {
          // leaves.add(json.decode(response.body));
        });
      } else if (response.statusCode == 409) {
        Toast.show(context, data['message'], type: ToastType.error);
      }
    }
  }

  void cancelLeave(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      // Implement save logic

      final url = Uri.parse("$UPDATE_LEAVE_URL/$leaveID");

      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        if (data['success'] == true) {
          Toast.show(context, data['message'], type: ToastType.success);
        }
        Navigator.pop(context, 'reload');
        setState(() {
          // leaves.add(json.decode(response.body));
        });
      } else if (response.statusCode == 409) {
        Toast.show(context, data['message'], type: ToastType.error);
      }
    }
  }

  void updateLeaveReason(String value) => setState(() => leaveReason = value);

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.grey[800],
    );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[100], // Light grey background for inputs
      labelStyle: TextStyle(color: Colors.grey[700]), // Label color
      prefixIconColor: Colors.grey[500], // Prefix icon color
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8), // Rounded corners
        borderSide: BorderSide.none, // Remove the border
      ),
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 16,
      ), // Padding inside the fields
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Update Leave Request',
          style: TextStyle(color: Colors.grey[800]), // Title style
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[700]),
        elevation: 0.5,
      ),
      backgroundColor:
          Colors.grey[50], // Light grey background for the whole page
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              // Leave Reason
              TextFormField(
                onChanged: updateLeaveReason,
                controller: _leaveReasonController,
                decoration: inputDecoration.copyWith(
                  labelText: 'Leave Reason',
                  prefixIcon: Icon(Icons.description),
                ),
                validator:
                    (value) => value?.isEmpty ?? true ? 'Required field' : null,
              ),
              SizedBox(height: 20),

              // Leave Type Dropdown
              Expanded(
                child: DropdownButtonFormField<String>(
                  decoration: inputDecoration.copyWith(
                    labelText: 'Leave Type',
                    prefixIcon: Icon(Icons.event),
                  ),
                  value: selectedLeaveType,
                  validator:
                      (value) =>
                          value == null || value == 'Unspecified'
                              ? 'Required field'
                              : null,
                  onChanged: (String? newValue) {
                    setState(() => selectedLeaveType = newValue);
                  },
                  isExpanded:
                      true, // Make dropdown button expand to available width
                  items:
                      [
                        'Unspecified',
                        'Annual Leave (Vacation)',
                        'Unpaid Leave - Leave',
                        'Bereavement (Compassionate) Leave',
                        'Community Service Leave',
                        'Long Service Leave',
                        'Time off in Lieu',
                        'Other Paid Leave',
                      ].map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: TextStyle(
                              color: Colors.grey[700],
                            ), // Gray color for text
                          ),
                        );
                      }).toList(),
                ),
              ),
              SizedBox(height: 20),

              // All Day Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Enable All Day'),
                  Switch(
                    value: enableAllDay,
                    onChanged: (bool value) {
                      setState(() {
                        enableAllDay = value;

                        if (value) {
                          // Strip time from date
                          if (startDateTime != null) {
                            startDateTime = DateTime(
                              startDateTime!.year,
                              startDateTime!.month,
                              startDateTime!.day,
                            );
                          }
                          if (endDateTime != null) {
                            endDateTime = DateTime(
                              endDateTime!.year,
                              endDateTime!.month,
                              endDateTime!.day,
                            );
                          }
                        }
                      });
                    },
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Date & Time Pickers
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  GestureDetector(
                    onTap: !enableAllDay ? pickStartDateTime : null,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: inputDecoration.copyWith(
                          labelText: 'Start Time',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text:
                              startDateTime != null
                                  ? DateFormat(
                                    'yyyy-MM-dd HH:mm',
                                  ).format(startDateTime!)
                                  : '',
                        ),
                        validator:
                            (value) =>
                                startDateTime == null ? 'Required field' : null,
                      ),
                    ),
                  ),

                  GestureDetector(
                    onTap: !enableAllDay ? pickEndDateTime : null,
                    child: AbsorbPointer(
                      child: TextFormField(
                        decoration: inputDecoration.copyWith(
                          labelText: 'End Time',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        readOnly: true,
                        controller: TextEditingController(
                          text:
                              endDateTime != null
                                  ? DateFormat(
                                    'yyyy-MM-dd HH:mm',
                                  ).format(endDateTime!)
                                  : '',
                        ),
                        validator:
                            (value) =>
                                endDateTime == null ? 'Required field' : null,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                textAlign: TextAlign.center,
                'Duration: ${leaveDuration.inHours} hours (${leaveDuration.inMinutes.remainder(60)} minutes)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),

              if (!isStartBeforeEnd)
                Text(
                  '⚠ Start time must be before end time!',
                  style: TextStyle(color: Colors.red),
                ),
              SizedBox(height: 12),

              // Save Button
              ElevatedButton.icon(
                onPressed: isFormValid ? () => saveLeave(context) : null,
                icon: Icon(Icons.save),
                label: Text('Save Leave Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightBlue[400],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                ),
              ),
              SizedBox(height: 12),

              // Cancel Button
              ElevatedButton.icon(
                onPressed: isFormValid ? () => cancelLeave(context) : null,
                icon: Icon(Icons.cancel),
                label: Text('Cancel Leave Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[400],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                  disabledForegroundColor: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
