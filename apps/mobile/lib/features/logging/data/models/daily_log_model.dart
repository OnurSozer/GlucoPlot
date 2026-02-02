import '../../domain/entities/daily_log.dart';

/// Daily log model for data layer with JSON serialization
/// Matches Supabase daily_logs table schema
class DailyLogModel extends DailyLog {
  const DailyLogModel({
    required super.id,
    required super.patientId,
    required super.logDate,
    required super.logType,
    required super.title,
    super.description,
    super.metadata,
    super.loggedAt,
    super.createdAt,
  });

  /// Create from JSON (Supabase response)
  factory DailyLogModel.fromJson(Map<String, dynamic> json) {
    return DailyLogModel(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      logDate: DateTime.parse(json['log_date'] as String),
      logType: LogType.fromString(json['log_type'] as String),
      title: json['title'] as String,
      description: json['description'] as String?,
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : null,
      loggedAt: json['logged_at'] != null
          ? DateTime.parse(json['logged_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Create from entity
  factory DailyLogModel.fromEntity(DailyLog log) {
    return DailyLogModel(
      id: log.id,
      patientId: log.patientId,
      logDate: log.logDate,
      logType: log.logType,
      title: log.title,
      description: log.description,
      metadata: log.metadata,
      loggedAt: log.loggedAt,
      createdAt: log.createdAt,
    );
  }

  /// Convert to JSON for Supabase insert
  /// Matches daily_logs table: patient_id, log_date, log_type, title, description, metadata, logged_at
  Map<String, dynamic> toJson() {
    return {
      'patient_id': patientId,
      'log_date': logDate.toIso8601String().split('T')[0],
      'log_type': logType.value,
      'title': title,
      if (description != null) 'description': description,
      if (metadata != null && metadata!.isNotEmpty) 'metadata': metadata,
      'logged_at': (loggedAt ?? DateTime.now()).toIso8601String(),
    };
  }
}
