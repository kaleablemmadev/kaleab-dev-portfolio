import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../widgets/swipeable_event_card.dart';
import '../widgets/calendar_grid.dart';
import '../services/event_service.dart';
import '../ui/widgets/glass_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    EventService().addListener(_onUpdate);
  }

  @override
  void dispose() {
    EventService().removeListener(_onUpdate);
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    final eventService = EventService();
    final events = eventService.events;
    final upcomingEvents = events.where((e) => e.date.isAfter(DateTime.now()) && !_isSameDay(e.date, DateTime.now())).toList();

    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildCapsuleButton('Month', true),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCapsuleButton('Week', false, () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/week');
                }),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCapsuleButton('Day', false, () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/day');
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GlassCard(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              // Increased opacity for better text legibility
              color: Colors.black.withOpacity(0.5), 
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('MMMM yyyy').format(_currentMonth),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: -0.5,
                            shadows: [Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 10)],
                          ),
                        ),
                        Row(
                          children: [
                            _buildIconButton(Icons.chevron_left, () {
                              setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1));
                            }),
                            const SizedBox(width: 8),
                            _buildIconButton(Icons.chevron_right, () {
                              setState(() => _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1));
                            }),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    CalendarGrid(
                      currentMonth: _currentMonth,
                      selectedDate: _selectedDate,
                      onDateSelected: (date) => setState(() => _selectedDate = date),
                      isTransparent: true, 
                    ),
                    const SizedBox(height: 32),
                    const Divider(color: Colors.white12, thickness: 1),
                    const SizedBox(height: 32),
                    _buildSectionHeader('Selected Day Agenda'),
                    const SizedBox(height: 16),
                    _buildEventsList(eventService.getEventsForDate(_selectedDate)),
                    const SizedBox(height: 40),
                    _buildSectionHeader('Upcoming Events'),
                    const SizedBox(height: 16),
                    if (upcomingEvents.isEmpty)
                      _buildEmptyState('No upcoming events')
                    else
                      ...upcomingEvents.take(5).map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SwipeableEventCard(
                          event: e,
                          onTap: () => Navigator.pushNamed(context, '/add-event', arguments: e),
                        ),
                      )),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
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

  Widget _buildEventsList(List<dynamic> events) {
    if (events.isEmpty) {
      return _buildEmptyState('No events for this day');
    }
    return Column(
      children: events.map((e) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SwipeableEventCard(
          event: e,
          onTap: () => Navigator.pushNamed(context, '/add-event', arguments: e),
        ),
      )).toList(),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            color: Colors.white.withOpacity(0.85), 
            fontSize: 15, 
            fontWeight: FontWeight.w700,
            shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
          ),
        ),
      ),
    );
  }

  Widget _buildCapsuleButton(String label, bool isActive, [VoidCallback? onTap]) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF4A80F0) : Colors.black.withOpacity(0.15),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isActive ? const Color(0xFF4A80F0) : Colors.white.withOpacity(0.15),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
        shadows: [Shadow(color: Colors.black87, offset: Offset(0, 2), blurRadius: 10)],
      ),
    );
  }
}
