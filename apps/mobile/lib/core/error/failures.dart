import 'package:equatable/equatable.dart';

/// Base failure class for domain layer errors
abstract class Failure extends Equatable {
  const Failure({this.message, this.code});

  final String? message;
  final String? code;

  @override
  List<Object?> get props => [message, code];

  String get displayMessage => message ?? 'An unexpected error occurred';
}

/// Server-side failures (API errors)
class ServerFailure extends Failure {
  const ServerFailure({super.message, super.code});
}

/// Network failures (no connection)
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure({super.message, super.code});

  factory AuthFailure.invalidCredentials() => const AuthFailure(
        message: 'Invalid email or password.',
        code: 'INVALID_CREDENTIALS',
      );

  factory AuthFailure.sessionExpired() => const AuthFailure(
        message: 'Your session has expired. Please log in again.',
        code: 'SESSION_EXPIRED',
      );

  factory AuthFailure.invalidToken() => const AuthFailure(
        message: 'Invalid invite token. Please scan a valid QR code.',
        code: 'INVALID_TOKEN',
      );

  factory AuthFailure.invalidOtp() => const AuthFailure(
        message: 'Invalid verification code. Please try again.',
        code: 'INVALID_OTP',
      );

  factory AuthFailure.otpExpired() => const AuthFailure(
        message: 'Verification code expired. Please request a new one.',
        code: 'OTP_EXPIRED',
      );

  factory AuthFailure.inviteExpired() => const AuthFailure(
        message: 'This invite has expired. Please contact your doctor.',
        code: 'INVITE_EXPIRED',
      );

  factory AuthFailure.inviteAlreadyUsed() => const AuthFailure(
        message: 'This invite has already been used.',
        code: 'INVITE_ALREADY_USED',
      );
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure({super.message, super.code = 'VALIDATION_ERROR'});
}

/// Cache failures (local storage)
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Unable to access local storage.',
    super.code = 'CACHE_ERROR',
  });
}

/// Not found failures
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    super.message = 'The requested resource was not found.',
    super.code = 'NOT_FOUND',
  });
}

/// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure({
    super.message = 'Permission denied.',
    super.code = 'PERMISSION_DENIED',
  });
}
