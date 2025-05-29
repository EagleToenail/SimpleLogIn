// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:simple_login/shifts/shift_detail.dart';
// import 'package:simple_login/store.dart';

// class AvailablePage extends StatelessWidget {
//   final List<Map<String, dynamic>> availableShifts;

//   const AvailablePage({Key? key, required this.availableShifts})
//     : super(key: key);

//   // Helper to format date
//   String formatDate(DateTime dt) => DateFormat('EEE, dd MMM yyyy').format(dt);

//   // Helper to format time
//   String formatTime(DateTime start, DateTime end) {
//     final timeFmt = DateFormat('h:mm a');
//     return '${timeFmt.format(start)} – ${timeFmt.format(end)}';
//   }

//   // Helper to group shifts by week
//   Map<String, List<Map<String, dynamic>>> groupByWeek(
//     List<Map<String, dynamic>> shifts,
//   ) {
//     Map<String, List<Map<String, dynamic>>> grouped = {};
//     for (var shift in shifts) {
//       DateTime start = DateTime.parse(shift['startTime']);
//       // Get the week start (Monday)
//       DateTime weekStart = start.subtract(Duration(days: start.weekday - 1));
//       String weekLabel = DateFormat("EEE, dd MMM yyyy").format(weekStart);
//       grouped.putIfAbsent(weekLabel, () => []).add(shift);
//     }
//     return grouped;
//   }

//   // Helper to sum hours in a week
//   double weeklyTotal(List<Map<String, dynamic>> weekShifts) {
//     double total = 0;
//     for (var shift in weekShifts) {
//       DateTime start = DateTime.parse(shift['startTime']);
//       DateTime end = DateTime.parse(shift['endTime']);
//       total += end.difference(start).inMinutes / 60.0;
//     }
//     return total;
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (availableShifts.isEmpty) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Available Shifts')),
//         body: const Center(
//           child: Text(
//             'No available shifts',
//             style: TextStyle(
//               color: Colors.blueGrey,
//               fontSize: 18,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ),
//         backgroundColor: const Color(0xFFF7F9FB),
//       );
//     }

//     // Sort and group shifts by week
//     List<Map<String, dynamic>> sortedShifts = List.from(availableShifts)
//       ..sort((a, b) => a['startTime'].compareTo(b['startTime']));
//     final grouped = groupByWeek(sortedShifts);

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Available Shifts'),
//         backgroundColor: Colors.white,
//         elevation: 0.5,
//       ),
//       backgroundColor: const Color(0xFFF7F9FB),
//       body: ListView(
//         children: [
//           for (var week in grouped.entries) ...[
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
//               child: Text(
//                 'Week of ${week.key}',
//                 style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF3B4861),
//                   fontSize: 15,
//                   letterSpacing: 0.2,
//                 ),
//               ),
//             ),
//             ...week.value.map((shift) {
//               final start = DateTime.parse(shift['startTime']);
//               final end = DateTime.parse(shift['endTime']);
//               final location = shift['locationID']?['name']?.trim() ?? '';
//               final area = shift['locationID']?['area'] ?? '';
//               final duration = end.difference(start);
//               final type = shift['type'] ?? '';
//               final durationStr =
//                   '${duration.inHours}h ${(duration.inMinutes % 60).toString().padLeft(2, '0')}m';

