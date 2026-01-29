import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/measurement_model.dart';
import '../../domain/entities/measurement.dart';

/// Remote data source for measurements
abstract class MeasurementRemoteDataSource {
  /// Get measurements for current patient
  Future<List<MeasurementModel>> getMeasurements({
    required String patientId,
    MeasurementType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  /// Get a single measurement by ID
  Future<MeasurementModel?> getMeasurement(String id);

  /// Get latest measurement for each type
  Future<Map<MeasurementType, MeasurementModel>> getLatestMeasurements(String patientId);

  /// Add a measurement
  Future<MeasurementModel> addMeasurement(MeasurementModel measurement);

  /// Update a measurement
  Future<MeasurementModel> updateMeasurement(MeasurementModel measurement);

  /// Delete a measurement
  Future<void> deleteMeasurement(String id);
}

/// Implementation of measurement remote data source
class MeasurementRemoteDataSourceImpl implements MeasurementRemoteDataSource {
  MeasurementRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  Future<List<MeasurementModel>> getMeasurements({
    required String patientId,
    MeasurementType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) async {
    var filterQuery = _client
        .from('measurements')
        .select()
        .eq('patient_id', patientId);

    if (type != null) {
      filterQuery = filterQuery.eq('type', type.value);
    }

    if (startDate != null) {
      filterQuery = filterQuery.gte('measured_at', startDate.toIso8601String());
    }

    if (endDate != null) {
      filterQuery = filterQuery.lte('measured_at', endDate.toIso8601String());
    }

    // Chain transform operations
    var transformQuery = filterQuery.order('measured_at', ascending: false);

    if (limit != null) {
      transformQuery = transformQuery.limit(limit);
    }

    if (offset != null) {
      transformQuery = transformQuery.range(offset, offset + (limit ?? 20) - 1);
    }

    final response = await transformQuery;
    return (response as List)
        .map((json) => MeasurementModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MeasurementModel?> getMeasurement(String id) async {
    final response = await _client
        .from('measurements')
        .select()
        .eq('id', id)
        .maybeSingle();

    if (response == null) return null;
    return MeasurementModel.fromJson(response);
  }

  @override
  Future<Map<MeasurementType, MeasurementModel>> getLatestMeasurements(
    String patientId,
  ) async {
    final result = <MeasurementType, MeasurementModel>{};

    // Get latest for each measurement type
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
  Future<MeasurementModel> addMeasurement(MeasurementModel measurement) async {
    final response = await _client
        .from('measurements')
        .insert(measurement.toJson())
        .select()
        .single();

    return MeasurementModel.fromJson(response);
  }

  @override
  Future<MeasurementModel> updateMeasurement(MeasurementModel measurement) async {
    final response = await _client
        .from('measurements')
        .update(measurement.toUpdateJson())
        .eq('id', measurement.id)
        .select()
        .single();

    return MeasurementModel.fromJson(response);
  }

  @override
  Future<void> deleteMeasurement(String id) async {
    await _client.from('measurements').delete().eq('id', id);
  }
}
