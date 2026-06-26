import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';
import '../models/repeat_config.dart';
import 'reminder_service.dart';

class TaskService extends ChangeNotifier {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal() {
    _loadTasks();
  }

  final List<Task> _tasks = [];
  final ReminderService _reminderService = ReminderService();
  static const String _tasksKey = 'tasks';
  bool _isLoaded = false;

  List<Task> get tasks => List.unmodifiable(_tasks);

  Future<void> _loadTasks() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = prefs.getString(_tasksKey);
      
      if (tasksJson != null && tasksJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(tasksJson);
        _tasks.clear();
        for (var item in decoded) {
          _tasks.add(Task.fromMap(item));
        }
      } else {
        _seedTasks();
      }
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load tasks: $e');
      _seedTasks();
      _isLoaded = true;
    }
  }

  Future<void> _saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tasksJson = json.encode(_tasks.map((t) => t.toMap()).toList());
      await prefs.setString(_tasksKey, tasksJson);
    } catch (e) {
      debugPrint('Failed to save tasks: $e');
    }
  }
  void _seedTasks() {
    const uuid = Uuid();
    final now = DateTime.now();
    _tasks.addAll([
      Task(
        id: uuid.v4(),
        title: 'Review Project Roadmap',
        priority: TaskPriority.high,
        isCompleted: false,
        color: Colors.redAccent,
        dueDate: DateTime(now.year, now.month, now.day, 14, 0),
      ),
      Task(
        id: uuid.v4(),
        title: 'Call Marketing Team',
        priority: TaskPriority.medium,
        isCompleted: true,
        color: Colors.blueAccent,
      ),
      Task(
        id: uuid.v4(),
        title: 'Buy Groceries',
        priority: TaskPriority.low,
        isCompleted: false,
        color: Colors.tealAccent,
      ),
    ]);
  }

  void addTask(Task task) {
    _tasks.add(task);
    if (task.reminderEnabled) {
      _reminderService.scheduleReminder(task);
    }
    _saveTasks();
    notifyListeners();
  }

  void updateTask(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _reminderService.cancelReminder(_tasks[index].id);
      _tasks[index] = task;
      if (task.reminderEnabled) {
        _reminderService.scheduleReminder(task);
      }
      _saveTasks();
      notifyListeners();
    }
  }

  void toggleTaskCompletion(String id) {
    final index = _tasks.indexWhere((t) => t.id == id);
    if (index != -1) {
      final task = _tasks[index];
      final newCompletedStatus = !task.isCompleted;
      _tasks[index] = task.copyWith(isCompleted: newCompletedStatus);
      
      // If repeating task is completed, we might want to generate the next instance
      // "Repeating tasks auto-generate new instances"
      if (newCompletedStatus && task.repeat != null && task.repeat!.type != RepeatType.none) {
        _generateNextTaskInstance(task);
      }
      
      _saveTasks();
      notifyListeners();
    }
  }

  void _generateNextTaskInstance(Task task) {
    if (task.dueDate == null) return;
    
    DateTime nextDueDate;
    final repeat = task.repeat!;
    
    switch (repeat.type) {
      case RepeatType.daily:
        nextDueDate = task.dueDate!.add(Duration(days: repeat.interval));
        break;
      case RepeatType.weekly:
        nextDueDate = task.dueDate!.add(Duration(days: 7 * repeat.interval));
        break;
      case RepeatType.monthly:
        nextDueDate = DateTime(task.dueDate!.year, task.dueDate!.month + repeat.interval, task.dueDate!.day, task.dueDate!.hour, task.dueDate!.minute);
        break;
      case RepeatType.yearly:
        nextDueDate = DateTime(task.dueDate!.year + repeat.interval, task.dueDate!.month, task.dueDate!.day, task.dueDate!.hour, task.dueDate!.minute);
        break;
      default:
        return;
    }

    if (repeat.endDate != null && nextDueDate.isAfter(repeat.endDate!)) return;
    if (repeat.occurrences != null) {
      // This would require tracking occurrences, for simplicity we'll skip for now or use a counter
    }

    final nextTask = Task(
      id: const Uuid().v4(),
      title: task.title,
      description: task.description,
      dueDate: nextDueDate,
      isCompleted: false,
      priority: task.priority,
      category: task.category,
      color: task.color,
      repeat: task.repeat,
      createdAt: DateTime.now(),
      reminderTime: task.reminderEnabled && task.reminderTime != null 
          ? nextDueDate.subtract(task.dueDate!.difference(task.reminderTime!))
          : null,
    );
    
    _tasks.add(nextTask);
    if (nextTask.reminderEnabled) {
      _reminderService.scheduleReminder(nextTask);
    }
    _saveTasks();
  }

  void deleteTask(String id) {
    _reminderService.cancelReminder(id);
    _tasks.removeWhere((t) => t.id == id);
    _saveTasks();
    notifyListeners();
  }

  List<Task> getTasksForDate(DateTime date) {
    return _tasks.where((t) {
      if (t.dueDate == null) return false;
      return DateUtils.isSameDay(t.dueDate!, date);
    }).toList();
  }
}
