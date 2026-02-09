import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env_config.dart';
import 'core/di/injection_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment config for development
  EnvConfig.initDev();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize HydratedBloc storage for SWR-like caching
  final storageDir = await getApplicationDocumentsDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(storageDir.path),
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: EnvConfig.instance.supabaseUrl,
    anonKey: EnvConfig.instance.supabaseAnonKey,
  );

  // Initialize dependencies
  await initDependencies();

  runApp(const GlucoPlotApp());
}
