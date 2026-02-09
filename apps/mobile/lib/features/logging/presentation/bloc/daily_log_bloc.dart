import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../domain/entities/daily_log.dart';
import '../../domain/repositories/daily_log_repository.dart';

part 'daily_log_event.dart';
part 'daily_log_state.dart';

/// Daily Log BLoC for managing daily log state
/// Uses HydratedBloc for SWR-like caching - shows cached data instantly
class DailyLogBloc extends HydratedBloc<DailyLogEvent, DailyLogState> {
  DailyLogBloc({required DailyLogRepository repository})
      : _repository = repository,
        super(const DailyLogInitial()) {
    on<DailyLogLoadRequested>(_onLoadRequested);
    on<DailyLogRefreshRequested>(_onRefreshRequested);
    on<DailyLogDateChanged>(_onDateChanged);
    on<DailyLogCategoryFilterChanged>(_onCategoryFilterChanged);
    on<DailyLogAdded>(_onLogAdded);
    on<DailyLogUpdated>(_onLogUpdated);
    on<DailyLogDeleteRequested>(_onDeleteRequested);
  }

  final DailyLogRepository _repository;

  /// Convert string category to LogType
  LogType? _categoryToLogType(String? category) {
    if (category == null) return null;
    switch (category.toLowerCase()) {
      case 'meal':
      case 'food':
        return LogType.food;
      case 'sleep':
        return LogType.sleep;
      case 'exercise':
      case 'sports':
        return LogType.exercise;
      case 'medication':
      case 'medicine':
        return LogType.medication;
      case 'symptom':
        return LogType.symptom;
      case 'note':
      case 'stress':
        return LogType.note;
      default:
        return null;
    }
  }

  Future<void> _onLoadRequested(
    DailyLogLoadRequested event,
    Emitter<DailyLogState> emit,
  ) async {
    final currentState = state;
    final existingCache = currentState is DailyLogLoaded
        ? currentState.logsCache
        : <String, List<DailyLog>>{};

    // Generate cache key
    final dateKey = event.date != null
        ? '${event.date!.year}-${event.date!.month.toString().padLeft(2, '0')}-${event.date!.day.toString().padLeft(2, '0')}'
        : null;

    // SWR: Check for cached data
    final cachedLogs = dateKey != null ? existingCache[dateKey] : null;

    if (cachedLogs != null) {
      // Show cached data immediately, refresh in background
      emit(DailyLogLoaded(
        logs: cachedLogs,
        selectedDate: event.date,
        filterLogType: event.logType,
        isRefreshing: true,
        logsCache: existingCache,
      ));
    } else {
      emit(const DailyLogLoading());
    }

    final result = await _repository.getLogs(
      date: event.date,
      logType: event.logType,
      limit: 50,
    );

    switch (result) {
      case DailyLogSuccess(:final data):
        final newCache = Map<String, List<DailyLog>>.from(existingCache);
        if (dateKey != null) {
          newCache[dateKey] = data;
          if (newCache.length > 7) {
            final sortedKeys = newCache.keys.toList()..sort();
            newCache.remove(sortedKeys.first);
          }
        }
        emit(DailyLogLoaded(
          logs: data,
          selectedDate: event.date,
          filterLogType: event.logType,
          logsCache: newCache,
        ));
      case DailyLogFailure(:final message):
        if (cachedLogs != null) {
          emit(DailyLogLoaded(
            logs: cachedLogs,
            selectedDate: event.date,
            filterLogType: event.logType,
            isRefreshing: false,
            error: message,
            logsCache: existingCache,
          ));
        } else {
          emit(DailyLogError(message));
        }
    }
  }

  Future<void> _onRefreshRequested(
    DailyLogRefreshRequested event,
    Emitter<DailyLogState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyLogLoaded) return;

    emit(currentState.copyWith(isRefreshing: true));

    final result = await _repository.getLogs(
      date: currentState.selectedDate,
      logType: currentState.filterLogType,
      limit: 50,
    );

