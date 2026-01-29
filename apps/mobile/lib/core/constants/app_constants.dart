/// App-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'GlucoPlot';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userIdKey = 'user_id';
  static const String patientIdKey = 'patient_id';
  static const String onboardingCompleteKey = 'onboarding_complete';
  static const String themeKey = 'theme_mode';

  // API Endpoints
  static const String createPatientEndpoint = '/functions/v1/create-patient-v1';
  static const String redeemInviteEndpoint = '/functions/v1/redeem-invite-v1';
  static const String evaluateRiskEndpoint = '/functions/v1/evaluate-risk-v1';

  // Timeouts
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration otpExpiry = Duration(minutes: 10);

  // Validation
  static const int otpLength = 6;
  static const int minPasswordLength = 8;
  static const int maxNotesLength = 500;

  // Measurement Defaults
  static const double defaultGlucoseMin = 70.0;
  static const double defaultGlucoseMax = 140.0;
  static const double defaultBPSystolicMax = 140.0;
  static const double defaultBPDiastolicMax = 90.0;
}
