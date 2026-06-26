import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../providers/event_provider.dart';
import '../core/theme.dart';
import 'widgets/event_list_item.dart';
import 'widgets/add_event_sheet.dart';
import 'widgets/empty_state.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late PageController _pageController;
  late DateTime _focusedMonth;
  late DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime.now();
    _selectedDay = DateTime.now();
    _pageController = PageController(initialPage: _getMonthIndex(_focusedMonth));
  }

  int _getMonthIndex(DateTime date) {
    return (date.year - 2000) * 12 + date.month - 1;
  }

  DateTime _getDateFromIndex(int index) {
    return DateTime(2000 + (index ~/ 12), (index % 12) + 1, 1);
  }

  void _onDaySelected(DateTime day) {
    setState(() {
      _selectedDay = day;
    });
    ref.read(selectedDateProvider.notifier).updateDate(day);
    HapticFeedback.lightImpact();
  }

  void _jumpToToday() {
    final now = DateTime.now();
    _onDaySelected(now);
    _pageController.animateToPage(
      _getMonthIndex(now),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventsForSelectedDate = ref.watch(filteredEventsProvider);
    final allEvents = ref.watch(allEventsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Container(
              color: AppTheme.backgroundDark,
            ),
          ),
          // Glassmorphism effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildWeekdayHeaders(),
                SizedBox(
                  height: 300,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _focusedMonth = _getDateFromIndex(index);
                      });
                    },
                    itemBuilder: (context, index) {
                      final monthDate = _getDateFromIndex(index);
                      return _buildCalendarGrid(monthDate, allEvents);
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(color: Colors.white10, height: 1),
                ),
                Expanded(
                  child: _buildEventList(eventsForSelectedDate),
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
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddEventSheet(initialDate: _selectedDay),
                );
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: _jumpToToday,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(_focusedMonth),
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  "Today: ${DateFormat('MMM d').format(DateTime.now())}",
                  style: const TextStyle(color: AppTheme.primaryIndigo, fontWeight: FontWeight.w600, fontSize: 14),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left, color: AppTheme.textPrimary),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right, color: AppTheme.textPrimary),
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: weekdays.map((d) => Expanded(
          child: Center(
            child: Text(
              d,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(DateTime monthDate, List<dynamic> allEvents) {
    final daysInMonth = DateTime(monthDate.year, monthDate.month + 1, 0).day;
    final firstDayWeekday = DateTime(monthDate.year, monthDate.month, 1).weekday;
    final firstDayOffset = firstDayWeekday - 1;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: 42, // Fixed 6 weeks to avoid height jumps
        itemBuilder: (context, index) {
          if (index < firstDayOffset || index >= firstDayOffset + daysInMonth) {
            return const SizedBox.shrink();
          }
          
          final dayNum = index - firstDayOffset + 1;
          final date = DateTime(monthDate.year, monthDate.month, dayNum);
          final isToday = DateUtils.isSameDay(date, DateTime.now());
          final isSelected = DateUtils.isSameDay(date, _selectedDay);
          final hasEvents = allEvents.any((e) => DateUtils.isSameDay(e.date, date));

          return GestureDetector(
            onTap: () => _onDaySelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: isToday ? const LinearGradient(colors: [AppTheme.primaryViolet, AppTheme.primaryIndigo]) : null,
                border: isSelected && !isToday ? Border.all(color: AppTheme.primaryViolet, width: 2) : null,
                color: !isToday ? (isSelected ? AppTheme.primaryViolet.withValues(alpha: 0.1) : const Color(0xFF1E1E1E)) : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayNum.toString(),
                    style: TextStyle(
                      color: isToday ? Colors.white : AppTheme.textPrimary,
                      fontWeight: isToday || isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (hasEvents)
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isToday ? Colors.white : AppTheme.primaryIndigo,
                      ),
                    )
                  else
                    const SizedBox(height: 4),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventList(List<dynamic> events) {
    if (events.isEmpty) {
      return const Center(child: EmptyState());
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 16, bottom: 100),
      itemCount: events.length,
      itemBuilder: (context, index) => EventListItem(event: events[index]),
    );
  }
}
