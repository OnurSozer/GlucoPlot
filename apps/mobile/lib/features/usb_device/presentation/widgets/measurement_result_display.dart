import 'package:flutter/material.dart';

import '../../domain/entities/glucose_reading.dart';

/// Widget displaying the measurement result prominently
class MeasurementResultDisplay extends StatelessWidget {
  final GlucoseReading? reading;
  final bool isConnected;

  const MeasurementResultDisplay({
    super.key,
    this.reading,
    this.isConnected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _getBackgroundColor(context),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Text(
              'Glucose Level',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: _getTextColor(context),
                  ),
            ),
            const SizedBox(height: 16),
            if (reading != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    reading!.concentration.toStringAsFixed(1),
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: _getValueColor(),
                        ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      'mg/dL',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: _getTextColor(context),
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _formatTimestamp(reading!.timestamp),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: _getTextColor(context)?.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: 8),
              _buildRangeIndicator(context),
            ] else ...[
              Icon(
                isConnected ? Icons.hourglass_empty : Icons.usb_off,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                isConnected
                    ? 'Waiting for reading...'
                    : 'Connect device to receive readings',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRangeIndicator(BuildContext context) {
    final range = _getGlucoseRange();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: _getValueColor().withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        range,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _getValueColor(),
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }

  Color? _getBackgroundColor(BuildContext context) {
    if (reading == null) return null;

    final value = reading!.concentration;
    if (value < 70) {
      return Colors.red.shade50;
    } else if (value > 180) {
      return Colors.orange.shade50;
    }
    return Colors.green.shade50;
  }

  Color? _getTextColor(BuildContext context) {
    if (reading == null) return null;

    final value = reading!.concentration;
    if (value < 70) {
      return Colors.red.shade900;
    } else if (value > 180) {
      return Colors.orange.shade900;
    }
    return Colors.green.shade900;
  }

  Color _getValueColor() {
    if (reading == null) return Colors.grey;

    final value = reading!.concentration;
    if (value < 70) {
      return Colors.red;
    } else if (value > 180) {
      return Colors.orange;
    }
    return Colors.green;
  }

  String _getGlucoseRange() {
    if (reading == null) return '';

    final value = reading!.concentration;
    if (value < 70) {
      return 'Low';
    } else if (value > 180) {
      return 'High';
    }
    return 'Normal';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final diff = now.difference(timestamp);

    if (diff.inSeconds < 60) {
      return 'Just now';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} min ago';
    } else {
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    }
  }
}
