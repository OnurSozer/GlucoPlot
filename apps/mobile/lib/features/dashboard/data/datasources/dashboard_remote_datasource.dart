import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../measurements/data/models/measurement_model.dart';
import '../../../measurements/domain/entities/measurement.dart';
import '../../../logging/data/models/daily_log_model.dart';
import '../models/risk_alert_model.dart';
import '../../domain/entities/risk_alert.dart';

/// Remote data source for dashboard
abstract class DashboardRemoteDataSource {
  /// Get latest measurements for all types
  Future<Map<MeasurementType, MeasurementModel>> getLatestMeasurements(String patientId);

  /// Get active alerts
  Future<List<RiskAlertModel>> getActiveAlerts(String patientId);

  /// Acknowledge an alert
  Future<RiskAlertModel> acknowledgeAlert(String alertId, String userId);

  /// Get today's logs
  Future<List<DailyLogModel>> getTodayLogs(String patientId);

  /// Get measurement chart data
  Future<List<MeasurementModel>> getChartData({
    required String patientId,
    required MeasurementType type,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Check if medication was taken today
  Future<bool?> getMedicationTakenToday(String patientId);
}

/// Implementation of dashboard remote data source
class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  DashboardRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<Map<MeasurementType, MeasurementModel>> getLatestMeasurements(
    String patientId,
  ) async {
    final result = <MeasurementType, MeasurementModel>{};

    for (final type in MeasurementType.values) {
      final response = await _client
          .from('measurements')
          .select()
          .eq('patient_id', patientId)
          .eq('type', type.value)
          .order('measured_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (response != null) {
        result[type] = MeasurementModel.fromJson(response);
      }
    }

    return result;
  }

  @override
  Future<List<RiskAlertModel>> getActiveAlerts(String patientId) async {
    final response = await _client
        .from('risk_alerts')
        .select('*, measurement:measurements(type, value_primary)')
        .eq('patient_id', patientId)
        .eq('status', AlertStatus.active.value)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => RiskAlertModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<RiskAlertModel> acknowledgeAlert(String alertId, String userId) async {
    final response = await _client
        .from('risk_alerts')
        .update({
          'status': AlertStatus.acknowledged.value,
          'acknowledged_at': DateTime.now().toIso8601String(),
          'acknowledged_by': userId,
        })
        .eq('id', alertId)
        .select()
        .single();

    return RiskAlertModel.fromJson(response);
  }

  @override
  Future<List<DailyLogModel>> getTodayLogs(String patientId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    final response = await _client
        .from('daily_logs')
        .select()
        .eq('patient_id', patientId)
        .eq('log_date', today)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => DailyLogModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<MeasurementModel>> getChartData({
    required String patientId,
    required MeasurementType type,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _client
        .from('measurements')
        .select()
        .eq('patient_id', patientId)
        .eq('type', type.value)
        .gte('measured_at', startDate.toIso8601String())
        .lte('measured_at', endDate.toIso8601String())
        .order('measured_at', ascending: true);

    return (response as List)
        .map((json) => MeasurementModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<bool?> getMedicationTakenToday(String patientId) async {
    final today = DateTime.now().toIso8601String().split('T')[0];

    // Check if there's a medication log entry for today
    final response = await _client
        .from('daily_logs')
        .select('id')
        .eq('patient_id', patientId)
        .eq('log_date', today)
        .eq('log_type', 'medication')
        .limit(1)
        .maybeSingle();

    // Returns true if medication log exists, null if no entry yet
    return response != null ? true : null;
  }
}
