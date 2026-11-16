import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../app/destinations.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../l10n/app_localizations.dart';
import '../../changes/domain/change_set.dart';
import '../../changes/presentation/change_preview_dialog.dart';
import '../../detection/application/detection_providers.dart';
import '../../detection/data/detection_repository.dart';
import '../../detection/domain/detection_report.dart';
import '../../git/application/git_providers.dart';
import '../../projects/application/project_providers.dart';
import '../../projects/domain/project_views.dart';
import 'changelog_tab.dart';
import 'icons_tab.dart';
import 'legal_tab.dart';
import 'screenshots_tab.dart';
import 'texts_tab.dart';
import 'version_tab.dart';
import '../../android/presentation/android_tab.dart';
import '../../android/presentation/play_tab.dart';
import '../../ios/presentation/app_store_tab.dart';
import '../../ios/presentation/ios_tab.dart';
import '../../web/presentation/hosting_tab.dart';
import '../../web/presentation/pwa_tab.dart';
import '../../web/presentation/seo_tab.dart';
import '../../web/presentation/web_tab.dart';

/// Outils de l'écran Contenus ; leur nom sert dans l'adresse (`?tab=`).
enum ContentTool {
  version,
  changelog,
  icons,
  screenshots,
  texts,
  legal,
  web,
  seo,
  pwa,
  hosting,
  android,
  play,
  ios,
  appStore;

  /// Outils propres à la cible Web.
  bool get webOnly => const {web, seo, pwa, hosting}.contains(this);

  /// Outils propres à la cible Android (projet Flutter).
  bool get androidOnly => this == android || this == play;

  /// Outils propres à la cible iOS (projet Flutter).
  bool get iosOnly => this == ios || this == appStore;
}

extension ContentToolUi on ContentTool {
  String label(AppLocalizations l10n) => switch (this) {
    ContentTool.version => l10n.contentTabVersion,
    ContentTool.changelog => l10n.contentTabChangelog,
    ContentTool.icons => l10n.contentIcons,
    ContentTool.screenshots => l10n.contentScreenshots,
    ContentTool.texts => l10n.contentTabTexts,
    ContentTool.legal => l10n.contentTabLegal,
    ContentTool.web => l10n.contentTabWeb,
    ContentTool.seo => 'SEO',
    ContentTool.pwa => 'PWA',
    ContentTool.hosting => l10n.contentTabHosting,
    ContentTool.android => l10n.contentTabAndroid,
    ContentTool.play => l10n.contentTabPlay,
    ContentTool.ios => l10n.contentTabIos,
    ContentTool.appStore => l10n.contentTabAppStore,
  };

  IconData get icon => switch (this) {
    ContentTool.version => Icons.tag,
    ContentTool.changelog => Icons.history_edu,
    ContentTool.icons => Icons.image_outlined,
    ContentTool.screenshots => Icons.screenshot_monitor_outlined,
    ContentTool.texts => Icons.text_fields,
    ContentTool.legal => Icons.gavel,
    ContentTool.web => Icons.language,
    ContentTool.seo => Icons.travel_explore,
    ContentTool.pwa => Icons.install_desktop,
    ContentTool.hosting => Icons.cloud_upload_outlined,
    ContentTool.android => Icons.android,
    ContentTool.play => Icons.shop_outlined,
    ContentTool.ios => Icons.phone_iphone,
    ContentTool.appStore => Icons.storefront,
  };
}

/// Ce que les outils savent du projet ouvert.
class ContentContext {
  const ContentContext(this.ws, this.detection);

  final ProjectWorkspace ws;
  final ProjectDetection? detection;

  String get root => ws.project.path;
  DetectionReport? get report => detection?.report;

  bool selected(PlatformTarget t) => detection?.selected.contains(t) ?? false;

  bool get isFlutter =>
      report?.technologies.any((t) => t.id == 'flutter') ?? false;

  /// Dossier (relatif) du pubspec.yaml, vide à la racine.
  String get pubDir {
    final pub = report?.packages.where((p) => p.manager == 'pub').firstOrNull;
    if (pub == null) return '';
    final dir = p.posix.dirname(pub.manifest);
    return dir == '.' ? '' : dir;
  }

