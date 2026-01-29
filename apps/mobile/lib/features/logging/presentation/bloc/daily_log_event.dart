part of 'daily_log_bloc.dart';

/// Base class for daily log events
sealed class DailyLogEvent extends Equatable {
  const DailyLogEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load logs
class DailyLogLoadRequested extends DailyLogEvent {
  const DailyLogLoadRequested({this.date, this.category});
  final DateTime? date;
  final String? category;

  @override
  List<Object?> get props => [date, category];
}

/// Event to refresh logs
class DailyLogRefreshRequested extends DailyLogEvent {
  const DailyLogRefreshRequested();
}

/// Event to change date
class DailyLogDateChanged extends DailyLogEvent {
  const DailyLogDateChanged(this.date);
  final DateTime date;

  @override
  List<Object?> get props => [date];
}

/// Event to change category filter
class DailyLogCategoryFilterChanged extends DailyLogEvent {
  const DailyLogCategoryFilterChanged(this.category);
  final String? category;

  @override
  List<Object?> get props => [category];
}

/// Event to add a meal log
class DailyLogMealAdded extends DailyLogEvent {
  const DailyLogMealAdded({
    required this.logDate,
    required this.mealType,
    this.mealDescription,
    this.carbsGrams,
    this.notes,
  });

  final DateTime logDate;
  final MealType mealType;
  final String? mealDescription;
  final int? carbsGrams;
  final String? notes;

  @override
  List<Object?> get props => [logDate, mealType, mealDescription, carbsGrams, notes];
}

/// Event to add an exercise log
class DailyLogExerciseAdded extends DailyLogEvent {
  const DailyLogExerciseAdded({
    required this.logDate,
    required this.exerciseType,
    required this.durationMinutes,
    this.intensity,
    this.notes,
  });

  final DateTime logDate;
  final String exerciseType;
  final int durationMinutes;
  final ExerciseIntensity? intensity;
  final String? notes;

  @override
  List<Object?> get props => [logDate, exerciseType, durationMinutes, intensity, notes];
}

/// Event to add a medication log
class DailyLogMedicationAdded extends DailyLogEvent {
  const DailyLogMedicationAdded({
    required this.logDate,
    required this.taken,
    this.medicationNotes,
    this.notes,
  });

  final DateTime logDate;
  final bool taken;
  final String? medicationNotes;
  final String? notes;

  @override
  List<Object?> get props => [logDate, taken, medicationNotes, notes];
}

/// Event to add a sleep log
class DailyLogSleepAdded extends DailyLogEvent {
  const DailyLogSleepAdded({
    required this.logDate,
    required this.hours,
    this.quality,
    this.notes,
  });

  final DateTime logDate;
  final double hours;
  final int? quality;
  final String? notes;

  @override
  List<Object?> get props => [logDate, hours, quality, notes];
}

/// Event to add a note
class DailyLogNoteAdded extends DailyLogEvent {
  const DailyLogNoteAdded({
    required this.logDate,
    required this.notes,
    this.stressLevel,
  });

  final DateTime logDate;
  final String notes;
  final int? stressLevel;

  @override
  List<Object?> get props => [logDate, notes, stressLevel];
}

/// Event to delete a log
class DailyLogDeleteRequested extends DailyLogEvent {
  const DailyLogDeleteRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
