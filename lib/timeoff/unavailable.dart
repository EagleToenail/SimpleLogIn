import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:simple_login/const.dart';
import 'package:provider/provider.dart';
import 'package:simple_login/store.dart';
import 'package:simple_login/toast.dart';
import 'dart:convert';

void main() => runApp(MaterialApp(home: UnavailableListPage()));

class UnavailableListPage extends StatefulWidget {
  @override
  _UnavailableListPageState createState() => _UnavailableListPageState();
}

class _UnavailableListPageState extends State<UnavailableListPage> {
  List<Map<String, dynamic>> unavailables = [];

  @override
  void initState() {
    super.initState();
    fetchList();
  }

  void reloadPage() {
    fetchList();
  }

  void fetchList() async {
    final loggedInUser = context.read<AppStore>().loggedInUser;

    final reqData = {'userID': loggedInUser?.userID};

    final url = Uri.parse(GET_UNAVAILABLE_URL);

    final response = await http.post(
      url,
      body: jsonEncode(reqData),
      headers: {'Content-Type': 'application/json'},
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      if (data['success'] == true) {
        setState(() {
          unavailables = List<Map<String, dynamic>>.from(data['data']);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My Unavailability'), elevation: 0),
      body:
          unavailables.isEmpty
              ? Center(child: Text('No unavailable records yet.'))
              : ListView.builder(
                itemCount: unavailables.length,
                itemBuilder: (context, index) {
                  final unavailable = unavailables[index];
                  final start = DateTime.parse(unavailable['startTime']);
                  final dateFormatted = DateFormat(
                    'EEE, d MMM, yyyy',
                  ).format(start);
                  final reason = unavailable['reason'] ?? '';

                  final hours = unavailable['duration'] ?? 1;
                  final days = (hours / 24).ceil();
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Text(
                            '$days DAY${days == 1 ? '' : 'S'}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          dateFormatted,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          reason,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
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
            MaterialPageRoute(builder: (context) => UnavailableAddPage()),
          );
          if (result != null && result == 'reload') {
            reloadPage();
          }
        },
      ),
    );
  }
}

class UnavailableAddPage extends StatefulWidget {
  @override
  _UnavailableAddPageState createState() => _UnavailableAddPageState();
}

class _UnavailableAddPageState extends State<UnavailableAddPage> {
  String unavailableReason = '';
  DateTime unavailableStartDate = DateTime.now();
  DateTime unavailableEndDate = DateTime.now();
  bool isFormValid = false;
  bool isStartDateBeforeEndDate = true;
  Duration unavailableDuration = Duration(hours: 0);

  late TextEditingController startDateController;
  late TextEditingController endDateController;

  @override
  void initState() {
    super.initState();
    startDateController = TextEditingController(
      text: _formatDate(unavailableStartDate),
    );
    endDateController = TextEditingController(
      text: _formatDate(unavailableEndDate),
    );
    calculateDuration();
  }

  @override
  void dispose() {
    startDateController.dispose();
    endDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Duration getUnavailableDuration() {
    return DateTime.utc(
      unavailableEndDate.year,
      unavailableEndDate.month,
      unavailableEndDate.day,
    ).difference(
      DateTime.utc(
        unavailableStartDate.year,
        unavailableStartDate.month,
        unavailableStartDate.day,
      ),
    );
  }

  void calculateDuration() {
    unavailableDuration = getUnavailableDuration();
    setState(() {});
  }

  void validateForm() {
    isFormValid =
        unavailableReason.trim().isNotEmpty &&
        unavailableStartDate.isBefore(unavailableEndDate);
    isStartDateBeforeEndDate = unavailableStartDate.isBefore(
      unavailableEndDate,
    );
    setState(() {});
  }

  void updateUnavailableReason(String value) {
    unavailableReason = value;
    validateForm();
  }

  Future<void> pickStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: unavailableStartDate,
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        unavailableStartDate = picked;
        startDateController.text = _formatDate(picked);
      });
      calculateDuration();
      validateForm();
    }
  }

  Future<void> pickEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: unavailableEndDate,
      firstDate: DateTime(2018),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        unavailableEndDate = picked;
        endDateController.text = _formatDate(picked);
      });
      calculateDuration();
      validateForm();
    }
  }

  void saveUnavailable() async {
    if (isFormValid) {
      final loggedInUser = context.read<AppStore>().loggedInUser;

      final reqData = {
        'userID': loggedInUser?.userID,
        'reason': unavailableReason,
        'start': unavailableStartDate.toIso8601String(),
        'end': unavailableEndDate.toIso8601String(),
        'duration': unavailableDuration.inHours.toString(),
      };

      final url = Uri.parse(ADD_UNAVAILABLE_URL);

      final response = await http.post(
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
      } else if (response.statusCode == 409) {
        Toast.show(context, data['message'], type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: Colors.grey[800],
    );

    final inputDecoration = InputDecoration(
      filled: true,
      fillColor: Colors.grey[100],
      labelStyle: TextStyle(color: Colors.grey[700]),
      prefixIconColor: Colors.grey[500],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Unavailable',
          style: TextStyle(color: Colors.grey[800]),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[700]),
        elevation: 0.5,
      ),
      backgroundColor: Colors.grey[50],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: ListView(
            children: <Widget>[
              TextFormField(
                onChanged: updateUnavailableReason,
                decoration: inputDecoration.copyWith(
                  labelText: 'Reason for Unavailability',
                  prefixIcon: Icon(Icons.report_problem_outlined),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      onTap: pickStartDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: startDateController,
                          readOnly: true,
                          decoration: inputDecoration.copyWith(
                            labelText: 'Start Time',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
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
                      onTap: pickEndDate,
                      child: AbsorbPointer(
                        child: TextFormField(
                          controller: endDateController,
                          readOnly: true,
                          decoration: inputDecoration.copyWith(
                            labelText: 'End Time',
                            prefixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Text(
                'Unavailable Duration: ${unavailableDuration.inHours} hours',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),

              SizedBox(height: 16),
              if (!isStartDateBeforeEndDate)
                Text(
                  '⚠ Start time must be before end time.',
                  style: TextStyle(color: Colors.red[600], fontSize: 13),
                ),
              SizedBox(height: 24),
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: isFormValid ? saveUnavailable : null,
                  child: Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[400],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                    textStyle: TextStyle(fontSize: 16),
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
