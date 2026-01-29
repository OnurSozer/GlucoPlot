import '../entities/measurement.dart';
import '../repositories/measurement_repository.dart';

/// Use case for getting measurements
class GetMeasurements {
  const GetMeasurements(this._repository);

  final MeasurementRepository _repository;

  Future<MeasurementResult<List<Measurement>>> call({
    MeasurementType? type,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) {
    return _repository.getMeasurements(
      type: type,
      startDate: startDate,
      endDate: endDate,
      limit: limit,
      offset: offset,
    );
  }
}

/// Use case for getting latest measurements
class GetLatestMeasurements {
  const GetLatestMeasurements(this._repository);

  final MeasurementRepository _repository;

  Future<MeasurementResult<Map<MeasurementType, Measurement>>> call() {
    return _repository.getLatestMeasurements();
  }
}
