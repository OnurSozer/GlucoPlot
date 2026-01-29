import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';

part 'auth_event.dart';
part 'auth_state.dart';

/// Auth BLoC for handling authentication flow
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthQrScanned>(_onQrScanned);
    on<AuthOtpSubmitted>(_onOtpSubmitted);
    on<AuthOtpResendRequested>(_onOtpResendRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);

    // Listen to auth state changes
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (data.event == AuthChangeEvent.signedOut || 
            data.event == AuthChangeEvent.signedIn ||
            data.event == AuthChangeEvent.tokenRefreshed) {
          add(const AuthCheckRequested());
        }
      },
    );
  }

  late final dynamic _authSubscription;
  final _supabase = Supabase.instance.client;

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    final session = _supabase.auth.currentSession;
    if (session == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    // Get patient info from user metadata
    final user = session.user;
    final metadata = user.userMetadata;
    final patientId = metadata?['patient_id'] as String?;
    final patientName = metadata?['full_name'] as String?;

    if (patientId != null) {
      emit(AuthAuthenticated(
        userId: user.id,
        patientId: patientId,
        patientName: patientName,
      ));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onQrScanned(
    AuthQrScanned event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Activating account...'));

    try {
      print('Calling redeem-invite-v1...');
      // Call Edge Function to Redeem Invite (Direct)
      final response = await _supabase.functions.invoke(
        'redeem-invite-v1',
        body: {
          'action': 'redeem',
          'token': event.token,
        },
      );
      print('Redeem response status: ${response.status}');

      if (response.status != 200) {
        final error = response.data?['error'];
        final message = error?['message'] ?? 'Failed to redeem QR code';
        print('Redeem failed: $message');
        final code = error?['code'];
        emit(AuthError(message: message, code: code));
        return;
      }

      final data = response.data;
      final authData = data?['auth'];
      final patient = data?['patient'];
      
      print('Redeem success. Auth data: $authData');

      // If we got auth data with temp password, login automatically
      if (authData != null && authData['temp_password'] != null) {
        final email = authData['email'];
        final password = authData['temp_password'];

        try {
            print('Starting signInWithPassword...');
            emit(const AuthLoading(message: 'Logging in...'));
            
            // Perform silent login using the temp password
            final authResponse = await _supabase.auth.signInWithPassword(
                email: email,
                password: password,
            );
            
            print('SignIn complete. Session: ${authResponse.session != null}');
            
            // After sign in, session should be active.
            add(const AuthCheckRequested());
            return;

        } catch (e) {
            print('Auto-login failed exception: $e');
            emit(AuthError(message: 'Activation successful, but login failed: $e'));
            return;
        }
      } else if (patient != null) {
         print('Patient data found but no auth/password.');
         // Fallback if no auth returned (should not happen with new backend)
         emit(const AuthError(message: 'Account activated, but auto-login failed.'));
      }
      
    } catch (e) {
      emit(AuthError(message: 'Failed to process QR code: $e'));
    }
  }

  Future<void> _onOtpSubmitted(
    AuthOtpSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Verifying code...'));

    try {
      // Call Edge Function to verify OTP
      final response = await _supabase.functions.invoke(
        'redeem-invite-v1',
        body: {
          'action': 'verify_otp',
          'token': event.token,
          'otp': event.otp,
        },
      );

      if (response.status != 200) {
        final error = response.data?['error'];
        final message = error?['message'] ?? 'Failed to verify code';
        final code = error?['code'];
        emit(AuthError(message: message, code: code));
        return;
      }

      final data = response.data;
      final patient = data?['patient'];
      final auth = data?['auth'];

      // If magic link is provided, sign in with it
      if (auth != null && auth['magic_link'] != null) {
        // For now, trigger auth check - in production handle magic link
        add(const AuthCheckRequested());
      } else if (patient != null) {
        emit(AuthAuthenticated(
          userId: patient['id'],
          patientId: patient['id'],
          patientName: patient['full_name'],
        ));
      } else {
        emit(const AuthError(message: 'Activation failed. Please try again.'));
      }
    } catch (e) {
      emit(AuthError(message: 'Verification failed: $e'));
    }
  }

  Future<void> _onOtpResendRequested(
    AuthOtpResendRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Sending new code...'));

    try {
      final response = await _supabase.functions.invoke(
        'redeem-invite-v1',
        body: {
          'action': 'request_otp',
          'token': event.token,
          'phone': '',
        },
      );

      if (response.status != 200) {
        final error = response.data?['error'];
        emit(AuthError(message: error?['message'] ?? 'Failed to resend code'));
        return;
      }

      final data = response.data;
      final expiresIn = data?['expires_in_seconds'] ?? 600;

      emit(AuthAwaitingOtp(
        token: event.token,
        phone: '***',
        expiresInSeconds: expiresIn,
      ));
    } catch (e) {
      emit(AuthError(message: 'Failed to resend code: $e'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading(message: 'Logging out...'));

    try {
      await _supabase.auth.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Failed to log out: $e'));
    }
  }
}
