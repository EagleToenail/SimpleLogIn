import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:simple_login/const.dart';
import 'package:simple_login/store.dart'; // Assuming the model is in this file

class ScheduleService {
  // Fetch schedule data for the selected week
  Future<List<ScheduleItem>> fetchData(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final requestBody = {
      'startTime': startDate.toIso8601String(),
      'endTime': endDate.toIso8601String(),
    };

    print("🥡 RequestBody: $requestBody");

    final url = Uri.parse(GET_SCHEDULE_URL);

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final scheduleMap = jsonDecode(response.body);

        List<dynamic> shiftData = scheduleMap['schedules'];

        print(shiftData);

        List<ScheduleItem> shiftList = [];
        if (shiftData.isNotEmpty) {
          shiftList =
              shiftData
                  .where((item) => item != null)
                  .map((item) => ScheduleItem.fromJson(item))
                  .toList();
        }

        print(shiftList);

        List<ScheduleItem> scheduleList = shiftList;

        return scheduleList;
      } else {
        throw Exception('Failed to load schedule data');
      }
    } catch (error) {
      print('Error fetching data: $error');
      throw Exception('Error fetching data: $error');
    }
  }

  // Get the first day of the week for the selected date
  DateTime getFirstDayOfWeek(DateTime date) {
    int currentWeekday = date.weekday;
    return date.subtract(Duration(days: currentWeekday - 1));
  }
}

List<ScheduleItem> expandScheduleItemsByDay(List<ScheduleItem> originalList) {
  List<ScheduleItem> expandedList = [];

  print(originalList);

  for (final item in originalList) {
    DateTime current = DateTime(
      item.startTime.year,
      item.startTime.month,
      item.startTime.day,
    );
    final DateTime end = DateTime(
      item.endTime.year,
      item.endTime.month,
      item.endTime.day,
    );

    while (!current.isAfter(end)) {
      final startOfDay = DateTime(
        current.year,
        current.month,
        current.day,
        0,
        0,
      );
      final endOfDay = DateTime(
        current.year,
        current.month,
        current.day,
        23,
        59,
        59,
      );

      expandedList.add(
        ScheduleItem(
          id: item.id,
          user: item.user,
          location: item.location,
          startTime: startOfDay,
          endTime: endOfDay,
          type: item.type,
          status: item.status,
          createdAt: item.createdAt,
          updatedAt: item.updatedAt,
        ),
      );

      current = current.add(Duration(days: 1));
    }
  }

  return expandedList;
}
