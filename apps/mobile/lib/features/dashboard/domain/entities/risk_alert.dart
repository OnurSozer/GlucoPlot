import 'package:equatable/equatable.dart';
import '../../../measurements/domain/entities/measurement.dart';

/// Alert severity enum
enum AlertSeverity {
  low('low'),
  medium('medium'),
  high('high'),
  critical('critical');

  const AlertSeverity(this.value);
  final String value;

  static AlertSeverity fromString(String value) {
    return AlertSeverity.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AlertSeverity.medium,
    );
  }

  String get displayName {
    switch (this) {
      case AlertSeverity.low:
        return 'Low';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }

  int get priority {
    switch (this) {
      case AlertSeverity.low:
        return 1;
      case AlertSeverity.medium:
        return 2;
      case AlertSeverity.high:
        return 3;
      case AlertSeverity.critical:
        return 4;
    }
  }
}

/// Alert status enum - matches database enum values ('new', 'acknowledged', 'resolved')
enum AlertStatus {
  /// New/active alert - maps to 'new' in database
  active('new'),
  acknowledged('acknowledged'),
  resolved('resolved');

  const AlertStatus(this.value);
  final String value;

  static AlertStatus fromString(String value) {
    return AlertStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => AlertStatus.active,
    );
  }
}

/// Risk alert entity representing health alerts for patients
class RiskAlert extends Equatable {
  const RiskAlert({
    required this.id,
    required this.patientId,
    this.measurementId,
    required this.measurementType,
    required this.severity,
    required this.message,
    this.value,
    this.thresholdMin,
    this.thresholdMax,
    required this.status,
    this.acknowledgedAt,
    this.acknowledgedBy,
    this.resolvedAt,
    this.resolvedBy,
    this.createdAt,
  });

  final String id;
  final String patientId;
  final String? measurementId;
  final MeasurementType measurementType;
  final AlertSeverity severity;
  final String message;
  final double? value;
  final double? thresholdMin;
  final double? thresholdMax;
  final AlertStatus status;
  final DateTime? acknowledgedAt;
  final String? acknowledgedBy;
  final DateTime? resolvedAt;
  final String? resolvedBy;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        patientId,
        measurementId,
        measurementType,
        severity,
        message,
        value,
        thresholdMin,
        thresholdMax,
        status,
        acknowledgedAt,
        acknowledgedBy,
        resolvedAt,
        resolvedBy,
        createdAt,
      ];

  /// Check if alert is active
  bool get isActive => status == AlertStatus.active;

  /// Check if alert needs attention
  bool get needsAttention =>
      status == AlertStatus.active &&
      (severity == AlertSeverity.high || severity == AlertSeverity.critical);

  RiskAlert copyWith({
    String? id,
    String? patientId,
    String? measurementId,
    MeasurementType? measurementType,
    AlertSeverity? severity,
    String? message,
    double? value,
    double? thresholdMin,
    double? thresholdMax,
    AlertStatus? status,
    DateTime? acknowledgedAt,
    String? acknowledgedBy,
    DateTime? resolvedAt,
    String? resolvedBy,
    DateTime? createdAt,
  }) {
    return RiskAlert(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      measurementId: measurementId ?? this.measurementId,
      measurementType: measurementType ?? this.measurementType,
      severity: severity ?? this.severity,
      message: message ?? this.message,
      value: value ?? this.value,
      thresholdMin: thresholdMin ?? this.thresholdMin,
      thresholdMax: thresholdMax ?? this.thresholdMax,
      status: status ?? this.status,
      acknowledgedAt: acknowledgedAt ?? this.acknowledgedAt,
      acknowledgedBy: acknowledgedBy ?? this.acknowledgedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert to JSON for HydratedBloc caching
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient_id': patientId,
      'measurement_id': measurementId,
      'measurement_type': measurementType.value,
      'severity': severity.value,
      'message': message,
      'value': value,
      'threshold_min': thresholdMin,
      'threshold_max': thresholdMax,
      'status': status.value,
      'acknowledged_at': acknowledgedAt?.toIso8601String(),
      'acknowledged_by': acknowledgedBy,
      'resolved_at': resolvedAt?.toIso8601String(),
      'resolved_by': resolvedBy,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  /// Create from JSON for HydratedBloc caching
  factory RiskAlert.fromJson(Map<String, dynamic> json) {
    return RiskAlert(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      measurementId: json['measurement_id'] as String?,
      measurementType: MeasurementType.fromString(json['measurement_type'] as String),
      severity: AlertSeverity.fromString(json['severity'] as String),
      message: json['message'] as String,
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      thresholdMin: json['threshold_min'] != null
          ? (json['threshold_min'] as num).toDouble()
          : null,
      thresholdMax: json['threshold_max'] != null
          ? (json['threshold_max'] as num).toDouble()
          : null,
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
}
