import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../ui/widgets/background_scaffold.dart';
import '../ui/widgets/glass_card.dart';
import '../widgets/swipeable_event_card.dart';
import '../services/event_service.dart';
import '../services/settings_service.dart';

class WeekScreen extends StatefulWidget {
  const WeekScreen({super.key});

  @override
  State<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends State<WeekScreen> {
  late DateTime _currentWeekStart;
  final SettingsService _settings = SettingsService();

  @override
  void initState() {
    super.initState();
    _currentWeekStart = _getStartOfWeek(DateTime.now());
    EventService().addListener(_onUpdate);
    _settings.addListener(_onUpdate);
  }

  @override
  void dispose() {
    EventService().removeListener(_onUpdate);
    _settings.removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() {
    if (mounted) setState(() {});
  }

  DateTime _getStartOfWeek(DateTime date) {
    final isMondayFirst = _settings.startOfWeek == 'Monday';
    if (isMondayFirst) {
      return date.subtract(Duration(days: date.weekday - 1));
    } else {
      return date.subtract(Duration(days: date.weekday % 7));
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final eventService = EventService();
    final events = eventService.events;
    final weekDays = List.generate(7, (i) => _currentWeekStart.add(Duration(days: i)));
    final weekRangeText = "${DateFormat('MMM d').format(weekDays.first)} – ${DateFormat('d, yyyy').format(weekDays.last)}";

    return BackgroundScaffold(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCapsuleButton('Month', false, () => Navigator.pop(context)),
                _buildCapsuleButton('Week', true),
                _buildCapsuleButton('Day', false, () => Navigator.pushReplacementNamed(context, '/day')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: GlassCard(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                color: Colors.black.withOpacity(0.35),
                padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            weekRangeText,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: -0.5,
                              shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            _buildIconButton(Icons.chevron_left, () {
                              setState(() => _currentWeekStart = _currentWeekStart.subtract(const Duration(days: 7)));
                            }),
                            const SizedBox(width: 4),
                            _buildIconButton(Icons.chevron_right, () {
                              setState(() => _currentWeekStart = _currentWeekStart.add(const Duration(days: 7)));
                            }),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: 7,
                        itemBuilder: (context, index) {
                          final day = weekDays[index];
                          final dayEvents = events.where((e) => _isSameDay(e.date, day)).toList();
                          final isToday = _isSameDay(day, DateTime.now());

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                child: Row(
                                  children: [
                                    Text(
                                      DateFormat('EEEE, MMM d').format(day),
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: isToday ? const Color(0xFF4A80F0) : Colors.white.withOpacity(0.9),
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (isToday) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        width: 6,
                                        height: 6,
                                        decoration: const BoxDecoration(color: Color(0xFF4A80F0), shape: BoxShape.circle),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (dayEvents.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(left: 4, bottom: 20),
                                  child: Text(
                                    'No events scheduled', 
                                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
                                  ),
                                )
                              else
                                ...dayEvents.map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: SwipeableEventCard(
                                    event: e,
                                    onTap: () => Navigator.pushNamed(context, '/add-event', arguments: e),
                                  ),
                                )),
                              const Divider(color: Colors.white12, height: 1),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap) {
    return IconButton(
      onPressed: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      icon: Icon(icon, color: Colors.white, size: 28),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
    );
  }

  Widget _buildCapsuleButton(String label, bool isActive, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          HapticFeedback.lightImpact();
          onTap();
        }
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4A80F0) : Colors.black.withOpacity(0.3),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? const Color(0xFF4A80F0) : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold, 
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
