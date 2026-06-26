import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/notification_service.dart';
import 'services/storage_service.dart';
import 'providers/event_provider.dart';
import 'ui/main_screen.dart';
import 'ui/setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Services
  final storageService = StorageService();
  await storageService.init();

  final notificationService = NotificationService();
  await notificationService.init();
  // Request permissions on first launch or when needed
  await notificationService.requestPermissions();

  runApp(
    ProviderScope(
      overrides: [
        storageServiceProvider.overrideWithValue(storageService),
      ],
      child: const MisolApp(),
    ),
  );
}

class MisolApp extends ConsumerWidget {
  const MisolApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final storageService = ref.read(storageServiceProvider);
    final isFirstLaunch = storageService.isFirstLaunch();

    return MaterialApp(
      title: 'Misol',
      theme: AppTheme.darkTheme,
      home: isFirstLaunch ? const SetupScreen() : const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
