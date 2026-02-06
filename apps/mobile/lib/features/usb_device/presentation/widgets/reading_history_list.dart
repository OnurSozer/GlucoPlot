import 'package:flutter/material.dart';

import '../../domain/entities/glucose_reading.dart';

/// Widget displaying a list of recent glucose readings
class ReadingHistoryList extends StatelessWidget {
  final List<GlucoseReading> readings;
  final VoidCallback? onClear;

  const ReadingHistoryList({
    super.key,
    required this.readings,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Readings',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (readings.isNotEmpty && onClear != null)
                  TextButton(
                    onPressed: onClear,
                    child: const Text('Clear'),
                  ),
              ],
            ),
          ),
          if (readings.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No readings yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: readings.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final reading = readings[index];
                return _ReadingListTile(reading: reading);
              },
            ),
        ],
      ),
    );
  }
}

class _ReadingListTile extends StatelessWidget {
  final GlucoseReading reading;

  const _ReadingListTile({required this.reading});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        width: 8,
        height: 40,
        decoration: BoxDecoration(
          color: _getColor(),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      title: Row(
        children: [
          Text(
            reading.concentration.toStringAsFixed(1),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 4),
          Text(
            'mg/dL',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      subtitle: Text(
        _formatTimestamp(reading.timestamp),
        style: Theme.of(context).textTheme.bodySmall,
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: _getColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _getRange(),
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _getColor(),
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }

  Color _getColor() {
    final value = reading.concentration;
    if (value < 70) {
      return Colors.red;
    } else if (value > 180) {
      return Colors.orange;
    }
    return Colors.green;
  }

  String _getRange() {
    final value = reading.concentration;
    if (value < 70) {
      return 'Low';
    } else if (value > 180) {
      return 'High';
    }
    return 'Normal';
  }

  String _formatTimestamp(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final second = timestamp.second.toString().padLeft(2, '0');
    return '$hour:$minute:$second';
  }
}
