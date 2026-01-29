import 'package:equatable/equatable.dart';

/// Meal type enum
enum MealType {
  breakfast('breakfast'),
  lunch('lunch'),
  dinner('dinner'),
  snack('snack');

  const MealType(this.value);
  final String value;

  static MealType fromString(String value) {
    return MealType.values.firstWhere(
      (e) => e.value == value,
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

/// Exercise intensity enum
enum ExerciseIntensity {
  light('light'),
  moderate('moderate'),
  intense('intense');

  const ExerciseIntensity(this.value);
  final String value;

  static ExerciseIntensity fromString(String value) {
    return ExerciseIntensity.values.firstWhere(
      (e) => e.value == value,
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

/// Daily log entity representing patient's daily activities
class DailyLog extends Equatable {
  const DailyLog({
    required this.id,
    required this.patientId,
    required this.logDate,
    this.mealType,
    this.mealDescription,
    this.carbsGrams,
    this.exerciseType,
    this.exerciseDurationMinutes,
    this.exerciseIntensity,
    this.medicationTaken,
    this.medicationNotes,
    this.sleepHours,
    this.sleepQuality,
    this.stressLevel,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String patientId;
  final DateTime logDate;

  // Meal tracking
  final MealType? mealType;
  final String? mealDescription;
  final int? carbsGrams;

  // Exercise tracking
  final String? exerciseType;
  final int? exerciseDurationMinutes;
  final ExerciseIntensity? exerciseIntensity;

  // Medication tracking
  final bool? medicationTaken;
  final String? medicationNotes;

  // Sleep tracking
  final double? sleepHours;
  final int? sleepQuality; // 1-5 scale

  // Wellness
  final int? stressLevel; // 1-5 scale
  final String? notes;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        patientId,
        logDate,
        mealType,
        mealDescription,
        carbsGrams,
        exerciseType,
        exerciseDurationMinutes,
        exerciseIntensity,
        medicationTaken,
        medicationNotes,
        sleepHours,
        sleepQuality,
        stressLevel,
        notes,
        createdAt,
      ];

  /// Check if this is a meal log
  bool get isMealLog => mealType != null;

  /// Check if this is an exercise log
  bool get isExerciseLog => exerciseType != null;

  /// Check if this is a medication log
  bool get isMedicationLog => medicationTaken != null;

  /// Check if this is a sleep log
  bool get isSleepLog => sleepHours != null;

  /// Get log category for display
  String get category {
    if (isMealLog) return 'Meal';
    if (isExerciseLog) return 'Exercise';
    if (isMedicationLog) return 'Medication';
    if (isSleepLog) return 'Sleep';
    return 'Note';
  }

  /// Get icon for log type
  String get icon {
    if (isMealLog) return mealType!.icon;
    if (isExerciseLog) return '🏃';
    if (isMedicationLog) return '💊';
    if (isSleepLog) return '😴';
    return '📝';
  }

  DailyLog copyWith({
    String? id,
    String? patientId,
    DateTime? logDate,
    MealType? mealType,
    String? mealDescription,
    int? carbsGrams,
    String? exerciseType,
    int? exerciseDurationMinutes,
    ExerciseIntensity? exerciseIntensity,
    bool? medicationTaken,
    String? medicationNotes,
    double? sleepHours,
    int? sleepQuality,
    int? stressLevel,
    String? notes,
    DateTime? createdAt,
  }) {
    return DailyLog(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      logDate: logDate ?? this.logDate,
      mealType: mealType ?? this.mealType,
      mealDescription: mealDescription ?? this.mealDescription,
      carbsGrams: carbsGrams ?? this.carbsGrams,
      exerciseType: exerciseType ?? this.exerciseType,
      exerciseDurationMinutes: exerciseDurationMinutes ?? this.exerciseDurationMinutes,
      exerciseIntensity: exerciseIntensity ?? this.exerciseIntensity,
      medicationTaken: medicationTaken ?? this.medicationTaken,
      medicationNotes: medicationNotes ?? this.medicationNotes,
      sleepHours: sleepHours ?? this.sleepHours,
      sleepQuality: sleepQuality ?? this.sleepQuality,
      stressLevel: stressLevel ?? this.stressLevel,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
