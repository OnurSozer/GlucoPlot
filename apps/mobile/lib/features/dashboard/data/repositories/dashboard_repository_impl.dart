import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../measurements/domain/entities/measurement.dart';
import '../../domain/entities/risk_alert.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

/// Implementation of DashboardRepository
class DashboardRepositoryImpl implements DashboardRepository {
  const DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  String? get _currentPatientId {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return null;
    // Patient ID is stored in user metadata, not the auth user ID
    final metadata = session.user.userMetadata;
    return metadata?['patient_id'] as String?;
  }

  @override
  Future<DashboardResult<DashboardSummary>> getSummary() async {
    try {
      final patientId = _currentPatientId;
      if (patientId == null) {
        return const DashboardFailure('Not authenticated');
      }

      // Fetch all data in parallel
      final results = await Future.wait([
        _remoteDataSource.getLatestMeasurements(patientId),
        _remoteDataSource.getActiveAlerts(patientId),
        _remoteDataSource.getTodayLogs(patientId),
        _remoteDataSource.getMedicationTakenToday(patientId),
      ]);

      final latestMeasurements = results[0] as Map<MeasurementType, Measurement>;
      final activeAlerts = results[1] as List<RiskAlert>;
      final todayLogs = results[2] as List;
      final medicationTaken = results[3] as bool?;

      // Get glucose trend
      MeasurementTrend? glucoseTrend;
      final lastGlucose = latestMeasurements[MeasurementType.glucose];

      if (lastGlucose != null) {
        // Get recent glucose readings for trend
        final now = DateTime.now();
        final weekAgo = now.subtract(const Duration(days: 7));
        final recentGlucose = await _remoteDataSource.getChartData(
          patientId: patientId,
          type: MeasurementType.glucose,
          startDate: weekAgo,
          endDate: now,
        );

        if (recentGlucose.length >= 4) {
          final midpoint = recentGlucose.length ~/ 2;
          final firstHalfAvg = recentGlucose
              .sublist(0, midpoint)
              .map((m) => m.value)
              .reduce((a, b) => a + b) / midpoint;
          final secondHalfAvg = recentGlucose
              .sublist(midpoint)
              .map((m) => m.value)
              .reduce((a, b) => a + b) / (recentGlucose.length - midpoint);

          if (secondHalfAvg > firstHalfAvg * 1.05) {
            glucoseTrend = MeasurementTrend.increasing;
          } else if (secondHalfAvg < firstHalfAvg * 0.95) {
            glucoseTrend = MeasurementTrend.decreasing;
          } else {
            glucoseTrend = MeasurementTrend.stable;
          }
        }
      }

      return DashboardSuccess(DashboardSummary(
        latestMeasurements: latestMeasurements,
        activeAlerts: activeAlerts,
        todayLogs: todayLogs.cast(),
        lastGlucose: lastGlucose,
        glucoseTrend: glucoseTrend,
        medicationTakenToday: medicationTaken,
      ));
    } catch (e) {
      return DashboardFailure('Failed to get dashboard summary: $e');
    }
  }

  @override
  Future<DashboardResult<List<RiskAlert>>> getActiveAlerts() async {
    try {
      final patientId = _currentPatientId;
      if (patientId == null) {
        return const DashboardFailure('Not authenticated');
      }

      final alerts = await _remoteDataSource.getActiveAlerts(patientId);
      return DashboardSuccess(alerts);
    } catch (e) {
      return DashboardFailure('Failed to get active alerts: $e');
    }
  }

  @override
  Future<DashboardResult<RiskAlert>> acknowledgeAlert(String alertId) async {
    try {
      final patientId = _currentPatientId;
      if (patientId == null) {
        return const DashboardFailure('Not authenticated');
      }

      final alert = await _remoteDataSource.acknowledgeAlert(alertId, patientId);
      return DashboardSuccess(alert);
    } catch (e) {
      return DashboardFailure('Failed to acknowledge alert: $e');
    }
  }

  @override
  Future<DashboardResult<List<Measurement>>> getChartData({
    required MeasurementType type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final patientId = _currentPatientId;
      if (patientId == null) {
        return const DashboardFailure('Not authenticated');
      }

      final data = await _remoteDataSource.getChartData(
        patientId: patientId,
        type: type,
        startDate: startDate,
        endDate: endDate,
      );

      return DashboardSuccess(data);
    } catch (e) {
      return DashboardFailure('Failed to get chart data: $e');
    }
  }
}
