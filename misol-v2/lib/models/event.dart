import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Event {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final DateTime date;
  @HiveField(3)
  final DateTime? time;
  @HiveField(4)
  final String? note;
  @HiveField(5)
  final bool isCompleted;
  @HiveField(6)
  final bool reminderEnabled;
  @HiveField(7)
  final int reminderOffset; // minutes before event
  @HiveField(8)
  final String? notificationId;

  Event({
    required this.id,
    required this.title,
    required this.date,
    this.time,
    this.note,
    this.isCompleted = false,
    this.reminderEnabled = false,
    this.reminderOffset = 15,
    this.notificationId,
  });

  Event copyWith({
    String? id,
    String? title,
    DateTime? date,
    DateTime? time,
    String? note,
    bool? isCompleted,
    bool? reminderEnabled,
    int? reminderOffset,
    String? notificationId,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      date: date ?? this.date,
      time: time ?? this.time,
      note: note ?? this.note,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderOffset: reminderOffset ?? this.reminderOffset,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}

class EventAdapter extends TypeAdapter<Event> {
  @override
  final int typeId = 0;

  @override
  Event read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Event(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as DateTime,
      time: fields[3] as DateTime?,
      note: fields[4] as String?,
      isCompleted: fields[5] as bool,
      reminderEnabled: fields[6] as bool? ?? false,
      reminderOffset: fields[7] as int? ?? 15,
      notificationId: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Event obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.note)
      ..writeByte(5)
      ..write(obj.isCompleted)
      ..writeByte(6)
      ..write(obj.reminderEnabled)
      ..writeByte(7)
      ..write(obj.reminderOffset)
      ..writeByte(8)
      ..write(obj.notificationId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
