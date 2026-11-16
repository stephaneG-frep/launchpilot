import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/database/app_database.dart';
import 'features/changes/application/change_providers.dart';
import 'features/projects/application/project_providers.dart';
import 'features/settings/application/settings_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Chargées avant le premier rendu pour éviter un flash de thème ou de langue.
  final prefs = await SharedPreferences.getInstance();
  // Sous Linux : ~/.local/share/com.nabucode.launchpilot/launchpilot.sqlite
  final supportDir = await getApplicationSupportDirectory();
  await Directory(supportDir.path).create(recursive: true);
  final dbPath = p.join(supportDir.path, 'launchpilot.sqlite');

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        appDatabaseProvider.overrideWithValue(AppDatabase.open(dbPath)),
        databaseLocationProvider.overrideWithValue(dbPath),
        backupRootProvider.overrideWithValue(
          p.join(supportDir.path, 'backups'),
        ),
      ],
      child: const LaunchPilotApp(),
    ),
  );
}
