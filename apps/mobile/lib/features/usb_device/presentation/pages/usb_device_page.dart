import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/usb_device_bloc.dart';
import '../bloc/usb_device_event.dart';
import '../bloc/usb_device_state.dart';
import '../widgets/device_info_card.dart';
import '../widgets/device_status_card.dart';
import '../widgets/live_reading_display.dart';
import '../widgets/reading_history_list.dart';

/// Main page for USB glucose meter functionality
class UsbDevicePage extends StatelessWidget {
  const UsbDevicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USB Glucose Meter'),
      ),
      body: BlocBuilder<UsbDeviceBloc, UsbDeviceState>(
        builder: (context, state) {
          return RefreshIndicator(
            onRefresh: () async {
              if (state.isConnected) {
                context.read<UsbDeviceBloc>().add(const UsbDeviceIdRequested());
              }
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Connection Status
                  DeviceStatusCard(
                    status: state.connectionStatus,
                    deviceName: state.deviceInfo?.deviceName,
                    isLoading: state.isLoading,
                    onConnect: () {
                      context
                          .read<UsbDeviceBloc>()
                          .add(const UsbDeviceCheckRequested());
                    },
                    onDisconnect: null, // Disconnect happens automatically on device unplug
                  ),
                  const SizedBox(height: 16),

                  // Device Info
                  DeviceInfoCard(
                    deviceInfo: state.deviceInfo,
                    isConnected: state.isConnected,
                    onRequestId: () {
                      context
                          .read<UsbDeviceBloc>()
                          .add(const UsbDeviceIdRequested());
                    },
                  ),
                  const SizedBox(height: 16),

                  // Live Reading Display
                  LiveReadingDisplay(
                    reading: state.latestReading,
                    isConnected: state.isConnected,
                  ),
                  const SizedBox(height: 16),

                  // Reading History
                  ReadingHistoryList(
                    readings: state.readingHistory,
                    onClear: () {
                      context
                          .read<UsbDeviceBloc>()
                          .add(const UsbDeviceClearHistoryRequested());
                    },
                  ),

                  // Error message
                  if (state.hasError && state.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Card(
                        color: Colors.red.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Icon(
                                Icons.error_outline,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: TextStyle(color: Colors.red.shade700),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Permission required message
                  if (state.permissionRequired)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Card(
                        color: Colors.amber.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Icon(
                                Icons.warning_amber,
                                color: Colors.amber.shade700,
                                size: 48,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'USB Permission Required',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      color: Colors.amber.shade900,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Please approve the USB permission request to connect to the glucose meter.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.amber.shade700),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () {
                                  context
                                      .read<UsbDeviceBloc>()
                                      .add(const UsbDeviceCheckRequested());
                                },
                                child: const Text('Try Again'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
