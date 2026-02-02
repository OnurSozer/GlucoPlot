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

/// Loaded state with data
class DailyLogLoaded extends DailyLogState {
  const DailyLogLoaded({
    required this.logs,
    this.selectedDate,
    this.filterLogType,
    this.isRefreshing = false,
    this.isSubmitting = false,
    this.submitSuccess = false,
    this.error,
  });

  final List<DailyLog> logs;
  final DateTime? selectedDate;
  final LogType? filterLogType;
  final bool isRefreshing;
  final bool isSubmitting;
  final bool submitSuccess;
  final String? error;

  @override
  List<Object?> get props => [
        logs,
        selectedDate,
        filterLogType,
        isRefreshing,
        isSubmitting,
        submitSuccess,
        error,
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
  }) {
    return DailyLogLoaded(
      logs: logs ?? this.logs,
      selectedDate: selectedDate ?? this.selectedDate,
      filterLogType: clearFilter ? null : (filterLogType ?? this.filterLogType),
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? false,
      error: error,
    );
  }
}

/// Error state
class DailyLogError extends DailyLogState {
  const DailyLogError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
