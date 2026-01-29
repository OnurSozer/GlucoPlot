import '../../../measurements/domain/entities/measurement.dart';
import '../../domain/entities/risk_alert.dart';

/// Risk alert model for data layer with JSON serialization
class RiskAlertModel extends RiskAlert {
  const RiskAlertModel({
    required super.id,
    required super.patientId,
    super.measurementId,
    required super.measurementType,
    required super.severity,
    required super.message,
    super.value,
    super.thresholdMin,
    super.thresholdMax,
    required super.status,
    super.acknowledgedAt,
    super.acknowledgedBy,
    super.resolvedAt,
    super.resolvedBy,
    super.createdAt,
  });

  /// Create from JSON (Supabase response)
  factory RiskAlertModel.fromJson(Map<String, dynamic> json) {
    final measurement = json['measurement'] as Map<String, dynamic>?;
    
    return RiskAlertModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      measurementId: json['measurement_id'] as String?,
      measurementType: measurement != null 
          ? MeasurementType.fromString(measurement['type'] as String)
          : MeasurementType.glucose, // Fallback if no measurement linked
      severity: AlertSeverity.fromString(json['severity'] as String),
      message: json['title'] as String, // Map title in DB to message in Entity
      value: measurement != null ? (measurement['value_primary'] as num).toDouble() : null,
      thresholdMin: null, // Not present in risk_alerts table
      thresholdMax: null, // Not present in risk_alerts table
      status: AlertStatus.fromString(json['status'] as String),
      acknowledgedAt: json['acknowledged_at'] != null
          ? DateTime.parse(json['acknowledged_at'] as String)
          : null,
      acknowledgedBy: json['acknowledged_by'] as String?,
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'] as String)
          : null,
      resolvedBy: json['resolved_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Create from entity
  factory RiskAlertModel.fromEntity(RiskAlert alert) {
    return RiskAlertModel(
      id: alert.id,
      patientId: alert.patientId,
      measurementId: alert.measurementId,
      measurementType: alert.measurementType,
      severity: alert.severity,
      message: alert.message,
      value: alert.value,
      thresholdMin: alert.thresholdMin,
      thresholdMax: alert.thresholdMax,
      status: alert.status,
      acknowledgedAt: alert.acknowledgedAt,
      acknowledgedBy: alert.acknowledgedBy,
      resolvedAt: alert.resolvedAt,
      resolvedBy: alert.resolvedBy,
      createdAt: alert.createdAt,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      if (measurementId != null) 'measurement_id': measurementId,
      'measurement_type': measurementType.value,
      'severity': severity.value,
      'message': message,
      if (value != null) 'value': value,
      if (thresholdMin != null) 'threshold_min': thresholdMin,
      if (thresholdMax != null) 'threshold_max': thresholdMax,
      'status': status.value,
    };
  }
}
