import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:simple_login/const.dart';
import 'package:simple_login/store.dart';

class SwapShiftPage extends StatefulWidget {
  final Map<String, dynamic> shift;
  const SwapShiftPage({super.key, required this.shift});

  @override
  State<SwapShiftPage> createState() => _SwapShiftPageState();
}

class _SwapShiftPageState extends State<SwapShiftPage> {
  final List<int> selectedShiftIndexes = [];

  List<Map<String, dynamic>> swapableShifts = [];
  List<Map<String, dynamic>> candidates = [];

  late final String userID;
  late final String userName;
  late final DateTime start;
  late final DateTime end;
  late final String shiftDate;
  late final String startTime;
  late final String endTime;
  late final Map location;
  late final String locationArea;
  late final String locationName;

  @override
  void initState() {
    super.initState();

    final loggedInUser =
        Provider.of<AppStore>(context, listen: false).loggedInUser;

    userID = loggedInUser?.userID ?? '';
    userName = loggedInUser?.preferredName ?? '';

    start = DateTime.parse(widget.shift['startTime']);
    end = DateTime.parse(widget.shift['endTime']);
    shiftDate = DateFormat('yyyy-MM-dd').format(start);

    startTime = DateFormat('hh:mm a').format(start);
    endTime = DateFormat('hh:mm a').format(end);

    final startStr = DateFormat('yyyy-MM-dd').format(start);
    final endStr = DateFormat('yyyy-MM-dd').format(end);

    location = widget.shift['location'];
    locationArea = location['area'];
    locationName = location['name'];

    final scheduleID = widget.shift['id'];

    getSwapAvailableList(startStr, endStr, userID, scheduleID);
  }

  void toggleSelection(int index) {
    setState(() {
      if (selectedShiftIndexes.contains(index)) {
        selectedShiftIndexes.remove(index);
      } else {
        selectedShiftIndexes.add(index);
      }
    });
  }

  void selectAll() {
    setState(() {
      if (selectedShiftIndexes.length == swapableShifts.length) {
        selectedShiftIndexes.clear();
      } else {
        selectedShiftIndexes.clear();
        selectedShiftIndexes.addAll(
          List.generate(swapableShifts.length, (i) => i),
        );
      }
    });
  }

  Future<void> setCandidateSchedules(scheduleID, selectedShiftIDs) async {
    final requestBody = {
      'scheduleID': scheduleID,
      "type": "shift_swap",
      'candidates':
          selectedShiftIDs.map((item) => {"scheduleID": item}).toList(),
    };

    final url = Uri.parse(SET_NOWORK_URL);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['success']) {
        final candidatesRaw = data['schedules'];

        // Ensure it's a list and convert each item to Map<String, dynamic>
        setState(() {
          candidates =
              (candidatesRaw as List<dynamic>)
                  .map((e) => Map<String, dynamic>.from(e as Map))
                  .toList();
        });

        print("🦢 ${candidates}");
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => SwapsSentPage(sentSwaps: candidates),
        //   ),
        // );
      }
    }
  }

  Future<void> getSwapAvailableList(
    startTime,
    endTime,
    userID,
    scheduleID,
  ) async {
    final requestBody = {
      'startTime': startTime,
      'endTime': endTime,
      'userID': userID,
      'scheduleID': scheduleID,
    };

    print(requestBody);

    final url = Uri.parse(GET_SWAP_AND_OFFER_LIST_URL);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        setState(() {
          swapableShifts = List<Map<String, dynamic>>.from(
            (data['swap_availables'] ?? []).map((item) {
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

          final candidatesRaw = data['schedules'];

          print("🦢 ${data}");

          // Ensure it's a list and convert each item to Map<String, dynamic>
          if (candidatesRaw is List) {
            candidates =
                candidatesRaw
                    .map((item) => Map<String, dynamic>.from(item as Map))
                    .toList();
          } else {
            candidates = [];
            debugPrint(
              'Expected a list of candidates, got: ${candidatesRaw.runtimeType}',
            );
          }
        });
      } else {
        print("💥 Error: ${data['message']}");
      }
    } else {
      print("💥 Get Swap Available Error: ${response.statusCode}");
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.shift);

    final theme = Theme.of(context);
    final ownerScheduleID = widget.shift['id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swap Shift'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, size: 28),
            onPressed: () {
              final selectedIds =
                  selectedShiftIndexes
                      .map((i) => swapableShifts[i]['id'])
                      .toList();

              setCandidateSchedules(ownerScheduleID, selectedIds);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              Card(
                elevation: 0,
                margin: const EdgeInsets.all(12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                color: Colors.white,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  title: Text(
                    "$userName",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$shiftDate",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "$startTime - $endTime",
                        style: TextStyle(color: Colors.black),
                      ),
                      Text(
                        '$locationArea, $locationName',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              ListView.builder(
                itemCount: candidates.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final swap = candidates[index];

                  final userName = swap['userID']['preferredName'];
                  final start = DateTime.parse(swap['startTime']);
                  final end = DateTime.parse(swap['endTime']);

                  final swapDate = DateFormat('yyyy-MM-dd').format(start);

                  final startStr = DateFormat('hh:mm a').format(start);
                  final endStr = DateFormat('hh:mm a').format(end);

                  final location = swap['locationID'];

                  final locationArea = location['area'];
                  final locationName = location['name'];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Icon(
                            Icons.calendar_today,
                            size: 20,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                swapDate,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "$startStr - $endStr",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                "$locationArea at $locationName",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            "PENDING",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // Filter text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'AVAILABLE SHIFTS FROM:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // SHIFT LIST - Replace ListView.builder with Column
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: List.generate(swapableShifts.length, (index) {
                    final shift = swapableShifts[index];
                    final sh_userName = shift['user']['preferredName'];
                    final sh_start = DateTime.parse(shift['startTime']);
                    final sh_end = DateTime.parse(shift['endTime']);
                    final sh_shiftDate = DateFormat(
                      'yyyy-MM-dd',
                    ).format(sh_start);

                    final sh_startStr = DateFormat('hh:mm a').format(sh_start);
                    final sh_endStr = DateFormat('hh:mm a').format(sh_end);

                    final sh_location = shift['location'];
                    final sh_locationName = sh_location['name'];
                    final sh_locationArea = sh_location['area'];

                    final isSelected = selectedShiftIndexes.contains(index);

                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      color: isSelected ? Colors.blue[50] : Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        leading: GestureDetector(
                          onTap: () => toggleSelection(index),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color:
                                    isSelected
                                        ? Colors.blue
                                        : Colors.grey[400]!,
                                width: 2,
                              ),
                              color: isSelected ? Colors.blue : Colors.white,
                            ),
                            child:
                                isSelected
                                    ? const Icon(
                                      Icons.check,
                                      color: Colors.white,
                                      size: 18,
                                    )
                                    : null,
                          ),
                        ),
                        title: Text(
                          sh_userName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sh_shiftDate,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.blue[900],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              "$sh_startStr- $sh_endStr",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "$sh_locationArea at $sh_locationName",
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                        onTap: () => toggleSelection(index),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
