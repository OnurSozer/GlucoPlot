import 'package:equatable/equatable.dart';

import '../../domain/entities/device_info.dart';
import '../../domain/entities/glucose_reading.dart';
import '../../domain/repositories/usb_device_repository.dart';

/// State for USB device BLoC
class UsbDeviceState extends Equatable {
  /// Current connection status
  final UsbConnectionStatus connectionStatus;

  /// Connected device information (null if not connected)
  final DeviceInfo? deviceInfo;

  /// Latest glucose reading (null if none received)
  final GlucoseReading? latestReading;

  /// History of glucose readings (most recent first)
  final List<GlucoseReading> readingHistory;

  /// Error message if any
  final String? errorMessage;

  /// Whether currently loading/connecting
  final bool isLoading;

  /// Whether GlucoPlot device is ready for measurement
  final bool isDeviceReady;

  /// Whether measurement is in progress (strip inserted, waiting for result)
  final bool isMeasuring;

  const UsbDeviceState({
    this.connectionStatus = UsbConnectionStatus.disconnected,
    this.deviceInfo,
    this.latestReading,
    this.readingHistory = const [],
    this.errorMessage,
    this.isLoading = false,
    this.isDeviceReady = false,
    this.isMeasuring = false,
  });

  /// Whether device is connected
  bool get isConnected => connectionStatus == UsbConnectionStatus.connected;

  /// Whether permission is required
  bool get permissionRequired =>
      connectionStatus == UsbConnectionStatus.permissionRequired;

  /// Whether there was an error
  bool get hasError => connectionStatus == UsbConnectionStatus.error;

  /// Copy with method for immutable state updates
  UsbDeviceState copyWith({
    UsbConnectionStatus? connectionStatus,
    DeviceInfo? deviceInfo,
    GlucoseReading? latestReading,
    List<GlucoseReading>? readingHistory,
    String? errorMessage,
    bool? isLoading,
    bool? isDeviceReady,
    bool? isMeasuring,
    bool clearDeviceInfo = false,
    bool clearLatestReading = false,
    bool clearError = false,
  }) {
    return UsbDeviceState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      deviceInfo: clearDeviceInfo ? null : (deviceInfo ?? this.deviceInfo),
      latestReading:
          clearLatestReading ? null : (latestReading ?? this.latestReading),
      readingHistory: readingHistory ?? this.readingHistory,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isLoading: isLoading ?? this.isLoading,
      isDeviceReady: isDeviceReady ?? this.isDeviceReady,
      isMeasuring: isMeasuring ?? this.isMeasuring,
    );
  }

  @override
  List<Object?> get props => [
        connectionStatus,
        deviceInfo,
        latestReading,
        readingHistory,
        errorMessage,
        isLoading,
        isDeviceReady,
        isMeasuring,
      ];
}