  String join(String a, String b) => a.isEmpty ? b : '$a/$b';
}

class ContentWorkspace extends ConsumerStatefulWidget {
  const ContentWorkspace({super.key, this.initialTool});

  final ContentTool? initialTool;

  @override
  ConsumerState<ContentWorkspace> createState() => _ContentWorkspaceState();
}

class _ContentWorkspaceState extends ConsumerState<ContentWorkspace> {
  late ContentTool _tool = widget.initialTool ?? ContentTool.version;

  @override
  void didUpdateWidget(ContentWorkspace old) {
    super.didUpdateWidget(old);
    if (widget.initialTool != null && widget.initialTool != old.initialTool) {
      _tool = widget.initialTool!;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ws = ref.watch(currentWorkspaceProvider).value;
    if (ws == null) {
      return EmptyState(
        icon: Icons.photo_library_outlined,
        title: l10n.publicationNoProjectTitle,
        message: l10n.contentNeedsProject,
        actions: [
          FilledButton.icon(
            onPressed: () => context.go(AppDestination.home.path),
            icon: const Icon(Icons.home_outlined),
            label: Text(l10n.publicationGoHome),
          ),
        ],
      );
    }
    final ctx = ContentContext(ws, ref.watch(currentDetectionProvider).value);
    final web = ctx.selected(PlatformTarget.web);
    final android = ctx.selected(PlatformTarget.android) && ctx.isFlutter;
    final ios = ctx.selected(PlatformTarget.ios) && ctx.isFlutter;
    final tools = [
      for (final t in ContentTool.values)
        if ((web || !t.webOnly) &&
            (android || !t.androidOnly) &&
            (ios || !t.iosOnly))
          t,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 20,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in tools)
              ChoiceChip(
                key: ValueKey('tool-${t.name}'),
                avatar: Icon(t.icon, size: 18),
                label: Text(t.label(l10n)),
                selected: _tool == t,
                onSelected: (_) => setState(() => _tool = t),
              ),
          ],
        ),
        switch (_tool) {
          ContentTool.version => VersionTab(ctx, key: ValueKey(ws.project.id)),
          ContentTool.changelog => ChangelogTab(
            ctx,
            key: ValueKey(ws.project.id),
          ),
          ContentTool.icons => IconsTab(ctx, key: ValueKey(ws.project.id)),
          ContentTool.screenshots => ScreenshotsTab(
            ctx,
            key: ValueKey(ws.project.id),
          ),
          ContentTool.texts => TextsTab(ctx, key: ValueKey(ws.project.id)),
          ContentTool.legal => LegalTab(ctx, key: ValueKey(ws.project.id)),
          ContentTool.android when android => AndroidTab(
            ctx,
            key: ValueKey(ws.project.id),
          ),
          ContentTool.play when android => PlayTab(
            ctx,
            key: ValueKey(ws.project.id),
          ),
          ContentTool.android ||
          ContentTool.play => Text(l10n.contentAndroidNotSelected),
          ContentTool.ios when ios => IosTab(ctx, key: ValueKey(ws.project.id)),
          ContentTool.appStore when ios => AppStoreTab(
            ctx,
            key: ValueKey(ws.project.id),
          ),
          ContentTool.ios ||
          ContentTool.appStore => Text(l10n.contentIosNotSelected),
          _ when !web => Text(l10n.contentWebNotSelected),
          ContentTool.web => WebTab(ctx, key: ValueKey(ws.project.id)),
          ContentTool.seo => SeoTab(ctx, key: ValueKey(ws.project.id)),
          ContentTool.pwa => PwaTab(ctx, key: ValueKey(ws.project.id)),
          ContentTool.hosting => HostingTab(ctx, key: ValueKey(ws.project.id)),
        },
      ],
    );
  }
}

/// Aperçu puis écriture, avec l'état Git pour avertir d'un dépôt modifié.
Future<bool> previewAndWrite(
  BuildContext context,
  WidgetRef ref,
  ChangeSet set,
) => showChangePreview(
  context,
  ref,
  set,
  git: ref.read(gitStatusProvider).value,
);
