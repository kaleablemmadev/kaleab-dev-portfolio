import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/week_screen.dart';
import 'screens/day_screen.dart';
import 'screens/add_event_screen.dart';
import 'screens/add_task_screen.dart';
import 'screens/search_screen.dart';
import 'screens/about_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/event_details_screen.dart';
import 'services/event_service.dart';
import 'services/task_service.dart';
import 'services/settings_service.dart';
import 'services/select_mode_service.dart';
import 'services/notification_service.dart';
import 'services/connectivity_service.dart';
import 'models/event.dart';
import 'models/task.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SettingsService().loadSettings();
  await NotificationService().initialize();
  runApp(const CalendarApp());
}

class CalendarApp extends StatefulWidget {
  const CalendarApp({super.key});

  @override
  State<CalendarApp> createState() => _CalendarAppState();
}

class _CalendarAppState extends State<CalendarApp> {
  @override
  void initState() {
    super.initState();
    EventService().addListener(_onUpdate);
    TaskService().addListener(_onUpdate);
    SettingsService().addListener(_onUpdate);
    SelectModeService().addListener(_onUpdate);
    ConnectivityService().addListener(_onUpdate);
  }

  void _onUpdate() => setState(() {});

  @override
  void dispose() {
    EventService().removeListener(_onUpdate);
    TaskService().removeListener(_onUpdate);
    SettingsService().removeListener(_onUpdate);
    SelectModeService().removeListener(_onUpdate);
    ConnectivityService().removeListener(_onUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color brandBlue = Color(0xFF4A80F0);
    const Color darkBlue = Color(0xFF334A8C);

    final List<Shadow> textShadows = [
      Shadow(
        color: Colors.black.withOpacity(0.5),
        offset: const Offset(0, 2),
        blurRadius: 10,
      ),
    ];

    final themeData = ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      primaryColor: brandBlue,
      fontFamily: 'Inter',
      textTheme: TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -1, shadows: textShadows),
        headlineMedium: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: -0.5, shadows: textShadows),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.white, shadows: textShadows),
        bodyLarge: TextStyle(color: Colors.white, shadows: textShadows),
        bodyMedium: TextStyle(color: Colors.white.withOpacity(0.9), shadows: textShadows),
      ),
      colorScheme: const ColorScheme.dark(
        primary: brandBlue,
        secondary: darkBlue,
        surface: Color(0xFF121212),
      ),
      useMaterial3: true,
    );

    return MaterialApp(
      title: 'Misol Calendar',
      debugShowCheckedModeBanner: false,
      theme: themeData,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/add-event') {
          final args = settings.arguments;
          if (args is Event) return MaterialPageRoute(builder: (_) => AddEventScreen(event: args));
          if (args is DateTime) return MaterialPageRoute(builder: (_) => AddEventScreen(initialDate: args));
          return MaterialPageRoute(builder: (_) => const AddEventScreen());
        }

        if (settings.name == '/add-task') {
          final args = settings.arguments;
          if (args is Task) return MaterialPageRoute(builder: (_) => AddTaskScreen(task: args));
          return MaterialPageRoute(builder: (_) => const AddTaskScreen());
        }

        if (settings.name == '/event-details') {
          final args = settings.arguments as Event;
          return MaterialPageRoute(builder: (_) => EventDetailsScreen(event: args));
        }
        
        switch (settings.name) {
          case '/': return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/home': return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/week': return MaterialPageRoute(builder: (_) => const WeekScreen());
          case '/day': return MaterialPageRoute(builder: (_) => const DayScreen());
          case '/search': return MaterialPageRoute(builder: (_) => const SearchScreen());
          case '/about': return MaterialPageRoute(builder: (_) => const AboutScreen());
          case '/privacy': return MaterialPageRoute(builder: (_) => const PrivacyScreen());
          default: return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
