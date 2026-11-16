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
import '../../changes/application/change_providers.dart';
import '../../changes/domain/change_set.dart';
import '../../commands/presentation/command_preview_dialog.dart';
import '../../content/application/content_providers.dart';
import '../../content/data/content_repository.dart';
import '../../content/domain/store_texts.dart';
import '../../content/domain/version.dart';
import '../../content/presentation/content_workspace.dart';
import '../../git/application/git_providers.dart';
import '../../settings/application/settings_controller.dart';
import '../../web/application/web_providers.dart';
import '../application/android_providers.dart';
import '../data/android_reader.dart';
import '../domain/deliverables.dart';
import '../domain/play_store.dart';

/// Clé de la fiche Play Store dans la session.
const playListingKey = 'play.listing';

String playFieldLabel(AppLocalizations l10n, PlayField f) => switch (f) {
  PlayField.title => l10n.playFieldTitle,
  PlayField.shortDescription => l10n.playFieldShort,
  PlayField.fullDescription => l10n.playFieldFull,
  PlayField.changelog => l10n.playFieldChangelog,
};

const _backgrounds = [0xFF0E1433, 0xFF3F4BD1, 0xFFFFFFFF, 0xFF1F7A5C];

/// Fiche Play Store, visuels, métadonnées Fastlane et envoi sur la piste de
/// test interne (brouillon) par le flux dédié.
class PlayTab extends ConsumerStatefulWidget {
  const PlayTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  ConsumerState<PlayTab> createState() => _PlayTabState();
}

class _PlayTabState extends ConsumerState<PlayTab> {
  final _listings = <String, PlayListing>{};
  String _locale = playLocales.first;
  final _fields = {
    for (final f in PlayField.values) f: TextEditingController(),
  };
  final _jsonKey = TextEditingController();
  Uint8List? _iconSource;
  int _background = _backgrounds.first;
  Deliverable? _aab;
  bool _aabChecked = false;

  int? get _sessionId => widget.ctx.ws.activeSession?.id;
  String get _root => widget.ctx.root;

  String get _pubDir {
    final r = widget.ctx.report;
    return r == null ? '' : AndroidReader.pubDir(r);
  }

