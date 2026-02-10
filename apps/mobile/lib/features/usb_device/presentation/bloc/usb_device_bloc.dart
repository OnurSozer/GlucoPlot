import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/usb_device_repository.dart';
import 'usb_device_event.dart';
import 'usb_device_state.dart';

/// BLoC for managing USB device connection and data
class UsbDeviceBloc extends Bloc<UsbDeviceEvent, UsbDeviceState> {
  final UsbDeviceRepository _repository;

  StreamSubscription? _connectionStatusSubscription;
  StreamSubscription? _glucoseReadingSubscription;
  StreamSubscription? _deviceInfoSubscription;
  StreamSubscription? _deviceReadySubscription;
  StreamSubscription? _measurementStartedSubscription;

  /// Maximum number of readings to keep in history
  static const int _maxHistorySize = 50;

  UsbDeviceBloc({required UsbDeviceRepository repository})
      : _repository = repository,
        super(const UsbDeviceState()) {
    on<UsbDeviceCheckRequested>(_onCheckRequested);
    on<UsbDeviceIdRequested>(_onDeviceIdRequested);
    on<UsbConnectionStatusChanged>(_onConnectionStatusChanged);
    on<UsbGlucoseReadingReceived>(_onGlucoseReadingReceived);
    on<UsbDeviceInfoReceived>(_onDeviceInfoReceived);
    on<UsbDeviceClearHistoryRequested>(_onClearHistoryRequested);
    on<UsbClearLatestReadingRequested>(_onClearLatestReadingRequested);
    on<UsbDeviceReadyReceived>(_onDeviceReady);
    on<UsbMeasurementStartedReceived>(_onMeasurementStarted);

    _setupStreamListeners();
  }

  Future<void> _onCheckRequested(
    UsbDeviceCheckRequested event,
    Emitter<UsbDeviceState> emit,
  ) async {
    // Check if device is already available and trigger events via stream
    await _repository.checkForDevice();
  }

  void _setupStreamListeners() {
    _connectionStatusSubscription = _repository.connectionStatus.listen(
      (status) => add(UsbConnectionStatusChanged(status)),
    );

    _glucoseReadingSubscription = _repository.glucoseReadings.listen(
      (reading) => add(UsbGlucoseReadingReceived(reading)),
    );

    _deviceInfoSubscription = _repository.deviceInfo.listen(
      (info) => add(UsbDeviceInfoReceived(info)),
    );

    _deviceReadySubscription = _repository.deviceReady.listen(
      (_) => add(const UsbDeviceReadyReceived()),
    );

    _measurementStartedSubscription = _repository.measurementStarted.listen(
      (_) => add(const UsbMeasurementStartedReceived()),
    );
  }

  Future<void> _onDeviceIdRequested(
    UsbDeviceIdRequested event,
    Emitter<UsbDeviceState> emit,
  ) async {
    if (!state.isConnected) return;

    await _repository.requestDeviceId();
  }

  Future<void> _onConnectionStatusChanged(
    UsbConnectionStatusChanged event,
    Emitter<UsbDeviceState> emit,
  ) async {
    print('[UsbBloc] Connection status changed: ${event.status}');
    if (event.status == UsbConnectionStatus.connected) {
      emit(state.copyWith(
        connectionStatus: event.status,
        isLoading: false,
      ));
    } else {
      // Device disconnected: reset all device-related state
      emit(state.copyWith(
        connectionStatus: event.status,
        isLoading: false,
        isDeviceReady: false,
        isMeasuring: false,
        clearDeviceInfo: true,
        clearError: true,
      ));
    }

    // Automatically request device ID when connected
    if (event.status == UsbConnectionStatus.connected) {
      print('[UsbBloc] Device connected, requesting device ID...');
      await _repository.requestDeviceId();
    }
  }

  void _onGlucoseReadingReceived(
    UsbGlucoseReadingReceived event,
    Emitter<UsbDeviceState> emit,
  ) {
    // Add new reading to history (most recent first)
    final newHistory = [event.reading, ...state.readingHistory];

    // Trim history if it exceeds max size
    final trimmedHistory = newHistory.length > _maxHistorySize
        ? newHistory.sublist(0, _maxHistorySize)
        : newHistory;

    emit(state.copyWith(
      latestReading: event.reading,
      readingHistory: trimmedHistory,
      isMeasuring: false, // Measurement complete
    ));
  }

  void _onDeviceInfoReceived(
    UsbDeviceInfoReceived event,
    Emitter<UsbDeviceState> emit,
  ) {
    emit(state.copyWith(deviceInfo: event.info));
  }

  void _onClearHistoryRequested(
    UsbDeviceClearHistoryRequested event,
    Emitter<UsbDeviceState> emit,
  ) {
    emit(state.copyWith(
      readingHistory: [],
      clearLatestReading: true,
    ));
  }

  void _onClearLatestReadingRequested(
    UsbClearLatestReadingRequested event,
    Emitter<UsbDeviceState> emit,
  ) {
    emit(state.copyWith(clearLatestReading: true));
  }

  void _onDeviceReady(
    UsbDeviceReadyReceived event,
    Emitter<UsbDeviceState> emit,
  ) {
    emit(state.copyWith(isDeviceReady: true));
  }

  void _onMeasurementStarted(
    UsbMeasurementStartedReceived event,
    Emitter<UsbDeviceState> emit,
  ) {
    emit(state.copyWith(isMeasuring: true));
  }

  @override
  Future<void> close() {
    _connectionStatusSubscription?.cancel();
    _glucoseReadingSubscription?.cancel();
    _deviceInfoSubscription?.cancel();
    _deviceReadySubscription?.cancel();
    _measurementStartedSubscription?.cancel();
    // Note: Don't dispose repository - it's a singleton that persists across pages
    return super.close();
  }
}
