import '../entities/measurement.dart';

/// Result type for measurement operations
sealed class MeasurementResult<T> {
  const MeasurementResult();
}

class MeasurementSuccess<T> extends MeasurementResult<T> {
  const MeasurementSuccess(this.data);
  final T data;
}

class MeasurementFailure<T> extends MeasurementResult<T> {
  const MeasurementFailure(this.message);
  final String message;
}

/// Measurement repository interface
abstract class MeasurementRepository {
  /// Get all measurements for current patient
  Future<MeasurementResult<List<Measurement>>> getMeasurements({
    MeasurementType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  });

  /// Get a single measurement by ID
  Future<MeasurementResult<Measurement>> getMeasurement(String id);

  /// Get latest measurement for each type
  Future<MeasurementResult<Map<MeasurementType, Measurement>>> getLatestMeasurements();

  /// Add a new measurement
  Future<MeasurementResult<Measurement>> addMeasurement({
    required MeasurementType type,
    required double value,
    double? secondaryValue,
    String? unit,
    required DateTime measuredAt,
    MealTiming? mealTiming,
    String? notes,
    bool isAutoSaved = false,
    String? deviceId,
    String? source,
  });

  /// Update a measurement
  Future<MeasurementResult<Measurement>> updateMeasurement(Measurement measurement);

  /// Delete a measurement
  Future<MeasurementResult<void>> deleteMeasurement(String id);

  /// Get measurement statistics
  Future<MeasurementResult<MeasurementStats>> getStats({
    required MeasurementType type,
    required DateTime startDate,
    required DateTime endDate,
  });
}

/// Measurement statistics
class MeasurementStats {
  const MeasurementStats({
    required this.type,
    required this.count,
    this.average,
    this.min,
    this.max,
    this.trend,
  });

  final MeasurementType type;
  final int count;
  final double? average;
  final double? min;
  final double? max;
  final MeasurementTrend? trend;
}

/// Measurement trend
enum MeasurementTrend {
  increasing,
  decreasing,
  stable,
}
