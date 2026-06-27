import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/event.dart';
import '../models/repeat_config.dart';
import 'reminder_service.dart';

class EventService extends ChangeNotifier {
  static final EventService _instance = EventService._internal();
  factory EventService() => _instance;
  EventService._internal() {
    _loadEvents();
  }

  final List<Event> _events = [];
  List<Event> _recentlyDeleted = [];
  final ReminderService _reminderService = ReminderService();
  static const String _eventsKey = 'events';
  bool _isLoaded = false;

  List<Event> get events => List.unmodifiable(_events);

  Future<void> _loadEvents() async {
    if (_isLoaded) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = prefs.getString(_eventsKey);
      
      if (eventsJson != null && eventsJson.isNotEmpty) {
        final List<dynamic> decoded = json.decode(eventsJson);
        _events.clear();
        for (var item in decoded) {
          _events.add(Event.fromMap(item));
        }
      } else {
        _seedEvents();
      }
      _isLoaded = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load events: $e');
      _seedEvents();
      _isLoaded = true;
    }
  }

  Future<void> _saveEvents() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final eventsJson = json.encode(_events.map((e) => e.toMap()).toList());
      await prefs.setString(_eventsKey, eventsJson);
    } catch (e) {
      debugPrint('Failed to save events: $e');
    }
  }
  void _seedEvents() {
    const uuid = Uuid();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    _events.addAll([
      Event(
        id: uuid.v4(),
        title: 'Team Meeting',
        location: 'Conference Room 4B',
        startTime: today.add(const Duration(hours: 10)),
        endTime: today.add(const Duration(hours: 11)),
        color: const Color(0xFF4A80F0),
        repeat: RepeatConfiguration(type: RepeatType.weekly),
      ),
      Event(
        id: uuid.v4(),
        title: "Morning Yoga",
        startTime: today.add(const Duration(hours: 7)),
        endTime: today.add(const Duration(hours: 7, minutes: 30)),
        color: Colors.tealAccent,
        repeat: RepeatConfiguration(type: RepeatType.daily),
      ),
    ]);
  }

  void addEvent(Event event) {
    _events.add(event);
    if (event.reminderEnabled) {
      _reminderService.scheduleReminder(event);
    }
    _saveEvents();
    notifyListeners();
  }

  void updateEvent(Event event) {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _reminderService.cancelReminder(_events[index].id);
      _events[index] = event;
      if (event.reminderEnabled) {
        _reminderService.scheduleReminder(event);
      }
      _saveEvents();
      notifyListeners();
    }
  }

  void deleteEvent(Event event) {
    _recentlyDeleted = [event];
    _reminderService.cancelReminder(event.id);
    _events.removeWhere((e) => e.id == event.id);
    _saveEvents();
    notifyListeners();
  }

  void undoDelete() {
    if (_recentlyDeleted.isNotEmpty) {
      for (var event in _recentlyDeleted) {
        _events.add(event);
        if (event.reminderEnabled) {
          _reminderService.scheduleReminder(event);
        }
      }
      _recentlyDeleted = [];
      _saveEvents();
      notifyListeners();
    }
  }

  List<Event> getEventsForDate(DateTime date) {
    final List<Event> results = [];
    final queryDate = DateTime(date.year, date.month, date.day);

    for (var event in _events) {
      if (_eventOccursOn(event, queryDate)) {
        // Return a virtual instance for that specific date
        results.add(event.copyWith(
          startTime: DateTime(queryDate.year, queryDate.month, queryDate.day, 
                              event.startTime.hour, event.startTime.minute),
          endTime: DateTime(queryDate.year, queryDate.month, queryDate.day, 
                            event.endTime.hour, event.endTime.minute),
        ));
      }
    }
    return results;
  }

  bool _eventOccursOn(Event event, DateTime date) {
    final eventStartDate = DateTime(event.startTime.year, event.startTime.month, event.startTime.day);
    if (date.isBefore(eventStartDate)) return false;

    if (event.repeat == null || event.repeat!.type == RepeatType.none) {
      return DateUtils.isSameDay(eventStartDate, date);
    }

    final repeat = event.repeat!;
    if (repeat.endDate != null && date.isAfter(repeat.endDate!)) return false;

    switch (repeat.type) {
      case RepeatType.daily:
        final difference = date.difference(eventStartDate).inDays;
        return difference % repeat.interval == 0;
      case RepeatType.weekly:
        final difference = date.difference(eventStartDate).inDays;
        if (difference % (7 * repeat.interval) != 0) return false;
        return true;
      case RepeatType.monthly:
        return date.day == eventStartDate.day;
      case RepeatType.yearly:
        return date.month == eventStartDate.month && date.day == eventStartDate.day;
      default:
        return DateUtils.isSameDay(eventStartDate, date);
    }
  }
}
