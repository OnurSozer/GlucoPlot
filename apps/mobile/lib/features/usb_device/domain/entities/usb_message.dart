/// Base class for all USB messages received from the device
sealed class UsbMessage {
  const UsbMessage();
}

/// Glucose reading message from the device
class GlucoseReadingMessage extends UsbMessage {
  /// Glucose concentration in mg/dL
  final double concentration;

  /// Measured current in uA (for diagnostics/future use)
  final double measuredCurrent;

  /// Baseline current in uA (for diagnostics/future use)
  final double baselineCurrent;

  /// Timestamp when the reading was received
  final DateTime timestamp;

  const GlucoseReadingMessage({
    required this.concentration,
    required this.measuredCurrent,
    required this.baselineCurrent,
    required this.timestamp,
  });

  @override
  String toString() =>
      'GlucoseReadingMessage(concentration: $concentration mg/dL, timestamp: $timestamp)';
}

/// Device ID response message
class DeviceIdMessage extends UsbMessage {
  /// Device ID as hex string (e.g., "00:11:22:33:44:55:66:77:88:99")
  final String deviceId;

  const DeviceIdMessage({required this.deviceId});

  @override
  String toString() => 'DeviceIdMessage(deviceId: $deviceId)';
}

/// Device ready message - GlucoPlot is ready for measurement
class DeviceReadyMessage extends UsbMessage {
  /// Timestamp when the device became ready
  final DateTime timestamp;

  const DeviceReadyMessage({required this.timestamp});

  @override
  String toString() => 'DeviceReadyMessage(timestamp: $timestamp)';
}

/// Measurement started message - strip inserted and experiment begins
class MeasurementStartedMessage extends UsbMessage {
  /// Timestamp when measurement started
  final DateTime timestamp;

  const MeasurementStartedMessage({required this.timestamp});

  @override
  String toString() => 'MeasurementStartedMessage(timestamp: $timestamp)';
}

/// Unknown message received from device
class UnknownMessage extends UsbMessage {
  /// The method ID that was not recognized
  final int methodId;

  /// Raw data bytes
  final List<int> data;

  const UnknownMessage({required this.methodId, required this.data});

  @override
  String toString() => 'UnknownMessage(methodId: $methodId, dataLength: ${data.length})';
}
