import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/daily_log_model.dart';

/// Remote data source for daily logs
abstract class DailyLogRemoteDataSource {
  /// Get logs for current patient
  Future<List<DailyLogModel>> getLogs({
    required String patientId,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    int? limit,
    int? offset,
  });

  /// Get a single log by ID
  Future<DailyLogModel?> getLog(String id);

  /// Get logs for a specific date
  Future<List<DailyLogModel>> getLogsForDate({
    required String patientId,
    required DateTime date,
  });

  /// Add a log
  Future<DailyLogModel> addLog(DailyLogModel log);

  /// Update a log
  Future<DailyLogModel> updateLog(DailyLogModel log);

  /// Delete a log
  Future<void> deleteLog(String id);
}

/// Implementation of daily log remote data source
class DailyLogRemoteDataSourceImpl implements DailyLogRemoteDataSource {
  DailyLogRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<DailyLogModel>> getLogs({
    required String patientId,
    DateTime? date,
    DateTime? startDate,
    DateTime? endDate,
    String? category,
    int? limit,
    int? offset,
  }) async {
    var filterQuery = _client
        .from('daily_logs')
        .select()
        .eq('patient_id', patientId);

    if (date != null) {
      final dateStr = date.toIso8601String().split('T')[0];
      filterQuery = filterQuery.eq('log_date', dateStr);
    }

    if (startDate != null) {
      filterQuery = filterQuery.gte('log_date', startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      filterQuery = filterQuery.lte('log_date', endDate.toIso8601String().split('T')[0]);
    }

    // Filter by category
    if (category != null) {
      switch (category.toLowerCase()) {
        case 'meal':
          filterQuery = filterQuery.not('meal_type', 'is', null);
          break;
        case 'exercise':
          filterQuery = filterQuery.not('exercise_type', 'is', null);
          break;
        case 'medication':
          filterQuery = filterQuery.not('medication_taken', 'is', null);
          break;
        case 'sleep':
          filterQuery = filterQuery.not('sleep_hours', 'is', null);
          break;
      }
    }

    // Chain transform operations
    var transformQuery = filterQuery
        .order('log_date', ascending: false)
        .order('created_at', ascending: false);

    if (limit != null) {
      transformQuery = transformQuery.limit(limit);
    }

    if (offset != null) {
      transformQuery = transformQuery.range(offset, offset + (limit ?? 20) - 1);
    }

    final response = await transformQuery;
    return (response as List)
        .map((json) => DailyLogModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DailyLogModel?> getLog(String id) async {
    final response = await _client
        .from('daily_logs')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return DailyLogModel.fromJson(response);
  }

  @override
  Future<List<DailyLogModel>> getLogsForDate({
    required String patientId,
    required DateTime date,
  }) async {
    final dateStr = date.toIso8601String().split('T')[0];

    final response = await _client
        .from('daily_logs')
        .select()
        .eq('patient_id', patientId)
        .eq('log_date', dateStr)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => DailyLogModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DailyLogModel> addLog(DailyLogModel log) async {
    final response = await _client
        .from('daily_logs')
        .insert(log.toJson())
        .select()
        .single();

    return DailyLogModel.fromJson(response);
  }

  @override
  Future<DailyLogModel> updateLog(DailyLogModel log) async {
    final json = log.toJson();
    json.remove('patient_id'); // Don't update patient_id

    final response = await _client
        .from('daily_logs')
        .update(json)
        .eq('id', log.id)
        .select()
        .single();

    return DailyLogModel.fromJson(response);
  }

  @override
  Future<void> deleteLog(String id) async {
    await _client.from('daily_logs').delete().eq('id', id);
  }
}
