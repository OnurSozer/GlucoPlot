import '../entities/daily_log.dart';
import '../repositories/daily_log_repository.dart';

/// Use case for adding a daily log entry
class AddLogEntry {
  const AddLogEntry(this._repository);

  final DailyLogRepository _repository;

  Future<DailyLogResult<DailyLog>> call({
    required DateTime logDate,
    required LogType logType,
    required String title,
    String? description,
    Map<String, dynamic>? metadata,
    DateTime? loggedAt,
  }) {
    return _repository.addLog(
      logDate: logDate,
      logType: logType,
      title: title,
      description: description,
      metadata: metadata,
      loggedAt: loggedAt,
    );
  }
}
