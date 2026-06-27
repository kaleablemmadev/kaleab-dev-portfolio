import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../ui/widgets/glass_card.dart';
import '../services/event_service.dart';
import '../services/settings_service.dart';
import '../widgets/swipeable_event_card.dart';
import '../models/event.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final eventService = EventService();
    final settingsService = SettingsService();
    final is24Hours = settingsService.timeFormat == '24h';
    final now = DateTime.now();
    final todayEvents = eventService.getEventsForDate(now);
    
    Event? nextEvent;
    for (var event in todayEvents) {
      if (event.startTime.isAfter(now)) {
        if (nextEvent == null || event.startTime.isBefore(nextEvent.startTime)) {
          nextEvent = event;
        }
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildHeader(),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(Icons.search, color: Colors.white, size: 24),
                  ),
                  onPressed: () => Navigator.pushNamed(context, '/search'),
                ),
              ],
            ),
            const SizedBox(height: 36),
            
            if (nextEvent != null) ...[
              _buildSectionTitle('Next Up'),
              const SizedBox(height: 16),
              _buildNextEventCard(context, nextEvent, is24Hours),
              const SizedBox(height: 36),
            ],

            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Today',
                    '${todayEvents.length}',
                    Icons.event,
                    const Color(0xFF4A80F0),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    'This Week',
                    '${_getEventsThisWeekCount(eventService)}',
                    Icons.calendar_view_week,
                    const Color(0xFF4A80F0),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            _buildSectionTitle('Today\'s Agenda'),
            const SizedBox(height: 16),
            if (todayEvents.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 60),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.event_available_outlined, size: 48, color: Colors.white.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        'Your day is clear!',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8), 
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...todayEvents.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: SwipeableEventCard(
                  event: e,
                  onTap: () => Navigator.pushNamed(context, '/add-event', arguments: e),
                ),
              )),
            
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
        letterSpacing: -0.5,
        shadows: [
          Shadow(color: Colors.black87, offset: Offset(0, 2), blurRadius: 10),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting = "Good Morning";
    if (hour >= 12 && hour < 17) greeting = "Good Afternoon";
    if (hour >= 17) greeting = "Good Evening";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.95),
            letterSpacing: 1.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormat('EEEE, MMM d').format(DateTime.now()),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
            shadows: [Shadow(color: Colors.black87, offset: Offset(0, 2), blurRadius: 12)],
          ),
        ),
      ],
    );
  }

  Widget _buildNextEventCard(BuildContext context, Event event, bool is24Hours) {
    return GlassCard(
      padding: const EdgeInsets.all(24),
      color: Colors.black.withOpacity(0.5), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: event.color.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.0),
                ),
                child: const Text(
                  'UPCOMING',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11, 
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat(is24Hours ? 'HH:mm' : 'h:mm a').format(event.startTime),
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            event.title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
              shadows: [Shadow(color: Colors.black87, offset: Offset(0, 2), blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 18, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Starts soon',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      color: Colors.black.withOpacity(0.5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black54, blurRadius: 8)],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  int _getEventsThisWeekCount(EventService service) {
    final now = DateTime.now();
    // Assuming Sunday as start for simplicity in stat card or follow setting
    final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
    int count = 0;
    for (int i = 0; i < 7; i++) {
      count += service.getEventsForDate(startOfWeek.add(Duration(days: i))).length;
    }
    return count;
  }
}
