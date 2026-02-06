import '../../domain/entities/device_info.dart';
import '../../domain/entities/usb_message.dart';

/// Data model for device info that can convert from USB messages
class DeviceInfoModel extends DeviceInfo {
  const DeviceInfoModel({
    required super.deviceId,
    super.deviceName,
  });

  /// Creates a model from a USB device ID message
  factory DeviceInfoModel.fromMessage(DeviceIdMessage message, {String? deviceName}) {
    return DeviceInfoModel(
      deviceId: message.deviceId,
      deviceName: deviceName,
    );
  }

  /// Converts to domain entity
  DeviceInfo toEntity() {
    return DeviceInfo(
      deviceId: deviceId,
      deviceName: deviceName,
    );
  }
}
