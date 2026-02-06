import 'package:flutter/material.dart';

import '../../domain/repositories/usb_device_repository.dart';

/// Widget displaying USB device connection status
class DeviceStatusCard extends StatelessWidget {
  final UsbConnectionStatus status;
  final String? deviceName;
  final bool isLoading;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;

  const DeviceStatusCard({
    super.key,
    required this.status,
    this.deviceName,
    this.isLoading = false,
    this.onConnect,
    this.onDisconnect,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIndicator(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'USB Device',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusText,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: _statusColor,
                            ),
                      ),
                      if (deviceName != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          deviceName!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                _buildActionButton(context),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _statusColor,
      ),
    );
  }

  Widget _buildActionButton(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    final isConnected = status == UsbConnectionStatus.connected;

    return ElevatedButton(
      onPressed: isConnected ? onDisconnect : onConnect,
      style: ElevatedButton.styleFrom(
        backgroundColor: isConnected ? Colors.red : Colors.green,
        foregroundColor: Colors.white,
      ),
      child: Text(isConnected ? 'Disconnect' : 'Connect'),
    );
  }

  String get _statusText {
    switch (status) {
      case UsbConnectionStatus.disconnected:
        return 'Disconnected';
      case UsbConnectionStatus.connecting:
        return 'Connecting...';
      case UsbConnectionStatus.connected:
        return 'Connected';
      case UsbConnectionStatus.permissionRequired:
        return 'Permission Required';
      case UsbConnectionStatus.error:
        return 'Connection Error';
    }
  }

  Color get _statusColor {
    switch (status) {
      case UsbConnectionStatus.disconnected:
        return Colors.grey;
      case UsbConnectionStatus.connecting:
        return Colors.orange;
      case UsbConnectionStatus.connected:
        return Colors.green;
      case UsbConnectionStatus.permissionRequired:
        return Colors.amber;
      case UsbConnectionStatus.error:
        return Colors.red;
    }
  }
}
