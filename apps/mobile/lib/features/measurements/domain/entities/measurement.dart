import 'package:equatable/equatable.dart';

/// Measurement type enum
enum MeasurementType {
  glucose('glucose'),
  bloodPressure('blood_pressure'),
  heartRate('heart_rate'),
  weight('weight'),
  temperature('temperature'),
  oxygenSaturation('spo2');

  const MeasurementType(this.value);
  final String value;

  static MeasurementType fromString(String value) {
    return MeasurementType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MeasurementType.glucose,
    );
  }

  String get displayName {
    switch (this) {
      case MeasurementType.glucose:
        return 'Blood Glucose';
      case MeasurementType.bloodPressure:
        return 'Blood Pressure';
      case MeasurementType.heartRate:
        return 'Heart Rate';
      case MeasurementType.weight:
        return 'Weight';
      case MeasurementType.temperature:
        return 'Temperature';
      case MeasurementType.oxygenSaturation:
        return 'Oxygen Saturation';
    }
  }

  String get unit {
    switch (this) {
      case MeasurementType.glucose:
        return 'mg/dL';
      case MeasurementType.bloodPressure:
        return 'mmHg';
      case MeasurementType.heartRate:
        return 'bpm';
      case MeasurementType.weight:
        return 'kg';
      case MeasurementType.temperature:
        return '°C';
      case MeasurementType.oxygenSaturation:
        return '%';
    }
  }

  String get icon {
    switch (this) {
      case MeasurementType.glucose:
        return '🩸';
      case MeasurementType.bloodPressure:
        return '💓';
      case MeasurementType.heartRate:
        return '❤️';
      case MeasurementType.weight:
        return '⚖️';
      case MeasurementType.temperature:
        return '🌡️';
      case MeasurementType.oxygenSaturation:
        return '🫁';
    }
  }
}

/// Measurement entity representing a health measurement
class Measurement extends Equatable {
  const Measurement({
    required this.id,
    required this.patientId,
    required this.type,
    required this.value,
    this.secondaryValue,
    this.unit,
    required this.measuredAt,
    this.notes,
    this.createdAt,
  });

  final String id;
  final String patientId;
  final MeasurementType type;
  final double value;
  final double? secondaryValue; // For blood pressure (diastolic)
  final String? unit;
  final DateTime measuredAt;
  final String? notes;
  final DateTime? createdAt;

  @override
  List<Object?> get props => [
        id,
        patientId,
        type,
        value,
        secondaryValue,
        unit,
        measuredAt,
        notes,
        createdAt,
      ];

  /// Get formatted value string
  String get formattedValue {
    if (type == MeasurementType.bloodPressure && secondaryValue != null) {
      return '${value.toInt()}/${secondaryValue!.toInt()}';
    }
    if (value == value.toInt()) {
      return value.toInt().toString();
    }
    return value.toStringAsFixed(1);
  }

  /// Get display unit
  String get displayUnit => unit ?? type.unit;

  Measurement copyWith({
    String? id,
    String? patientId,
    MeasurementType? type,
    double? value,
    double? secondaryValue,
    String? unit,
    DateTime? measuredAt,
    String? notes,
    DateTime? createdAt,
  }) {
    return Measurement(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      type: type ?? this.type,
      value: value ?? this.value,
      secondaryValue: secondaryValue ?? this.secondaryValue,
      unit: unit ?? this.unit,
      measuredAt: measuredAt ?? this.measuredAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
