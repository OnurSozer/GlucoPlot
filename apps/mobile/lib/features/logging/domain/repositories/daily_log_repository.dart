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
    LogType? logType,
    int? limit,
    int? offset,
  });

  /// Get a single log by ID
  Future<DailyLogResult<DailyLog>> getLog(String id);

  /// Get logs for a specific date
  Future<DailyLogResult<List<DailyLog>>> getLogsForDate(DateTime date);

  /// Add a log (generic method for all log types)
  /// Pass metadata for type-specific data (carbs, duration, etc.)
  Future<DailyLogResult<DailyLog>> addLog({
    required DateTime logDate,
    required LogType logType,
    required String title,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? loggedAt,
  });

  /// Update a log
  Future<DailyLogResult<DailyLog>> updateLog(DailyLog log);

  /// Delete a log
  Future<DailyLogResult<void>> deleteLog(String id);
}