  String get _androidDir => widget.ctx.join(_pubDir, 'android');

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [..._fields.values, _jsonKey]) {
      c.dispose();
    }
    super.dispose();
  }

  ({String? version, Set<String> dependencies}) _pubspec() {
    final r = widget.ctx.report;
    return r == null
        ? (version: null, dependencies: const <String>{})
        : ref.read(androidReaderProvider).pubspec(_root, r);
  }

  int get _versionCode {
    final v = _pubspec().version;
    return int.tryParse(v?.split('+').elementAtOrNull(1) ?? '') ?? 1;
  }

  String? get _packageName {
    final r = widget.ctx.report;
    if (r == null) return null;
    return ref.read(androidReaderProvider).read(_root, r)?.applicationId;
  }

  /// Fiche enregistrée, sinon préremplie avec les textes de store et le
  /// changelog public de la session (outils Textes et Changelog).
  Future<void> _load() async {
    final id = _sessionId;
    if (id == null) return;
    final repo = ref.read(contentRepositoryProvider);
    final saved = await repo.latestJson(id, playListingKey);
    if (!mounted) return;
    if (saved is Map) {
      for (final l in playLocales) {
        if (saved[l] case final Map m) {
          _listings[l] = PlayListing.fromJson(m.cast());
        }
      }
    } else {
      final texts = await repo.latestJson(id, ContentRepository.storeTextsKey);
      final version = SemVer.tryParse(_pubspec().version ?? '')?.name;
      final changelog = version == null
          ? null
          : await repo.latestJson(id, ContentRepository.changelogKey(version));
      for (final (locale, lang) in const [('fr-FR', 'fr'), ('en-US', 'en')]) {
        final t = texts is Map && texts[lang] is Map
            ? StoreTexts.fromJson((texts[lang] as Map).cast())
            : null;
        if (t == null) continue;
        _listings[locale] = PlayListing({
          PlayField.title: t[StoreField.title],
          PlayField.shortDescription: t[StoreField.shortDescription],
          PlayField.fullDescription: t[StoreField.longDescription],
          if (changelog is Map && lang == 'fr')
            PlayField.changelog: '${changelog['public'] ?? ''}',
        });
      }
    }
    if (mounted) setState(_fill);
  }

  PlayListing get _current =>
      PlayListing({for (final e in _fields.entries) e.key: e.value.text});

  void _fill() {
    final l = _listings[_locale] ?? const PlayListing();
    for (final e in _fields.entries) {
      e.value.text = l[e.key];
    }
  }

  void _switch(String locale) => setState(() {
    _listings[_locale] = _current;
    _locale = locale;
    _fill();
  });

  Future<void> _save() async {
    final l10n = context.l10n;
    _listings[_locale] = _current;
    await ref.read(contentRepositoryProvider).saveJson(
      _sessionId!,
      playListingKey,
      {for (final e in _listings.entries) e.key: e.value.toJson()},
    );
    if (mounted) showInfo(ScaffoldMessenger.of(context), l10n.playSaved);
  }

  /// Captures exportées par l'outil Captures (format Play).
  List<File> _screenshots() {
    final dir = Directory(p.join(_root, 'store_assets', 'screenshots', 'play'));
    if (!dir.existsSync()) return const [];
    return dir
        .listSync(followLinks: false)
        .whereType<File>()
        .where((f) => f.path.toLowerCase().endsWith('.png'))
        .toList()
      ..sort((a, b) => a.path.compareTo(b.path));
  }

  Future<void> _pickIcon() async {
    final picked = await ref.read(imagePickerProvider).pickOne();
    if (picked != null && mounted) setState(() => _iconSource = picked.bytes);
  }

  Future<void> _writeFastlane() async {
    final l10n = context.l10n;
    _listings[_locale] = _current;
    final writer = ref.read(projectWriterProvider);
    final fastlane = '$_androidDir/fastlane';
    final pkg = _packageName!;
    final texts = <String, String>{
      '$fastlane/Appfile': appfile(pkg),
      '$fastlane/Fastfile': fastfile(
        aabPath: '../build/app/outputs/bundle/release/app-release.aab',
      ),
      for (final e in supplyTextFiles(
        _listings,
        versionCode: _versionCode,
      ).entries)
        '$fastlane/${e.key}': e.value,
    };
    final images = <String, Uint8List>{};
    final icon = _iconSource == null ? null : playIcon(_iconSource!);
    final shots = _screenshots();
    for (final locale in _listings.keys.where((l) => !_listings[l]!.isEmpty)) {
      final base = '$fastlane/metadata/android/$locale/images';
      if (icon != null) {
        images['$base/icon.png'] = icon;
        images['$base/featureGraphic.png'] = featureGraphic(icon, _background);
      }
      for (final (i, f) in shots.indexed) {
        images['$base/phoneScreenshots/${i + 1}.png'] = f.readAsBytesSync();
      }
    }
    final textSet = await writer.plan(_root, l10n.playFastlaneLabel, texts);
    final binarySet = images.isEmpty
        ? null
        : await writer.planBinary(_root, l10n.playFastlaneLabel, images);
    final set = ChangeSet(
      label: l10n.playFastlaneLabel,
      files: [...textSet.files, ...?binarySet?.files],
    );
    if (!mounted) return;
    await previewAndWrite(context, ref, set);
  }

  Future<void> _checkAab() async {
    final list = await ref.read(deliverableInspectorProvider)((
      root: _root,
      paths: [deliverableCandidates(_pubDir).first],
    ));
    if (mounted) {
      setState(() {
        _aab = list.firstOrNull;
        _aabChecked = true;
      });
    }
  }

  Future<void> _upload(String lane) async {
    final spec = fastlaneCommand(
      widget.ctx.join(_root, _androidDir),
      lane,
      _jsonKey.text.trim(),
    );
    final git = ref.read(gitStatusProvider).value;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => _PlayRecap(
        lane: lane,
        packageName: _packageName ?? '?',
        versionCode: _versionCode,
        command: spec.display,
        dirty: git != null && git.isRepo && !git.clean,
        simulation: ref.read(settingsControllerProvider).simulationMode,
      ),
    );
    if (ok != true || !mounted) return;
    await previewAndRun(context, ref, spec);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final current = _current;
    final pkg = _packageName;
    final shots = _screenshots();
    final tools = ref.watch(installedToolsProvider).value ?? const <String>{};
    final hasFastlane = tools.contains('fastlane');
    final keyPath = _jsonKey.text.trim();
    final keyOk =
        p.isAbsolute(keyPath) &&
        keyPath.endsWith('.json') &&
        File(keyPath).existsSync();
    final keyInProject = keyOk && p.isWithin(_root, keyPath);
    final fastfileExists = ref
        .read(projectWriterProvider)
        .exists(_root, '$_androidDir/fastlane/Fastfile');
    final aabReady = _aab != null && _aab!.signing == DeliverableSigning.signed;
    final canUpload = hasFastlane && keyOk && fastfileExists && aabReady;
    final listingsReady = [
      ..._listings.keys,
      _locale,
    ].any((l) => (l == _locale ? current : _listings[l]!).missing.isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        // ------------------------------------------------------- Fiche
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(l10n.playListingTitle, style: theme.textTheme.titleMedium),
              Text(l10n.playListingHelp),
              if (_sessionId == null)
                Text(
                  l10n.contentNeedsSession,
                  style: TextStyle(color: palette.statusWarning),
                ),
              SegmentedButton<String>(
                segments: [
                  for (final l in playLocales)
                    ButtonSegment(value: l, label: Text(l)),
                ],
                selected: {_locale},
                showSelectedIcon: false,
                onSelectionChanged: (s) => _switch(s.first),
              ),
              for (final f in PlayField.values)
                TextField(
                  key: ValueKey('play-${f.name}'),
                  controller: _fields[f],
                  minLines: f == PlayField.fullDescription ? 4 : 1,
                  maxLines: f == PlayField.fullDescription
                      ? 10
                      : f == PlayField.changelog
                      ? 5
                      : 2,
                  decoration: InputDecoration(
                    labelText: playFieldLabel(l10n, f),
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
              FilledButton.icon(
                key: const ValueKey('play-save'),
                onPressed: _sessionId == null ? null : _save,
                icon: const Icon(Icons.save_outlined),
                label: Text(l10n.textsSave),
              ),
            ],
          ),
        ),
        // ----------------------------------------------------- Visuels
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.playVisualsTitle, style: theme.textTheme.titleMedium),
              Text(l10n.playVisualsHelp),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  OutlinedButton.icon(
                    key: const ValueKey('play-icon'),
                    onPressed: _pickIcon,
                    icon: const Icon(Icons.image_outlined),
                    label: Text(l10n.playIconPick),
                  ),
                  for (final c in _backgrounds)
                    InkWell(
                      key: ValueKey('play-bg-$c'),
                      onTap: () => setState(() => _background = c),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: Color(c),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            width: _background == c ? 3 : 1,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (_iconSource != null)
                Builder(
                  builder: (context) {
                    final icon = playIcon(_iconSource!);
                    if (icon == null) {
                      return Text(
                        l10n.playIconTooSmall,
                        style: TextStyle(color: palette.statusFailed),
                      );
                    }
                    return Row(
                      spacing: 12,
                      children: [
                        Image.memory(icon, width: 64, height: 64),
                        Expanded(
                          child: Image.memory(
                            featureGraphic(icon, _background),
                            height: 80,
                            key: const ValueKey('play-feature-graphic'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              Text(
                l10n.playScreenshots(shots.length),
                key: const ValueKey('play-shots'),
                style: TextStyle(
                  color: shots.length >= 2
                      ? palette.statusSucceeded
                      : palette.statusWarning,
                ),
              ),
            ],
          ),
        ),
        // ---------------------------------------------------- Fastlane
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text('Fastlane', style: theme.textTheme.titleMedium),
              Text(l10n.playFastlaneHelp),
              if (pkg == null)
                Text(
                  l10n.playNoPackage,
                  style: TextStyle(color: palette.statusWarning),
                )
              else
                Text(l10n.playPackage(pkg, _versionCode)),
              if (pkg != null && pkg.startsWith('com.example'))
                Text(
                  l10n.playExamplePackage,
                  style: TextStyle(color: palette.statusFailed),
                ),
              FilledButton.tonalIcon(
                key: const ValueKey('play-fastlane'),
                onPressed: pkg != null && listingsReady ? _writeFastlane : null,
                icon: const Icon(Icons.difference_outlined),
                label: Text(l10n.playFastlanePrepare),
              ),
              if (!listingsReady)
                Text(
                  l10n.playListingIncomplete,
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ),
        ),
        // ------------------------------------------------------- Envoi
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.playUploadTitle, style: theme.textTheme.titleMedium),
              Text(
                l10n.playFirstUpload,
                key: const ValueKey('play-first-upload'),
                style: TextStyle(color: palette.statusPedagogy),
              ),
              if (!hasFastlane) ...[
                Text(
                  l10n.playFastlaneMissing,
                  key: const ValueKey('play-fastlane-missing'),
                ),
                const SelectableText(
                  'gem install --user-install fastlane',
                  style: TextStyle(fontFamily: 'monospace'),
                ),
              ],
              if (!fastfileExists) Text(l10n.playFastfileFirst),
              OutlinedButton.icon(
                key: const ValueKey('play-check-aab'),
                onPressed: _checkAab,
                icon: const Icon(Icons.fingerprint),
                label: Text(l10n.playCheckAab),
              ),
              if (_aabChecked)
                Text(
                  _aab == null
                      ? l10n.androidDeliverablesNone
                      : switch (_aab!.signing) {
                          DeliverableSigning.signed => l10n.playAabReady(
                            formatSize(_aab!.size),
                          ),
                          DeliverableSigning.debug => l10n.androidSignedDebug,
                          DeliverableSigning.unsigned => l10n.androidUnsigned,
                        },
                  key: const ValueKey('play-aab-state'),
                  style: TextStyle(
                    color: aabReady
                        ? palette.statusSucceeded
                        : palette.statusFailed,
                  ),
                ),
              TextField(
                key: const ValueKey('play-json-key'),
                controller: _jsonKey,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: l10n.playJsonKey,
                  helperText: l10n.playJsonKeyHelp,
                  helperMaxLines: 3,
                  errorText: keyPath.isNotEmpty && !keyOk
                      ? l10n.playJsonKeyInvalid
                      : null,
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (keyInProject)
                Text(
                  l10n.playJsonKeyInProject,
                  style: TextStyle(color: palette.statusWarning),
                ),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    key: const ValueKey('play-validate-key'),
                    onPressed: hasFastlane && keyOk && fastfileExists
                        ? () => previewAndRun(
                            context,
                            ref,
                            fastlaneCommand(
                              widget.ctx.join(_root, _androidDir),
                              'check',
                              keyPath,
                            ),
                          )
                        : null,
                    icon: const Icon(Icons.key_outlined),
                    label: Text(l10n.playValidateKey),
                  ),
                  FilledButton.icon(
                    key: const ValueKey('play-upload'),
                    onPressed: canUpload ? () => _upload('internal') : null,
                    icon: const Icon(Icons.upload_outlined),
                    label: Text(l10n.playUploadInternal),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('play-upload-metadata'),
                    onPressed: hasFastlane && keyOk && fastfileExists
                        ? () => _upload('metadata')
                        : null,
                    icon: const Icon(Icons.storefront_outlined),
                    label: Text(l10n.playUploadMetadata),
                  ),
                ],
              ),
              Text(l10n.playUploadNote, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}

/// Récapitulatif avant un envoi vers Google Play, à cocher explicitement.
class _PlayRecap extends StatefulWidget {
  const _PlayRecap({
    required this.lane,
    required this.packageName,
    required this.versionCode,
    required this.command,
    required this.dirty,
    required this.simulation,
  });

  final String lane;
  final String packageName;
  final int versionCode;
  final String command;
  final bool dirty;
  final bool simulation;

  @override
  State<_PlayRecap> createState() => _PlayRecapState();
}

class _PlayRecapState extends State<_PlayRecap> {
  bool _ack = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = LaunchPalette.of(context);
    final internal = widget.lane == 'internal';
    return AlertDialog(
      title: Text(internal ? l10n.playRecapInternal : l10n.playRecapMetadata),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Text(l10n.playRecapPackage(widget.packageName)),
            if (internal) Text(l10n.playRecapVersionCode(widget.versionCode)),
            SelectableText(
              widget.command,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
            Text(
              internal
                  ? l10n.playRecapInternalEffect
                  : l10n.playRecapMetadataEffect,
            ),
            if (widget.dirty)
              Text(
                l10n.deployRecapDirty,
                style: TextStyle(color: palette.statusWarning),
              ),
            if (widget.simulation)
              Text(
                l10n.deployRecapSimulation,
                style: TextStyle(color: palette.statusPedagogy),
              ),
            CheckboxListTile(
              key: const ValueKey('deploy-ack'),
              contentPadding: EdgeInsets.zero,
              value: _ack,
              onChanged: (v) => setState(() => _ack = v ?? false),
              title: Text(l10n.deployRecapAck),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const ValueKey('deploy-continue'),
          onPressed: _ack ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.deployRecapContinue),
        ),
      ],
    );
  }
}
