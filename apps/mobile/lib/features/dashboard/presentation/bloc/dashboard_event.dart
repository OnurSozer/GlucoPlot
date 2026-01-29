part of 'dashboard_bloc.dart';

/// Base class for dashboard events
sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load dashboard data
class DashboardLoadRequested extends DashboardEvent {
  const DashboardLoadRequested();
}

/// Event to refresh dashboard data
class DashboardRefreshRequested extends DashboardEvent {
  const DashboardRefreshRequested();
}

/// Event to acknowledge an alert
class DashboardAlertAcknowledged extends DashboardEvent {
  const DashboardAlertAcknowledged(this.alertId);
  final String alertId;

  @override
  List<Object?> get props => [alertId];
}

/// Event to change chart type
class DashboardChartTypeChanged extends DashboardEvent {
  const DashboardChartTypeChanged(this.type);
  final MeasurementType type;

  @override
  List<Object?> get props => [type];
}
