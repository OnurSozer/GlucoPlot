import 'dart:async';
import 'dart:typed_data';

import '../../domain/entities/usb_message.dart';
import 'protocol_constants.dart';

/// Handles incoming bytes from the USB device and parses them into messages
class MessageResponseHandler {
  final StreamController<UsbMessage> _messageController =
      StreamController<UsbMessage>.broadcast();

  /// Internal buffer for accumulating incoming bytes
  List<int> _buffer = [];

  /// Stream of parsed USB messages
  Stream<UsbMessage> get messages => _messageController.stream;

  /// Handles incoming bytes from the USB device
  ///
  /// Bytes are accumulated in a buffer and processed to extract complete packets
  void handleIncomingBytes(List<int> bytes) {
    _buffer.addAll(bytes);
    _processBuffer();
  }

  /// Processes the buffer to extract and parse complete packets
  void _processBuffer() {
    while (_buffer.isNotEmpty) {
      // Find start byte, discarding any leading garbage
      while (_buffer.isNotEmpty &&
          _buffer.first != ProtocolConstants.startByte) {
        _buffer.removeAt(0);
      }

      // Need at least 3 bytes to read method ID (start + 2 method bytes)
      if (_buffer.length < 3) {
        return;
      }

      // Parse method ID to determine expected packet size
      final methodId = _buffer[1] | (_buffer[2] << 8);
      final expectedPacketSize = ProtocolConstants.getPacketSizeForMethod(methodId);

      if (expectedPacketSize < 0) {
        // Unknown method ID - discard start byte and try again
        print('[MessageHandler] Unknown method ID: $methodId, discarding start byte');
        _buffer.removeAt(0);
        continue;
      }

      // Wait until we have the full packet
      if (_buffer.length < expectedPacketSize) {
        return;
      }

      // Extract packet
      final packet = _buffer.sublist(0, expectedPacketSize);
      _buffer = _buffer.sublist(expectedPacketSize);

      // Verify stop byte
      if (packet.last != ProtocolConstants.stopByte) {
        print('[MessageHandler] Invalid stop byte: ${packet.last}, expected ${ProtocolConstants.stopByte}');
        continue;
      }

      // Parse and route the packet
      _parsePacket(packet);
    }
  }

  /// Parses a complete packet and routes it to the appropriate handler
  void _parsePacket(List<int> packet) {
    if (packet.length < ProtocolConstants.minPacketSize) {
      return;
    }

    // Parse method ID (uint16 little endian)
    final methodId = packet[1] | (packet[2] << 8);

    // Extract data (between method and stop byte)
    final data = packet.sublist(3, packet.length - 1);

    // Route to appropriate handler
    _routeMessage(methodId, data);
  }

  /// Routes the message to the appropriate handler based on method ID
  void _routeMessage(int methodId, List<int> data) {
    print('[MessageHandler] Received method ID: $methodId (0x${methodId.toRadixString(16)})');

    switch (methodId) {
      case ProtocolConstants.methodGlucoseReading:
        print('[MessageHandler] -> Glucose Reading');
        _handleGlucoseReading(data);
        break;
      case ProtocolConstants.methodDeviceIdResponse:
        print('[MessageHandler] -> Device ID Response');
        _handleDeviceIdResponse(data);
        break;
      case ProtocolConstants.methodDeviceReady:
        print('[MessageHandler] -> Device Ready');
        _handleDeviceReady();
        break;
      case ProtocolConstants.methodMeasurementStarted:
        print('[MessageHandler] -> Measurement Started');
        _handleMeasurementStarted();
        break;
      default:
        print('[MessageHandler] -> Unknown method');
        _messageController.add(UnknownMessage(methodId: methodId, data: data));
    }
  }

  /// Handles glucose reading message (method 1010)
  ///
  /// Data format: [concentration(4 bytes float)] [measuredCurrent(4 bytes float)] [baselineCurrent(4 bytes float)]
  void _handleGlucoseReading(List<int> data) {
    if (data.length < ProtocolConstants.glucoseReadingDataSize) {
      return;
    }

    // Parse concentration (IEEE 754 float, little endian)
    final concentrationBytes =
        ByteData.sublistView(Uint8List.fromList(data.sublist(0, 4)));
    final concentration = concentrationBytes.getFloat32(0, Endian.little);

    // Parse measured current (for future use)
    final measuredCurrentBytes =
        ByteData.sublistView(Uint8List.fromList(data.sublist(4, 8)));
    final measuredCurrent = measuredCurrentBytes.getFloat32(0, Endian.little);

    // Parse baseline current (for future use)
    final baselineCurrentBytes =
        ByteData.sublistView(Uint8List.fromList(data.sublist(8, 12)));
    final baselineCurrent = baselineCurrentBytes.getFloat32(0, Endian.little);

    _messageController.add(GlucoseReadingMessage(
      concentration: concentration,
      measuredCurrent: measuredCurrent,
      baselineCurrent: baselineCurrent,
      timestamp: DateTime.now(),
    ));
  }

  /// Handles device ID response message (method 1007)
  ///
  /// Data format: [device ID (10 bytes ASCII)]
  void _handleDeviceIdResponse(List<int> data) {
    if (data.length < ProtocolConstants.deviceIdDataSize) {
      return;
    }

    // Convert 10 bytes to ASCII string (e.g., "GlP-000034")
    final deviceIdBytes = data.sublist(0, 10);
    final deviceId = String.fromCharCodes(deviceIdBytes);

    _messageController.add(DeviceIdMessage(deviceId: deviceId));
  }

  /// Handles device ready message (method 1008)
  ///
  /// No data payload - indicates GlucoPlot is ready for measurement
  void _handleDeviceReady() {
    _messageController.add(DeviceReadyMessage(timestamp: DateTime.now()));
  }

  /// Handles measurement started message (method 1009)
  ///
  /// No data payload - indicates strip inserted and experiment begins
  void _handleMeasurementStarted() {
    _messageController.add(MeasurementStartedMessage(timestamp: DateTime.now()));
  }

  /// Clears the internal buffer
  void clearBuffer() {
    _buffer.clear();
  }

  /// Disposes of resources
  void dispose() {
    _messageController.close();
  }
}
