/// Environment configuration for the app.
/// Uses different values based on build flavor.
class EnvConfig {
  EnvConfig._();

  static late EnvConfig _instance;
  static EnvConfig get instance => _instance;

  late final String supabaseUrl;
  late final String supabaseAnonKey;
  late final String appName;
  late final bool isProduction;

  /// Initialize with development configuration
  /// NOTE: Update supabaseAnonKey with your actual key from Supabase dashboard
  static void initDev() {
    _instance = EnvConfig._()
      // Using hosted Supabase - update with your credentials
      ..supabaseUrl = 'https://rctedscwqymzsecpqsjz.supabase.co'
      ..supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJjdGVkc2N3cXltenNlY3Bxc2p6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk1OTQyOTIsImV4cCI6MjA4NTE3MDI5Mn0.mjQChmoLaDyuq9c4IymSjRIK6nQNmKJd5Vdf1VPZFWc'  // Get from Supabase dashboard
      ..appName = 'GlucoPlot Dev'
      ..isProduction = false;
  }

  /// Initialize with production configuration
  static void initProd() {
    _instance = EnvConfig._()
      ..supabaseUrl = const String.fromEnvironment(
        'SUPABASE_URL',
        defaultValue: '',
      )
      ..supabaseAnonKey = const String.fromEnvironment(
        'SUPABASE_ANON_KEY',
        defaultValue: '',
      )
      ..appName = 'GlucoPlot'
      ..isProduction = true;
  }
}
