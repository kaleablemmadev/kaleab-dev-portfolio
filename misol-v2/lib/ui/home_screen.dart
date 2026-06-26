import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import '../../providers/event_provider.dart';
import '../../core/constants.dart';
import '../../core/theme.dart';
import 'widgets/event_list_item.dart';
import 'widgets/add_event_sheet.dart';
import 'widgets/empty_state.dart';
import 'settings_screen.dart';
import 'package:flutter/services.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late String _quote;
  Timer? _dayChangeTimer;

  @override
  void initState() {
    super.initState();
    final random = Random();
    _quote = AppConstants.gentleQuotes[random.nextInt(AppConstants.gentleQuotes.length)];
    WidgetsBinding.instance.addObserver(this);
    _startDayChangeTimer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dayChangeTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(allEventsProvider.notifier).loadEvents();
    }
  }

  void _startDayChangeTimer() {
    _dayChangeTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      ref.read(allEventsProvider.notifier).loadEvents();
    });
  }

  String _getGreeting(String name) {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning,\n$name.";
    if (hour < 17) return "Good Afternoon,\n$name.";
    return "Welcome Back,\n$name.";
  }

  @override
  Widget build(BuildContext context) {
    final todayEvents = ref.watch(todayEventsProvider);
    final userName = ref.watch(userNameProvider) ?? "friend";

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppTheme.textPrimary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/background.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0D0D0D),
                        Color(0xFF1A1A2E),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.4, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreeting(userName),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          shadows: [
                            Shadow(
                              color: Colors.white.withValues(alpha: 0.3),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _quote,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: todayEvents.isEmpty
                      ? const EmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 100),
                          itemCount: todayEvents.length,
                          itemBuilder: (context, index) {
                            return EventListItem(event: todayEvents[index]);
                          },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () {
                HapticFeedback.lightImpact();
                final AnimationController controller = BottomSheet.createAnimationController(this);
                controller.duration = const Duration(milliseconds: 350);
                controller.drive(CurveTween(curve: Curves.easeOutCubic));

                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  transitionAnimationController: controller,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const AddEventSheet(),
                ).whenComplete(() => controller.dispose());
              },
              child: ShaderMask(
                shaderCallback: (Rect bounds) {
                  return const LinearGradient(
                    colors: [AppTheme.primaryViolet, AppTheme.primaryIndigo],
                  ).createShader(bounds);
                },
                child: const Icon(Icons.add, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
