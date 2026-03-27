import '../../../../core/utils/date_utils.dart';

/// Core domain entity representing a countdown event.
///
/// This is a pure Dart class with no framework dependencies.
/// All business rules for countdowns live here or in use cases.
class Countdown {
  final String id;
  final String title;
  final DateTime targetDate;
  final String emoji;
  final int colorIndex;
  final RecurrenceType recurrence;
  final bool notificationsEnabled;
  final List<int> notificationOffsets; // minutes before event
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Countdown({
    required this.id,
    required this.title,
    required this.targetDate,
    required this.emoji,
    required this.colorIndex,
    this.recurrence = RecurrenceType.none,
    this.notificationsEnabled = true,
    this.notificationOffsets = const [0, 1440],
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Days until the target date. Positive = future, negative = past.
  int get daysUntil => CountdownDateUtils.daysUntil(effectiveDate);

  /// The effective date, accounting for recurrence.
  /// For recurring events, this is the next occurrence.
  DateTime get effectiveDate {
    if (recurrence == RecurrenceType.none) return targetDate;
    return CountdownDateUtils.nextOccurrence(targetDate, recurrence);
  }

  /// Whether this countdown is for a past event (non-recurring).
  bool get isPast =>
      recurrence == RecurrenceType.none &&
      CountdownDateUtils.isPast(targetDate);

  /// Whether this countdown is happening today.
  bool get isToday => CountdownDateUtils.isToday(effectiveDate);

  /// Human-readable countdown string.
  String get formattedCountdown =>
      CountdownDateUtils.formatCountdown(effectiveDate);

  /// Absolute days remaining for display.
  int get daysRemaining => CountdownDateUtils.daysRemaining(effectiveDate);

  /// Create a copy with updated fields.
  Countdown copyWith({
    String? id,
    String? title,
    DateTime? targetDate,
    String? emoji,
    int? colorIndex,
    RecurrenceType? recurrence,
    bool? notificationsEnabled,
    List<int>? notificationOffsets,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Countdown(
      id: id ?? this.id,
      title: title ?? this.title,
      targetDate: targetDate ?? this.targetDate,
      emoji: emoji ?? this.emoji,
      colorIndex: colorIndex ?? this.colorIndex,
      recurrence: recurrence ?? this.recurrence,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationOffsets: notificationOffsets ?? this.notificationOffsets,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Countdown &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Countdown(id: $id, title: $title, '
      'targetDate: $targetDate, recurrence: $recurrence)';
}
