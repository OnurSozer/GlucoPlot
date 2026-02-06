import 'protocol_constants.dart';

/// Generates messages to send to the STM32 device
class MessageGenerator {
  const MessageGenerator();

  /// Creates a message packet with proper framing
  ///
  /// Packet structure:
  /// [START_BYTE] [METHOD_LOW] [METHOD_HIGH] [DATA...] [STOP_BYTE]
  List<int> createMessage(int methodId, [List<int> data = const []]) {
    return [
      ProtocolConstants.startByte,
      methodId & 0xFF, // Low byte (little endian)
      (methodId >> 8) & 0xFF, // High byte
      ...data,
      ProtocolConstants.stopByte,
    ];
  }

  /// Creates a device ID request message
  ///
  /// Packet: [0x6B] [0x07] [0x00] [0x64]
  List<int> requestDeviceId() {
    return createMessage(ProtocolConstants.methodRequestDeviceId);
  }
}
