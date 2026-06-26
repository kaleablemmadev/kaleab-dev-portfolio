import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/event.dart';
import '../models/repeat_config.dart';
import '../services/event_service.dart';
import '../services/settings_service.dart';
import '../ui/widgets/background_scaffold.dart';
import '../ui/widgets/glass_card.dart';
import '../widgets/color_picker.dart';

class AddEventScreen extends StatefulWidget {
  final Event? event;
  final DateTime? initialDate;

  const AddEventScreen({super.key, this.event, this.initialDate});

  @override
  State<AddEventScreen> createState() => _AddEventScreenState();
}

class _AddEventScreenState extends State<AddEventScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late Color _selectedColor;
  
  bool _reminderEnabled = false;
  int _reminderMinutesBefore = 15;
  RepeatType _repeatType = RepeatType.none;

  @override
  void initState() {
    super.initState();
    final event = widget.event;
    _titleController = TextEditingController(text: event?.title ?? '');
    _locationController = TextEditingController(text: event?.location ?? '');
    _descriptionController = TextEditingController(text: event?.description ?? '');
    
    _selectedDate = event?.startTime ?? widget.initialDate ?? DateTime.now();
    _startTime = event != null 
        ? TimeOfDay.fromDateTime(event.startTime) 
        : const TimeOfDay(hour: 9, minute: 0);
    _endTime = event != null 
        ? TimeOfDay.fromDateTime(event.endTime) 
        : const TimeOfDay(hour: 10, minute: 0);
        
    _selectedColor = event?.color ?? const Color(0xFF4A80F0);
    _reminderEnabled = event?.reminderEnabled ?? false;
    _repeatType = event?.repeat?.type ?? RepeatType.none;
    
    if (event?.reminderTime != null) {
      _reminderMinutesBefore = event!.startTime.difference(event.reminderTime!).inMinutes;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final is24Hours = SettingsService().timeFormat == '24h';
    return DateFormat(is24Hours ? 'HH:mm' : 'h:mm a').format(dateTime);
  }

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4A80F0),
            onPrimary: Colors.white,
            surface: Color(0xFF1E1E1E),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime({required bool isStart}) async {
    HapticFeedback.selectionClick();
    final picked = await showTimePicker(
      context: context,
      initialTime: isStart ? _startTime : _endTime,
      builder: (context, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF4A80F0),
            onPrimary: Colors.white,
            surface: Color(0xFF1E1E1E),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  void _saveEvent() {
    if (!_formKey.currentState!.validate()) {
      HapticFeedback.vibrate();
      return;
    }

    final startDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _startTime.hour, _startTime.minute
    );
    
    final endDateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _endTime.hour, _endTime.minute
    );

    DateTime? reminderTime;
    if (_reminderEnabled) {
      reminderTime = startDateTime.subtract(Duration(minutes: _reminderMinutesBefore));
    }

    HapticFeedback.mediumImpact();
    final event = Event(
      id: widget.event?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      description: _descriptionController.text.trim(),
      startTime: startDateTime,
      endTime: endDateTime,
      color: _selectedColor,
      reminderEnabled: _reminderEnabled,
      reminderTime: reminderTime,
      repeat: _repeatType == RepeatType.none ? null : RepeatConfiguration(type: _repeatType),
    );

    if (widget.event == null) {
      EventService().addEvent(event);
    } else {
      EventService().updateEvent(event);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      child: Column(
        children: [
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.event == null ? 'New Event' : 'Edit Event',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -1.0,
                    shadows: [
                      Shadow(
                        color: Colors.black87,
                        offset: Offset(0, 2),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: GlassCard(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                color: Colors.black.withOpacity(0.25),
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Details'),
                        _buildInputField(
                          controller: _titleController,
                          hint: 'Event Title',
                          icon: Icons.title_rounded,
                          validator: (v) => v == null || v.isEmpty ? 'Please enter a title' : null,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _locationController,
                          hint: 'Add Location',
                          icon: Icons.location_on_outlined,
                        ),
                        const SizedBox(height: 16),
                        _buildInputField(
                          controller: _descriptionController,
                          hint: 'Add Description',
                          icon: Icons.notes_rounded,
                          maxLines: 4,
                        ),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Schedule'),
                        _buildPickerTile(
                          label: 'Date',
                          value: DateFormat('EEE, MMM d, yyyy').format(_selectedDate),
                          icon: Icons.calendar_today_rounded,
                          onTap: _pickDate,
                        ),
                        _buildPickerTile(
                          label: 'Starts',
                          value: _formatTime(_startTime),
                          icon: Icons.access_time_rounded,
                          onTap: () => _pickTime(isStart: true),
                        ),
                        _buildPickerTile(
                          label: 'Ends',
                          value: _formatTime(_endTime),
                          icon: Icons.access_time_filled_rounded,
                          onTap: () => _pickTime(isStart: false),
                        ),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Reminders & Repeat'),
                        _buildReminderSwitch(),
                        if (_reminderEnabled) _buildReminderPicker(),
                        _buildRepeatPicker(),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Tag Color'),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: ColorPicker(
                            selectedColor: _selectedColor,
                            onColorSelected: (color) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedColor = color);
                            },
                          ),
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF4A80F0).withOpacity(0.4),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: _saveEvent,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A80F0),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 22),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
                                elevation: 0,
                              ),
                              child: Text(
                                widget.event == null ? 'CREATE EVENT' : 'SAVE CHANGES',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 2.0),
                              ),
                            ),
                          ),
                        ),
                        if (widget.event != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Center(
                              child: TextButton.icon(
                                onPressed: () {
                                  HapticFeedback.vibrate();
                                  EventService().deleteEvent(widget.event!);
                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.delete_outline, size: 20),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.redAccent.withOpacity(0.9),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                ),
                                label: const Text('Delete Event', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13, 
          fontWeight: FontWeight.w900, 
          color: Colors.white.withOpacity(0.9),
          letterSpacing: 2.0,
          shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
        maxLines: maxLines,
        cursorColor: const Color(0xFF4A80F0),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w400),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 4),
            child: Icon(icon, color: Colors.white.withOpacity(0.8), size: 22),
          ),
        ),
        validator: validator,
      ),
    );
  }

  Widget _buildPickerTile({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.8), size: 22),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label, 
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                value, 
                style: const TextStyle(
                  color: Colors.white, 
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: Colors.white.withOpacity(0.5), size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReminderSwitch() {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      title: const Text('Enable Reminder', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
      value: _reminderEnabled,
      activeColor: const Color(0xFF4A80F0),
      onChanged: (val) => setState(() => _reminderEnabled = val),
    );
  }

  Widget _buildReminderPicker() {
    final options = {
      0: 'At time of event',
      5: '5 minutes before',
      10: '10 minutes before',
      15: '15 minutes before',
      30: '30 minutes before',
      60: '1 hour before',
      120: '2 hours before',
      1440: '1 day before',
    };

    return _buildPickerTile(
      label: 'Reminder',
      value: options[_reminderMinutesBefore] ?? '${_reminderMinutesBefore}m before',
      icon: Icons.notifications_active_outlined,
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF1E1E1E),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (context) => ListView(
            shrinkWrap: true,
            children: options.entries.map((e) => ListTile(
              title: Text(e.value, style: const TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _reminderMinutesBefore = e.key);
                Navigator.pop(context);
              },
            )).toList(),
          ),
        );
      },
    );
  }

  Widget _buildRepeatPicker() {
    return _buildPickerTile(
      label: 'Repeat',
      value: _repeatType.toString().split('.').last.toUpperCase(),
      icon: Icons.repeat_rounded,
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF1E1E1E),
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
          builder: (context) => ListView(
            shrinkWrap: true,
            children: RepeatType.values.map((type) => ListTile(
              title: Text(type.toString().split('.').last.toUpperCase(), style: const TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _repeatType = type);
                Navigator.pop(context);
              },
            )).toList(),
          ),
        );
      },
    );
  }
}
