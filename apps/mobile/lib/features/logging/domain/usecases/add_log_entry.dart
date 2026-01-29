import '../entities/daily_log.dart';
import '../repositories/daily_log_repository.dart';

/// Use case for adding a meal log
class AddMealLog {
  const AddMealLog(this._repository);

  final DailyLogRepository _repository;

  Future<DailyLogResult<DailyLog>> call({
    required DateTime logDate,
    required MealType mealType,
    String? mealDescription,
    int? carbsGrams,
    String? notes,
  }) {
    return _repository.addMealLog(
      logDate: logDate,
      mealType: mealType,
      mealDescription: mealDescription,
      carbsGrams: carbsGrams,
      notes: notes,
    );
  }
}

/// Use case for adding an exercise log
class AddExerciseLog {
  const AddExerciseLog(this._repository);

  final DailyLogRepository _repository;

  Future<DailyLogResult<DailyLog>> call({
    required DateTime logDate,
    required String exerciseType,
    required int durationMinutes,
    ExerciseIntensity? intensity,
    String? notes,
  }) {
    return _repository.addExerciseLog(
      logDate: logDate,
      exerciseType: exerciseType,
      durationMinutes: durationMinutes,
      intensity: intensity,
      notes: notes,
    );
  }
}

/// Use case for adding a medication log
class AddMedicationLog {
  const AddMedicationLog(this._repository);

  final DailyLogRepository _repository;

  Future<DailyLogResult<DailyLog>> call({
    required DateTime logDate,
    required bool taken,
    String? medicationNotes,
    String? notes,
  }) {
    return _repository.addMedicationLog(
      logDate: logDate,
      taken: taken,
      medicationNotes: medicationNotes,
      notes: notes,
    );
  }
}

/// Use case for adding a sleep log
class AddSleepLog {
  const AddSleepLog(this._repository);

  final DailyLogRepository _repository;

  Future<DailyLogResult<DailyLog>> call({
    required DateTime logDate,
    required double hours,
    int? quality,
    String? notes,
  }) {
    return _repository.addSleepLog(
      logDate: logDate,
      hours: hours,
      quality: quality,
      notes: notes,
    );
  }
}
