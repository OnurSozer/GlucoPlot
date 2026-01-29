/// App-wide string constants for UI text
class AppStrings {
  AppStrings._();

  // General
  static const String appName = 'GlucoPlot';
  static const String ok = 'OK';
  static const String cancel = 'Cancel';
  static const String save = 'Save';
  static const String delete = 'Delete';
  static const String edit = 'Edit';
  static const String done = 'Done';
  static const String next = 'Next';
  static const String back = 'Back';
  static const String retry = 'Retry';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';

  // Auth
  static const String welcome = 'Welcome';
  static const String welcomeBack = 'Welcome Back';
  static const String scanQrCode = 'Scan QR Code';
  static const String scanQrDescription =
      'Scan the QR code provided by your doctor to activate your account.';
  static const String enterOtp = 'Enter Verification Code';
  static const String otpSentTo = 'A verification code was sent to';
  static const String verifyOtp = 'Verify';
  static const String resendOtp = 'Resend Code';
  static const String invalidQrCode = 'Invalid QR code. Please try again.';
  static const String invalidOtp = 'Invalid verification code.';
  static const String otpExpired = 'Code expired. Please request a new one.';

  // Dashboard
  static const String dashboard = 'Dashboard';
  static const String todaySummary = 'Today\'s Summary';
  static const String recentMeasurements = 'Recent Measurements';
  static const String quickActions = 'Quick Actions';
  static const String viewAll = 'View All';
  static const String noData = 'No Data';
  static const String lastMeasured = 'Last measured';

  // Measurements
  static const String measurements = 'Measurements';
  static const String addMeasurement = 'Add Measurement';
  static const String glucose = 'Blood Glucose';
  static const String bloodPressure = 'Blood Pressure';
  static const String heartRate = 'Heart Rate';
  static const String weight = 'Weight';
  static const String temperature = 'Temperature';
  static const String oxygenSaturation = 'Oxygen (SpO2)';
  static const String selectType = 'Select Type';
  static const String enterValue = 'Enter Value';
  static const String notes = 'Notes (optional)';
  static const String measurementSaved = 'Measurement saved';

  // Logging
  static const String dailyLog = 'Daily Log';
  static const String addEntry = 'Add Entry';
  static const String food = 'Food';
  static const String sleep = 'Sleep';
  static const String exercise = 'Exercise';
  static const String medication = 'Medication';
  static const String symptoms = 'Symptoms';
  static const String entrySaved = 'Entry saved';

  // Settings
  static const String settings = 'Settings';
  static const String profile = 'Profile';
  static const String notifications = 'Notifications';
  static const String appearance = 'Appearance';
  static const String darkMode = 'Dark Mode';
  static const String language = 'Language';
  static const String about = 'About';
  static const String logout = 'Log Out';
  static const String logoutConfirm = 'Are you sure you want to log out?';
  static const String version = 'Version';

  // Errors
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'No internet connection. Please check your network.';
  static const String sessionExpired =
      'Your session has expired. Please log in again.';
}
