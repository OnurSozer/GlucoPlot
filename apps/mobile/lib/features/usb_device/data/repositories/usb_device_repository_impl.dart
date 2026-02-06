import 'dart:async';

import '../datasources/usb_device_datasource.dart';
import '../models/device_info_model.dart';
import '../models/glucose_reading_model.dart';
import '../protocol/message_generator.dart';
import '../protocol/message_response_handler.dart';
import '../../domain/entities/device_info.dart';
import '../../domain/entities/glucose_reading.dart';
import '../../domain/entities/usb_message.dart';
import '../../domain/repositories/usb_device_repository.dart';

/// Implementation of UsbDeviceRepository
class UsbDeviceRepositoryImpl implements UsbDeviceRepository {
  final UsbDeviceDataSource _dataSource;
  final MessageGenerator _messageGenerator;
  final MessageResponseHandler _responseHandler;

  final StreamController<UsbConnectionStatus> _connectionStatusController =
      StreamController<UsbConnectionStatus>.broadcast();

  final StreamController<GlucoseReading> _glucoseReadingController =
      StreamController<GlucoseReading>.broadcast();

  final StreamController<DeviceInfo> _deviceInfoController =
      StreamController<DeviceInfo>.broadcast();

  final StreamController<bool> _deviceReadyController =
      StreamController<bool>.broadcast();

  final StreamController<bool> _measurementStartedController =
      StreamController<bool>.broadcast();

  StreamSubscription<String>? _connectionStatusSubscription;
  StreamSubscription<String>? _dataReceivedSubscription;
  String? _connectedDeviceName;

  UsbDeviceRepositoryImpl({
    required UsbDeviceDataSource dataSource,
    required MessageGenerator messageGenerator,
    required MessageResponseHandler responseHandler,
  })  : _dataSource = dataSource,
        _messageGenerator = messageGenerator,
        _responseHandler = responseHandler {
    _setupMessageHandling();
    _startListening();
  }

  void _setupMessageHandling() {
    // Listen to parsed messages from the response handler
    _responseHandler.messages.listen((message) {
      switch (message) {
        case GlucoseReadingMessage():
          final reading = GlucoseReadingModel.fromMessage(message).toEntity();
          _glucoseReadingController.add(reading);

        case DeviceIdMessage():
          final info = DeviceInfoModel.fromMessage(
            message,
            deviceName: _connectedDeviceName,
          ).toEntity();
          _deviceInfoController.add(info);

        case DeviceReadyMessage():
          _deviceReadyController.add(true);

        case MeasurementStartedMessage():
          _measurementStartedController.add(true);

        case UnknownMessage():
          // Log or handle unknown messages
          break;
      }
    });
  }

  void _startListening() {
    print('[UsbRepo] Starting to listen to native callbacks');

    // Listen to connection status changes from native
    _connectionStatusSubscription?.cancel();
    _connectionStatusSubscription = _dataSource.connectionStatus.listen((status) {
      print('[UsbRepo] Connection status from native: $status');

      switch (status) {
        case 'Connected':
          // Set device name if not already set (connected via callback)
          _connectedDeviceName ??= 'GlucoPlot Device';
          print('[UsbRepo] Emitting connected status');
          _connectionStatusController.add(UsbConnectionStatus.connected);

        case 'Disconnected':
          _connectedDeviceName = null;
          _responseHandler.clearBuffer();
          print('[UsbRepo] Emitting disconnected status');
          _connectionStatusController.add(UsbConnectionStatus.disconnected);

        case 'Connecting':
          print('[UsbRepo] Emitting connecting status');
          _connectionStatusController.add(UsbConnectionStatus.connecting);

        default:
          print('[UsbRepo] Unknown status: $status');
      }
    });

    // Listen to data received from native
    _dataReceivedSubscription?.cancel();
    _dataReceivedSubscription = _dataSource.dataReceived.listen((dataString) {
      print('[UsbRepo] Data received from native: $dataString');

      // Parse comma-separated unsigned byte values
      try {
        final bytes = dataString
            .split(', ')
            .map((s) => int.parse(s.trim()))
            .toList();
        _responseHandler.handleIncomingBytes(bytes);
      } catch (e) {
        print('[UsbRepo] Error parsing data: $e');
      }
    });
  }

  @override
  Future<void> checkForDevice() async {
    await _dataSource.checkForDevice();
  }

  @override
  Future<int> sendBytes(List<int> data) => _dataSource.send(data);

  @override
  Future<void> requestDeviceId() async {
    final message = _messageGenerator.requestDeviceId();
    await sendBytes(message);
  }

  @override
  Stream<UsbMessage> get messages => _responseHandler.messages;

  @override
  Stream<GlucoseReading> get glucoseReadings => _glucoseReadingController.stream;

  @override
  Stream<DeviceInfo> get deviceInfo => _deviceInfoController.stream;

  @override
  Stream<UsbConnectionStatus> get connectionStatus =>
      _connectionStatusController.stream;

  @override
  Stream<bool> get deviceReady => _deviceReadyController.stream;

  @override
  Stream<bool> get measurementStarted => _measurementStartedController.stream;

  @override
  void dispose() {
    _connectionStatusSubscription?.cancel();
    _dataReceivedSubscription?.cancel();
    _connectionStatusController.close();
    _glucoseReadingController.close();
    _deviceInfoController.close();
    _deviceReadyController.close();
    _measurementStartedController.close();
    _responseHandler.dispose();
    _dataSource.dispose();
  }
}
