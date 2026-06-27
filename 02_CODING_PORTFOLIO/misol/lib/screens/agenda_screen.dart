import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../ui/widgets/glass_card.dart';
import '../widgets/swipeable_event_card.dart';
import '../services/event_service.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
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

  @override
  Widget build(BuildContext context) {
    final events = EventService().events;
    
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Agenda',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1.0,
                  shadows: [Shadow(color: Colors.black87, offset: Offset(0, 2), blurRadius: 10)],
                ),
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Icon(Icons.search_rounded, color: Colors.white, size: 24),
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pushNamed(context, '/search');
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: GlassCard(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              color: Colors.black.withOpacity(0.25), 
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
              child: events.isEmpty 
                ? _buildEmptyState()
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _buildAgendaGroup('Today', events.where((e) => DateUtils.isSameDay(e.date, DateTime.now())).toList()),
                      _buildAgendaGroup('Tomorrow', events.where((e) => DateUtils.isSameDay(e.date, DateTime.now().add(const Duration(days: 1)))).toList()),
                      ..._buildFutureGroups(events),
                      const SizedBox(height: 120),
                    ],
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 64, color: Colors.white.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(
            'No events scheduled',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8), 
              fontSize: 16, 
              fontWeight: FontWeight.w600,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgendaGroup(String title, List<Event> groupEvents) {
    if (groupEvents.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 16, top: 8),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: Color(0xFF4A80F0), 
              letterSpacing: 2.0,
              shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
            ),
          ),
        ),
        ...groupEvents.map((e) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: SwipeableEventCard(
            event: e,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.pushNamed(context, '/add-event', arguments: e);
            },
          ),
        )),
        const SizedBox(height: 24),
      ],
    );
  }

  List<Widget> _buildFutureGroups(List<Event> events) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final futureEvents = events.where((e) => e.date.isAfter(tomorrow) && !DateUtils.isSameDay(e.date, tomorrow)).toList();

    final Map<DateTime, List<Event>> grouped = {};
    for (final e in futureEvents) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      grouped.putIfAbsent(d, () => []).add(e);
    }

    final sortedKeys = grouped.keys.toList()..sort();

    return sortedKeys.map((date) {
      return _buildAgendaGroup(
        DateFormat('EEEE, MMM d').format(date),
        grouped[date]!,
      );
    }).toList();
  }
}
