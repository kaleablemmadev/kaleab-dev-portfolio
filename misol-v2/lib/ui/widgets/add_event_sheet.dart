import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'dart:ui';
import '../../models/event.dart';
import '../../providers/event_provider.dart';
import '../../core/theme.dart';

class AddEventSheet extends ConsumerStatefulWidget {
  final Event? event;
  final DateTime? initialDate;

  const AddEventSheet({super.key, this.event, this.initialDate});

  @override
  ConsumerState<AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<AddEventSheet> {
  final _titleController = TextEditingController();
  final _noteController = TextEditingController();
  TimeOfDay? _selectedTime;
  bool _reminderEnabled = false;
  int _reminderOffset = 15;

  final List<Map<String, dynamic>> _reminderOptions = [
    {'label': 'At time of event', 'value': 0},
    {'label': '5 min before', 'value': 5},
    {'label': '15 min before', 'value': 15},
    {'label': '30 min before', 'value': 30},
    {'label': '1 hour before', 'value': 60},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.event != null) {
      _titleController.text = widget.event!.title;
      _noteController.text = widget.event!.note ?? '';
      if (widget.event!.time != null) {
        _selectedTime = TimeOfDay.fromDateTime(widget.event!.time!);
      }
      _reminderEnabled = widget.event!.reminderEnabled;
      _reminderOffset = widget.event!.reminderOffset;
    }
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.primaryViolet,
              surface: Color(0xFF1E1E1E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _saveEvent() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final date = widget.event?.date ?? widget.initialDate ?? DateTime.now();
    DateTime? eventTime;
    if (_selectedTime != null) {
      eventTime = DateTime(date.year, date.month, date.day, _selectedTime!.hour, _selectedTime!.minute);
    }

    final event = Event(
      id: widget.event?.id ?? const Uuid().v4(),
      title: title,
      date: date,
      time: eventTime,
      note: _noteController.text.trim(),
      isCompleted: widget.event?.isCompleted ?? false,
      reminderEnabled: _reminderEnabled,
      reminderOffset: _reminderOffset,
    );

    HapticFeedback.lightImpact();

    if (widget.event == null) {
      await ref.read(allEventsProvider.notifier).addEvent(event);
    } else {
      await ref.read(allEventsProvider.notifier).updateEvent(event);
    }

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: AppTheme.surfaceGlass,
              border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.textHint.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _titleController,
                  autofocus: widget.event == null,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
                  decoration: const InputDecoration(
                    hintText: "Title",
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    fillColor: Colors.transparent,
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _noteController,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: "Optional Note",
                    prefixIcon: Icon(Icons.notes, color: AppTheme.textHint),
                    fillColor: Color(0xFF2D2D2D),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _pickTime,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2D2D2D),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, color: AppTheme.textHint),
                              const SizedBox(width: 12),
                              Text(
                                _selectedTime != null
                                    ? _selectedTime!.format(context)
                                    : "Select Time",
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: _selectedTime != null ? AppTheme.textPrimary : AppTheme.textHint,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.notifications_none_outlined,
                                color: _reminderEnabled ? AppTheme.primaryIndigo : AppTheme.textHint,
                              ),
                              const SizedBox(width: 12),
                              const Text("Set Reminder", style: TextStyle(color: AppTheme.textPrimary)),
                            ],
                          ),
                          Switch.adaptive(
                            value: _reminderEnabled,
                            activeThumbColor: AppTheme.primaryIndigo,
                            onChanged: (value) => setState(() => _reminderEnabled = value),
                          ),
                        ],
                      ),
                      if (_reminderEnabled) ...[
                        const Divider(color: Colors.white10),
                        DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _reminderOffset,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1E1E1E),
                            items: _reminderOptions.map((opt) {
                              return DropdownMenuItem<int>(
                                value: opt['value'],
                                child: Text(opt['label'], style: const TextStyle(color: AppTheme.textPrimary)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _reminderOffset = val);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [AppTheme.primaryViolet, AppTheme.primaryIndigo],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryViolet.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _saveEvent,
                      borderRadius: BorderRadius.circular(16),
                      splashColor: Colors.white.withValues(alpha: 0.2),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        alignment: Alignment.center,
                        child: Text(
                          "Save",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
