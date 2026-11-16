import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../detection/application/detection_providers.dart';
import '../../llm/application/llm_service.dart';
import '../../projects/application/project_providers.dart';
import '../../settings/application/settings_controller.dart';
import '../data/site_reader.dart';
import '../data/web_config_repository.dart';
import '../data/web_services.dart';
import '../domain/hosting.dart';
import '../domain/web_build.dart';

final webConfigRepositoryProvider = Provider<WebConfigRepository>(
  (ref) => WebConfigRepository(ref.watch(sharedPreferencesProvider)),
);

/// Réglages web du projet ouvert.
final webConfigProvider =
    NotifierProvider<WebConfigController, WebProjectConfig>(
      WebConfigController.new,
    );

class WebConfigController extends Notifier<WebProjectConfig> {
  int? get _projectId => ref.watch(currentProjectIdProvider);

  @override
  WebProjectConfig build() {
    final id = _projectId;
    if (id == null) return const WebProjectConfig();
    final saved = ref.read(webConfigRepositoryProvider).load(id);
    // Hébergeur préféré des paramètres, tant que le projet n'en a pas.
    return saved.host == null
        ? saved.copyWith(
            host: ref.read(settingsControllerProvider).preferredHost,
          )
        : saved;
  }

  Future<void> update(WebProjectConfig next) async {
    final id = ref.read(currentProjectIdProvider);
    if (id == null || next == state) return;
    state = next;
    await ref.read(webConfigRepositoryProvider).save(id, next);
  }
}

/// Plan de build du projet ouvert, avec le dossier de sortie corrigé.
final webBuildPlanProvider = Provider<WebBuildPlan?>((ref) {
  final report = ref.watch(currentDetectionProvider).value?.report;
  if (report == null) return null;
  final plan = planWebBuild(report);
  final override = ref.watch(webConfigProvider.select((c) => c.outputDir));
  return plan == null || override == null || override.isEmpty
      ? plan
      : plan.withOutputDir(override);
});

final siteReaderProvider = Provider<SiteReader>((ref) => const SiteReader());

final toolLocatorProvider = Provider<ToolLocator>(
  (ref) => const PathToolLocator(),
);

final dnsResolverProvider = Provider<DnsResolver>(
  (ref) => const SystemDnsResolver(),
);

final siteCheckerProvider = Provider<SiteChecker>(
  (ref) => SiteChecker(ref.watch(httpClientProvider)),
);

/// Serveur d'aperçu local : un seul à la fois, arrêté avec l'application.
final previewServerProvider = Provider<LocalPreviewServer>((ref) {
  final server = LocalPreviewServer();
  ref.onDispose(server.stop);
  return server;
});

/// Outils d'hébergement installés (recherche dans le PATH).
final installedToolsProvider = FutureProvider<Set<String>>((ref) async {
  final locator = ref.watch(toolLocatorProvider);
  final out = <String>{};
  for (final tool in const [
    'firebase',
    'vercel',
    'netlify',
    'lighthouse',
    'fastlane',
  ]) {
    if (await locator.isInstalled(tool)) out.add(tool);
  }
  return out;
}, retry: (_, _) => null);
