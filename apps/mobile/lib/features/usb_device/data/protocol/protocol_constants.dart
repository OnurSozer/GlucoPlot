/// Protocol constants for STM32 USB communication
class ProtocolConstants {
  ProtocolConstants._();

  /// Start byte for all packets
  static const int startByte = 107; // 0x6B

  /// Stop byte for all packets
  static const int stopByte = 100; // 0x64

  // =========================================
  // TX Methods (App -> Device)
  // =========================================

  /// Request device ID from the device
  static const int methodRequestDeviceId = 7; // 0x0007

  // =========================================
  // RX Methods (Device -> App)
  // =========================================

  /// Device ID response from the device (10 bytes payload)
  static const int methodDeviceIdResponse = 1007; // 0x03EF

  /// Device ready notification - GlucoPlot is ready for measurement (no payload)
  static const int methodDeviceReady = 1008; // 0x03F0

  /// Measurement started - strip inserted and experiment begins (no payload)
  static const int methodMeasurementStarted = 1009; // 0x03F1

  /// Glucose reading from the device (12 bytes payload)
  static const int methodGlucoseReading = 1010; // 0x03F2

  // =========================================
  // Packet Sizes
  // =========================================

  /// Minimum packet size: START(1) + METHOD(2) + STOP(1) = 4 bytes
  static const int minPacketSize = 4;

  /// Glucose reading packet data size: concentration(4) + measuredCurrent(4) + baselineCurrent(4) = 12 bytes
  static const int glucoseReadingDataSize = 12;

  /// Device ID response data size: 10 bytes
  static const int deviceIdDataSize = 10;

  /// Returns the expected data size for a given method ID
  /// Returns -1 if method ID is unknown
  static int getDataSizeForMethod(int methodId) {
    switch (methodId) {
      case methodDeviceIdResponse:
        return deviceIdDataSize; // 10 bytes
      case methodDeviceReady:
        return 0; // No payload
      case methodMeasurementStarted:
        return 0; // No payload
      case methodGlucoseReading:
        return glucoseReadingDataSize; // 12 bytes
      default:
        return -1; // Unknown method
    }
  }

  /// Returns the total packet size for a given method ID
  /// Packet = START(1) + METHOD(2) + DATA(n) + STOP(1)
  /// Returns -1 if method ID is unknown
  static int getPacketSizeForMethod(int methodId) {
    final dataSize = getDataSizeForMethod(methodId);
    if (dataSize < 0) return -1;
    return 1 + 2 + dataSize + 1; // start + method + data + stop
  }
}
