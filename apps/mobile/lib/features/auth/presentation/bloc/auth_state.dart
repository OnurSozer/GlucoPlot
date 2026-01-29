part of 'auth_bloc.dart';

/// Auth states
sealed class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state - checking auth status
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during auth operations
class AuthLoading extends AuthState {
  const AuthLoading({this.message});

  final String? message;

  @override
  List<Object?> get props => [message];
}

/// Unauthenticated - user needs to log in
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// QR code validated - waiting for OTP
class AuthAwaitingOtp extends AuthState {
  const AuthAwaitingOtp({
    required this.token,
    required this.phone,
    required this.expiresInSeconds,
  });

  final String token;
  final String phone;
  final int expiresInSeconds;

  @override
  List<Object?> get props => [token, phone, expiresInSeconds];
}

/// Authenticated - user is logged in
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({
    required this.userId,
    required this.patientId,
    this.patientName,
  });

  final String userId;
  final String patientId;
  final String? patientName;

  @override
  List<Object?> get props => [userId, patientId, patientName];
}

/// Auth error
class AuthError extends AuthState {
  const AuthError({
    required this.message,
    this.code,
  });

  final String message;
  final String? code;

  @override
  List<Object?> get props => [message, code];
}
