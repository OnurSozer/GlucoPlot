import '../../domain/entities/measurement.dart';

/// Measurement model for data layer with JSON serialization
class MeasurementModel extends Measurement {
  const MeasurementModel({
    required super.id,
    required super.patientId,
    required super.type,
    required super.value,
    super.secondaryValue,
    super.unit,
    required super.measuredAt,
    super.notes,
    super.createdAt,
  });

  /// Create from JSON (Supabase response)
  factory MeasurementModel.fromJson(Map<String, dynamic> json) {
    return MeasurementModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      type: MeasurementType.fromString(json['type'] as String),
      value: (json['value_primary'] as num).toDouble(),
      secondaryValue: json['value_secondary'] != null
          ? (json['value_secondary'] as num).toDouble()
          : null,
      unit: json['unit'] as String?,
      measuredAt: DateTime.parse(json['measured_at'] as String),
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Create from entity
  factory MeasurementModel.fromEntity(Measurement measurement) {
    return MeasurementModel(
      id: measurement.id,
      patientId: measurement.patientId,
      type: measurement.type,
      value: measurement.value,
      secondaryValue: measurement.secondaryValue,
      unit: measurement.unit,
      measuredAt: measurement.measuredAt,
      notes: measurement.notes,
      createdAt: measurement.createdAt,
    );
  }

  /// Convert to JSON for Supabase insert
  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'type': type.value,
      'value_primary': value,
      if (secondaryValue != null) 'value_secondary': secondaryValue,
      if (unit != null) 'unit': unit,
      'measured_at': measuredAt.toIso8601String(),
      if (notes != null) 'notes': notes,
    };
  }

  /// Convert to JSON for update (excludes patient_id)
  Map<String, dynamic> toUpdateJson() {
    return {
      'type': type.value,
      'value_primary': value,
      'value_secondary': secondaryValue,
      'unit': unit,
      'measured_at': measuredAt.toIso8601String(),
      'notes': notes,
    };
  }
}
