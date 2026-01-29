import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../measurements/domain/entities/measurement.dart';
import '../../../logging/domain/entities/daily_log.dart';
import '../../domain/entities/risk_alert.dart';
import '../../domain/repositories/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// Dashboard BLoC for managing dashboard state
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc({required DashboardRepository repository})
      : _repository = repository,
        super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoadRequested);
    on<DashboardRefreshRequested>(_onRefreshRequested);
    on<DashboardAlertAcknowledged>(_onAlertAcknowledged);
    on<DashboardChartTypeChanged>(_onChartTypeChanged);
  }

  final DashboardRepository _repository;

  Future<void> _onLoadRequested(
    DashboardLoadRequested event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    final result = await _repository.getSummary();

    switch (result) {
      case DashboardSuccess(:final data):
        emit(DashboardLoaded(
          latestMeasurements: data.latestMeasurements,
          activeAlerts: data.activeAlerts,
          todayLogs: data.todayLogs,
          lastGlucose: data.lastGlucose,
          glucoseTrend: data.glucoseTrend,
          medicationTakenToday: data.medicationTakenToday,
        ));
      case DashboardFailure(:final message):
        emit(DashboardError(message));
    }
  }

  Future<void> _onRefreshRequested(
    DashboardRefreshRequested event,
    Emitter<DashboardState> emit,
  ) async {
    // Keep existing data while refreshing
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    }

    final result = await _repository.getSummary();

    switch (result) {
      case DashboardSuccess(:final data):
        emit(DashboardLoaded(
          latestMeasurements: data.latestMeasurements,
          activeAlerts: data.activeAlerts,
          todayLogs: data.todayLogs,
          lastGlucose: data.lastGlucose,
          glucoseTrend: data.glucoseTrend,
          medicationTakenToday: data.medicationTakenToday,
        ));
      case DashboardFailure(:final message):
        if (currentState is DashboardLoaded) {
          emit(currentState.copyWith(isRefreshing: false, error: message));
        } else {
          emit(DashboardError(message));
        }
    }
  }

  Future<void> _onAlertAcknowledged(
    DashboardAlertAcknowledged event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    final result = await _repository.acknowledgeAlert(event.alertId);

    switch (result) {
      case DashboardSuccess(:final data):
        final updatedAlerts = currentState.activeAlerts
            .map((a) => a.id == event.alertId ? data : a)
            .where((a) => a.status == AlertStatus.active)
            .toList();
        emit(currentState.copyWith(activeAlerts: updatedAlerts));
      case DashboardFailure(:final message):
        emit(currentState.copyWith(error: message));
    }
  }

  Future<void> _onChartTypeChanged(
    DashboardChartTypeChanged event,
    Emitter<DashboardState> emit,
  ) async {
    final currentState = state;
    if (currentState is! DashboardLoaded) return;

    emit(currentState.copyWith(selectedChartType: event.type));

    // Load chart data for the selected type
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 7));

    final result = await _repository.getChartData(
      type: event.type,
      startDate: startDate,
      endDate: now,
    );

    switch (result) {
      case DashboardSuccess(:final data):
        emit(currentState.copyWith(
          selectedChartType: event.type,
          chartData: data,
        ));
      case DashboardFailure(:final message):
        emit(currentState.copyWith(error: message));
    }
  }
}
