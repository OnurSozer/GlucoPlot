import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/daily_log.dart';
import '../../domain/repositories/daily_log_repository.dart';
import '../datasources/daily_log_remote_datasource.dart';
import '../models/daily_log_model.dart';

/// Implementation of DailyLogRepository
class DailyLogRepositoryImpl implements DailyLogRepository {
  const DailyLogRepositoryImpl(this._remoteDataSource);

  final DailyLogRemoteDataSource _remoteDataSource;

  String? get _currentPatientId {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;
    // Patient ID is stored in user metadata, not the auth user ID
    final metadata = session.user.userMetadata;
    return metadata?['patient_id'] as String?;
  }

  @override
  Future<DailyLogResult<List<DailyLog>>> getLogs({
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    int? limit,
    int? offset,
  }) async {
    try {
      final patientId = _currentPatientId;
      if (patientId == null) {
        return const DailyLogFailure('Not authenticated');
      }

      final logs = await _remoteDataSource.getLogs(
        patientId: patientId,
        date: date,
        startDate: startDate,
        endDate: endDate,
        category: category,
        limit: limit,
        offset: offset,
      );

      return DailyLogSuccess(logs);
    } catch (e) {
      return DailyLogFailure('Failed to get logs: $e');
    }
  }

  @override
  Future<DailyLogResult<DailyLog>> getLog(String id) async {
    try {
      final log = await _remoteDataSource.getLog(id);
      if (log == null) {
        return const DailyLogFailure('Log not found');
      }
      return DailyLogSuccess(log);
    } catch (e) {
      return DailyLogFailure('Failed to get log: $e');
    }
  }

  @override
  Future<DailyLogResult<List<DailyLog>>> getLogsForDate(DateTime date) async {
    try {
      final patientId = _currentPatientId;
      if (patientId == null) {
        return const DailyLogFailure('Not authenticated');
      }

      final logs = await _remoteDataSource.getLogsForDate(
        patientId: patientId,
        date: date,
      );

      return DailyLogSuccess(logs);
    } catch (e) {
      return DailyLogFailure('Failed to get logs for date: $e');
    }
  }

  @override
  Future<DailyLogResult<DailyLog>> addMealLog({
    required DateTime logDate,
    required MealType mealType,
    String? mealDescription,
    int? carbsGrams,
    String? notes,
  }) async {
    try {
      final patientId = _currentPatientId;
      if (patientId == null) {
        return const DailyLogFailure('Not authenticated');
      }

      final model = DailyLogModel(
        id: '',
        patientId: patientId,
        logDate: logDate,
        mealType: mealType,
        mealDescription: mealDescription,
        carbsGrams: carbsGrams,
        notes: notes,
      );

      final result = await _remoteDataSource.addLog(model);
      return DailyLogSuccess(result);
    } catch (e) {
      return DailyLogFailure('Failed to add meal log: $e');
    }
  }

  @override
  Future<DailyLogResult<DailyLog>> addExerciseLog({
    required DateTime logDate,
    required String exerciseType,
    required int durationMinutes,
    ExerciseIntensity? intensity,
    String? notes,
  }) async {
    try {
      final patientId = _currentPatientId;
      if (patientId == null) {
        return const DailyLogFailure('Not authenticated');
      }

      final model = DailyLogModel(
        id: '',
        patientId: patientId,
        logDate: logDate,
        exerciseType: exerciseType,
        exerciseDurationMinutes: durationMinutes,
        exerciseIntensity: intensity,
        notes: notes,
      );

      final result = await _remoteDataSource.addLog(model);
      return DailyLogSuccess(result);
    } catch (e) {
      return DailyLogFailure('Failed to add exercise log: $e');
    }
  }

  @override
  Future<DailyLogResult<DailyLog>> addMedicationLog({
    required DateTime logDate,
    required bool taken,
    String? medicationNotes,
    String? notes,
  }) async {
    try {
      final patientId = _currentPatientId;
      if (patientId == null) {
        return const DailyLogFailure('Not authenticated');
      }

      final model = DailyLogModel(
        id: '',
        patientId: patientId,
        logDate: logDate,
        medicationTaken: taken,
        medicationNotes: medicationNotes,
        notes: notes,
      );

      final result = await _remoteDataSource.addLog(model);
      return DailyLogSuccess(result);
    } catch (e) {
      return DailyLogFailure('Failed to add medication log: $e');
    }
  }

  @override
  Future<DailyLogResult<DailyLog>> addSleepLog({
    required DateTime logDate,
    required double hours,
    int? quality,
    String? notes,
  }) async {
    try {
      final patientId = _currentPatientId;
      if (patientId == null) {
        return const DailyLogFailure('Not authenticated');
      }

      final model = DailyLogModel(
        id: '',
        patientId: patientId,
        logDate: logDate,
        sleepHours: hours,
        sleepQuality: quality,
        notes: notes,
      );

      final result = await _remoteDataSource.addLog(model);
      return DailyLogSuccess(result);
    } catch (e) {
      return DailyLogFailure('Failed to add sleep log: $e');
    }
  }

  @override
  Future<DailyLogResult<DailyLog>> addNote({
    required DateTime logDate,
    required String notes,
    int? stressLevel,
  }) async {
    try {
      final patientId = _currentPatientId;
      if (patientId == null) {
        return const DailyLogFailure('Not authenticated');
      }

      final model = DailyLogModel(
        id: '',
        patientId: patientId,
        logDate: logDate,
        stressLevel: stressLevel,
        notes: notes,
      );

      final result = await _remoteDataSource.addLog(model);
      return DailyLogSuccess(result);
    } catch (e) {
      return DailyLogFailure('Failed to add note: $e');
    }
  }

  @override
  Future<DailyLogResult<DailyLog>> updateLog(DailyLog log) async {
    try {
      final model = DailyLogModel.fromEntity(log);
      final result = await _remoteDataSource.updateLog(model);
      return DailyLogSuccess(result);
    } catch (e) {
      return DailyLogFailure('Failed to update log: $e');
    }
  }

  @override
  Future<DailyLogResult<void>> deleteLog(String id) async {
    try {
      await _remoteDataSource.deleteLog(id);
      return const DailyLogSuccess(null);
    } catch (e) {
      return DailyLogFailure('Failed to delete log: $e');
    }
  }
}