    switch (result) {
      case DailyLogSuccess(:final data):
        emit(currentState.copyWith(logs: data, isRefreshing: false));
      case DailyLogFailure(:final message):
        emit(currentState.copyWith(isRefreshing: false, error: message));
    }
  }

  Future<void> _onDateChanged(
    DailyLogDateChanged event,
    Emitter<DailyLogState> emit,
  ) async {
    final currentState = state;
    final logType = currentState is DailyLogLoaded
        ? currentState.filterLogType
        : null;
    final existingCache = currentState is DailyLogLoaded
        ? currentState.logsCache
        : <String, List<DailyLog>>{};

    // Generate cache key for the new date
    final dateKey = '${event.date.year}-${event.date.month.toString().padLeft(2, '0')}-${event.date.day.toString().padLeft(2, '0')}';

    // SWR: Check if we have cached data for this date
    final cachedLogs = existingCache[dateKey];

    if (cachedLogs != null) {
      // Show cached data immediately, then refresh in background
      emit(DailyLogLoaded(
        logs: cachedLogs,
        selectedDate: event.date,
        filterLogType: logType,
        isRefreshing: true, // Show refresh indicator
        logsCache: existingCache,
      ));
    } else {
      // No cache, show loading
      emit(const DailyLogLoading());
    }

    final result = await _repository.getLogs(
      date: event.date,
      logType: logType,
      limit: 50,
    );

    switch (result) {
      case DailyLogSuccess(:final data):
        // Update cache with fresh data
        final newCache = Map<String, List<DailyLog>>.from(existingCache);
        newCache[dateKey] = data;
        // Keep only last 7 days in cache
        if (newCache.length > 7) {
          final sortedKeys = newCache.keys.toList()..sort();
          newCache.remove(sortedKeys.first);
        }
        emit(DailyLogLoaded(
          logs: data,
          selectedDate: event.date,
          filterLogType: logType,
          logsCache: newCache,
        ));
      case DailyLogFailure(:final message):
        if (cachedLogs != null) {
          // Keep showing cached data but with error
          emit(DailyLogLoaded(
            logs: cachedLogs,
            selectedDate: event.date,
            filterLogType: logType,
            isRefreshing: false,
            error: message,
            logsCache: existingCache,
          ));
        } else {
          emit(DailyLogError(message));
        }
    }
  }

  Future<void> _onCategoryFilterChanged(
    DailyLogCategoryFilterChanged event,
    Emitter<DailyLogState> emit,
  ) async {
    final currentState = state;
    final date = currentState is DailyLogLoaded
        ? currentState.selectedDate
        : null;

    emit(const DailyLogLoading());

    final logType = _categoryToLogType(event.category);

    final result = await _repository.getLogs(
      date: date,
      logType: logType,
      limit: 50,
    );

    switch (result) {
      case DailyLogSuccess(:final data):
        emit(DailyLogLoaded(
          logs: data,
          selectedDate: date,
          filterLogType: logType,
        ));
      case DailyLogFailure(:final message):
        emit(DailyLogError(message));
    }
  }

  Future<void> _onLogAdded(
    DailyLogAdded event,
    Emitter<DailyLogState> emit,
  ) async {
    final currentState = state;

    // If not in loaded state, just add the log without updating UI list
    if (currentState is! DailyLogLoaded) {
      await _repository.addLog(
        logDate: event.logDate,
        logType: event.logType,
        title: event.title,
        description: event.description,
        metadata: event.metadata,
        loggedAt: event.loggedAt,
      );
      return;
    }

    emit(currentState.copyWith(isSubmitting: true));

    final result = await _repository.addLog(
      logDate: event.logDate,
      logType: event.logType,
      title: event.title,
      description: event.description,
      metadata: event.metadata,
      loggedAt: event.loggedAt,
    );

    switch (result) {
      case DailyLogSuccess(:final data):
        final updated = [data, ...currentState.logs];
        emit(currentState.copyWith(
          logs: updated,
          isSubmitting: false,
          submitSuccess: true,
        ));
      case DailyLogFailure(:final message):
        emit(currentState.copyWith(isSubmitting: false, error: message));
    }
  }

  Future<void> _onLogUpdated(
    DailyLogUpdated event,
    Emitter<DailyLogState> emit,
  ) async {
    final currentState = state;

    // Build updated log entity
    final updatedLog = DailyLog(
      id: event.id,
      patientId: '', // Will be ignored in update
      logDate: event.logDate,
      logType: event.logType,
      title: event.title,
      description: event.description,
      metadata: event.metadata,
      loggedAt: event.loggedAt,
    );

    // If not in loaded state, just update the log without updating UI list
    if (currentState is! DailyLogLoaded) {
      await _repository.updateLog(updatedLog);
      return;
    }

    emit(currentState.copyWith(isSubmitting: true));

    final result = await _repository.updateLog(updatedLog);

    switch (result) {
      case DailyLogSuccess(:final data):
        // Replace the log in the list with the updated version
        final updatedLogs = currentState.logs.map((log) {
          return log.id == event.id ? data : log;
        }).toList();
        emit(currentState.copyWith(
          logs: updatedLogs,
          isSubmitting: false,
          submitSuccess: true,
        ));
      case DailyLogFailure(:final message):
        emit(currentState.copyWith(isSubmitting: false, error: message));
    }
  }

  Future<void> _onDeleteRequested(
    DailyLogDeleteRequested event,
    Emitter<DailyLogState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyLogLoaded) return;

    final result = await _repository.deleteLog(event.id);

    switch (result) {
      case DailyLogSuccess():
        final updated = currentState.logs.where((l) => l.id != event.id).toList();
        emit(currentState.copyWith(logs: updated));
      case DailyLogFailure(:final message):
        emit(currentState.copyWith(error: message));
    }
  }

  /// Restore state from cache for SWR pattern
  @override
  DailyLogState? fromJson(Map<String, dynamic> json) {
    try {
      final logsJson = json['logs'] as List<dynamic>?;
      if (logsJson == null) return null;

      final logs = logsJson
          .map((e) => DailyLog.fromJson(e as Map<String, dynamic>))
          .toList();

      final selectedDateStr = json['selectedDate'] as String?;
      final filterLogTypeStr = json['filterLogType'] as String?;

      // Restore per-date cache
      final logsCacheJson = json['logsCache'] as Map<String, dynamic>?;
      final logsCache = <String, List<DailyLog>>{};
      if (logsCacheJson != null) {
        for (final entry in logsCacheJson.entries) {
          final dateKey = entry.key;
          final logsList = (entry.value as List<dynamic>)
              .map((e) => DailyLog.fromJson(e as Map<String, dynamic>))
              .toList();
          logsCache[dateKey] = logsList;
        }
      }

      return DailyLogLoaded(
        logs: logs,
        selectedDate:
            selectedDateStr != null ? DateTime.parse(selectedDateStr) : null,
        filterLogType:
            filterLogTypeStr != null ? LogType.fromString(filterLogTypeStr) : null,
        logsCache: logsCache,
      );
    } catch (e) {
      return null;
    }
  }

  /// Save state to cache for SWR pattern
  @override
  Map<String, dynamic>? toJson(DailyLogState state) {
    if (state is DailyLogLoaded) {
      // Serialize per-date cache
      final logsCacheJson = <String, dynamic>{};
      for (final entry in state.logsCache.entries) {
        logsCacheJson[entry.key] = entry.value.map((e) => e.toJson()).toList();
      }

      return {
        'logs': state.logs.map((e) => e.toJson()).toList(),
        'selectedDate': state.selectedDate?.toIso8601String(),
        'filterLogType': state.filterLogType?.value,
        'logsCache': logsCacheJson,
        'cachedAt': DateTime.now().toIso8601String(),
      };
    }
    return null;
  }
}
