import 'package:equatable/equatable.dart';

/// Domain entity representing USB device information
class DeviceInfo extends Equatable {
  /// Device ID as hex string (e.g., "00:11:22:33:44:55:66:77:88:99")
  final String deviceId;

  /// Device name (from USB descriptor)
  final String? deviceName;

  const DeviceInfo({
    required this.deviceId,
    this.deviceName,
  });

  @override
  List<Object?> get props => [deviceId, deviceName];

  @override
  String toString() => 'DeviceInfo(deviceId: $deviceId, deviceName: $deviceName)';
}
