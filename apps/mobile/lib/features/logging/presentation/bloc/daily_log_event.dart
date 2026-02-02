part of 'daily_log_bloc.dart';

/// Base class for daily log events
sealed class DailyLogEvent extends Equatable {
  const DailyLogEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load logs
class DailyLogLoadRequested extends DailyLogEvent {
  const DailyLogLoadRequested({this.date, this.logType});
  final DateTime? date;
  final LogType? logType;

  @override
  List<Object?> get props => [date, logType];
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

/// Event to add a log (generic for all types)
class DailyLogAdded extends DailyLogEvent {
  const DailyLogAdded({
    required this.logDate,
    required this.logType,
    required this.title,
    this.description,
    this.metadata,
    this.loggedAt,
  });

  final DateTime logDate;
  final LogType logType;
  final String title;
  final String? description;
  final Map<String, dynamic>? metadata;
  final DateTime? loggedAt;

  @override
  List<Object?> get props => [logDate, logType, title, description, metadata, loggedAt];
}

/// Event to delete a log
class DailyLogDeleteRequested extends DailyLogEvent {
  const DailyLogDeleteRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}
