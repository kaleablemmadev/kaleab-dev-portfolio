import 'package:flutter/material.dart';
import 'repeat_config.dart';

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final DateTime? reminderTime;
  final bool reminderEnabled;
  final bool isCompleted;
  final TaskPriority priority;
  final String category;
  final Color color;
  final RepeatConfiguration? repeat;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.dueDate,
    this.reminderTime,
    this.reminderEnabled = false,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    this.category = 'General',
    this.color = Colors.blue,
    this.repeat,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Task copyWith({
    String? title,
    String? description,
    DateTime? dueDate,
    DateTime? reminderTime,
    bool? reminderEnabled,
    bool? isCompleted,
    TaskPriority? priority,
    String? category,
    Color? color,
    RepeatConfiguration? repeat,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      reminderTime: reminderTime ?? this.reminderTime,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      color: color ?? this.color,
      repeat: repeat ?? this.repeat,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'reminderTime': reminderTime?.millisecondsSinceEpoch,
      'reminderEnabled': reminderEnabled,
      'isCompleted': isCompleted,
      'priority': priority.index,
      'category': category,
      'color': color.value,
      'repeat': repeat?.toMap(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      dueDate: map['dueDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['dueDate']) : null,
      reminderTime: map['reminderTime'] != null ? DateTime.fromMillisecondsSinceEpoch(map['reminderTime']) : null,
      reminderEnabled: map['reminderEnabled'] ?? false,
      isCompleted: map['isCompleted'] ?? false,
      priority: TaskPriority.values[map['priority'] ?? 1],
      category: map['category'] ?? 'General',
      color: Color(map['color']),
      repeat: map['repeat'] != null ? RepeatConfiguration.fromMap(map['repeat']) : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updatedAt']),
    );
  }
}
