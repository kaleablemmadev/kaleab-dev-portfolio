enum RepeatType { none, daily, weekly, biWeekly, monthly, yearly, custom }

class RepeatConfiguration {
  final RepeatType type;
  final int interval; // For custom repeat (every X days/weeks/etc.)
  final DateTime? endDate;
  final int? occurrences;
  final List<int>? daysOfWeek; // 1-7 (Monday-Sunday)
  final int? dayOfMonth;

  RepeatConfiguration({
    this.type = RepeatType.none,
    this.interval = 1,
    this.endDate,
    this.occurrences,
    this.daysOfWeek,
    this.dayOfMonth,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.index,
      'interval': interval,
      'endDate': endDate?.millisecondsSinceEpoch,
      'occurrences': occurrences,
      'daysOfWeek': daysOfWeek,
      'dayOfMonth': dayOfMonth,
    };
  }

  factory RepeatConfiguration.fromMap(Map<String, dynamic> map) {
    return RepeatConfiguration(
      type: RepeatType.values[map['type'] ?? 0],
      interval: map['interval'] ?? 1,
      endDate: map['endDate'] != null ? DateTime.fromMillisecondsSinceEpoch(map['endDate']) : null,
      occurrences: map['occurrences'],
      daysOfWeek: map['daysOfWeek'] != null ? List<int>.from(map['daysOfWeek']) : null,
      dayOfMonth: map['dayOfMonth'],
    );
  }
}
