import '../../domain/entities/glucose_reading.dart';
import '../../domain/entities/usb_message.dart';

/// Data model for glucose readings that can convert from USB messages
class GlucoseReadingModel extends GlucoseReading {
  const GlucoseReadingModel({
    required super.concentration,
    required super.measuredCurrent,
    required super.baselineCurrent,
    required super.timestamp,
  });

  /// Creates a model from a USB glucose reading message
  factory GlucoseReadingModel.fromMessage(GlucoseReadingMessage message) {
    return GlucoseReadingModel(
      concentration: message.concentration,
      measuredCurrent: message.measuredCurrent,
      baselineCurrent: message.baselineCurrent,
      timestamp: message.timestamp,
    );
  }

  /// Converts to domain entity
  GlucoseReading toEntity() {
    return GlucoseReading(
      concentration: concentration,
      measuredCurrent: measuredCurrent,
      baselineCurrent: baselineCurrent,
      timestamp: timestamp,
    );
  }
}
