import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_login/store.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:simple_login/const.dart';

class OfferShiftPage extends StatefulWidget {
  final Map<String, dynamic> shift;

  const OfferShiftPage({super.key, required this.shift});

  @override
  State<OfferShiftPage> createState() => _OfferShiftPageState();
}

class _OfferShiftPageState extends State<OfferShiftPage> {
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

  void toggleSelection(int index) async {
    setState(() {
      if (selectedShiftIndexes.contains(index)) {
        selectedShiftIndexes.remove(index);
      } else {
        selectedShiftIndexes.add(index);
      }
    });
  }

  void selectAll() async {
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

    final url = Uri.parse(GET_SWAP_AND_OFFER_LIST_URL);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        swapableShifts = List<Map<String, dynamic>>.from(
          (data['swap_availables'] ?? []).map((item) {
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

        print(swapableShifts);

        final Map<dynamic, Map<String, dynamic>> lastUserItems = {};
        for (var item in swapableShifts) {
          final user = item['user'];
          final userId = user['_id'];
          lastUserItems[userId] = item;
        }

        setState(() {
          swapableShifts = lastUserItems.values.toList();

          final candidatesRaw = data['candidates'];
          if (candidatesRaw is List) {
            candidates =
                candidatesRaw.map((item) {
                  final map = Map<String, dynamic>.from(item as Map);

                  // Rename keys: userID -> user, locationID -> location
                  if (map.containsKey('userID')) {
                    map['user'] = map['userID'];
                    map.remove('userID');
                  }
                  if (map.containsKey('locationID')) {
                    map['location'] = map['locationID'];
                    map.remove('locationID');
                  }

                  return map;
                }).toList();
          } else {
            candidates = [];
          }
        });
      }
    }
  }

  Future<void> setCandidateUsers(scheduleID, selectedShiftIDs) async {
    final requestBody = {
      'scheduleID': scheduleID,
      'type': "shift_offer",
      'candidates': selectedShiftIDs.map((item) => {"user": item}).toList(),
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
        final candidatesRaw = data['candidates'];

        // Ensure it's a list and convert each item to Map<String, dynamic>
        setState(() {
          final candidatesRaw = data['candidates'] as List<dynamic>;

          candidates =
              candidatesRaw.map((item) {
                final map = Map<String, dynamic>.from(item as Map);

                return {'user': map, 'agreed': map['agreed'] ?? false};
              }).toList();
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ownerScheduleID = widget.shift['id'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offer Shift'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              print("🎞🎞🎞🎞🎞🎞🎞🎞🎞");
              final selectedIds =
                  selectedShiftIndexes
                      .map((i) => swapableShifts[i]['user']['id'])
                      .toList();

              setCandidateUsers(ownerScheduleID, selectedIds);
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$shiftDate",
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        "$startTime - $endTime",
                        style: const TextStyle(color: Colors.black),
                      ),
                      Text(
                        '$locationArea, $locationName',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),

              // --- Offers Sent List ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'OFFERS SENT:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Use a fixed height for the sent offers list
              SizedBox(
                height: 120,
                child: OfferSentList(candidates: candidates),
              ),

              const SizedBox(height: 20),

              // --- Available Employees List ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'RECOMMENDED EMPLOYEES:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  children: List.generate(swapableShifts.length, (index) {
                    final shift = swapableShifts[index];
                    final sh_userName = shift['user']['preferredName'];
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
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Custom circular checkbox
                            GestureDetector(
                              onTap: () => toggleSelection(index),
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color:
                                      isSelected ? Colors.blue : Colors.white,
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? Colors.blue
                                            : Colors.grey[400]!,
                                    width: 2,
                                  ),
                                ),
                                child:
                                    isSelected
                                        ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // User avatar (smaller)
                            CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(
                                'https://www.w3schools.com/howto/img_avatar.png',
                              ),
                              backgroundColor: Colors.grey[300],
                            ),
                          ],
                        ),
                        title: Text(
                          sh_userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
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

// --- OfferSentList Widget (no Scaffold, just the list) ---
class OfferSentList extends StatelessWidget {
  final List<Map<String, dynamic>> candidates;
  const OfferSentList({Key? key, required this.candidates}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (candidates.isEmpty) {
      return const Center(child: Text("No offers sent yet."));
    }
    return ListView.builder(
      itemCount: candidates.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final candidate = candidates[index];
        final user = candidate['user'] ?? {};
        final preferredName = user['preferredName'] ?? 'Unknown';
        final email = user['email'] ?? '';
        final agreed = candidate['agreed'] ?? false;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  'https://www.w3schools.com/howto/img_avatar.png',
                ),
                backgroundColor: Colors.grey[300],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      preferredName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              Icon(
                agreed ? Icons.check_circle : Icons.hourglass_empty,
                color: agreed ? Colors.green : Colors.orange,
                size: 24,
              ),
            ],
          ),
        );
      },
    );
  }
}
