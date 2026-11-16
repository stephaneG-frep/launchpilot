import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/application/settings_controller.dart';
import 'demo_catalog.dart';

/// Catalogue fictif quand le mode démo est actif, `null` sinon.
final demoCatalogProvider = Provider<DemoCatalog?>((ref) {
  final demo = ref.watch(demoModeProvider);
  if (!demo) return null;
  final language = ref.watch(
    settingsControllerProvider.select((s) => s.language),
  );
  return DemoCatalog.forLanguage(language);
});
