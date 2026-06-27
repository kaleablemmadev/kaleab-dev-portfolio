import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../ui/widgets/background_scaffold.dart';
import '../ui/widgets/glass_card.dart';
import '../services/event_service.dart';
import '../services/settings_service.dart';
import '../models/event.dart';

class DayScreen extends StatefulWidget {
  final DateTime? initialDate;
  const DayScreen({super.key, this.initialDate});

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  late DateTime _selectedDate;
  final ScrollController _scrollController = ScrollController();
  final double _hourHeight = 80.0;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
    EventService().addListener(_onUpdate);
    // Scroll to a reasonable hour (e.g., 8 AM) after layout
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpTo(_hourHeight * 8);
    });
  }

  @override
  void dispose() {
    EventService().removeListener(_onUpdate);
    _scrollController.dispose();
    super.dispose();
  }

  void _onUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final events = EventService().getEventsForDate(_selectedDate);
    final isToday = DateUtils.isSameDay(_selectedDate, DateTime.now());
    final dateText = DateFormat('EEEE, MMM d').format(_selectedDate);
    final is24Hours = SettingsService().timeFormat == '24h';

    return BackgroundScaffold(
      child: Column(
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCapsuleButton('Month', false, () => Navigator.pushReplacementNamed(context, '/')),
                _buildCapsuleButton('Week', false, () => Navigator.pushReplacementNamed(context, '/week')),
                _buildCapsuleButton('Day', true),
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
                padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dateText,
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: -0.5,
                                    shadows: [Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 10)],
                                  ),
                                ),
                                if (isToday)
                                  const Text(
                                    'TODAY',
                                    style: TextStyle(
                                      color: Color(0xFF4A80F0), 
                                      fontWeight: FontWeight.w900,
                                      fontSize: 12,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              _buildIconButton(Icons.chevron_left, () {
                                setState(() => _selectedDate = _selectedDate.subtract(const Duration(days: 1)));
                              }),
                              const SizedBox(width: 4),
                              _buildIconButton(Icons.chevron_right, () {
                                setState(() => _selectedDate = _selectedDate.add(const Duration(days: 1)));
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: Stack(
                          children: [
                            _buildTimeGrid(is24Hours),
                            ...events.map((event) => _buildEventBlock(context, event, is24Hours)),
                          ],
                        ),
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

  Widget _buildTimeGrid(bool is24Hours) {
    return Column(
      children: List.generate(24, (hour) {
        return Container(
          height: _hourHeight,
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: Text(
                  _formatHour(hour, is24Hours),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Expanded(
                child: Container(),
              ),
            ],
          ),
        );
      }),
    );
  }

  String _formatHour(int hour, bool is24Hours) {
    if (is24Hours) {
      return '${hour.toString().padLeft(2, '0')}:00';
    } else {
      final h = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
      final ampm = hour < 12 ? 'AM' : 'PM';
      return '$h $ampm';
    }
  }

  Widget _buildEventBlock(BuildContext context, Event event, bool is24Hours) {
    final startMinutes = event.startTime.hour * 60 + event.startTime.minute;
    final endMinutes = event.endTime.hour * 60 + event.endTime.minute;
    final duration = endMinutes - startMinutes;
    
    final top = (startMinutes / 60.0) * _hourHeight;
    final height = (duration / 60.0) * _hourHeight;

    return Positioned(
      top: top,
      left: 70,
      right: 20,
      child: GestureDetector(
        onTap: () => Navigator.pushNamed(context, '/add-event', arguments: event),
        child: Container(
          height: height < 30 ? 30 : height,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: event.color.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (height > 45) ...[
                const SizedBox(height: 4),
                Text(
                  '${_formatTimeOfDay(TimeOfDay.fromDateTime(event.startTime), is24Hours)} - ${_formatTimeOfDay(TimeOfDay.fromDateTime(event.endTime), is24Hours)}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time, bool is24Hours) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat(is24Hours ? 'HH:mm' : 'h:mm a').format(dt);
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
}
