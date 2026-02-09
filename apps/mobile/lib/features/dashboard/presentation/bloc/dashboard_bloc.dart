import 'package:equatable/equatable.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import '../../../measurements/domain/entities/measurement.dart';
import '../../../logging/domain/entities/daily_log.dart';
import '../../domain/entities/risk_alert.dart';
import '../../domain/repositories/dashboard_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

/// Dashboard BLoC for managing dashboard state
/// Uses HydratedBloc for SWR-like caching - shows cached data instantly
class DashboardBloc extends HydratedBloc<DashboardEvent, DashboardState> {
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

  /// Restore state from cache for SWR pattern
  @override
  DashboardState? fromJson(Map<String, dynamic> json) {
    try {
      // Deserialize latestMeasurements map
      final latestMeasurementsJson =
          json['latestMeasurements'] as Map<String, dynamic>?;
      final latestMeasurements = <MeasurementType, Measurement>{};
      if (latestMeasurementsJson != null) {
        for (final entry in latestMeasurementsJson.entries) {
          final type = MeasurementType.fromString(entry.key);
          final measurement =
              Measurement.fromJson(entry.value as Map<String, dynamic>);
          latestMeasurements[type] = measurement;
        }
      }

      // Deserialize activeAlerts list
      final alertsJson = json['activeAlerts'] as List<dynamic>?;
      final activeAlerts = alertsJson
              ?.map((e) => RiskAlert.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      // Deserialize todayLogs list
      final logsJson = json['todayLogs'] as List<dynamic>?;
      final todayLogs = logsJson
              ?.map((e) => DailyLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [];

      // Deserialize lastGlucose
      final lastGlucoseJson = json['lastGlucose'] as Map<String, dynamic>?;
      final lastGlucose = lastGlucoseJson != null
          ? Measurement.fromJson(lastGlucoseJson)
          : null;

      // Deserialize glucoseTrend
      final glucoseTrendStr = json['glucoseTrend'] as String?;
      final glucoseTrend = MeasurementTrend.fromString(glucoseTrendStr);

      return DashboardLoaded(
        latestMeasurements: latestMeasurements,
        activeAlerts: activeAlerts,
        todayLogs: todayLogs,
        lastGlucose: lastGlucose,
        glucoseTrend: glucoseTrend,
        medicationTakenToday: json['medicationTakenToday'] as bool?,
      );
    } catch (e) {
      return null;
    }
  }

  /// Save state to cache for SWR pattern
  @override
  Map<String, dynamic>? toJson(DashboardState state) {
    if (state is DashboardLoaded) {
      // Serialize latestMeasurements map
      final latestMeasurementsJson = <String, dynamic>{};
      for (final entry in state.latestMeasurements.entries) {
        latestMeasurementsJson[entry.key.value] = entry.value.toJson();
      }

      return {
        'latestMeasurements': latestMeasurementsJson,
        'activeAlerts': state.activeAlerts.map((e) => e.toJson()).toList(),
        'todayLogs': state.todayLogs.map((e) => e.toJson()).toList(),
        'lastGlucose': state.lastGlucose?.toJson(),
        'glucoseTrend': state.glucoseTrend?.name,
        'medicationTakenToday': state.medicationTakenToday,
        'cachedAt': DateTime.now().toIso8601String(),
      };
    }
    return null;
  }
}
