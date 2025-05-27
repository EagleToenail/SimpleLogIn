import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simple_login/store.dart';
import 'package:simple_login/shifts/offer_shift.dart';
import 'package:simple_login/shifts/swap_shift.dart';

class ShiftDetailPage extends StatelessWidget {
  final Map<String, dynamic> shift;
  final bool nowork;

  const ShiftDetailPage({Key? key, required this.shift, required this.nowork})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final loggedInUser =
        Provider.of<AppStore>(context, listen: false).loggedInUser;
    final userID = loggedInUser?.userID;

    final start = DateTime.parse(shift['startTime']);
    final end = DateTime.parse(shift['endTime']);
    final shiftUserID = shift['user']?['id'] ?? 'open_id';
    final shiftUserName = shift['user']?['preferredName'] ?? 'Open Shift';
    final shiftUserEmail = shift['user']?['email'] ?? '';
    final location = shift['location']?['name'] ?? '';
    final area = shift['location']?['area'] ?? '';
    final type = shift['type'];
    final totalHours = end.difference(start).inMinutes ~/ 60;
    final totalMinutes = end.difference(start).inMinutes % 60;
    final totalTime =
        '${totalHours.toString().padLeft(2, '0')}:${totalMinutes.toString().padLeft(2, '0')}';

    print(shift);
    print("🗒 userID: $userID");
    print("🗒 shiftUserID: $shiftUserID");
    print("🗒 shiftType: $type");

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shift Details'),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: const BackButton(),
      ),
      backgroundColor: const Color(0xFFF7F9FB),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Date
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      DateFormat('EEE, d MMM yyyy').format(start),
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF3B4861),
                      ),
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
                        borderRadius: BorderRadius.circular(8),
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
                        borderRadius: BorderRadius.circular(8),
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

              // Userinfo
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 18,
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          'https://www.w3schools.com/howto/img_avatar.png',
                        ),
                        backgroundColor: Colors.grey,
                      ),
                      const SizedBox(width: 16),
                      // Name and Email
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shiftUserName, // Replace with your variable e.g. userName
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF3B4861),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              shiftUserEmail, // Replace with your variable e.g. userEmail
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Location & Area Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 18,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              location,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (area.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Text(
                              area,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF3B4861),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Start/Finish Time Card
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Start Time',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('h:mm a').format(start),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF3B4861),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Finish Time',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('h:mm a').format(end),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF3B4861),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),

              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 18,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Breaks',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Icon(
                            Icons.timer_outlined,
                            color: Colors.grey,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Rest (total 0min)',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: const [
                          Icon(
                            Icons.lunch_dining_outlined,
                            color: Colors.grey,
                            size: 16,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Meal (total 1hr)',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Total Time Badge
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Total Time',
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      totalTime, // e.g. '07:00'
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 32,
                        color: Colors.black,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Button to fit content width
                    ShiftActionButtons(
                      nowork: nowork,
                      userID: userID,
                      shiftUserID: shiftUserID,
                      shift: shift,
                      parentContext: context,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ShiftActionButtons extends StatelessWidget {
  final bool nowork;
  final String? userID;
  final String shiftUserID;
  final dynamic shift; // Replace with your actual Shift type
  final BuildContext parentContext;

  const ShiftActionButtons({
    Key? key,
    required this.nowork,
    this.userID,
    required this.shiftUserID,
    required this.shift,
    required this.parentContext,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final type = shift['type'];

    if (nowork) {
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 750),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  // Accept logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Green
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                child: const Text('ACCEPT'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  // Decline logic here
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF44336), // Red
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 12,
                  ),
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
                child: const Text('DECLINE'),
              ),
            ],
          ),
        ),
      );
    }

    if (userID == shiftUserID) {
      if (type == "shift") {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4174E2),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            onPressed: () {
              showModalBottomSheet(
                context: parentContext,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                builder:
                    (context) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _ActionSheetButton(
                            label: 'Swap Shift',
                            color: const Color(0xFF4174E2),
                            onTap:
                                () => Navigator.push(
                                  parentContext,
                                  MaterialPageRoute(
                                    builder: (_) => SwapShiftPage(shift: shift),
                                  ),
                                ),
                          ),
                          _ActionSheetButton(
                            label: 'Offer Shift',
                            color: const Color(0xFF4174E2),
                            onTap:
                                () => Navigator.push(
                                  parentContext,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => OfferShiftPage(shift: shift),
                                  ),
                                ),
                          ),
                          _ActionSheetButton(
                            label: 'Cancel',
                            color: const Color(0xFF4174E2),
                            isCancel: true,
                            onTap: () => Navigator.pop(parentContext),
                          ),
                        ],
                      ),
                    ),
              );
            },
            child: const Text("Can't Work"),
          ),
        );
      }

      if (type == "shift_offer") {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFB429),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            onPressed: () {
              Navigator.push(
                parentContext,
                MaterialPageRoute(builder: (_) => OfferShiftPage(shift: shift)),
              );
            },
            child: const Text("Shift Offered"),
          ),
        );
      }

      if (type == "shift_swap") {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 750),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5B29),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            onPressed: () {
              Navigator.push(
                parentContext,
                MaterialPageRoute(builder: (_) => SwapShiftPage(shift: shift)),
              );
            },
            child: const Text("Shift Swapped"),
          ),
        );
      }
    }

    return Container();
  }
}

class _ActionSheetButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isCancel;

  const _ActionSheetButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.isCancel = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin:
          isCancel
              ? const EdgeInsets.only(top: 6, bottom: 8)
              : const EdgeInsets.only(top: 0),
      width: double.infinity,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 18),
          textStyle: TextStyle(
            fontWeight: isCancel ? FontWeight.bold : FontWeight.normal,
            fontSize: 18,
          ),
        ),
        onPressed: onTap,
        child: Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: isCancel ? FontWeight.bold : FontWeight.normal,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}
