import 'package:hive_ce/hive.dart';

import '../../../../core/utils/date_utils.dart';
import '../../domain/entities/countdown.dart';

/// Hive-compatible data model for countdown persistence.
///
/// Separating the persistence model from the domain entity means:
/// 1. Domain entity stays clean (no Hive annotations)
/// 2. We can evolve the storage format independently
/// 3. Migration logic lives in one place
class CountdownModel extends HiveObject {
  String id;
  String title;
  DateTime targetDate;
  String emoji;
  int colorIndex;
  int recurrenceIndex;
  bool notificationsEnabled;
  List<int> notificationOffsets;
  int sortOrder;
  DateTime createdAt;
  DateTime updatedAt;

  CountdownModel({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.emoji,
    required this.colorIndex,
    required this.recurrenceIndex,
    required this.notificationsEnabled,
    required this.notificationOffsets,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert from domain entity to data model.
  factory CountdownModel.fromEntity(Countdown entity) {
    return CountdownModel(
      id: entity.id,
      title: entity.title,
      targetDate: entity.targetDate,
      emoji: entity.emoji,
      colorIndex: entity.colorIndex,
      recurrenceIndex: entity.recurrence.index,
      notificationsEnabled: entity.notificationsEnabled,
      notificationOffsets: entity.notificationOffsets,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert from data model to domain entity.
  Countdown toEntity() {
    return Countdown(
      id: id,
      title: title,
      targetDate: targetDate,
      emoji: emoji,
      colorIndex: colorIndex,
      recurrence: RecurrenceType.values[recurrenceIndex],
      notificationsEnabled: notificationsEnabled,
      notificationOffsets: notificationOffsets,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Hive TypeAdapter for CountdownModel.
/// Type ID 0 — must be unique across all adapters.
class CountdownModelAdapter extends TypeAdapter<CountdownModel> {
  @override
  final int typeId = 0;

  @override
  CountdownModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return CountdownModel(
      id: fields[0] as String,
      title: fields[1] as String,
      targetDate: fields[2] as DateTime,
      emoji: fields[3] as String,
      colorIndex: fields[4] as int,
      recurrenceIndex: fields[5] as int,
      notificationsEnabled: fields[6] as bool,
      notificationOffsets: (fields[7] as List).cast<int>(),
      sortOrder: fields[8] as int,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CountdownModel obj) {
    writer
      ..writeByte(11) // number of fields
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.targetDate)
      ..writeByte(3)
      ..write(obj.emoji)
      ..writeByte(4)
      ..write(obj.colorIndex)
      ..writeByte(5)
      ..write(obj.recurrenceIndex)
      ..writeByte(6)
      ..write(obj.notificationsEnabled)
      ..writeByte(7)
      ..write(obj.notificationOffsets)
      ..writeByte(8)
      ..write(obj.sortOrder)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt);
  }
}
