part of 'daily_log_bloc.dart';

/// Base class for daily log states
sealed class DailyLogState extends Equatable {
  const DailyLogState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DailyLogInitial extends DailyLogState {
  const DailyLogInitial();
}

/// Loading state
class DailyLogLoading extends DailyLogState {
  const DailyLogLoading();
}

/// Loaded state with data and per-date cache for SWR pattern
class DailyLogLoaded extends DailyLogState {
  const DailyLogLoaded({
    required this.logs,
    this.selectedDate,
    this.filterLogType,
    this.isRefreshing = false,
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.error,
    this.logsCache = const {}, // Per-date cache: dateString -> logs
  });

  final List<DailyLog> logs;
  final DateTime? selectedDate;
  final LogType? filterLogType;
  final bool isRefreshing;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? error;
  final Map<String, List<DailyLog>> logsCache; // Cache logs by date string

  /// Get cache key for current date
  String? get currentCacheKey => selectedDate != null
      ? '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}'
      : null;

  @override
  List<Object?> get props => [
        logs,
        selectedDate,
        filterLogType,
        isRefreshing,
        isSubmitting,
        submitSuccess,
        error,
        logsCache,
      ];

  DailyLogLoaded copyWith({
    List<DailyLog>? logs,
    DateTime? selectedDate,
    LogType? filterLogType,
    bool clearFilter = false,
    bool? isRefreshing,
    bool? isSubmitting,
    bool? submitSuccess,
    String? error,
    Map<String, List<DailyLog>>? logsCache,
  }) {
    return DailyLogLoaded(
      logs: logs ?? this.logs,
      selectedDate: selectedDate ?? this.selectedDate,
      filterLogType: clearFilter ? null : (filterLogType ?? this.filterLogType),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? false,
      error: error,
      logsCache: logsCache ?? this.logsCache,
    );
  }

  /// Update cache for a specific date
  DailyLogLoaded withCachedLogs(String dateKey, List<DailyLog> logs) {
    final newCache = Map<String, List<DailyLog>>.from(logsCache);
    newCache[dateKey] = logs;
    // Keep only last 7 days in cache to prevent memory bloat
    if (newCache.length > 7) {
      final sortedKeys = newCache.keys.toList()..sort();
      newCache.remove(sortedKeys.first);
    }
    return copyWith(logsCache: newCache);
  }
}

/// Error state
class DailyLogError extends DailyLogState {
  const DailyLogError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
