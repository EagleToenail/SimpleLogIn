import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:simple_login/const.dart';

class AppStore with ChangeNotifier {
  List<PeopleItem> _people = [];
  List<LocationItem> _locations = [];

  final _schedule = <String, dynamic>{
    "id": '',
    "user": {"id": '', "preferredName": ''},
    "location": {"id": '', "area": ''},
    "startTime": DateTime.now(),
    "endTime": DateTime.now(),
    "status": '',
  };

  List<PeopleItem> get people => _people;
  List<LocationItem> get locations => _locations;
  Map<String, dynamic> get schedule => _schedule;

  UserInfo? _loggedInUser;
  UserInfo? get loggedInUser => _loggedInUser;

  void setPeople(List<PeopleItem> people) {
    _people = people;
    notifyListeners();
  }

  void setLocations(List<LocationItem> locations) {
    _locations = locations;
    notifyListeners();
  }

  void updateSchedule(Map<String, dynamic> newSchedule) {
    print("✨ updated schedule: $newSchedule");
    _schedule.clear();
    _schedule.addAll(newSchedule);
    notifyListeners();
  }

  void clearSchedule() {
    _schedule.clear();
    _schedule.addAll({
      'id': '',
      'user': {'id': '', 'preferredName': ''},
      'location': {'id': '', 'area': ''},
      'startTime': DateTime.now(),
      'endTime': DateTime.now(),
    });
    notifyListeners();
  }

  void updateScheduleField(String key, dynamic value) {
    _schedule[key] = value;
    notifyListeners();
  }

  // Your one-time fetch function
  Future<void> loadPeople() async {
    try {
      // Fetch people
      final peopleRes = await http.get(Uri.parse(GET_PEOPLE_URL));

      if (peopleRes.statusCode == 200) {
        final Map<String, dynamic> resData = jsonDecode(peopleRes.body);
        List<dynamic> peopleData = resData['users'];

        List<PeopleItem> peopleList =
            peopleData.map((userData) {
              return PeopleItem(
                id: userData['_id'], // Safe default value for missing or null fields
                firstName: userData['firstName'],
                lastName: userData['lastName'],
                preferredName: userData['preferredName'],
                deputyAccessLevel: userData['deputyAccessLevel'],

                email: userData['email'], // Nullable handling
                phone: userData['phone'],
                address: userData['address'], // Nullable handling
                city: userData['city'], // Nullable handling
                country: userData['country'], // Nullable handling
                postCode: userData['postCode'],
                birthday: userData['birthday'],
                pronoun: userData['pronouns'],
                gender: userData['gender'],
                locationID: userData['locationID'],
              );
            }).toList();

        setPeople(peopleList);
        notifyListeners();
      }
    } catch (e) {
      print("🔥 Failed loading people data: $e");
    }
  }

  Future<void> loadLocations() async {
    try {
      // Fetch locations
      final locRes = await http.get(Uri.parse(GET_LOCATIONS_URL));

      if (locRes.statusCode == 200) {
        final Map<String, dynamic> resData = jsonDecode(locRes.body);
        List<dynamic> locData = resData['locations'];

        print("🎀 location list");
        print(locData);
        List<LocationItem> locList =
            locData.map((loc) {
              return LocationItem(
                id: loc['_id'], // Safe default value for missing or null fields
                name: loc['name'],
                address: loc['address'],
                area: loc['area'],
              );
            }).toList();

        setLocations(locList);

        notifyListeners();
      }
    } catch (e) {
      print("🔥 Failed loading locations data: $e");
    }
  }

  // * Set Logged User Information
  void setLoggedInUser({
    required String userID,
    required String username,
    required String preferredName,
  }) {
    _loggedInUser = UserInfo(
      userID: userID,
      username: username,
      preferredName: preferredName,
    );
    notifyListeners();
  }

  // Optionally, a method to clear user info on logout
  void clearLoggedInUser() {
    _loggedInUser = null;
    notifyListeners();
  }
}

class PeopleItem {
  // * Personal Information
  final String id;
  final String firstName;
  final String lastName;
  final String preferredName;
  final DateTime? birthday;
  final String? pronoun;
  final String? gender;

  // * Contact Information
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? country;
  final String? postCode;

  final String deputyAccessLevel;
  final String? locationID;

  PeopleItem({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.preferredName,
    required this.deputyAccessLevel,

    this.email,
    this.address,
    this.city,
    this.country,
    this.phone,
    this.postCode,
    this.birthday,
    this.pronoun,
    this.gender,
    this.locationID,
  });
}

class LocationItem {
  final String id; // Safe default value for missing or null fields
  final String name;
  final String address;
  final String area;

  LocationItem({
    required this.id,
    required this.name,
    required this.address,
    required this.area,
  });
}

class ScheduleItem {
  final String id;
  final User user;
  final Location location;
  final DateTime startTime;
  final DateTime endTime;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String type;

  ScheduleItem({
    required this.id,
    required this.user,
    required this.location,
    required this.startTime,
    required this.endTime,
    required this.type,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    print("🏭🏭🏭🏭🏭🏭🏭🏭🏭 Factory");
    print(json);

    return ScheduleItem(
      id: json['_id'],
      user: User.fromJson(json['userID']),
      location: Location.fromJson(json['locationID']),
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      type: json['type'],
      status: json['status'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': user.toJson(),
      'location': location.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'status': status,
      'type': type,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class User {
  final String id;
  final String preferredName;
  final String email;

  User({required this.id, required this.preferredName, required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      preferredName: json['preferredName'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'preferredName': preferredName, 'email': email};
  }
}

class Location {
  final String? id;
  final String? area;
  final String? name;

  Location({this.id, this.area, this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      id: json['id'] as String?,
      area: json['area'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'area': area, 'name': name};
  }
}

String formatTime(DateTime dateTime) {
  return DateFormat('h a').format(dateTime).toLowerCase();
}

class UserInfo {
  final String userID;
  final String username;
  final String preferredName;

  UserInfo({
    required this.userID,
    required this.username,
    required this.preferredName,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      userID: json['_id'] ?? '',
      username: json['email'] ?? '',
      preferredName: json['name'] ?? '',
    );
  }
}
