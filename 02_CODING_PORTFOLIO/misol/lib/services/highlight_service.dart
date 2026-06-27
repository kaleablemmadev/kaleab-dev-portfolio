import 'package:flutter/material.dart';

class HighlightService extends ChangeNotifier {
  static final HighlightService _instance = HighlightService._internal();
  factory HighlightService() => _instance;
  HighlightService._internal();

  String? _highlightedEventId;
  DateTime? _highlightedEventDate;

  String? get highlightedEventId => _highlightedEventId;
  DateTime? get highlightedEventDate => _highlightedEventDate;

  void highlightEvent(String eventId, DateTime eventDate) {
    _highlightedEventId = eventId;
    _highlightedEventDate = eventDate;
    notifyListeners();
  }

  void clearHighlightedEvent() {
    _highlightedEventId = null;
    _highlightedEventDate = null;
    notifyListeners();
  }

  bool isDateHighlighted(DateTime date) {
    if (_highlightedEventDate == null) return false;
    return DateUtils.isSameDay(_highlightedEventDate!, date);
  }
}