//               return Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   border: Border.all(
//                     color: const Color(0xFFD2E6F5), // changed to blue pastel
//                     width: 1.2,
//                   ),
//                 ),
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(8),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder:
//                             (context) =>
//                                 ShiftDetailPage(shift: shift, nowork: true),
//                       ),
//                     );
//                   },
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                       vertical: 8,
//                       horizontal: 14,
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   Text(
//                                     DateFormat(
//                                       'EEE, dd MMM yyyy',
//                                     ).format(start),
//                                     style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey[700],
//                                       fontSize: 14,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 7),
//                                   if (type == "shift_swap")
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 8,
//                                         vertical: 2,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: const Color(0xFFFF5B29),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: const Text(
//                                         'SWAP',
//                                         style: TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                   if (type == "shift_offer")
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(
//                                         horizontal: 8,
//                                         vertical: 2,
//                                       ),
//                                       decoration: BoxDecoration(
//                                         color: Color(0xFFFFB429),
//                                         borderRadius: BorderRadius.circular(8),
//                                       ),
//                                       child: Text(
//                                         'OFFER',
//                                         style: const TextStyle(
//                                           fontSize: 10,
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.w500,
//                                         ),
//                                       ),
//                                     ),
//                                 ],
//                               ),
//                               const SizedBox(height: 3),
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.schedule,
//                                     size: 12,
//                                     color: Color(0xFF8A94A6),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     '${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}',
//                                     style: const TextStyle(
//                                       color: Color(0xFF3B4861),
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                   const SizedBox(width: 7),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(
//                                       horizontal: 8,
//                                       vertical: 2,
//                                     ),
//                                     decoration: BoxDecoration(
//                                       color:
//                                           Colors
//                                               .blue[50], // changed to blue pastel
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: Text(
//                                       durationStr,
//                                       style: const TextStyle(
//                                         fontSize: 12,
//                                         color: Color(
//                                           0xFF2962FF,
//                                         ), // changed to blue
//                                         fontWeight: FontWeight.w500,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 5),
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.assignment_ind,
//                                     size: 12,
//                                     color: Color(0xFF8A94A6),
//                                   ),
//                                   const SizedBox(width: 4),
//                                   Text(
//                                     area,
//                                     style: const TextStyle(
//                                       color: Color(0xFF3B4861),
//                                       fontSize: 12,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               if (location.isNotEmpty) ...[
//                                 const SizedBox(height: 5),
//                                 Row(
//                                   children: [
//                                     const Icon(
//                                       Icons.location_on,
//                                       size: 12,
//                                       color: Color(0xFF8A94A6),
//                                     ),
//                                     const SizedBox(width: 4),
//                                     Expanded(
//                                       child: Text(
//                                         location,
//                                         style: const TextStyle(
//                                           color: Color(0xFF8A94A6),
//                                           fontSize: 12,
//                                           overflow: TextOverflow.ellipsis,
//                                         ),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                               ],
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               );
//             }),
//             Padding(
//               padding: const EdgeInsets.fromLTRB(20, 2, 20, 18),
//               child: Text(
//                 'Weekly total: ${weeklyTotal(week.value).toStringAsFixed(1)} hrs',
//                 style: const TextStyle(
//                   color: Color(0xFF8A94A6),
//                   fontStyle: FontStyle.italic,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:simple_login/shifts/shift_detail.dart';
import 'package:simple_login/store.dart';
import 'package:simple_login/const.dart';

class AvailablePage extends StatefulWidget {
  const AvailablePage({Key? key}) : super(key: key);

  @override
  State<AvailablePage> createState() => _AvailablePageState();
}

class _AvailablePageState extends State<AvailablePage> {
  List<Map<String, dynamic>> availableShifts = [];
  bool _loading = false;
  String _error = '';
  bool _dataChanged = false; // Track if data was refreshed

  @override
  void initState() {
    super.initState();
    _fetchAvailableShifts();
  }

  Future<bool> _fetchAvailableShifts() async {
    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      final loggedInUser =
          Provider.of<AppStore>(context, listen: false).loggedInUser;
      final userID = loggedInUser?.userID;

      final requestBody = {'userID': userID};
      final url = Uri.parse(GET_SHIFT_LIST_URL); // Adjust if a different endpoint is needed

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          // Assuming 'noworks' or a similar key contains available shifts
          availableShifts = List<Map<String, dynamic>>.from(
            (data['noworks'] ?? []).map((item) {
              final newItem = Map<String, dynamic>.from(item);
              if (newItem.containsKey('userID')) {
                newItem['user'] = newItem['userID'];
                newItem.remove('userID');
              }
              if (newItem.containsKey('locationID')) {
                newItem['location'] = newItem['locationID'];
                newItem.remove('locationID');
              }
              return newItem;
            }),
          );
          _dataChanged = true; // Mark that data has been refreshed
        });
        print("✅ Available shifts fetch success");
        return true;
      } else {
        setState(() {
          _error = 'Failed to load available shifts: ${response.statusCode}';
        });
        print('❌ Error: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching available shifts: $e';
      });
      print('❌ Error: $e');
      return false;
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  // Helper to format date
  String formatDate(DateTime dt) => DateFormat('EEE, dd MMM yyyy').format(dt);

  // Helper to format time
  String formatTime(DateTime start, DateTime end) {
    final timeFmt = DateFormat('h:mm a');
    return '${timeFmt.format(start)} – ${timeFmt.format(end)}';
  }

  // Helper to group shifts by week
  Map<String, List<Map<String, dynamic>>> groupByWeek(
      List<Map<String, dynamic>> shifts) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var shift in shifts) {
      DateTime start = DateTime.parse(shift['startTime']);
      // Get the week start (Monday)
      DateTime weekStart = start.subtract(Duration(days: start.weekday - 1));
      String weekLabel = DateFormat("EEE, dd MMM yyyy").format(weekStart);
      grouped.putIfAbsent(weekLabel, () => []).add(shift);
    }
    return grouped;
  }

  // Helper to sum hours in a week
  double weeklyTotal(List<Map<String, dynamic>> weekShifts) {
    double total = 0;
    for (var shift in weekShifts) {
      DateTime start = DateTime.parse(shift['startTime']);
      DateTime end = DateTime.parse(shift['endTime']);
      total += end.difference(start).inMinutes / 60.0;
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Available Shifts'),
          backgroundColor: Colors.white,
          elevation: 0.5,
        ),
        body: const Center(child: CircularProgressIndicator()),
        backgroundColor: const Color(0xFFF7F9FB),
      );
    }

    if (_error.isNotEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Available Shifts'),
          backgroundColor: Colors.white,
          elevation: 0.5,
        ),
        body: Center(child: Text(_error)),
        backgroundColor: const Color(0xFFF7F9FB),
      );
    }

    if (availableShifts.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Available Shifts'),
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context, _dataChanged); // Return whether data changed
            },
          ),
        ),
        body: const Center(
          child: Text(
            'No available shifts',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        backgroundColor: const Color(0xFFF7F9FB),
      );
    }

    // Sort and group shifts by week
    List<Map<String, dynamic>> sortedShifts = List.from(availableShifts)
      ..sort((a, b) => a['startTime'].compareTo(b['startTime']));
    final grouped = groupByWeek(sortedShifts);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Shifts'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _dataChanged); // Return whether data changed
          },
        ),
      ),
      backgroundColor: const Color(0xFFF7F9FB),
      body: RefreshIndicator(
        onRefresh: _fetchAvailableShifts,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            for (var week in grouped.entries) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Text(
                  'Week of ${week.key}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3B4861),
                    fontSize: 15,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              ...week.value.map((shift) {
                final start = DateTime.parse(shift['startTime']);
                final end = DateTime.parse(shift['endTime']);
                final location = shift['locationID']?['name']?.trim() ?? '';
                final area = shift['locationID']?['area'] ?? '';
                final duration = end.difference(start);
                final type = shift['type'] ?? '';
                final durationStr =
                    '${duration.inHours}h ${(duration.inMinutes % 60).toString().padLeft(2, '0')}m';

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFFD2E6F5),
                      width: 1.2,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ShiftDetailPage(shift: shift, nowork: true),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 14,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      DateFormat('EEE, dd MMM yyyy').format(start),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey[700],
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    if (type == "shift_swap")
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFF5B29),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          'SWAP',
                                          style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    if (type == "shift_offer")
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Color(0xFFFFB429),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'OFFER',
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.schedule,
                                      size: 12,
                                      color: Color(0xFF8A94A6),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${DateFormat('h:mm a').format(start)} - ${DateFormat('h:mm a').format(end)}',
                                      style: const TextStyle(
                                        color: Color(0xFF3B4861),
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 7),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue[50],
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        durationStr,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF2962FF),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.assignment_ind,
                                      size: 12,
                                      color: Color(0xFF8A94A6),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      area,
                                      style: const TextStyle(
                                        color: Color(0xFF3B4861),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                                if (location.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 12,
                                        color: Color(0xFF8A94A6),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          location,
                                          style: const TextStyle(
                                            color: Color(0xFF8A94A6),
                                            fontSize: 12,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 2, 20, 18),
                child: Text(
                  'Weekly total: ${weeklyTotal(week.value).toStringAsFixed(1)} hrs',
                  style: const TextStyle(
                    color: Color(0xFF8A94A6),
                    fontStyle: FontStyle.italic,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
