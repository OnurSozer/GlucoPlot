import 'package:flutter/material.dart';

import '../../domain/entities/device_info.dart';

/// Widget displaying USB device information
class DeviceInfoCard extends StatelessWidget {
  final DeviceInfo? deviceInfo;
  final VoidCallback? onRequestId;
  final bool isConnected;

  const DeviceInfoCard({
    super.key,
    this.deviceInfo,
    this.onRequestId,
    this.isConnected = false,
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Device Info',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (isConnected && onRequestId != null)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: onRequestId,
                    tooltip: 'Request Device ID',
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (deviceInfo != null) ...[
              _buildInfoRow(context, 'Device ID', deviceInfo!.deviceId),
              if (deviceInfo!.deviceName != null)
                _buildInfoRow(context, 'Name', deviceInfo!.deviceName!),
            ] else ...[
              Text(
                isConnected
                    ? 'Tap refresh to get device info'
                    : 'Connect device to view info',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
