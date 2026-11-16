import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../android/application/android_providers.dart';
import '../../changes/application/change_providers.dart';
import '../../changes/domain/change_set.dart';
import '../../content/application/content_providers.dart';
import '../../content/data/content_repository.dart';
import '../../content/domain/legal.dart';
import '../../content/domain/store_texts.dart';
import '../../content/domain/version.dart';
import '../../content/presentation/content_workspace.dart';
import '../application/ios_providers.dart';
import '../domain/app_store.dart';
import '../domain/ios_project.dart';

/// Clé de la fiche App Store dans la session.
const appStoreListingKey = 'appstore.listing';

String appStoreFieldLabel(AppLocalizations l10n, AppStoreField f) =>
    switch (f) {
      AppStoreField.name => l10n.asFieldName,
      AppStoreField.subtitle => l10n.asFieldSubtitle,
      AppStoreField.description => l10n.asFieldDescription,
      AppStoreField.keywords => l10n.asFieldKeywords,
      AppStoreField.promotionalText => l10n.asFieldPromo,
      AppStoreField.releaseNotes => l10n.asFieldReleaseNotes,
    };

/// Fiche App Store, captures, étiquettes de confidentialité et fichiers
/// Fastlane `deliver` (lancés sur un Mac ou une CI macOS, jamais ici).
class AppStoreTab extends ConsumerStatefulWidget {
  const AppStoreTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  ConsumerState<AppStoreTab> createState() => _AppStoreTabState();
}

enum _Url { support, privacy, marketing, copyright }

class _AppStoreTabState extends ConsumerState<AppStoreTab> {
  final _listings = <String, AppStoreListing>{};
  String _locale = appStoreLocales.first;
  final _fields = {
    for (final f in AppStoreField.values) f: TextEditingController(),
  };
  late final _urls = {for (final u in _Url.values) u: TextEditingController()};
  Set<DataCategory> _data = const {};

  int? get _sessionId => widget.ctx.ws.activeSession?.id;
  String get _root => widget.ctx.root;

  @override
  void initState() {
    super.initState();
    final c = ref.read(iosConfigProvider);
    _urls[_Url.support]!.text = c.supportUrl;
    _urls[_Url.privacy]!.text = c.privacyUrl;
    _urls[_Url.marketing]!.text = c.marketingUrl;
    _urls[_Url.copyright]!.text = c.copyright.isEmpty
        ? '${DateTime.now().year} ${widget.ctx.ws.project.name}'
        : c.copyright;
    _load();
  }

  @override
  void dispose() {
    for (final c in [..._fields.values, ..._urls.values]) {
      c.dispose();
    }
    super.dispose();
  }

  IosProject? _project() {
    final r = widget.ctx.report;
    return r == null ? null : ref.read(iosReaderProvider).read(_root, r);
  }

  /// Fiche enregistrée, sinon textes de store et changelog de la session.
  Future<void> _load() async {
    final r = widget.ctx.report;
    final id = _sessionId;
    if (id == null) {
      if (r != null) _data = LegalAnswers.fromDetection(r).data;
      return;
    }
    final repo = ref.read(contentRepositoryProvider);
    final legal = await repo.latestJson(id, ContentRepository.legalAnswersKey);
    _data = legal is Map
        ? LegalAnswers.fromJson(legal.cast()).data
        : r == null
        ? const {}
        : LegalAnswers.fromDetection(r).data;
    final saved = await repo.latestJson(id, appStoreListingKey);
    if (saved is Map) {
      for (final l in appStoreLocales) {
        if (saved[l] case final Map m) {
          _listings[l] = AppStoreListing.fromJson(m.cast());
        }
      }
    } else {
      final texts = await repo.latestJson(id, ContentRepository.storeTextsKey);
      final pub = r == null
          ? null
          : ref.read(androidReaderProvider).pubspec(_root, r).version;
      final version = SemVer.tryParse(pub ?? '')?.name;
      final changelog = version == null
          ? null
          : await repo.latestJson(id, ContentRepository.changelogKey(version));
      for (final (locale, lang) in const [('fr-FR', 'fr'), ('en-US', 'en')]) {
        if (texts is! Map || texts[lang] is! Map) continue;
        final t = StoreTexts.fromJson((texts[lang] as Map).cast());
        _listings[locale] = AppStoreListing({
          AppStoreField.name: t[StoreField.title],
          AppStoreField.subtitle: t[StoreField.subtitle],
          AppStoreField.description: t[StoreField.longDescription],
          AppStoreField.keywords: t[StoreField.keywords],
          AppStoreField.promotionalText: t[StoreField.promoText],
          if (changelog is Map && lang == 'fr')
            AppStoreField.releaseNotes: '${changelog['public'] ?? ''}',
        });
      }
    }
    if (mounted) setState(_fill);
  }

