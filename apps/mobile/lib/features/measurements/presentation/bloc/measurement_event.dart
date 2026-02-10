part of 'measurement_bloc.dart';

/// Base class for measurement events
sealed class MeasurementEvent extends Equatable {
  const MeasurementEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load measurements
class MeasurementLoadRequested extends MeasurementEvent {
  const MeasurementLoadRequested({this.type});
  final MeasurementType? type;

  @override
  List<Object?> get props => [type];
}

/// Event to refresh measurements
class MeasurementRefreshRequested extends MeasurementEvent {
  const MeasurementRefreshRequested();
}

/// Event to change type filter
class MeasurementTypeFilterChanged extends MeasurementEvent {
  const MeasurementTypeFilterChanged(this.type);
  final MeasurementType? type;

  @override
  List<Object?> get props => [type];
}

/// Event to add a measurement
class MeasurementAddRequested extends MeasurementEvent {
  const MeasurementAddRequested({
    required this.type,
    required this.value,
    this.secondaryValue,
    this.unit,
    required this.measuredAt,
    this.mealTiming,
    this.notes,
  });

  final MeasurementType type;
  final double value;
  final double? secondaryValue;
  final String? unit;
  final DateTime measuredAt;
  final MealTiming? mealTiming;
  final String? notes;

  @override
  List<Object?> get props => [type, value, secondaryValue, unit, measuredAt, mealTiming, notes];
}

/// Event to delete a measurement
class MeasurementDeleteRequested extends MeasurementEvent {
  const MeasurementDeleteRequested(this.id);
  final String id;

  @override
  List<Object?> get props => [id];
}

/// Event to load more measurements
class MeasurementLoadMoreRequested extends MeasurementEvent {
  const MeasurementLoadMoreRequested();
}
