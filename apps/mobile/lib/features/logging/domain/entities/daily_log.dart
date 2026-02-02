import 'package:equatable/equatable.dart';

/// Log type enum matching Supabase schema
enum LogType {
  food('food'),
  sleep('sleep'),
  exercise('exercise'),
  medication('medication'),
  symptom('symptom'),
  note('note');

  const LogType(this.value);
  final String value;

  static LogType fromString(String value) {
    return LogType.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => LogType.note,
    );
  }

  String get displayName {
    switch (this) {
      case LogType.food:
        return 'Food';
      case LogType.sleep:
        return 'Sleep';
      case LogType.exercise:
        return 'Exercise';
      case LogType.medication:
        return 'Medication';
      case LogType.symptom:
        return 'Symptom';
      case LogType.note:
        return 'Note';
    }
  }

  String get icon {
    switch (this) {
      case LogType.food:
        return '🍽️';
      case LogType.sleep:
        return '😴';
      case LogType.exercise:
        return '🏃';
      case LogType.medication:
        return '💊';
      case LogType.symptom:
        return '🩺';
      case LogType.note:
        return '📝';
    }
  }
}

/// Meal type for food logs (stored in metadata)
enum MealType {
  breakfast('breakfast'),
  lunch('lunch'),
  dinner('dinner'),
  snack('snack');

  const MealType(this.value);
  final String value;

  static MealType fromString(String value) {
    return MealType.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => MealType.snack,
    );
  }

  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Breakfast';
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.snack:
        return 'Snack';
    }
  }

  String get icon {
    switch (this) {
      case MealType.breakfast:
        return '🌅';
      case MealType.lunch:
        return '☀️';
      case MealType.dinner:
        return '🌙';
      case MealType.snack:
        return '🍎';
    }
  }
}

/// Exercise intensity for exercise logs (stored in metadata)
enum ExerciseIntensity {
  light('light'),
  moderate('moderate'),
  intense('intense');

  const ExerciseIntensity(this.value);
  final String value;

  static ExerciseIntensity fromString(String value) {
    return ExerciseIntensity.values.firstWhere(
      (e) => e.value == value.toLowerCase(),
      orElse: () => ExerciseIntensity.moderate,
    );
  }

  String get displayName {
    switch (this) {
      case ExerciseIntensity.light:
        return 'Light';
      case ExerciseIntensity.moderate:
        return 'Moderate';
      case ExerciseIntensity.intense:
        return 'Intense';
    }
  }
}

/// Daily log entity matching Supabase schema
class DailyLog extends Equatable {
  const DailyLog({
    required this.id,
    required this.patientId,
    required this.logDate,
    required this.logType,
    required this.title,
    this.description,
    this.metadata,
    this.loggedAt,
    this.createdAt,
  });

  final String id;
  final String patientId;
  final DateTime logDate;
  final LogType logType;
  final String title;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime? loggedAt;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        patientId,
        logDate,
        logType,
        title,
        description,
        metadata,
        loggedAt,
        createdAt,
      ];

  /// Get category for display (alias for logType.displayName)
  String get category => logType.displayName;

  /// Get icon for log type
  String get icon => logType.icon;

  /// Helper: Get meal type from metadata (for food logs)
  MealType? get mealType {
    if (logType != LogType.food || metadata == null) return null;
    final value = metadata!['meal_type'] as String?;
    return value != null ? MealType.fromString(value) : null;
  }

  /// Helper: Get carbs from metadata (for food logs)
  int? get carbsGrams {
    if (metadata == null) return null;
    return metadata!['carbs_grams'] as int?;
  }

  /// Helper: Get calories from metadata
  int? get calories {
    if (metadata == null) return null;
    return metadata!['calories'] as int?;
  }

  /// Helper: Get sleep hours from metadata (for sleep logs)
  double? get sleepHours {
    if (logType != LogType.sleep || metadata == null) return null;
    final value = metadata!['hours'];
    if (value == null) return null;
    return (value as num).toDouble();
  }

  /// Helper: Get sleep quality from metadata (for sleep logs)
  int? get sleepQuality {
    if (metadata == null) return null;
    return metadata!['quality'] as int?;
  }

  /// Helper: Get exercise duration from metadata (for exercise logs)
  int? get exerciseDuration {
    if (logType != LogType.exercise || metadata == null) return null;
    return metadata!['duration_minutes'] as int?;
  }

  /// Helper: Get exercise intensity from metadata
  ExerciseIntensity? get exerciseIntensity {
    if (metadata == null) return null;
    final value = metadata!['intensity'] as String?;
    return value != null ? ExerciseIntensity.fromString(value) : null;
  }

  /// Helper: Get stress level from metadata
  int? get stressLevel {
    if (metadata == null) return null;
    return metadata!['stress_level'] as int?;
  }

  /// Helper: Get amount in ml (for water/alcohol logs)
  int? get amountMl {
    if (metadata == null) return null;
    return metadata!['amount_ml'] as int?;
  }

  DailyLog copyWith({
    String? id,
    String? patientId,
    DateTime? logDate,
    LogType? logType,
    String? title,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? loggedAt,
    DateTime? createdAt,
  }) {
    return DailyLog(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      logDate: logDate ?? this.logDate,
      logType: logType ?? this.logType,
      title: title ?? this.title,
      description: description ?? this.description,
      metadata: metadata ?? this.metadata,
      loggedAt: loggedAt ?? this.loggedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
