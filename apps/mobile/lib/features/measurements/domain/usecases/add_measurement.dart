import '../entities/measurement.dart';
import '../repositories/measurement_repository.dart';

/// Parameters for adding a measurement
class AddMeasurementParams {
  const AddMeasurementParams({
    required this.type,
    required this.value,
    this.secondaryValue,
    this.unit,
    required this.measuredAt,
    this.notes,
  });

  final MeasurementType type;
  final double value;
  final double? secondaryValue;
  final String? unit;
  final DateTime measuredAt;
  final String? notes;
}

/// Use case for adding a measurement
class AddMeasurement {
  const AddMeasurement(this._repository);

  final MeasurementRepository _repository;

  Future<MeasurementResult<Measurement>> call(AddMeasurementParams params) {
    return _repository.addMeasurement(
      type: params.type,
      value: params.value,
      secondaryValue: params.secondaryValue,
      unit: params.unit,
      measuredAt: params.measuredAt,
      notes: params.notes,
    );
  }
}
