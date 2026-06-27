import 'package:flutter/material.dart';
import 'repeat_config.dart';

class Event {
  final String id;
  final String title;
  final String description;
  final DateTime startTime;
  final DateTime endTime;
  final Color color; // Ensure color is stored for each event
  final DateTime? reminderTime;
  final bool reminderEnabled;
  final RepeatConfiguration? repeat;
  final String? location;
  final List<String> attendees;
  final DateTime createdAt;
  final DateTime updatedAt;

  Event({
    required this.id,
    required this.title,
    this.description = '',
    required this.startTime,
    required this.endTime,
    required this.color, // Make color a required parameter
    this.reminderTime,
    this.reminderEnabled = false,
    this.repeat,
    this.location,
    this.attendees = const [],
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Event copyWith({
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    Color? color,
    DateTime? reminderTime,
    bool? reminderEnabled,
    RepeatConfiguration? repeat,
    String? location,
    List<String>? attendees,
    DateTime? updatedAt,
  }) {
    return Event(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      color: color ?? this.color,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      repeat: repeat ?? this.repeat,
      location: location ?? this.location,
      attendees: attendees ?? this.attendees,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // Helper for UI components that still expect a 'date'
  DateTime get date => DateTime(startTime.year, startTime.month, startTime.day);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime.millisecondsSinceEpoch,
      'color': color.value,
      'reminderTime': reminderTime?.millisecondsSinceEpoch,
      'reminderEnabled': reminderEnabled,
      'repeat': repeat?.toMap(),
      'location': location,
      'attendees': attendees,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime']),
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime']),
      color: Color(map['color']),
      reminderTime: map['reminderTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['reminderTime']) : null,
      reminderEnabled: map['reminderEnabled'] ?? false,
      repeat: map['repeat'] != null ? RepeatConfiguration.fromMap(map['repeat']) : null,
      location: map['location'],
      attendees: map['attendees'] != null ? List<String>.from(map['attendees']) : [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
}
