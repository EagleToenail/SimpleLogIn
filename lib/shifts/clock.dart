import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:simple_login/const.dart';
import 'package:simple_login/store.dart';
import 'package:simple_login/toast.dart';

import 'package:geolocator/geolocator.dart';

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

  Position? currentLocation;
  bool isLoading = false;
  bool _isFirstLocationCall = true;

  List<Map<String, dynamic>> todayShifts = [];
  ShiftStatus _shiftStatus = ShiftStatus.notStarted;

  @override
  void initState() {
    super.initState();
    _fetchServerTime();
    _getTodayShift();
    // Fetch location asynchronously with loading state
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isLoading = true;
      });
      bool success = await getCurrentLocation();
      if (!success) {
        // Prompt user to retry if initial attempt fails
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: const Color.fromARGB(255, 136, 57, 57),
              content: Row(
                children: [
                  const Text('Could not obtain location. '),
                  TextButton(
                    onPressed: () async {
                      setState(() {
                        isLoading = true;
                      });
                      await getCurrentLocation();
                      setState(() {
                        isLoading = false;
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      setState(() {
        isLoading = false;
        _isFirstLocationCall = false;
      });
    });
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
          _serverTime = serverTime.toUtc();
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
          final publishedShifts = today_shifts.where((shift) => shift['published'] == true && shift['approved'] == false && shift['status'] != "missed").toList();
          setState(() {
            todayShifts =
                publishedShifts
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

  Future<bool> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          Toast.show(context, 'Please enable location services.', type: ToastType.warn);
        }
        return false;
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            Toast.show(context, 'Location permission denied.', type: ToastType.warn);
          }
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
           Toast.show(context, 'Location permission permanently denied. Please enable it in settings.', type: ToastType.warn);
        }
        return false;
      }

      // Use a position stream to wait for a fresh position
      Position? freshPosition;
      final maxWaitTime = _isFirstLocationCall
          ? Duration(seconds: 45) // 45 seconds for first call
          : Duration(seconds: 15); // 15 seconds for subsequent calls
      try {
        final positionStream = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 0, // Receive all updates
          ),
        ).timeout(
          maxWaitTime,
          onTimeout: (_) =>
              throw TimeoutException('Location acquisition timed out'),
        );

        await for (Position position in positionStream) {
          print("Position update: ${position.latitude}, ${position.longitude}, "
              "Accuracy: ${position.accuracy} meters, Timestamp: ${position.timestamp}");
          freshPosition = position;
          break; // Take the first position from the stream
        }
      } catch (e) {
        if (mounted) {
          Toast.show(context, 'Failed to obtain location: $e', type: ToastType.warn);
        }
        print('Location error: $e');
        return false;
      }

      if (freshPosition == null) {
        if (mounted) {
          Toast.show(context, 'Could not obtain a location.', type: ToastType.warn);
        }
        return false;
      }

      setState(() {
        currentLocation = freshPosition;
      });
      print(
          "Location obtained: ${currentLocation!.latitude}, ${currentLocation!.longitude}, "
          "Accuracy: ${currentLocation!.accuracy} meters, Timestamp: ${currentLocation!.timestamp}");
      return true;
    } catch (e) {
      if (mounted) {
        Toast.show(context, 'Location Error: $e', type: ToastType.warn);
      }
      print("Error obtaining location: $e");
      return false;
    }
  }

  Future<void> _setShiftStatus(String type, int index) async {
    try {

      print('Index: $index, Type: ${index.runtimeType}');
      final scheduleID = todayShifts[index]['id'];

      bool locationSuccess = await getCurrentLocation();
      if (!locationSuccess || currentLocation == null) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final requestBody = {"scheduleID": scheduleID, "type": type, "location": currentLocation};

      final url = Uri.parse(CLOCK_SCHEDULE_URL);

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            todayShifts[index] = data['schedule']; // Update the specific shift with the new data
          });
          Toast.show(context, 'Success', type: ToastType.success);
        } else {
          print("💥 Clock InOut Error: ${data['message'] ?? 'Unknown error'}");
          Toast.show(context, data['message'], type: ToastType.warn);
        }
      } else {
        print("💥 Clock InOut Error: ${response.statusCode}");
      }
    } catch (err) {
      print("💥 Shift ClockInOut Error: $err");
    }
  }

  void _startShift(int index) {
    _setShiftStatus("clockIn", index);
  }

  void _startBreak(int index) {
    _setShiftStatus("breakClockIn", index);
  }

  void _stopBreak(int index) {
    _setShiftStatus("breakClockOut", index);
  }

  void _stopShift(int index) {
    _setShiftStatus("clockOut", index);
  }

