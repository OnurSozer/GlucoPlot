import 'dart:async';

import 'package:flutter/services.dart';

/// Data source that wraps the platform channel communication with native USB code
class UsbDeviceDataSource {
  static const _methodChannel = MethodChannel('com.glucoplot.app/usb');

  // Stream controllers for native callbacks
  final _connectionStatusController = StreamController<String>.broadcast();
  final _dataReceivedController = StreamController<String>.broadcast();
  final _dataSentController =
      StreamController<Map<String, dynamic>>.broadcast();

  bool _isInitialized = false;

  UsbDeviceDataSource() {
    _initializeCallbacks();
  }

  void _initializeCallbacks() {
    if (_isInitialized) return;
    _isInitialized = true;

    _methodChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case 'onConnectionStatusChanged':
          final status = call.arguments as String;
          print('[UsbDataSource] Connection status changed: $status');
          _connectionStatusController.add(status);
          break;

        case 'onDataReceived':
          final data = call.arguments as String;
          print('[UsbDataSource] Data received: $data');
          _dataReceivedController.add(data);
          break;

        case 'onDataSent':
          final result = Map<String, dynamic>.from(call.arguments as Map);
          print('[UsbDataSource] Data sent: $result');
          _dataSentController.add(result);
          break;
      }
    });
  }

  /// Stream of connection status changes ("Connected", "Disconnected", "Connecting")
  Stream<String> get connectionStatus => _connectionStatusController.stream;

  /// Stream of received data (comma-separated unsigned byte values)
  Stream<String> get dataReceived => _dataReceivedController.stream;

  /// Stream of data sent results
  Stream<Map<String, dynamic>> get dataSent => _dataSentController.stream;

  /// Checks if a device is connected and requests permission if needed
  Future<void> checkForDevice() async {
    await _methodChannel.invokeMethod<void>('checkForDevice');
  }

  /// Sends raw bytes to the USB device
  Future<int> send(List<int> data) async {
    final result = await _methodChannel.invokeMethod<int>(
      'send',
      {'data': data},
    );
    return result ?? -1;
  }

  /// Dispose resources
  void dispose() {
    _connectionStatusController.close();
    _dataReceivedController.close();
    _dataSentController.close();
  }
}
