import '../../domain/entities/patient.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

/// Implementation of AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);

  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<bool> isAuthenticated() async {
    return _remoteDataSource.isAuthenticated;
  }

  @override
  Future<AuthResult<Patient?>> getCurrentPatient() async {
    try {
      final patient = await _remoteDataSource.getCurrentPatient();
      return AuthSuccess(patient);
    } catch (e) {
      return AuthFailure('Failed to get current patient: $e');
    }
  }

  @override
  Future<AuthResult<OtpRequestResult>> requestOtp(String token) async {
    try {
      final response = await _remoteDataSource.requestOtp(token);

      if (!response.success) {
        return AuthFailure(response.error ?? 'Failed to request OTP');
      }

      return AuthSuccess(OtpRequestResult(
        success: true,
        expiresInSeconds: response.expiresInSeconds,
        maskedPhone: response.maskedPhone,
      ));
    } catch (e) {
      return AuthFailure('Failed to request OTP: $e');
    }
  }

  @override
  Future<AuthResult<OtpVerificationResult>> verifyOtp({
    required String token,
    required String otp,
  }) async {
    try {
      final response = await _remoteDataSource.verifyOtp(
        token: token,
        otp: otp,
      );

      if (!response.success || response.patient == null) {
        return AuthFailure(response.error ?? 'Failed to verify OTP');
      }

      return AuthSuccess(OtpVerificationResult(
        patient: response.patient!,
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      ));
    } catch (e) {
      return AuthFailure('Failed to verify OTP: $e');
    }
  }

  @override
  Future<AuthResult<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const AuthSuccess(null);
    } catch (e) {
      return AuthFailure('Failed to sign out: $e');
    }
  }

  @override
  Stream<bool> get authStateChanges {
    return _remoteDataSource.authStateChanges.map(
      (state) => state.session != null,
    );
  }
}
