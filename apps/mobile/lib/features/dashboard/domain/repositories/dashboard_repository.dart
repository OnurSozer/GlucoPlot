import '../../../measurements/domain/entities/measurement.dart';
import '../../../logging/domain/entities/daily_log.dart';
import '../entities/risk_alert.dart';

/// Result type for dashboard operations
sealed class DashboardResult<T> {
  const DashboardResult();
}

class DashboardSuccess<T> extends DashboardResult<T> {
  const DashboardSuccess(this.data);
  final T data;
}

class DashboardFailure<T> extends DashboardResult<T> {
  const DashboardFailure(this.message);
  final String message;
}

/// Dashboard summary data
class DashboardSummary {
  const DashboardSummary({
    required this.latestMeasurements,
    required this.activeAlerts,
    required this.todayLogs,
    this.lastGlucose,
    this.glucoseTrend,
    this.medicationTakenToday,
  });

  final Map<MeasurementType, Measurement> latestMeasurements;
  final List<RiskAlert> activeAlerts;
  final List<DailyLog> todayLogs;
  final Measurement? lastGlucose;
  final MeasurementTrend? glucoseTrend;
  final bool? medicationTakenToday;
}

/// Measurement trend for dashboard
enum MeasurementTrend {
  increasing,
  decreasing,
  stable,
}

/// Dashboard repository interface
abstract class DashboardRepository {
  /// Get dashboard summary
  Future<DashboardResult<DashboardSummary>> getSummary();

  /// Get active risk alerts
  Future<DashboardResult<List<RiskAlert>>> getActiveAlerts();

  /// Acknowledge an alert
  Future<DashboardResult<RiskAlert>> acknowledgeAlert(String alertId);

  /// Get measurement chart data
  Future<DashboardResult<List<Measurement>>> getChartData({
    required MeasurementType type,
    required DateTime startDate,
    required DateTime endDate,
  });
}
