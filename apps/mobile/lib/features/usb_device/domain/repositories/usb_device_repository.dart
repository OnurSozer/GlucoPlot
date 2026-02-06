import '../entities/device_info.dart';
import '../entities/glucose_reading.dart';
import '../entities/usb_message.dart';

/// Connection status for the USB device
enum UsbConnectionStatus {
  disconnected,
  connecting,
  connected,
  permissionRequired,
  error,
}

/// Abstract repository for USB device operations
abstract class UsbDeviceRepository {
  /// Checks if a device is connected and requests permission if needed
  Future<void> checkForDevice();

  /// Sends raw bytes to the device
  Future<int> sendBytes(List<int> data);

  /// Requests the device ID from the connected device
  Future<void> requestDeviceId();

  /// Stream of all USB messages received from the device
  Stream<UsbMessage> get messages;

  /// Stream of glucose readings only
  Stream<GlucoseReading> get glucoseReadings;

  /// Stream of device info updates
  Stream<DeviceInfo> get deviceInfo;

  /// Stream of connection status changes
  Stream<UsbConnectionStatus> get connectionStatus;

  /// Stream of device ready events (true when GlucoPlot is ready for measurement)
  Stream<bool> get deviceReady;

  /// Stream of measurement started events (true when strip inserted and experiment begins)
  Stream<bool> get measurementStarted;

  /// Disposes resources
  void dispose();
}
