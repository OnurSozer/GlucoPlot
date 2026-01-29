import '../../domain/entities/daily_log.dart';

/// Daily log model for data layer with JSON serialization
class DailyLogModel extends DailyLog {
  const DailyLogModel({
    required super.id,
    required super.patientId,
    required super.logDate,
    super.mealType,
    super.mealDescription,
    super.carbsGrams,
    super.exerciseType,
    super.exerciseDurationMinutes,
    super.exerciseIntensity,
    super.medicationTaken,
    super.medicationNotes,
    super.sleepHours,
    super.sleepQuality,
    super.stressLevel,
    super.notes,
    super.createdAt,
  });

  /// Create from JSON (Supabase response)
  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      mealType: json['meal_type'] != null
          ? MealType.fromString(json['meal_type'] as String)
          : null,
      mealDescription: json['meal_description'] as String?,
      carbsGrams: json['carbs_grams'] as int?,
      exerciseType: json['exercise_type'] as String?,
      exerciseDurationMinutes: json['exercise_duration_minutes'] as int?,
      exerciseIntensity: json['exercise_intensity'] != null
          ? ExerciseIntensity.fromString(json['exercise_intensity'] as String)
          : null,
      medicationTaken: json['medication_taken'] as bool?,
      medicationNotes: json['medication_notes'] as String?,
      sleepHours: json['sleep_hours'] != null
          ? (json['sleep_hours'] as num).toDouble()
          : null,
      sleepQuality: json['sleep_quality'] as int?,
      stressLevel: json['stress_level'] as int?,
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Create from entity
  factory DailyLogModel.fromEntity(DailyLog log) {
    return DailyLogModel(
      id: log.id,
      patientId: log.patientId,
      logDate: log.logDate,
      mealType: log.mealType,
      mealDescription: log.mealDescription,
      carbsGrams: log.carbsGrams,
      exerciseType: log.exerciseType,
      exerciseDurationMinutes: log.exerciseDurationMinutes,
      exerciseIntensity: log.exerciseIntensity,
      medicationTaken: log.medicationTaken,
      medicationNotes: log.medicationNotes,
      sleepHours: log.sleepHours,
      sleepQuality: log.sleepQuality,
      stressLevel: log.stressLevel,
      notes: log.notes,
      createdAt: log.createdAt,
    );
  }

  /// Convert to JSON for Supabase insert
  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'log_date': logDate.toIso8601String().split('T')[0],
      if (mealType != null) 'meal_type': mealType!.value,
      if (mealDescription != null) 'meal_description': mealDescription,
      if (carbsGrams != null) 'carbs_grams': carbsGrams,
      if (exerciseType != null) 'exercise_type': exerciseType,
      if (exerciseDurationMinutes != null) 'exercise_duration_minutes': exerciseDurationMinutes,
      if (exerciseIntensity != null) 'exercise_intensity': exerciseIntensity!.value,
      if (medicationTaken != null) 'medication_taken': medicationTaken,
      if (medicationNotes != null) 'medication_notes': medicationNotes,
      if (sleepHours != null) 'sleep_hours': sleepHours,
      if (sleepQuality != null) 'sleep_quality': sleepQuality,
      if (stressLevel != null) 'stress_level': stressLevel,
      if (notes != null) 'notes': notes,
    };
  }
}
