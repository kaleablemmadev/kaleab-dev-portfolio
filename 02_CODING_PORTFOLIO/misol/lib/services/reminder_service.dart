import 'dart:async';
import 'package:flutter/material.dart';
import '../models/event.dart';
import '../models/task.dart';
import 'notification_service.dart';
import 'event_service.dart';
import 'task_service.dart';

class ReminderService {
  static final ReminderService _instance = ReminderService._internal();
  factory ReminderService() => _instance;
  ReminderService._internal();

  final NotificationService _notification = NotificationService();
  Timer? _checkTimer;
  final Map<int, Timer> _scheduledTimers = {};

  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  Future<void> scheduleReminder(dynamic item) async {
    if (item is! Event && item is! Task) return;

    final String id = item.id;
    final String title = item.title;
    final DateTime? reminderTime = item.reminderTime;
    final bool reminderEnabled = item.reminderEnabled;

    if (!reminderEnabled || reminderTime == null) {
      cancelReminder(id);
      return;
    }

    final now = DateTime.now();
    final String channel = item is Event ? 'event_reminders' : 'task_due_dates';

    if (reminderTime.isAfter(now)) {
      await _notification.showReminder(
        id: id.hashCode,
        title: 'Reminder: $title',
        body: item is Event 
            ? 'Event starting at ${_formatDateTime(item.startTime)}'
            : 'Task due at ${_formatDateTime(item.dueDate ?? reminderTime)}',
        scheduledTime: reminderTime,
        ringtone: _notification.selectedRingtone,
        channel: channel,
      );

      final duration = reminderTime.difference(now);
      _scheduledTimers[id.hashCode]?.cancel();
      _scheduledTimers[id.hashCode] = Timer(duration, () {
        _showInAppReminder(title);
      });
      
      print('⏰ Reminder set for $title at $reminderTime');
    } else {
      // If it's very close or already passed but within a small window, show immediate
      if (now.difference(reminderTime).inMinutes < 1) {
         await _notification.showImmediateNotification(
          id: id.hashCode,
          title: 'Reminder: $title',
          body: 'Started/Due now',
          ringtone: _notification.selectedRingtone,
          channel: channel,
        );
      }
    }
  }

  String _formatDateTime(DateTime dt) {
    // Simple format for notification body
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  }

  void _showInAppReminder(String title) {
    print('🔔 In-app reminder: $title');
    if (_context != null) {
      ScaffoldMessenger.of(_context!).showSnackBar(
        SnackBar(
          content: Text('🔔 Reminder: $title'),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  void cancelReminder(String id) {
    final timer = _scheduledTimers.remove(id.hashCode);
    timer?.cancel();
    _notification.cancelNotification(id.hashCode);
    print('❌ Reminder cancelled for ID: $id');
  }

  Future<void> snoozeReminder(dynamic item, Duration snoozeDuration) async {
    if (item is! Event && item is! Task) return;

    final String id = item.id;
    final String title = item.title;
    
    // Cancel existing reminder
    cancelReminder(id);
    
    // Calculate new reminder time
    final newReminderTime = DateTime.now().add(snoozeDuration);
    
    // Update the item with new reminder time
    if (item is Event) {
      final updatedEvent = item.copyWith(reminderTime: newReminderTime);
      EventService().updateEvent(updatedEvent);
    } else if (item is Task) {
      final updatedTask = item.copyWith(reminderTime: newReminderTime);
      TaskService().updateTask(updatedTask);
    }
    
    // Schedule new reminder
    await scheduleReminder(item);
    
    print('⏰ Reminder snoozed for $title by ${snoozeDuration.inMinutes} minutes');
  }

  void stopReminderChecker() {
    _checkTimer?.cancel();
    for (final timer in _scheduledTimers.values) {
      timer.cancel();
    }
    _scheduledTimers.clear();
  }

  void dispose() {
    stopReminderChecker();
  }
}
