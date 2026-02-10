import 'package:equatable/equatable.dart';

import '../../domain/entities/device_info.dart';
import '../../domain/entities/glucose_reading.dart';
import '../../domain/repositories/usb_device_repository.dart';

/// Base class for all USB device events
sealed class UsbDeviceEvent extends Equatable {
  const UsbDeviceEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check if a USB device is already connected
class UsbDeviceCheckRequested extends UsbDeviceEvent {
  const UsbDeviceCheckRequested();
}

/// Event to request device ID from the connected device
class UsbDeviceIdRequested extends UsbDeviceEvent {
  const UsbDeviceIdRequested();
}

/// Internal event when connection status changes (used by BLoC internally)
class UsbConnectionStatusChanged extends UsbDeviceEvent {
  final UsbConnectionStatus status;

  const UsbConnectionStatusChanged(this.status);

  @override
  List<Object?> get props => [status];
}

/// Internal event when a glucose reading is received (used by BLoC internally)
class UsbGlucoseReadingReceived extends UsbDeviceEvent {
  final GlucoseReading reading;

  const UsbGlucoseReadingReceived(this.reading);

  @override
  List<Object?> get props => [reading];
}

/// Internal event when device info is received (used by BLoC internally)
class UsbDeviceInfoReceived extends UsbDeviceEvent {
  final DeviceInfo info;

  const UsbDeviceInfoReceived(this.info);

  @override
  List<Object?> get props => [info];
}

/// Event to clear the reading history
class UsbDeviceClearHistoryRequested extends UsbDeviceEvent {
  const UsbDeviceClearHistoryRequested();
}

/// Event to clear the latest reading (for starting a new measurement session)
class UsbClearLatestReadingRequested extends UsbDeviceEvent {
  const UsbClearLatestReadingRequested();
}

/// Internal event when device is ready for measurement (used by BLoC internally)
class UsbDeviceReadyReceived extends UsbDeviceEvent {
  const UsbDeviceReadyReceived();
}

/// Internal event when measurement starts (strip inserted, experiment begins)
class UsbMeasurementStartedReceived extends UsbDeviceEvent {
  const UsbMeasurementStartedReceived();
}

/// Internal event fired when deviceReady heartbeat times out (strip removed)
class UsbDeviceReadyTimeout extends UsbDeviceEvent {
  const UsbDeviceReadyTimeout();
}
