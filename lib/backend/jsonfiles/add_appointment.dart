import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

class Appointment {
  final int id;
  final String eventName;
  final DateTime from;
  final DateTime to;
  final int background; // Color represented as int
  final bool isAllDay;

  Appointment({
    required this.id,
    required this.eventName,
    required this.from,
    required this.to,
    required this.background,
    required this.isAllDay,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventName': eventName,
      'from': from.toIso8601String(),
      'to': to.toIso8601String(),
      'background': background,
      'isAllDay': isAllDay,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id'],
      eventName: json['eventName'],
      from: DateTime.parse(json['from']),
      to: DateTime.parse(json['to']),
      background: json['background'],
      isAllDay: json['isAllDay'],
    );
  }
}

class AppointmentManager {
  late List<Appointment> _appointments;

  AppointmentManager() {
    _appointments = [];
  }

  List<Appointment> get appointments => _appointments;

  Future<void> loadAppointmentsFromJson(String path) async {
    try {
      final jsonString = await rootBundle.loadString(path);
      final jsonData = json.decode(jsonString) as List;
      _appointments =
          jsonData.map((item) => Appointment.fromJson(item)).toList();
    } catch (e) {
      print("Error loading appointments: $e");
      _appointments = [];
    }
  }

  Future<void> saveAppointmentsToJson(String path) async {
    final List<Map<String, dynamic>> jsonData =
        _appointments.map((appointment) => appointment.toJson()).toList();

    final jsonString = json.encode(jsonData);
    try {
      final file = File(path);
      await file.writeAsString(jsonString);
    } catch (e) {
      print("Error saving appointments: $e");
    }
  }
}
