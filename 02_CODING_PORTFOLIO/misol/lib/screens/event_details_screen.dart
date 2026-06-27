import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/settings_service.dart';
import '../ui/widgets/background_scaffold.dart';
import '../ui/widgets/glass_card.dart';

class EventDetailsScreen extends StatelessWidget {
  final Event event;

  const EventDetailsScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final settingsService = SettingsService();
    final is24Hours = settingsService.timeFormat == '24h';
    
    return BackgroundScaffold(
      child: Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  'Event Details',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                    shadows: [Shadow(color: Colors.black45, blurRadius: 8)],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, color: Colors.white),
                  onPressed: () => Navigator.pushNamed(context, '/add-event', arguments: event),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: GlassCard(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                color: Colors.black.withOpacity(0.35),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Pill
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: event.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: event.color.withOpacity(0.4)),
                        ),
                        child: Text(
                          _getEventStatus(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      _buildDetailRow(Icons.calendar_today_outlined, 'Date', 
                        DateFormat('EEEE, MMMM d, yyyy').format(event.startTime)),
                      
                      _buildDetailRow(Icons.access_time, 'Time', 
                        '${_formatTime(event.startTime, is24Hours)} - ${_formatTime(event.endTime, is24Hours)}'),
                      
                      if (event.location != null && event.location!.isNotEmpty)
                        _buildDetailRow(Icons.location_on_outlined, 'Location', event.location!),
                      
                      const Divider(color: Colors.white12, height: 48),
                      
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold, 
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black26, blurRadius: 2)],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.description.isNotEmpty ? event.description : 'No description provided for this event.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85), 
                          fontSize: 16, 
                          height: 1.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // Notification Reminder info
                      if (event.reminderEnabled)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.05)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_active_outlined, color: Color(0xFF4A80F0)),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  'Reminder set for ${_getReminderText(event)}',
                                  style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          ),
                        ),

                      if (event.repeat != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.repeat_rounded, color: Color(0xFF4A80F0)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    'Repeats ${event.repeat!.type.name}',
                                    style: TextStyle(color: Colors.white.withOpacity(0.9), fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white.withOpacity(0.9), size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time, bool is24Hours) {
    return DateFormat(is24Hours ? 'HH:mm' : 'h:mm a').format(time);
  }

  String _getEventStatus() {
    final now = DateTime.now();
    if (now.isAfter(event.endTime)) return 'COMPLETED';
    if (now.isAfter(event.startTime) && now.isBefore(event.endTime)) return 'IN PROGRESS';
    return 'UPCOMING';
  }

  String _getReminderText(Event event) {
    if (event.reminderTime == null) return "Unknown";
    final diff = event.startTime.difference(event.reminderTime!).inMinutes;
    if (diff == 0) return "At time of event";
    if (diff < 60) return "$diff minutes before";
    if (diff == 60) return "1 hour before";
    if (diff < 1440) return "${diff ~/ 60} hours before";
    return "1 day before";
  }
}
