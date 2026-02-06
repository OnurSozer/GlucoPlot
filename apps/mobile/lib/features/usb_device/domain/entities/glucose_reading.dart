import 'package:equatable/equatable.dart';

/// Domain entity representing a glucose reading from the USB device
class GlucoseReading extends Equatable {
  /// Glucose concentration in mg/dL
  final double concentration;

  /// Measured current in uA (for diagnostics/future use)
  final double measuredCurrent;

  /// Baseline current in uA (for diagnostics/future use)
  final double baselineCurrent;

  /// Timestamp when the reading was received
  final DateTime timestamp;

  const GlucoseReading({
    required this.concentration,
    required this.measuredCurrent,
    required this.baselineCurrent,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [concentration, measuredCurrent, baselineCurrent, timestamp];

  @override
  String toString() => 'GlucoseReading(concentration: $concentration mg/dL)';
}
