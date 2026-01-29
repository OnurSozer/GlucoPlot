import '../entities/daily_log.dart';

/// Result type for daily log operations
sealed class DailyLogResult<T> {
  const DailyLogResult();
}

class DailyLogSuccess<T> extends DailyLogResult<T> {
  const DailyLogSuccess(this.data);
  final T data;
}

class DailyLogFailure<T> extends DailyLogResult<T> {
  const DailyLogFailure(this.message);
  final String message;
}

/// Daily log repository interface
abstract class DailyLogRepository {
  /// Get all daily logs for current patient
  Future<DailyLogResult<List<DailyLog>>> getLogs({
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    String? category, // meal, exercise, medication, sleep
    int? limit,
    int? offset,
  });

  /// Get a single log by ID
  Future<DailyLogResult<DailyLog>> getLog(String id);

  /// Get logs for a specific date
  Future<DailyLogResult<List<DailyLog>>> getLogsForDate(DateTime date);

  /// Add a meal log
  Future<DailyLogResult<DailyLog>> addMealLog({
    required DateTime logDate,
    required MealType mealType,
    String? mealDescription,
    int? carbsGrams,
    String? notes,
  });

  /// Add an exercise log
  Future<DailyLogResult<DailyLog>> addExerciseLog({
    required DateTime logDate,
    required String exerciseType,
    required int durationMinutes,
    ExerciseIntensity? intensity,
    String? notes,
  });

  /// Add a medication log
  Future<DailyLogResult<DailyLog>> addMedicationLog({
    required DateTime logDate,
    required bool taken,
    String? medicationNotes,
    String? notes,
  });

  /// Add a sleep log
  Future<DailyLogResult<DailyLog>> addSleepLog({
    required DateTime logDate,
    required double hours,
    int? quality, // 1-5
    String? notes,
  });

  /// Add a general note
  Future<DailyLogResult<DailyLog>> addNote({
    required DateTime logDate,
    required String notes,
    int? stressLevel, // 1-5
  });

  /// Update a log
  Future<DailyLogResult<DailyLog>> updateLog(DailyLog log);

  /// Delete a log
  Future<DailyLogResult<void>> deleteLog(String id);
}