Widget _buildActionButtonForShift({required int index, required ShiftStatus shiftStatus}) {
    final buttonPadding = const EdgeInsets.symmetric(
      vertical: 6,
      horizontal: 10,
    );
    final borderRadius = BorderRadius.circular(16);

    Widget currentActionButton;
    Widget? secondaryButton;

    switch (shiftStatus) {
      case ShiftStatus.notStarted:
        currentActionButton = ElevatedButton.icon(
        onPressed: () {
          print('Start Shift pressed with index: $index, Type: ${index.runtimeType}');
          _startShift(index);
        },
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
            alignment: Alignment.center,
          ),
        );
        break;

      case ShiftStatus.shiftStarted:
        currentActionButton = ElevatedButton.icon(
          onPressed: () => _startBreak(index),
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
        secondaryButton = ElevatedButton.icon(
          onPressed: () => _stopShift(index),
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
        break;

      case ShiftStatus.breakStarted:
        currentActionButton = ElevatedButton.icon(
        onPressed: () {
          print('Stop Shift pressed with index: $index, Type: ${index.runtimeType}');
          _stopBreak(index);
        },
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
        secondaryButton = ElevatedButton.icon(
          onPressed: () => _stopShift(index),
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
        break;

      case ShiftStatus.breakStopped:
        currentActionButton = ElevatedButton.icon(
          onPressed: () => _stopShift(index),
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
            backgroundColor: Colors.white,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 3,
            shadowColor: Colors.grey.withOpacity(0.15),
            side: const BorderSide(color: Color(0xFF2D7C3F), width: 1.5),
            foregroundColor: const Color(0xFF2D7C3F),
            alignment: Alignment.center,
          ),
        );
        break;

      case ShiftStatus.shiftStopped:
        currentActionButton = ElevatedButton.icon(
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
            backgroundColor: Colors.white,
            padding: buttonPadding,
            shape: RoundedRectangleBorder(borderRadius: borderRadius),
            elevation: 3,
            shadowColor: Colors.grey.withOpacity(0.15),
            side: const BorderSide(color: Color(0xFF2D7C3F), width: 1.5),
            foregroundColor: const Color(0xFF2D7C3F),
            alignment: Alignment.center,
          ),
        );
        secondaryButton = null;
        break;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: currentActionButton),
        if (secondaryButton != null) ...[
          const SizedBox(width: 8),
          Expanded(child: secondaryButton),
        ],
      ],
    );
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
              Column(
                children: todayShifts.asMap().entries.map<Widget>((entry) {
                  final index = entry.key;
                  final shift = entry.value;
                  return Column(
                    children: [
                      ShiftCard(shift: shift),
                      const SizedBox(height: 10),
                      _buildActionButtonForShift(
                        index: index,
                        shiftStatus: getShiftStatus(shift),
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                }).toList(),
              )
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
    final next = (shift['next'] as bool?) ?? false;
    final startTime =
        startTimeRaw != null ? DateTime.parse(startTimeRaw).toUtc() : null;
    final endTime =
        endTimeRaw != null ? DateTime.parse(endTimeRaw).toUtc() : null;

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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'End: $endFormatted',
                      style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                    ),
                    if (next) ...[
                      const SizedBox(width: 4),
                      const Text(
                        '*',
                        style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}