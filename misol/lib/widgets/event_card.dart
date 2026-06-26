import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/event.dart';
import '../services/settings_service.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool showCheckbox;
  final bool isSelected;

  const EventCard({
    super.key,
    required this.event,
    this.onTap,
    this.onLongPress,
    this.showCheckbox = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final settingsService = SettingsService();
    final is24Hours = settingsService.timeFormat == '24h';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? const Color(0xFF4A80F0) : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              if (showCheckbox)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                    color: isSelected ? const Color(0xFF4A80F0) : Colors.white38,
                    size: 22,
                  ),
                ),
              // Color indicator from palette
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: event.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(color: Colors.black26, offset: Offset(0, 1), blurRadius: 2),
                        ],
                      ),
                    ),
                    if (event.location != null && event.location!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Row(
                          children: [
                            Icon(Icons.location_on_outlined, size: 14, color: Colors.white.withOpacity(0.75)),
                            const SizedBox(width: 6),
                            Text(
                              event.location!,
                              style: TextStyle(
                                fontSize: 13, 
                                color: Colors.white.withOpacity(0.75),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormat(is24Hours ? 'HH:mm' : 'h:mm a').format(event.startTime),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    _getEventIcon(),
                    size: 20,
                    color: event.color,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getEventIcon() {
    final title = event.title.toLowerCase();
    if (title.contains('meeting') || title.contains('team')) return Icons.groups_rounded;
    if (title.contains('birthday') || title.contains('party')) return Icons.celebration;
    if (title.contains('call')) return Icons.call;
    if (title.contains('work')) return Icons.work;
    return Icons.event;
  }
}
