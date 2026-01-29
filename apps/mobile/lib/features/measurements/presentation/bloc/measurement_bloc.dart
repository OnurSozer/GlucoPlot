import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/measurement.dart';
import '../../domain/repositories/measurement_repository.dart';

part 'measurement_event.dart';
part 'measurement_state.dart';

/// Measurement BLoC for managing measurement state
class MeasurementBloc extends Bloc<MeasurementEvent, MeasurementState> {
  MeasurementBloc({required MeasurementRepository repository})
      : _repository = repository,
        super(const MeasurementInitial()) {
    on<MeasurementLoadRequested>(_onLoadRequested);
    on<MeasurementRefreshRequested>(_onRefreshRequested);
    on<MeasurementTypeFilterChanged>(_onTypeFilterChanged);
    on<MeasurementAddRequested>(_onAddRequested);
    on<MeasurementDeleteRequested>(_onDeleteRequested);
    on<MeasurementLoadMoreRequested>(_onLoadMoreRequested);
  }

  final MeasurementRepository _repository;
  static const _pageSize = 20;

  Future<void> _onLoadRequested(
    MeasurementLoadRequested event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(const MeasurementLoading());

    final result = await _repository.getMeasurements(
      type: event.type,
      limit: _pageSize,
    );

    switch (result) {
      case MeasurementSuccess(:final data):
        emit(MeasurementLoaded(
          measurements: data,
          filterType: event.type,
          hasMore: data.length >= _pageSize,
        ));
      case MeasurementFailure(:final message):
        emit(MeasurementError(message));
    }
  }

  Future<void> _onRefreshRequested(
    MeasurementRefreshRequested event,
    Emitter<MeasurementState> emit,
  ) async {
    final currentState = state;
    MeasurementType? filterType;

    if (currentState is MeasurementLoaded) {
      filterType = currentState.filterType;
      emit(currentState.copyWith(isRefreshing: true));
    }

    final result = await _repository.getMeasurements(
      type: filterType,
      limit: _pageSize,
    );

    switch (result) {
      case MeasurementSuccess(:final data):
        emit(MeasurementLoaded(
          measurements: data,
          filterType: filterType,
          hasMore: data.length >= _pageSize,
        ));
      case MeasurementFailure(:final message):
        if (currentState is MeasurementLoaded) {
          emit(currentState.copyWith(isRefreshing: false, error: message));
        } else {
          emit(MeasurementError(message));
        }
    }
  }

  Future<void> _onTypeFilterChanged(
    MeasurementTypeFilterChanged event,
    Emitter<MeasurementState> emit,
  ) async {
    emit(const MeasurementLoading());

    final result = await _repository.getMeasurements(
      type: event.type,
      limit: _pageSize,
    );

    switch (result) {
      case MeasurementSuccess(:final data):
        emit(MeasurementLoaded(
          measurements: data,
          filterType: event.type,
          hasMore: data.length >= _pageSize,
        ));
      case MeasurementFailure(:final message):
        emit(MeasurementError(message));
    }
  }

  Future<void> _onAddRequested(
    MeasurementAddRequested event,
    Emitter<MeasurementState> emit,
  ) async {
    final currentState = state;

    // If measurements are loaded, show submitting state
    if (currentState is MeasurementLoaded) {
      emit(currentState.copyWith(isSubmitting: true));
    }

    final result = await _repository.addMeasurement(
      type: event.type,
      value: event.value,
      secondaryValue: event.secondaryValue,
      unit: event.unit,
      measuredAt: event.measuredAt,
      notes: event.notes,
    );

    switch (result) {
      case MeasurementSuccess(:final data):
        // If we have a loaded state, update the list
        if (currentState is MeasurementLoaded) {
          if (currentState.filterType == null ||
              currentState.filterType == data.type) {
            final updated = [data, ...currentState.measurements];
            emit(currentState.copyWith(
              measurements: updated,
              isSubmitting: false,
              submitSuccess: true,
            ));
          } else {
            emit(currentState.copyWith(isSubmitting: false, submitSuccess: true));
          }
        } else {
          // If not loaded, just emit a loaded state with the new measurement
          emit(MeasurementLoaded(
            measurements: [data],
            hasMore: false,
            submitSuccess: true,
          ));
        }
      case MeasurementFailure(:final message):
        if (currentState is MeasurementLoaded) {
          emit(currentState.copyWith(isSubmitting: false, error: message));
        } else {
          emit(MeasurementError(message));
        }
    }
  }

  Future<void> _onDeleteRequested(
    MeasurementDeleteRequested event,
    Emitter<MeasurementState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MeasurementLoaded) return;

    final result = await _repository.deleteMeasurement(event.id);

    switch (result) {
      case MeasurementSuccess():
        final updated = currentState.measurements
            .where((m) => m.id != event.id)
            .toList();
        emit(currentState.copyWith(measurements: updated));
      case MeasurementFailure(:final message):
        emit(currentState.copyWith(error: message));
    }
  }

  Future<void> _onLoadMoreRequested(
    MeasurementLoadMoreRequested event,
    Emitter<MeasurementState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MeasurementLoaded || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await _repository.getMeasurements(
      type: currentState.filterType,
      limit: _pageSize,
      offset: currentState.measurements.length,
    );

    switch (result) {
      case MeasurementSuccess(:final data):
        final updated = [...currentState.measurements, ...data];
        emit(currentState.copyWith(
          measurements: updated,
          hasMore: data.length >= _pageSize,
          isLoadingMore: false,
        ));
      case MeasurementFailure(:final message):
        emit(currentState.copyWith(isLoadingMore: false, error: message));
    }
  }
}
