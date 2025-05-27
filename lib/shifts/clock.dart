import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:simple_login/const.dart';
import 'package:simple_login/store.dart';
import 'package:simple_login/toast.dart';

enum ShiftStatus {
  notStarted,
  shiftStarted,
  breakStarted,
  breakStopped,
  shiftStopped,
}

class ServerTimeClock extends StatefulWidget {
  const ServerTimeClock({Key? key}) : super(key: key);

  @override
  State<ServerTimeClock> createState() => _ServerTimeClockState();
}

class _ServerTimeClockState extends State<ServerTimeClock> {
  DateTime? _serverTime;
  Timer? _timer;

  List<Map<String, dynamic>> todayShifts = [];
  ShiftStatus _shiftStatus = ShiftStatus.notStarted;

  @override
  void initState() {
    super.initState();
    _fetchServerTime();
    _getTodayShift();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  ShiftStatus getShiftStatus(Map<String, dynamic> shift) {
    final clockIn = shift['clockIn'];
    final clockOut = shift['clockOut'];
    final breakClockIn = shift['breakClockIn'];
    final breakClockOut = shift['breakClockOut'];

    // Check in order according to your rules:
    if (clockIn == null &&
        clockOut == null &&
        breakClockIn == null &&
        breakClockOut == null) {
      return ShiftStatus.notStarted;
    }
    if (clockIn != null && clockOut == null) {
      // Shift started but not clocked out yet
      if (breakClockIn == null && breakClockOut == null) {
        return ShiftStatus.shiftStarted;
      }
      if (breakClockIn != null && breakClockOut == null) {
        return ShiftStatus.breakStarted;
      }
      if (breakClockOut != null) {
        return ShiftStatus.breakStopped;
      }
    }
    if (clockOut != null) {
      return ShiftStatus.shiftStopped;
    }

    // Default fallback
    return ShiftStatus.notStarted;
  }

  Future<void> _fetchServerTime() async {
    try {
      final response = await http.get(Uri.parse(GET_SERVER_TIME_URL));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final serverTimeString = data['serverTime'];
        final serverTime = DateTime.parse(serverTimeString);
        setState(() {
          _serverTime = serverTime.toLocal();
        });
        _timer?.cancel();
        _timer = Timer.periodic(const Duration(seconds: 1), (_) {
          setState(() {
            _serverTime = _serverTime?.add(const Duration(seconds: 1));
          });
        });
      } else {
        print('Failed to fetch server time: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching server time: $e');
    }
  }

  Future<void> _getTodayShift() async {
    try {
      // Replace with your userID fetching logic
      final loggedInUser =
          Provider.of<AppStore>(context, listen: false).loggedInUser;
      final userID = loggedInUser?.userID;
      final requestBody = {"userID": userID};
      final url = Uri.parse(CHECK_SCHEDULE_TODAY_URL);
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          final today_shifts = data['schedules'];
          print(today_shifts);
          setState(() {
            todayShifts =
                today_shifts
                    .map<Map<String, dynamic>>(
                      (e) => Map<String, dynamic>.from(e),
                    )
                    .toList();

            _shiftStatus = getShiftStatus(todayShifts.first);
          });
        }
      }
    } catch (err) {
      print("Get Today Shift Error: $err");
    }
  }

  Future<void> _setShiftStatus(type) async {
    try {
      final scheduleID = todayShifts.first['id'];

      final requestBody = {"scheduleID": scheduleID, "type": type};

      final url = Uri.parse(CLOCK_SCHEDULE_URL);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          getShiftStatus(data['schedule']);
          Toast.show(context, 'Success', type: ToastType.success);
        }
      } else {
        print("💥 CLock InOut Error: ${response.statusCode}");
      }
    } catch (err) {
      print("💥 Shift ClockInOut Error: $err");
    }
  }

  void _startShift() {
    setState(() {
      _shiftStatus = ShiftStatus.shiftStarted;
    });
    _setShiftStatus("clockIn");
  }

  void _startBreak() {
    setState(() {
      _shiftStatus = ShiftStatus.breakStarted;
    });
    _setShiftStatus("breakClockIn");
  }

  void _stopBreak() {
    setState(() {
      _shiftStatus = ShiftStatus.breakStopped;
    });
    _setShiftStatus("breakClockOut");
  }

  void _stopShift() {
    setState(() {
      _shiftStatus = ShiftStatus.shiftStopped;
    });
    _setShiftStatus("clockOut");
  }

  Widget _buildActionButton() {
    final buttonPadding = const EdgeInsets.symmetric(
      vertical: 12,
      horizontal: 20,
    );
    final borderRadius = BorderRadius.circular(16);

    switch (_shiftStatus) {
      case ShiftStatus.notStarted:
        return ElevatedButton.icon(
          onPressed: _startShift,
          icon: const Icon(
            Icons.play_arrow_rounded,
            color: Color(0xFF2D7C3F),
            size: 20,
          ),
          label: const Text(
            'Start Shift',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF2D7C3F),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 3,
            shadowColor: Colors.grey.withOpacity(0.15),
            side: const BorderSide(color: Color(0xFF2D7C3F), width: 1.5),
            foregroundColor: const Color(0xFF2D7C3F),
            alignment: Alignment.centerLeft,
          ),
        );

      case ShiftStatus.shiftStarted:
        return ElevatedButton.icon(
          onPressed: _startBreak,
          icon: const Icon(
            Icons.coffee_rounded,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          label: const Text(
            'Start Break',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF4CAF50),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8F5E9), // very soft green
            padding: buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 0,
            alignment: Alignment.centerLeft,
          ),
        );

      case ShiftStatus.breakStarted:
        return ElevatedButton.icon(
          onPressed: _stopBreak,
          icon: const Icon(
            Icons.coffee_outlined,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          label: const Text(
            'Stop Break',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF4CAF50),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8F5E9),
            padding: buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 0,
            alignment: Alignment.centerLeft,
          ),
        );

      case ShiftStatus.breakStopped:
        return ElevatedButton.icon(
          onPressed: _stopShift,
          icon: const Icon(
            Icons.stop_circle_outlined,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          label: const Text(
            'Stop Shift',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF4CAF50),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8F5E9),
            padding: buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 0,
            alignment: Alignment.centerLeft,
          ),
        );

      case ShiftStatus.shiftStopped:
        return ElevatedButton.icon(
          onPressed: null,
          icon: const Icon(
            Icons.check_circle,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          label: const Text(
            'Shift Completed',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.normal,
              color: Color(0xFF4CAF50),
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE8F5E9),
            padding: buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 0,
            alignment: Alignment.centerLeft,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_serverTime == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final formattedTime = DateFormat.jm().format(_serverTime!);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        // centers the Column horizontally inside the padding
        child: Column(
          mainAxisSize: MainAxisSize.min, // shrink column width to fit children
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              formattedTime,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2A),
              ),
            ),
            const SizedBox(height: 20),
            if (todayShifts.isNotEmpty)
              ShiftCard(shift: todayShifts.first)
            else
              const Text(
                'No scheduled shifts',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFBFC2CE),
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 30),
            _buildActionButton(),
          ],
        ),
      ),
    );
  }
}

class ShiftCard extends StatelessWidget {
  final Map<String, dynamic> shift;
  const ShiftCard({Key? key, required this.shift}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final location = shift['locationID']?['name'] ?? 'Unknown location';
    final area = shift['locationID']?['area'] ?? '';
    final startTimeRaw = shift['startTime'] as String?;
    final endTimeRaw = shift['endTime'] as String?;
    final startTime =
        startTimeRaw != null ? DateTime.parse(startTimeRaw).toLocal() : null;
    final endTime =
        endTimeRaw != null ? DateTime.parse(endTimeRaw).toLocal() : null;

    final startFormatted =
        startTime != null ? DateFormat.jm().format(startTime) : 'N/A';
    final endFormatted =
        endTime != null ? DateFormat.jm().format(endTime) : 'N/A';
    final dateFormatted =
        startTime != null ? DateFormat.yMMMMEEEEd().format(startTime) : 'N/A';

    return Padding(
      padding: const EdgeInsets.all(1),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              dateFormatted,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$location${area.isNotEmpty ? ", $area" : ""}',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Start: $startFormatted',
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                ),
                const SizedBox(width: 24),
                Text(
                  'End: $endFormatted',
                  style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
