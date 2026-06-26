import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/repeat_config.dart';
import '../services/task_service.dart';
import '../services/settings_service.dart';
import '../ui/widgets/background_scaffold.dart';
import '../ui/widgets/glass_card.dart';
import '../widgets/color_picker.dart';

class AddTaskScreen extends StatefulWidget {
  final Task? task;
  const AddTaskScreen({super.key, this.task});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  late Color _selectedColor;
  late TaskPriority _priority;
  bool _reminderEnabled = false;
  int _reminderMinutesBefore = 15;
  RepeatType _repeatType = RepeatType.none;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(text: task?.description ?? '');
    _dueDate = task?.dueDate;
    if (task?.dueDate != null) {
      _dueTime = TimeOfDay.fromDateTime(task!.dueDate!);
    }
    _selectedColor = task?.color ?? const Color(0xFF4A80F0);
    _priority = task?.priority ?? TaskPriority.medium;
    _reminderEnabled = task?.reminderEnabled ?? false;
    _repeatType = task?.repeat?.type ?? RepeatType.none;

    if (task?.reminderTime != null && task?.dueDate != null) {
      _reminderMinutesBefore = task!.dueDate!.difference(task.reminderTime!).inMinutes;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _dueTime = picked);
    }
  }

  void _saveTask() {
    if (!_formKey.currentState!.validate()) return;

    DateTime? fullDueDate;
    if (_dueDate != null) {
      fullDueDate = DateTime(
        _dueDate!.year, _dueDate!.month, _dueDate!.day,
        _dueTime?.hour ?? 0, _dueTime?.minute ?? 0,
      );
    }

    DateTime? reminderTime;
    if (_reminderEnabled && fullDueDate != null) {
      reminderTime = fullDueDate.subtract(Duration(minutes: _reminderMinutesBefore));
    }

    final task = Task(
      id: widget.task?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      dueDate: fullDueDate,
      reminderEnabled: _reminderEnabled,
      reminderTime: reminderTime,
      priority: _priority,
      color: _selectedColor,
      repeat: _repeatType == RepeatType.none ? null : RepeatConfiguration(type: _repeatType),
      isCompleted: widget.task?.isCompleted ?? false,
    );

    if (widget.task == null) {
      TaskService().addTask(task);
    } else {
      TaskService().updateTask(task);
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
                  widget.task == null ? 'New Task' : 'Edit Task',
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInputField(controller: _titleController, hint: 'Task Title', icon: Icons.title),
                        const SizedBox(height: 16),
                        _buildInputField(controller: _descriptionController, hint: 'Description', icon: Icons.notes, maxLines: 3),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Priority'),
                        _buildPriorityPicker(),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Due Date'),
                        _buildPickerTile(
                          label: 'Date',
                          value: _dueDate == null ? 'None' : DateFormat('MMM d, yyyy').format(_dueDate!),
                          icon: Icons.calendar_today,
                          onTap: _pickDate,
                        ),
                        if (_dueDate != null)
                          _buildPickerTile(
                            label: 'Time',
                            value: _dueTime == null ? 'None' : _formatTime(_dueTime!),
                            icon: Icons.access_time,
                            onTap: _pickTime,
                          ),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Reminders & Repeat'),
                        _buildReminderSwitch(),
                        if (_reminderEnabled) _buildReminderPicker(),
                        _buildRepeatPicker(),
                        const SizedBox(height: 32),
                        _buildSectionHeader('Tag Color'),
                        ColorPicker(
                          selectedColor: _selectedColor,
                          onColorSelected: (color) => setState(() => _selectedColor = color),
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _saveTask,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4A80F0),
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            child: Text(widget.task == null ? 'CREATE TASK' : 'SAVE CHANGES', style: const TextStyle(fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white70, letterSpacing: 1.5)),
    );
  }

  Widget _buildInputField({required TextEditingController controller, required String hint, required IconData icon, int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(color: Colors.black.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
      child: TextFormField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white38),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(icon, color: Colors.white70),
        ),
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
    );
  }

  Widget _buildPickerTile({required String label, required String value, required IconData icon, required VoidCallback onTap}) {
    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value, style: const TextStyle(color: Color(0xFF4A80F0), fontWeight: FontWeight.bold)),
          const Icon(Icons.chevron_right, color: Colors.white24),
        ],
      ),
    );
  }

  Widget _buildPriorityPicker() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: TaskPriority.values.map((p) {
        final isSelected = _priority == p;
        return GestureDetector(
          onTap: () => setState(() => _priority = p),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF4A80F0) : Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(p.name.toUpperCase(), style: TextStyle(color: isSelected ? Colors.white : Colors.white38, fontWeight: FontWeight.bold)),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildReminderSwitch() {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Enable Reminder', style: TextStyle(color: Colors.white)),
      value: _reminderEnabled,
      onChanged: (val) => setState(() => _reminderEnabled = val),
      activeColor: const Color(0xFF4A80F0),
    );
  }

  Widget _buildReminderPicker() {
    final options = {0: 'At time of task', 5: '5m before', 15: '15m before', 30: '30m before', 60: '1h before', 1440: '1d before'};
    return _buildPickerTile(
      label: 'Notify',
      value: options[_reminderMinutesBefore] ?? '${_reminderMinutesBefore}m before',
      icon: Icons.notifications_none,
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF1E1E1E),
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
      value: _repeatType.name.toUpperCase(),
      icon: Icons.repeat,
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: const Color(0xFF1E1E1E),
          builder: (context) => ListView(
            shrinkWrap: true,
            children: RepeatType.values.map((t) => ListTile(
              title: Text(t.name.toUpperCase(), style: const TextStyle(color: Colors.white)),
              onTap: () {
                setState(() => _repeatType = t);
                Navigator.pop(context);
              },
            )).toList(),
          ),
        );
      },
    );
  }
}
