import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Auth
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';

// Dashboard
import '../../features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/domain/usecases/get_dashboard_summary.dart';
import '../../features/dashboard/presentation/bloc/dashboard_bloc.dart';

// Measurements
import '../../features/measurements/data/datasources/measurement_remote_datasource.dart';
import '../../features/measurements/data/repositories/measurement_repository_impl.dart';
import '../../features/measurements/domain/repositories/measurement_repository.dart';
import '../../features/measurements/domain/usecases/get_measurements.dart';
import '../../features/measurements/domain/usecases/add_measurement.dart';
import '../../features/measurements/presentation/bloc/measurement_bloc.dart';

// Logging
import '../../features/logging/data/datasources/daily_log_remote_datasource.dart';
import '../../features/logging/data/repositories/daily_log_repository_impl.dart';
import '../../features/logging/domain/repositories/daily_log_repository.dart';
import '../../features/logging/domain/usecases/get_daily_logs.dart';
import '../../features/logging/domain/usecases/add_log_entry.dart';
import '../../features/logging/presentation/bloc/daily_log_bloc.dart';

/// Service locator instance
final sl = GetIt.instance;

/// Initialize all dependencies
Future<void> initDependencies() async {
  // External
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // ===== AUTH =====
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  // BLoC - Auth uses Supabase directly, not through repository
  sl.registerFactory(() => AuthBloc());

  // ===== DASHBOARD =====
  // Data sources
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDashboardSummary(sl()));
  sl.registerLazySingleton(() => GetActiveAlerts(sl()));
  sl.registerLazySingleton(() => AcknowledgeAlert(sl()));
  sl.registerLazySingleton(() => GetChartData(sl()));

  // BLoC
  sl.registerFactory(() => DashboardBloc(repository: sl()));

  // ===== MEASUREMENTS =====
  // Data sources
  sl.registerLazySingleton<MeasurementRemoteDataSource>(
    () => MeasurementRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<MeasurementRepository>(
    () => MeasurementRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetMeasurements(sl()));
  sl.registerLazySingleton(() => GetLatestMeasurements(sl()));
  sl.registerLazySingleton(() => AddMeasurement(sl()));

  // BLoC
  sl.registerFactory(() => MeasurementBloc(repository: sl()));

  // ===== LOGGING =====
  // Data sources
  sl.registerLazySingleton<DailyLogRemoteDataSource>(
    () => DailyLogRemoteDataSourceImpl(client: sl()),
  );

  // Repositories
  sl.registerLazySingleton<DailyLogRepository>(
    () => DailyLogRepositoryImpl(sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetDailyLogs(sl()));
  sl.registerLazySingleton(() => GetLogsForDate(sl()));
  sl.registerLazySingleton(() => AddLogEntry(sl()));

  // BLoC
  sl.registerFactory(() => DailyLogBloc(repository: sl()));
}

/// Reset all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}
