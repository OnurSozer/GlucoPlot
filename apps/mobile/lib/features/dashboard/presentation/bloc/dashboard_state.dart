part of 'dashboard_bloc.dart';

/// Base class for dashboard states
sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

/// Loading state
class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

/// Loaded state with data
class DashboardLoaded extends DashboardState {
  const DashboardLoaded({
    required this.latestMeasurements,
    required this.activeAlerts,
    required this.todayLogs,
    this.lastGlucose,
    this.glucoseTrend,
    this.medicationTakenToday,
    this.selectedChartType = MeasurementType.glucose,
    this.chartData = const [],
    this.isRefreshing = false,
    this.error,
  });

  final Map<MeasurementType, Measurement> latestMeasurements;
  final List<RiskAlert> activeAlerts;
  final List<DailyLog> todayLogs;
  final Measurement? lastGlucose;
  final MeasurementTrend? glucoseTrend;
  final bool? medicationTakenToday;
  final MeasurementType selectedChartType;
  final List<Measurement> chartData;
  final bool isRefreshing;
  final String? error;

  @override
  List<Object?> get props => [
        latestMeasurements,
        activeAlerts,
        todayLogs,
        lastGlucose,
        glucoseTrend,
        medicationTakenToday,
        selectedChartType,
        chartData,
        isRefreshing,
        error,
      ];

  DashboardLoaded copyWith({
    Map<MeasurementType, Measurement>? latestMeasurements,
    List<RiskAlert>? activeAlerts,
    List<DailyLog>? todayLogs,
    Measurement? lastGlucose,
    MeasurementTrend? glucoseTrend,
    bool? medicationTakenToday,
    MeasurementType? selectedChartType,
    List<Measurement>? chartData,
    bool? isRefreshing,
    String? error,
  }) {
    return DashboardLoaded(
      latestMeasurements: latestMeasurements ?? this.latestMeasurements,
      activeAlerts: activeAlerts ?? this.activeAlerts,
      todayLogs: todayLogs ?? this.todayLogs,
      lastGlucose: lastGlucose ?? this.lastGlucose,
      glucoseTrend: glucoseTrend ?? this.glucoseTrend,
      medicationTakenToday: medicationTakenToday ?? this.medicationTakenToday,
      selectedChartType: selectedChartType ?? this.selectedChartType,
      chartData: chartData ?? this.chartData,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: error,
    );
  }
}

/// Error state
class DashboardError extends DashboardState {
  const DashboardError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
