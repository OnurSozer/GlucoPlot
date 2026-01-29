import '../../../measurements/domain/entities/measurement.dart';
import '../entities/risk_alert.dart';
import '../repositories/dashboard_repository.dart';

/// Use case for getting dashboard summary
class GetDashboardSummary {
  const GetDashboardSummary(this._repository);

  final DashboardRepository _repository;

  Future<DashboardResult<DashboardSummary>> call() {
    return _repository.getSummary();
  }
}

/// Use case for getting active alerts
class GetActiveAlerts {
  const GetActiveAlerts(this._repository);

  final DashboardRepository _repository;

  Future<DashboardResult<List<RiskAlert>>> call() {
    return _repository.getActiveAlerts();
  }
}

/// Use case for acknowledging an alert
class AcknowledgeAlert {
  const AcknowledgeAlert(this._repository);

  final DashboardRepository _repository;

  Future<DashboardResult<RiskAlert>> call(String alertId) {
    return _repository.acknowledgeAlert(alertId);
  }
}

/// Use case for getting chart data
class GetChartData {
  const GetChartData(this._repository);

  final DashboardRepository _repository;

  Future<DashboardResult<List<Measurement>>> call({
    required MeasurementType type,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _repository.getChartData(
      type: type,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
