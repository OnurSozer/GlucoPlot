import '../entities/patient.dart';

/// Result type for auth operations
sealed class AuthResult<T> {
  const AuthResult();
}

class AuthSuccess<T> extends AuthResult<T> {
  const AuthSuccess(this.data);
  final T data;
}

class AuthFailure<T> extends AuthResult<T> {
  const AuthFailure(this.message, {this.code});
  final String message;
  final String? code;
}

/// OTP request result
class OtpRequestResult {
  const OtpRequestResult({
    required this.success,
    this.expiresInSeconds,
    this.maskedPhone,
  });

  final bool success;
  final int? expiresInSeconds;
  final String? maskedPhone;
}

/// OTP verification result
class OtpVerificationResult {
  const OtpVerificationResult({
    required this.patient,
    this.accessToken,
    this.refreshToken,
  });

  final Patient patient;
  final String? accessToken;
  final String? refreshToken;
}

/// Auth repository interface
abstract class AuthRepository {
  /// Check if user is currently authenticated
  Future<bool> isAuthenticated();

  /// Get current patient
  Future<AuthResult<Patient?>> getCurrentPatient();

  /// Request OTP for QR code token
  Future<AuthResult<OtpRequestResult>> requestOtp(String token);

  /// Verify OTP and complete authentication
  Future<AuthResult<OtpVerificationResult>> verifyOtp({
    required String token,
    required String otp,
  });

  /// Sign out
  Future<AuthResult<void>> signOut();

  /// Stream of auth state changes
  Stream<bool> get authStateChanges;
}
