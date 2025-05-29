import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:simple_login/main.dart';
import 'package:simple_login/shifts/shift_detail.dart';
import 'package:simple_login/schedule_service.dart';
import 'package:simple_login/store.dart';

class SchedulesPage extends StatefulWidget {
  @override
  _SchedulesPageState createState() => _SchedulesPageState();
}

class _SchedulesPageState extends State<SchedulesPage> {
  DateTimeRange? selectedDateRange;
  List<ScheduleItem> scheduleItems = [];
  final ScheduleService _scheduleService = ScheduleService();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    selectedDateRange = DateTimeRange(start: startOfWeek, end: endOfWeek);
    fetchData();
  }

  void reloadPage() {
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      if (selectedDateRange == null) return;

      final List<ScheduleItem> scheduleList = await _scheduleService.fetchData(
        selectedDateRange!.start,
        selectedDateRange!.end,
      );

      print("🥼 ScheduleList: ${scheduleList.length}");

      setState(() {
        scheduleItems = scheduleList.toList();
      });
    } catch (error) {
      print('💥 Error schedule fetching data: $error');
    }
  }

  String formatTime(DateTime time) {
    return DateFormat('h:mm a').format(time);
  }

  String formatDate(DateTime time) {
    return DateFormat('yyyy-MM-dd').format(time);
  }

  Widget scheduleListTile(ScheduleItem item) {
    String initials =
        item.user.preferredName
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase();

    return InkWell(
      onTap: () async {
        myAppKey.currentState?.updateSchedule(item.toJson());
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    ShiftDetailPage(shift: item.toJson(), nowork: false),
          ),
        );
        if (result == 'reload') {
          reloadPage();
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(
                'https://www.w3schools.com/howto/img_avatar.png',
              ),
              backgroundColor: Colors.grey,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.user.preferredName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${formatDate(item.startTime)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                  Text(
                    '${formatTime(item.startTime)} - ${formatTime(item.endTime)} at ${item.location.area}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  Text(
                    "${item.location.name}",
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Future<void> pickDateRange() async {
    DateTimeRange? tempRange = selectedDateRange;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: SizedBox(
            width: 320,
            height: 400,
            child: SfDateRangePicker(
              view: DateRangePickerView.month,
              selectionMode: DateRangePickerSelectionMode.range,
              initialSelectedRange: PickerDateRange(
                selectedDateRange?.start,
                selectedDateRange?.end,
              ),
              initialDisplayDate:
                  selectedDateRange?.start, // 👈 shows current week
              showActionButtons: true,
              onSelectionChanged: (args) {
                if (args.value is PickerDateRange) {
                  final range = args.value as PickerDateRange;
                  if (range.startDate != null && range.endDate != null) {
                    tempRange = DateTimeRange(
                      start: range.startDate!,
                      end: range.endDate!,
                    );
                  }
                }
              },
              onSubmit: (value) {
                Navigator.pop(context);
              },
              onCancel: () {
                tempRange = null;
                Navigator.pop(context);
              },
            ),
          ),
        );
      },
    );

    if (tempRange != null) {
      setState(() {
        selectedDateRange = tempRange;
      });
      fetchData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateRangeText =
        selectedDateRange != null
            ? '${DateFormat('MMM d, yyyy').format(selectedDateRange!.start)} - ${DateFormat('MMM d, yyyy').format(selectedDateRange!.end)}'
            : 'Select Date Range';

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact date range picker box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: pickDateRange,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.deepPurple.shade100,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_today,
                            size: 18,
                            color: Colors.lightBlue,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dateRangeText,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Colors.lightBlue,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              "Scheduled",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchData,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: scheduleItems.length,
                itemBuilder: (context, index) {
                  return scheduleListTile(scheduleItems[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
