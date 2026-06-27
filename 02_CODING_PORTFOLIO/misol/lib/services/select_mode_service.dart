import 'package:flutter/material.dart';
import '../models/event.dart';

class SelectModeService extends ChangeNotifier {
  static final SelectModeService _instance = SelectModeService._internal();
  factory SelectModeService() => _instance;
  SelectModeService._internal();

  bool _isSelectionMode = false;
  final Set<String> _selectedEventIds = {};

  bool get isSelectionMode => _isSelectionMode;
  Set<String> get selectedEventIds => _selectedEventIds;

  void enterSelectionMode(String eventId) {
    _isSelectionMode = true;
    _selectedEventIds.add(eventId);
    notifyListeners();
  }

  void exitSelectionMode() {
    _isSelectionMode = false;
    _selectedEventIds.clear();
    notifyListeners();
  }

  void toggleSelection(String eventId) {
    if (_selectedEventIds.contains(eventId)) {
      _selectedEventIds.remove(eventId);
      if (_selectedEventIds.isEmpty) {
        _isSelectionMode = false;
      }
    } else {
      _selectedEventIds.add(eventId);
    }
    notifyListeners();
  }

  void selectAll(List<Event> events) {
    _selectedEventIds.addAll(events.map((e) => e.id));
    notifyListeners();
  }

  bool isSelected(String eventId) => _selectedEventIds.contains(eventId);
}