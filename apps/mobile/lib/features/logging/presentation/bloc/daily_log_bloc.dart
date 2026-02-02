import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/daily_log.dart';
import '../../domain/repositories/daily_log_repository.dart';

part 'daily_log_event.dart';
part 'daily_log_state.dart';

/// Daily Log BLoC for managing daily log state
class DailyLogBloc extends Bloc<DailyLogEvent, DailyLogState> {
  DailyLogBloc({required DailyLogRepository repository})
      : _repository = repository,
        super(const DailyLogInitial()) {
    on<DailyLogLoadRequested>(_onLoadRequested);
    on<DailyLogRefreshRequested>(_onRefreshRequested);
    on<DailyLogDateChanged>(_onDateChanged);
    on<DailyLogCategoryFilterChanged>(_onCategoryFilterChanged);
    on<DailyLogAdded>(_onLogAdded);
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
    emit(const DailyLogLoading());

    final result = await _repository.getLogs(
      date: event.date,
      logType: event.logType,
      limit: 50,
    );

    switch (result) {
      case DailyLogSuccess(:final data):
        emit(DailyLogLoaded(
          logs: data,
          selectedDate: event.date,
          filterLogType: event.logType,
        ));
      case DailyLogFailure(:final message):
        emit(DailyLogError(message));
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

    emit(const DailyLogLoading());

    final result = await _repository.getLogs(
      date: event.date,
      logType: logType,
      limit: 50,
    );

    switch (result) {
      case DailyLogSuccess(:final data):
        emit(DailyLogLoaded(
          logs: data,
          selectedDate: event.date,
          filterLogType: logType,
        ));
      case DailyLogFailure(:final message):
        emit(DailyLogError(message));
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
}
