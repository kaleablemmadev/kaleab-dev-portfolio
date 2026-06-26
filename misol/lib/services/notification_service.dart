import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  
  // iOS System Ringtones
  static const List<String> iOSRingtones = [
    'alarm', 'alert', 'bell', 'chime', 'glass', 'horn', 'piano', 'radar', 'ringtone', 'sms', 'tweet', 'twitter',
  ];

  static const Map<String, int> iOSSystemSoundMap = {
    'alarm': 1005, 'alert': 1006, 'bell': 1007, 'chime': 1008, 'glass': 1010, 'horn': 1011, 'piano': 1012, 'radar': 1013, 'ringtone': 1014, 'sms': 1015, 'tweet': 1016, 'twitter': 1017,
  };

  String? _selectedRingtone = 'ringtone';
  bool _isInitialized = false;

  String? get selectedRingtone => _selectedRingtone;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tzdata.initializeTimeZones();

    if (Platform.isAndroid || Platform.isIOS) {
      await Permission.notification.request();
    }

    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (details) {
        print('Notification tapped: ${details.payload}');
      },
    );

    _isInitialized = true;
    print('✅ Notification Service initialized');
  }

  tz.TZDateTime _toTZDateTime(DateTime dateTime) {
    return tz.TZDateTime.from(dateTime, tz.local);
  }

  Future<void> showReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? ringtone,
    String channel = 'event_reminders',
  }) async {
    final String soundName = ringtone ?? _selectedRingtone ?? 'ringtone';
    
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel,
      'Reminders',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: soundName,
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      _toTZDateTime(scheduledTime),
      details,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
    String? ringtone,
    String channel = 'general_notifications',
  }) async {
    final String soundName = ringtone ?? _selectedRingtone ?? 'ringtone';

    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channel,
      'General',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    final DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: soundName,
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(id, title, body, details);
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  void setRingtone(String ringtone) {
    _selectedRingtone = ringtone;
  }

  List<String> getAvailableRingtones() => iOSRingtones;

  Future<void> previewRingtone(String ringtoneName) async {
    print('🎵 Previewing ringtone: $ringtoneName');
  }
}
