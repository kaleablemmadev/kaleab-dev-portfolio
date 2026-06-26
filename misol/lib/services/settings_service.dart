import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService extends ChangeNotifier {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // Settings keys
  static const String _keyDefaultView = 'default_view';
  static const String _keyStartOfWeek = 'start_of_week';
  static const String _keyTimeFormat = 'time_format';
  static const String _keyNotifications = 'notifications';

  // Default values
  String _defaultView = 'Month';
  String _startOfWeek = 'Sunday';
  String _timeFormat = '12h';
  bool _notifications = true;

  // Getters
  String get defaultView => _defaultView;
  String get startOfWeek => _startOfWeek;
  String get timeFormat => _timeFormat;
  bool get notifications => _notifications;

  // Setters with persistence
  Future<void> setDefaultView(String view) async {
    _defaultView = view;
    await _saveSetting(_keyDefaultView, view);
    notifyListeners();
  }

  Future<void> setStartOfWeek(String day) async {
    _startOfWeek = day;
    await _saveSetting(_keyStartOfWeek, day);
    notifyListeners();
  }

  Future<void> setTimeFormat(String format) async {
    _timeFormat = format;
    await _saveSetting(_keyTimeFormat, format);
    notifyListeners();
  }

  Future<void> setNotifications(bool enabled) async {
    _notifications = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyNotifications, enabled);
    } catch (e) {
      debugPrint('Failed to save notifications setting: $e');
    }
    notifyListeners();
  }

  // Load settings from SharedPreferences
  Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _defaultView = prefs.getString(_keyDefaultView) ?? 'Month';
      _startOfWeek = prefs.getString(_keyStartOfWeek) ?? 'Sunday';
      _timeFormat = prefs.getString(_keyTimeFormat) ?? '12h';
      _notifications = prefs.getBool(_keyNotifications) ?? true;
    } catch (e) {
      debugPrint('Failed to load settings: $e');
    }
    
    notifyListeners();
  }

  // Save individual setting
  Future<void> _saveSetting(String key, String value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, value);
    } catch (e) {
      debugPrint('Failed to save setting $key: $e');
    }
  }

  // Reset all settings to defaults
  Future<void> resetSettings() async {
    await setDefaultView('Month');
    await setStartOfWeek('Sunday');
    await setTimeFormat('12h');
    await setNotifications(true);
  }
}
