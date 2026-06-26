import 'package:hive_flutter/hive_flutter.dart';
import '../core/constants.dart';
import '../models/event.dart';

class StorageService {
  late Box<Event> _eventsBox;
  late Box _settingsBox;

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(EventAdapter());
    
    _eventsBox = await Hive.openBox<Event>(AppConstants.eventBoxName);
    _settingsBox = await Hive.openBox(AppConstants.settingsBoxName);
  }

  // --- Settings ---
  String? getUserName() {
    return _settingsBox.get(AppConstants.userNameKey);
  }

  Future<void> setUserName(String name) async {
    await _settingsBox.put(AppConstants.userNameKey, name);
  }

  bool isFirstLaunch() {
    return _settingsBox.get(AppConstants.isFirstLaunchKey, defaultValue: true);
  }

  Future<void> setFirstLaunchCompleted() async {
    await _settingsBox.put(AppConstants.isFirstLaunchKey, false);
  }

  // --- Events ---
  List<Event> getEventsForDate(DateTime date) {
    return _eventsBox.values.where((event) {
      return event.date.year == date.year &&
             event.date.month == date.month &&
             event.date.day == date.day;
    }).toList()
      ..sort((a, b) {
        if (a.time == null && b.time == null) return 0;
        if (a.time == null) return -1;
        if (b.time == null) return 1;
        return a.time!.compareTo(b.time!);
      });
  }

  List<Event> getTodayEvents() {
    return getEventsForDate(DateTime.now());
  }

  List<Event> getAllEvents() {
    return _eventsBox.values.toList();
  }

  Future<void> saveEvent(Event event) async {
    await _eventsBox.put(event.id, event);
  }

  Future<void> deleteEvent(String id) async {
    await _eventsBox.delete(id);
  }
}
