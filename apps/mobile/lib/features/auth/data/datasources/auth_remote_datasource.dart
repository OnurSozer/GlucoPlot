import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/patient_model.dart';

/// Remote data source for authentication
abstract class AuthRemoteDataSource {
  /// Check if user is authenticated
  bool get isAuthenticated;

  /// Get current session
  Session? get currentSession;

  /// Get current patient from metadata
  Future<PatientModel?> getCurrentPatient();

  /// Request OTP for QR code token
  Future<OtpRequestResponse> requestOtp(String token);

  /// Verify OTP
  Future<OtpVerifyResponse> verifyOtp({
    required String token,
    required String otp,
  });

  /// Sign out
  Future<void> signOut();

  /// Stream of auth state changes
  Stream<AuthState> get authStateChanges;
}

/// OTP request response
class OtpRequestResponse {
  const OtpRequestResponse({
    required this.success,
    this.expiresInSeconds,
    this.maskedPhone,
    this.error,
  });

  final bool success;
  final int? expiresInSeconds;
  final String? maskedPhone;
  final String? error;
}

/// OTP verification response
class OtpVerifyResponse {
  const OtpVerifyResponse({
    required this.success,
    this.patient,
    this.accessToken,
    this.refreshToken,
    this.error,
  });

  final bool success;
  final PatientModel? patient;
  final String? accessToken;
  final String? refreshToken;
  final String? error;
}

/// Implementation of auth remote data source
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  @override
  bool get isAuthenticated => _client.auth.currentSession != null;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Future<PatientModel?> getCurrentPatient() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;

    final userId = session.user.id;

    // Fetch patient data from database
    final response = await _client
        .from('patients')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (response == null) return null;
    return PatientModel.fromJson(response);
  }

  @override
  Future<OtpRequestResponse> requestOtp(String token) async {
    try {
      final response = await _client.functions.invoke(
        'redeem-invite-v1',
        body: {
          'action': 'request_otp',
          'token': token,
          'phone': '',
        },
      );

      if (response.status != 200) {
        final error = response.data?['error'];
        return OtpRequestResponse(
          success: false,
          error: error?['message'] ?? 'Failed to request OTP',
        );
      }

      final data = response.data;
      return OtpRequestResponse(
        success: true,
        expiresInSeconds: data?['expires_in_seconds'] as int? ?? 600,
        maskedPhone: data?['masked_phone'] as String?,
      );
    } catch (e) {
      return OtpRequestResponse(
        success: false,
        error: 'Failed to request OTP: $e',
      );
    }
  }

  @override
  Future<OtpVerifyResponse> verifyOtp({
    required String token,
    required String otp,
  }) async {
    try {
      final response = await _client.functions.invoke(
        'redeem-invite-v1',
        body: {
          'action': 'verify_otp',
          'token': token,
          'otp': otp,
        },
      );

      if (response.status != 200) {
        final error = response.data?['error'];
        return OtpVerifyResponse(
          success: false,
          error: error?['message'] ?? 'Failed to verify OTP',
        );
      }

      final data = response.data;
      final patientData = data?['patient'] as Map<String, dynamic>?;
      final authData = data?['auth'] as Map<String, dynamic>?;

      return OtpVerifyResponse(
        success: true,
        patient: patientData != null ? PatientModel.fromJson(patientData) : null,
        accessToken: authData?['access_token'] as String?,
        refreshToken: authData?['refresh_token'] as String?,
      );
    } catch (e) {
      return OtpVerifyResponse(
        success: false,
        error: 'Failed to verify OTP: $e',
      );
    }
  }

  @override
  Future<void> signOut() async {
    await _client.auth.signOut();
  }
}
