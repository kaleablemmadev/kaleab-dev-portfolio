import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class RingtonePicker extends StatefulWidget {
  final String? selectedRingtone;
  final Function(String) onRingtoneSelected;

  const RingtonePicker({
    super.key,
    this.selectedRingtone,
    required this.onRingtoneSelected,
  });

  @override
  State<RingtonePicker> createState() => _RingtonePickerState();
}

class _RingtonePickerState extends State<RingtonePicker> {
  late String _selectedRingtone;
  final NotificationService _notification = NotificationService();
  String? _previewingRingtone;

  @override
  void initState() {
    super.initState();
    _selectedRingtone = widget.selectedRingtone ?? 'ringtone';
  }

  @override
  Widget build(BuildContext context) {
    final ringtones = _notification.getAvailableRingtones();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Ringtone',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Column(
            children: ringtones.map((ringtone) {
              final isSelected = _selectedRingtone == ringtone;
              final isPreviewing = _previewingRingtone == ringtone;

              return ListTile(
                dense: true,
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: isSelected ? Colors.blueAccent : Colors.white24,
                  size: 20,
                ),
                title: Text(
                  ringtone.toUpperCase(),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Colors.blueAccent : Colors.white,
                  ),
                ),
                trailing: IconButton(
                  icon: Icon(
                    isPreviewing ? Icons.stop_circle : Icons.play_circle_outline,
                    color: isPreviewing ? Colors.blueAccent : Colors.white54,
                    size: 24,
                  ),
                  onPressed: () {
                    _previewRingtone(ringtone);
                  },
                ),
                onTap: () {
                  setState(() {
                    _selectedRingtone = ringtone;
                  });
                  widget.onRingtoneSelected(ringtone);
                  _notification.setRingtone(ringtone);
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Play to preview, tap to select',
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ),
      ],
    );
  }

  void _previewRingtone(String ringtone) async {
    setState(() {
      _previewingRingtone = _previewingRingtone == ringtone ? null : ringtone;
    });

    if (_previewingRingtone != null) {
      await _notification.previewRingtone(ringtone);
      
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _previewingRingtone == ringtone) {
          setState(() {
            _previewingRingtone = null;
          });
        }
      });
    }
  }
}
