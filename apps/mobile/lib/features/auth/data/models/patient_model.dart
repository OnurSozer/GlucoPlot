import '../../domain/entities/patient.dart';

/// Patient model for data layer with JSON serialization
class PatientModel extends Patient {
  const PatientModel({
    required super.id,
    required super.doctorId,
    required super.fullName,
    super.dateOfBirth,
    super.phone,
    super.email,
    super.notes,
    super.isActive = true,
    super.createdAt,
    super.updatedAt,
  });

  /// Create from JSON (Supabase response)
  factory PatientModel.fromJson(Map<String, dynamic> json) {
    return PatientModel(
      id: json['id'] as String,
      doctorId: json['doctor_id'] as String,
      fullName: json['full_name'] as String,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Create from entity
  factory PatientModel.fromEntity(Patient patient) {
    return PatientModel(
      id: patient.id,
      doctorId: patient.doctorId,
      fullName: patient.fullName,
      dateOfBirth: patient.dateOfBirth,
      phone: patient.phone,
      email: patient.email,
      notes: patient.notes,
      isActive: patient.isActive,
      createdAt: patient.createdAt,
      updatedAt: patient.updatedAt,
    );
  }

  /// Convert to JSON for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctor_id': doctorId,
      'full_name': fullName,
      if (dateOfBirth != null) 'date_of_birth': dateOfBirth!.toIso8601String().split('T')[0],
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (notes != null) 'notes': notes,
      'is_active': isActive,
    };
  }
}
