import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/event.dart';
import '../services/storage_service.dart';
import '../core/notification_service.dart';

// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('storageServiceProvider must be overridden');
});

// Provider for all events
final allEventsProvider = NotifierProvider<AllEventsNotifier, List<Event>>(AllEventsNotifier.new);

// Provider for the selected date in calendar
final selectedDateProvider = NotifierProvider<SelectedDateNotifier, DateTime>(SelectedDateNotifier.new);

class SelectedDateNotifier extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now();

  void updateDate(DateTime date) {
    state = date;
  }
}

// Provider for events on a specific date (today by default, or selected date)
final filteredEventsProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(allEventsProvider);
  final selectedDate = ref.watch(selectedDateProvider);
  
  return events.where((event) {
    return event.date.year == selectedDate.year &&
           event.date.month == selectedDate.month &&
           event.date.day == selectedDate.day;
  }).toList()
    ..sort((a, b) {
      if (a.time == null && b.time == null) return 0;
      if (a.time == null) return -1;
      if (b.time == null) return 1;
      return a.time!.compareTo(b.time!);
    });
});

// Provider for today's events list (for Home screen)
final todayEventsProvider = Provider<List<Event>>((ref) {
  final events = ref.watch(allEventsProvider);
  final now = DateTime.now();
  
  return events.where((event) {
    return event.date.year == now.year &&
           event.date.month == now.month &&
           event.date.day == now.day;
  }).toList()
    ..sort((a, b) {
      if (a.time == null && b.time == null) return 0;
      if (a.time == null) return -1;
      if (b.time == null) return 1;
      return a.time!.compareTo(b.time!);
    });
});

// Provider for user's name
final userNameProvider = NotifierProvider<UserNameNotifier, String?>(UserNameNotifier.new);

class AllEventsNotifier extends Notifier<List<Event>> {
  late StorageService _storageService;
  final NotificationService _notificationService = NotificationService();

  @override
  List<Event> build() {
    _storageService = ref.watch(storageServiceProvider);
    return _storageService.getAllEvents();
  }

  void loadEvents() {
    state = _storageService.getAllEvents();
  }

  Future<void> addEvent(Event event) async {
    await _storageService.saveEvent(event);
    if (event.reminderEnabled) {
      await _notificationService.scheduleEventReminder(event);
    }
    loadEvents();
  }

  Future<void> updateEvent(Event event) async {
    await _storageService.saveEvent(event);
    await _notificationService.scheduleEventReminder(event);
    loadEvents();
  }

  Future<void> deleteEvent(String id) async {
    await _storageService.deleteEvent(id);
    await _notificationService.cancelReminder(id);
    loadEvents();
  }

  Future<void> toggleCompletion(Event event) async {
    final updatedEvent = event.copyWith(isCompleted: !event.isCompleted);
    await _storageService.saveEvent(updatedEvent);
    if (updatedEvent.isCompleted) {
      await _notificationService.cancelReminder(event.id);
    } else if (updatedEvent.reminderEnabled) {
      await _notificationService.scheduleEventReminder(updatedEvent);
    }
    loadEvents();
  }
}

class UserNameNotifier extends Notifier<String?> {
  late StorageService _storageService;

  @override
  String? build() {
    _storageService = ref.watch(storageServiceProvider);
    return _storageService.getUserName();
  }

  Future<void> setName(String name) async {
    await _storageService.setUserName(name);
    state = name;
  }
}

// Deprecated: keeping it for compatibility if home screen uses it directly, but transitioning to allEventsProvider
final eventsProvider = Provider<List<Event>>((ref) => ref.watch(todayEventsProvider));
