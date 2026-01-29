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
    on<DailyLogMealAdded>(_onMealAdded);
    on<DailyLogExerciseAdded>(_onExerciseAdded);
    on<DailyLogMedicationAdded>(_onMedicationAdded);
    on<DailyLogSleepAdded>(_onSleepAdded);
    on<DailyLogNoteAdded>(_onNoteAdded);
    on<DailyLogDeleteRequested>(_onDeleteRequested);
  }

  final DailyLogRepository _repository;

  Future<void> _onLoadRequested(
    DailyLogLoadRequested event,
    Emitter<DailyLogState> emit,
  ) async {
    emit(const DailyLogLoading());

    final result = await _repository.getLogs(
      date: event.date,
      category: event.category,
      limit: 50,
    );

    switch (result) {
      case DailyLogSuccess(:final data):
        emit(DailyLogLoaded(
          logs: data,
          selectedDate: event.date,
          filterCategory: event.category,
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
      category: currentState.filterCategory,
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
    final category = currentState is DailyLogLoaded
        ? currentState.filterCategory
        : null;

    emit(const DailyLogLoading());

    final result = await _repository.getLogs(
      date: event.date,
      category: category,
      limit: 50,
    );

    switch (result) {
      case DailyLogSuccess(:final data):
        emit(DailyLogLoaded(
          logs: data,
          selectedDate: event.date,
          filterCategory: category,
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

    final result = await _repository.getLogs(
      date: date,
      category: event.category,
      limit: 50,
    );

    switch (result) {
      case DailyLogSuccess(:final data):
        emit(DailyLogLoaded(
          logs: data,
          selectedDate: date,
          filterCategory: event.category,
        ));
      case DailyLogFailure(:final message):
        emit(DailyLogError(message));
    }
  }

  Future<void> _onMealAdded(
    DailyLogMealAdded event,
    Emitter<DailyLogState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyLogLoaded) return;

    emit(currentState.copyWith(isSubmitting: true));

    final result = await _repository.addMealLog(
      logDate: event.logDate,
      mealType: event.mealType,
      mealDescription: event.mealDescription,
      carbsGrams: event.carbsGrams,
      notes: event.notes,
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

  Future<void> _onExerciseAdded(
    DailyLogExerciseAdded event,
    Emitter<DailyLogState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyLogLoaded) return;

    emit(currentState.copyWith(isSubmitting: true));

    final result = await _repository.addExerciseLog(
      logDate: event.logDate,
      exerciseType: event.exerciseType,
      durationMinutes: event.durationMinutes,
      intensity: event.intensity,
      notes: event.notes,
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

  Future<void> _onMedicationAdded(
    DailyLogMedicationAdded event,
    Emitter<DailyLogState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyLogLoaded) return;

    emit(currentState.copyWith(isSubmitting: true));

    final result = await _repository.addMedicationLog(
      logDate: event.logDate,
      taken: event.taken,
      medicationNotes: event.medicationNotes,
      notes: event.notes,
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

  Future<void> _onSleepAdded(
    DailyLogSleepAdded event,
    Emitter<DailyLogState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyLogLoaded) return;

    emit(currentState.copyWith(isSubmitting: true));

    final result = await _repository.addSleepLog(
      logDate: event.logDate,
      hours: event.hours,
      quality: event.quality,
      notes: event.notes,
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

  Future<void> _onNoteAdded(
    DailyLogNoteAdded event,
    Emitter<DailyLogState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DailyLogLoaded) return;

    emit(currentState.copyWith(isSubmitting: true));

    final result = await _repository.addNote(
      logDate: event.logDate,
      notes: event.notes,
      stressLevel: event.stressLevel,
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
