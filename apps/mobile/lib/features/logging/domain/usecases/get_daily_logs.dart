import '../entities/daily_log.dart';
import '../repositories/daily_log_repository.dart';

/// Use case for getting daily logs
class GetDailyLogs {
  const GetDailyLogs(this._repository);

  final DailyLogRepository _repository;

  Future<DailyLogResult<List<DailyLog>>> call({
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    int? limit,
    int? offset,
  }) {
    return _repository.getLogs(
      date: date,
      startDate: startDate,
      endDate: endDate,
      category: category,
      limit: limit,
      offset: offset,
    );
  }
}

/// Use case for getting logs for a specific date
class GetLogsForDate {
  const GetLogsForDate(this._repository);

  final DailyLogRepository _repository;

  Future<DailyLogResult<List<DailyLog>>> call(DateTime date) {
    return _repository.getLogsForDate(date);
  }
}
