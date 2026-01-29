part of 'auth_bloc.dart';

/// Auth events
sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Check if user is authenticated
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// QR code scanned - validate token and request OTP
class AuthQrScanned extends AuthEvent {
  const AuthQrScanned(this.token);

  final String token;

  @override
  List<Object?> get props => [token];
}

/// OTP submitted - verify and complete authentication
class AuthOtpSubmitted extends AuthEvent {
  const AuthOtpSubmitted({
    required this.token,
    required this.otp,
  });

  final String token;
  final String otp;

  @override
  List<Object?> get props => [token, otp];
}

/// Request new OTP
class AuthOtpResendRequested extends AuthEvent {
  const AuthOtpResendRequested(this.token);

  final String token;

  @override
  List<Object?> get props => [token];
}

/// User requested logout
class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}
