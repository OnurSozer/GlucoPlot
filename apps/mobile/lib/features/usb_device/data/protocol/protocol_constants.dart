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
}
