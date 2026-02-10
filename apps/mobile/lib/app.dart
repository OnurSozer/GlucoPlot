import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env_config.dart';
import 'core/di/injection_container.dart';
import 'core/providers/settings_provider.dart';
import 'core/theme/theme.dart';
import 'l10n/app_localizations.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/pages/qr_scan_page.dart';
import 'features/auth/presentation/pages/otp_page.dart';
import 'features/auth/presentation/pages/welcome_page.dart';
import 'features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'features/dashboard/presentation/pages/dashboard_page.dart';
import 'features/measurements/presentation/bloc/measurement_bloc.dart';
import 'features/measurements/presentation/pages/add_measurement_page.dart';
import 'features/logging/presentation/bloc/daily_log_bloc.dart';
import 'features/logging/presentation/pages/daily_log_page.dart';
import 'features/logging/presentation/pages/add_log_entry_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';
import 'features/usb_device/presentation/bloc/usb_device_bloc.dart';
import 'features/usb_device/presentation/bloc/usb_device_state.dart';
import 'features/usb_device/domain/repositories/usb_device_repository.dart';
import 'features/usb_device/presentation/pages/glucose_measurement_page.dart';
import 'shell_page.dart';

/// Root application widget
class GlucoPlotApp extends StatefulWidget {
  const GlucoPlotApp({super.key});

  @override
  State<GlucoPlotApp> createState() => _GlucoPlotAppState();
}

class _GlucoPlotAppState extends State<GlucoPlotApp> {
  late final GoRouter _router;
  late final SettingsProvider _settingsProvider;

  @override
  void initState() {
    super.initState();
    _router = _createRouter();
    _settingsProvider = SettingsProvider()..init();
  }

  @override
  void dispose() {
    _settingsProvider.dispose();
    super.dispose();
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: !EnvConfig.instance.isProduction,
      redirect: (context, state) {
        final session = Supabase.instance.client.auth.currentSession;
        final isLoggedIn = session != null;
        final isAuthRoute = state.matchedLocation == '/' ||
            state.matchedLocation.startsWith('/auth');

        // If not logged in and not on auth route, redirect to welcome
        if (!isLoggedIn && !isAuthRoute) {
          return '/';
        }

        // If logged in and on auth route, redirect to dashboard
        if (isLoggedIn && isAuthRoute) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        // Auth routes
        GoRoute(
          path: '/',
          name: 'welcome',
          builder: (context, state) => const WelcomePage(),
        ),
        GoRoute(
          path: '/auth/scan',
          name: 'qr-scan',
          builder: (context, state) => const QrScanPage(),
        ),
        GoRoute(
          path: '/auth/otp',
          name: 'otp',
          builder: (context, state) {
            final token = state.extra as String? ?? '';
            return OtpPage(token: token);
          },
        ),

        // Glucose measurement (full screen, no bottom nav)
        GoRoute(
          path: '/glucose-measurement',
          name: 'glucose-measurement',
          builder: (context, state) => const GlucoseMeasurementPage(),
        ),

        // Main app shell with bottom navigation
        ShellRoute(
          builder: (context, state, child) => ShellPage(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: '/measurements/add',
              name: 'add-measurement',
              builder: (context, state) {
                final initialType = state.extra as String?;
                return AddMeasurementPage(initialType: initialType);
              },
            ),
            GoRoute(
              path: '/log',
              name: 'daily-log',
              builder: (context, state) => const DailyLogPage(),
              routes: [
                GoRoute(
                  path: 'add',
                  name: 'add-log-entry',
                  builder: (context, state) {
                    final initialType = state.extra as String?;
                    return AddLogEntryPage(initialType: initialType);
                  },
                ),
              ],
            ),
            GoRoute(
              path: '/settings',
              name: 'settings',
              builder: (context, state) => const SettingsPage(),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _settingsProvider,
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => sl<AuthBloc>()..add(const AuthCheckRequested()),
              ),
              BlocProvider(
                create: (_) => sl<DashboardBloc>(),
              ),
              BlocProvider(
                create: (_) => sl<MeasurementBloc>(),
              ),
              BlocProvider(
                create: (_) => sl<DailyLogBloc>(),
              ),
              // USB Device - singleton that handles device attach/detach globally
              BlocProvider(
                create: (_) => sl<UsbDeviceBloc>(),
              ),
            ],
            child: BlocListener<UsbDeviceBloc, UsbDeviceState>(
              listenWhen: (previous, current) =>
                  previous.connectionStatus != UsbConnectionStatus.connected &&
                  current.connectionStatus == UsbConnectionStatus.connected,
              listener: (context, state) {
                final session =
                    Supabase.instance.client.auth.currentSession;
                if (session == null) return;

                final currentPath = _router
                    .routeInformationProvider.value.uri.path;
                if (currentPath == '/glucose-measurement') return;

                _router.push('/glucose-measurement');
              },
              child: MaterialApp.router(
                title: 'GlucoPlot',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.light,
                darkTheme: AppTheme.dark,
                themeMode: settings.themeMode,
                locale: settings.locale,
                routerConfig: _router,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: SettingsProvider.supportedLocales,
                builder: (context, child) {
                  // Apply text scale factor from settings
                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.linear(settings.textScaleFactor),
                    ),
                    child: child ?? const SizedBox.shrink(),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
