import 'package:equatable/equatable.dart';

/// Patient entity representing a patient in the domain layer
class Patient extends Equatable {
  const Patient({
    required this.id,
    required this.doctorId,
    required this.fullName,
    this.dateOfBirth,
    this.phone,
    this.email,
    this.notes,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String doctorId;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? phone;
  final String? email;
  final String? notes;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        doctorId,
        fullName,
        dateOfBirth,
        phone,
        email,
        notes,
        isActive,
        createdAt,
        updatedAt,
      ];

  Patient copyWith({
    String? id,
    String? doctorId,
    String? fullName,
    DateTime? dateOfBirth,
    String? phone,
    String? email,
    String? notes,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Patient(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
