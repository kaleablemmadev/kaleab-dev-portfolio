import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/event.dart';
import '../services/event_service.dart';
import '../services/settings_service.dart';

class CalendarGrid extends StatelessWidget {
  final DateTime currentMonth;
  final DateTime selectedDate;
  final Function(DateTime) onDateSelected;
  final bool isTransparent;

  const CalendarGrid({
    super.key,
    required this.currentMonth,
    required this.selectedDate,
    required this.onDateSelected,
    this.isTransparent = false,
  });

  @override
  Widget build(BuildContext context) {
    final settingsService = SettingsService();
    final startOfWeek = settingsService.startOfWeek;
    final isMondayFirst = startOfWeek == 'Monday';

    final firstDayOfMonth = DateTime(currentMonth.year, currentMonth.month, 1);
    final lastDayOfMonth = DateTime(currentMonth.year, currentMonth.month + 1, 0);
    
    int offset;
    if (isMondayFirst) {
      offset = firstDayOfMonth.weekday - 1;
    } else {
      offset = firstDayOfMonth.weekday % 7;
    }

    final daysInMonth = lastDayOfMonth.day;
    final totalCells = ((daysInMonth + offset) / 7).ceil() * 7;
    
    final eventService = EventService();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildWeekdayHeaders(isMondayFirst),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 16,
            crossAxisSpacing: 8,
            childAspectRatio: 0.8,
          ),
          itemCount: totalCells,
          itemBuilder: (context, index) {
            final dayNumber = index - offset + 1;
            final date = DateTime(currentMonth.year, currentMonth.month, dayNumber);
            final isCurrentMonth = dayNumber > 0 && dayNumber <= daysInMonth;
            
            return _buildDateCell(context, date, isCurrentMonth, eventService);
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(bool isMondayFirst) {
    final weekdays = isMondayFirst 
        ? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
        : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((d) => Expanded(
        child: Center(
          child: Text(
            d,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1.0,
              shadows: [Shadow(color: Colors.black45, offset: Offset(0, 1), blurRadius: 4)],
            ),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildDateCell(BuildContext context, DateTime date, bool isCurrentMonth, EventService eventService) {
    final isSelected = DateUtils.isSameDay(date, selectedDate);
    final isToday = DateUtils.isSameDay(date, DateTime.now());
    
    // Use getEventsForDate to handle recurring events correctly
    final dayEvents = eventService.getEventsForDate(date);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onDateSelected(date);
      },
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected 
                ? const Color(0xFF4A80F0) 
                : (isToday ? Colors.white.withOpacity(0.15) : Colors.transparent),
              border: isToday && !isSelected
                ? Border.all(color: const Color(0xFF4A80F0), width: 2.0)
                : null,
              boxShadow: isSelected ? [
                BoxShadow(
                  color: const Color(0xFF4A80F0).withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 1,
                )
              ] : null,
            ),
            child: Text(
              date.day.toString(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w600,
                color: isSelected 
                  ? Colors.white 
                  : (isCurrentMonth ? Colors.white : Colors.white.withOpacity(0.5)),
                shadows: isSelected ? null : const [
                  Shadow(color: Colors.black38, offset: Offset(0, 1), blurRadius: 4)
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: dayEvents.take(3).map((e) => Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: e.color,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.black.withOpacity(0.3), width: 1.0),
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