  AppStoreListing get _current =>
      AppStoreListing({for (final e in _fields.entries) e.key: e.value.text});

  void _fill() {
    final l = _listings[_locale] ?? const AppStoreListing();
    for (final e in _fields.entries) {
      e.value.text = l[e.key];
    }
  }

  void _switch(String locale) => setState(() {
    _listings[_locale] = _current;
    _locale = locale;
    _fill();
  });

  Future<void> _saveConfig() => ref
      .read(iosConfigProvider.notifier)
      .update(
        ref
            .read(iosConfigProvider)
            .copyWith(
              supportUrl: _urls[_Url.support]!.text.trim(),
              privacyUrl: _urls[_Url.privacy]!.text.trim(),
              marketingUrl: _urls[_Url.marketing]!.text.trim(),
              copyright: _urls[_Url.copyright]!.text.trim(),
            ),
      );

  Future<void> _save() async {
    final l10n = context.l10n;
    _listings[_locale] = _current;
    await _saveConfig();
    await ref.read(contentRepositoryProvider).saveJson(
      _sessionId!,
      appStoreListingKey,
      {for (final e in _listings.entries) e.key: e.value.toJson()},
    );
    if (mounted) showInfo(ScaffoldMessenger.of(context), l10n.asSaved);
  }

  List<File> _shots(String format) {
    final dir = Directory(p.join(_root, 'store_assets', 'screenshots', format));
    if (!dir.existsSync()) return const [];
    return dir
        .listSync(followLinks: false)
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.png'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  Future<void> _writeFastlane(IosProject project) async {
    final l10n = context.l10n;
    _listings[_locale] = _current;
    await _saveConfig();
    final config = ref.read(iosConfigProvider);
    final writer = ref.read(projectWriterProvider);
    final fastlane = '${project.iosDir}/fastlane';
    final texts = <String, String>{
      '$fastlane/Appfile': iosAppfile(project.bundleId ?? '', config.teamId),
      '$fastlane/Fastfile': iosFastfile(),
      for (final e in deliverTextFiles(_listings, config).entries)
        '$fastlane/${e.key}': e.value,
    };
    final images = <String, Uint8List>{};
    for (final locale in _listings.keys.where((l) => !_listings[l]!.isEmpty)) {
      for (final format in const ['iphone', 'ipad']) {
        for (final (i, f) in _shots(format).indexed) {
          images['$fastlane/screenshots/$locale/$format-${i + 1}.png'] = f
              .readAsBytesSync();
        }
      }
    }
    final textSet = await writer.plan(_root, l10n.asFastlaneLabel, texts);
    final binarySet = images.isEmpty
        ? null
        : await writer.planBinary(_root, l10n.asFastlaneLabel, images);
    final set = ChangeSet(
      label: l10n.asFastlaneLabel,
      files: [...textSet.files, ...?binarySet?.files],
    );
    if (!mounted) return;
    await previewAndWrite(context, ref, set);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final project = _project();
    if (project == null) return Text(l10n.iosNoModule);
    final current = _current;
    final iphone = _shots('iphone').length;
    final ipad = _shots('ipad').length;
    final supportsIpad = project.plist.containsKey(
      'UISupportedInterfaceOrientations~ipad',
    );
    final listingReady = [
      ..._listings.keys,
      _locale,
    ].any((l) => (l == _locale ? current : _listings[l]!).missing.isEmpty);
    final urlsOk = [_Url.support, _Url.privacy].every(
      (u) => (Uri.tryParse(_urls[u]!.text.trim())?.scheme ?? '') == 'https',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(l10n.asListingTitle, style: theme.textTheme.titleMedium),
              Text(l10n.asListingHelp),
              if (_sessionId == null)
                Text(
                  l10n.contentNeedsSession,
                  style: TextStyle(color: palette.statusWarning),
                ),
              SegmentedButton<String>(
                segments: [
                  for (final l in appStoreLocales)
                    ButtonSegment(value: l, label: Text(l)),
                ],
                selected: {_locale},
                showSelectedIcon: false,
                onSelectionChanged: (s) => _switch(s.first),
              ),
              for (final f in AppStoreField.values)
                TextField(
                  key: ValueKey('as-${f.name}'),
                  controller: _fields[f],
                  minLines: f == AppStoreField.description ? 4 : 1,
                  maxLines:
                      f == AppStoreField.description ||
                          f == AppStoreField.releaseNotes
                      ? 10
                      : 3,
                  decoration: InputDecoration(
                    labelText: appStoreFieldLabel(l10n, f),
                    helperText: f == AppStoreField.keywords
                        ? l10n.asKeywordsHint
                        : null,
                    counterText:
                        '${_fields[f]!.text.runes.length} / ${f.limit}',
                    counterStyle: TextStyle(
                      color: _fields[f]!.text.runes.length > f.limit
                          ? palette.statusFailed
                          : null,
                    ),
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              if (current.overLimit.isNotEmpty)
                Text(
                  l10n.textsOverLimit,
                  style: TextStyle(color: palette.statusFailed),
                ),
              TextField(
                key: const ValueKey('as-support'),
                controller: _urls[_Url.support],
                decoration: InputDecoration(
                  labelText: l10n.asSupportUrl,
                  hintText: 'https://…',
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                key: const ValueKey('as-privacy'),
                controller: _urls[_Url.privacy],
                decoration: InputDecoration(
                  labelText: l10n.asPrivacyUrl,
                  helperText: l10n.asPrivacyUrlHelp,
                  hintText: 'https://…',
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _urls[_Url.marketing],
                decoration: InputDecoration(
                  labelText: l10n.asMarketingUrl,
                  hintText: 'https://…',
                  isDense: true,
                ),
              ),
              TextField(
                controller: _urls[_Url.copyright],
                decoration: InputDecoration(
                  labelText: l10n.asCopyright,
                  isDense: true,
                ),
              ),
              FilledButton.icon(
                key: const ValueKey('as-save'),
                onPressed: _sessionId == null ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.textsSave),
              ),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(l10n.asScreenshotsTitle, style: theme.textTheme.titleMedium),
              Text(l10n.asScreenshotsHelp),
              Text(
                l10n.asIphoneShots(iphone),
                key: const ValueKey('as-iphone'),
                style: TextStyle(
                  color: iphone > 0
                      ? palette.statusSucceeded
                      : palette.statusFailed,
                ),
              ),
              if (supportsIpad)
                Text(
                  l10n.asIpadShots(ipad),
                  key: const ValueKey('as-ipad'),
                  style: TextStyle(
                    color: ipad > 0
                        ? palette.statusSucceeded
                        : palette.statusWarning,
                  ),
                ),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(l10n.asPrivacyTitle, style: theme.textTheme.titleMedium),
              Text(l10n.asPrivacyHelp),
              if (_data.isEmpty)
                Text(l10n.asPrivacyNone, key: const ValueKey('as-privacy-none'))
              else
                for (final d in DataCategory.values.where(_data.contains))
                  Text(
                    '•  ${appPrivacyLabels[d.name]}',
                    key: ValueKey('as-label-${d.name}'),
                  ),
              Text(l10n.asPrivacyManual, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text('Fastlane deliver', style: theme.textTheme.titleMedium),
              Text(l10n.asFastlaneHelp),
              FilledButton.tonalIcon(
                key: const ValueKey('as-fastlane'),
                onPressed: listingReady && urlsOk
                    ? () => _writeFastlane(project)
                    : null,
                icon: const Icon(Icons.difference_outlined),
                label: Text(l10n.asFastlanePrepare),
              ),
              if (!listingReady || !urlsOk)
                Text(l10n.asFastlaneMissing, style: theme.textTheme.bodySmall),
              Text(
                l10n.asFastlaneWhere,
                style: TextStyle(color: palette.statusPedagogy),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
