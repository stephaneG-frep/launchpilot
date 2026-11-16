import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/audit_status.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../android/application/android_providers.dart';
import '../../android/data/android_reader.dart';
import '../../android/presentation/android_tab.dart' show statusStyle;
import '../../changes/application/change_providers.dart';
import '../../content/application/content_providers.dart';
import '../../content/data/content_repository.dart';
import '../../content/domain/legal.dart';
import '../../content/presentation/content_workspace.dart';
import '../../settings/application/settings_controller.dart';
import '../../settings/domain/app_settings.dart';
import '../application/ios_providers.dart';
import '../domain/app_store.dart';
import '../domain/ios_audit.dart';
import '../domain/ios_edits.dart';
import '../domain/ios_project.dart';
import 'ios_texts.dart';

String iosAreaLabel(AppLocalizations l10n, IosArea a) => switch (a) {
  IosArea.linux => l10n.iosAreaLinux,
  IosArea.identity => l10n.androidAreaIdentity,
  IosArea.privacy => l10n.iosAreaPrivacy,
  IosArea.signing => l10n.androidAreaSigning,
  IosArea.icons => l10n.androidAreaIcons,
};

/// Limites Linux, audit, Info.plist, manifeste de confidentialité, étapes
/// Apple et configuration CI.
class IosTab extends ConsumerStatefulWidget {
  const IosTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  ConsumerState<IosTab> createState() => _IosTabState();
}

class _IosTabState extends ConsumerState<IosTab> {
  List<IosCheck>? _checks;
  final _usage = <String, TextEditingController>{};
  bool _standardEncryption = true;
  bool _tracking = false;
  PbxEditOutcome? _pbxOutcome;
  final _teamId = TextEditingController();
  final _appleAppId = TextEditingController();

  String get _root => widget.ctx.root;

  @override
  void initState() {
    super.initState();
    final c = ref.read(iosConfigProvider);
    _teamId.text = c.teamId;
    _appleAppId.text = c.appleAppId;
  }

  @override
  void dispose() {
    for (final c in [..._usage.values, _teamId, _appleAppId]) {
      c.dispose();
    }
    super.dispose();
  }

  IosProject? _project() {
    final r = widget.ctx.report;
    return r == null ? null : ref.read(iosReaderProvider).read(_root, r);
  }

  Set<String> get _dependencies {
    final r = widget.ctx.report;
    return r == null
        ? const {}
        : ref.read(androidReaderProvider).pubspec(_root, r).dependencies;
  }

  bool get _fr =>
      ref.read(settingsControllerProvider).language == AppLanguage.fr;

  void _audit() {
    final project = _project();
    if (project == null) return;
    final checks = auditIos(
      project,
      linuxHost: ref.read(hostIsLinuxProvider),
      dependencies: _dependencies,
    );
    final name = project.stringValue('CFBundleDisplayName') ?? '';
    setState(() {
      _checks = checks;
      // Champs à remplir : textes manquants ou trop vagues.
      for (final c in checks.where(
        (c) => c.id == 'usageMissing' || c.id == 'usageWeak',
      )) {
        final key = c.values.first;
        _usage.putIfAbsent(
          key,
          () => TextEditingController(
            text: suggestedUsageText(key, name, fr: _fr),
          ),
        );
      }
    });
  }

  Future<void> _writePlist(IosProject project) async {
    final l10n = context.l10n;
    final writer = ref.read(projectWriterProvider);
    var xml = writer.readCurrent(_root, project.infoPlistPath!);
    if (xml == null) return;
    for (final e in _usage.entries) {
      final text = e.value.text.trim();
      if (text.isEmpty) continue;
      xml = setPlistValue(xml!, e.key, text);
      if (xml == null) break;
    }
    if (xml != null && _standardEncryption) {
      xml = setPlistValue(xml, 'ITSAppUsesNonExemptEncryption', false);
    }
    if (xml == null) {
      showInfo(ScaffoldMessenger.of(context), l10n.iosPlistUnrecognized);
      return;
    }
    final set = await writer.plan(_root, l10n.iosPlistLabel, {
      project.infoPlistPath!: xml,
    });
    if (!mounted) return;
    if (await previewAndWrite(context, ref, set)) _audit();
  }

  Future<void> _writePrivacy(IosProject project) async {
    final l10n = context.l10n;
    final writer = ref.read(projectWriterProvider);
    final session = widget.ctx.ws.activeSession;
    final saved = session == null
        ? null
        : await ref
              .read(contentRepositoryProvider)
              .latestJson(session.id, ContentRepository.legalAnswersKey);
    final r = widget.ctx.report;
    final answers = saved is Map
        ? LegalAnswers.fromJson(saved.cast())
        : r == null
        ? const LegalAnswers()
        : LegalAnswers.fromDetection(r);
    final files = <String, String>{
      project.privacyManifestPath: privacyManifest(
        answers,
        tracking: _tracking,
      ),
    };
    final pbx = writer.readCurrent(_root, project.pbxprojPath!);
    final edit = pbx == null
        ? (outcome: PbxEditOutcome.unrecognized, content: null)
        : addPrivacyManifestToProject(pbx);
    setState(() => _pbxOutcome = edit.outcome);
    if (edit.content != null) files[project.pbxprojPath!] = edit.content!;
    final set = await writer.plan(_root, l10n.iosPrivacyLabel, files);
    if (!mounted) return;
    if (await previewAndWrite(context, ref, set)) _audit();
  }

  Future<void> _saveConfig() => ref
      .read(iosConfigProvider.notifier)
      .update(
        ref
            .read(iosConfigProvider)
            .copyWith(
              teamId: _teamId.text.trim().toUpperCase(),
              appleAppId: _appleAppId.text.trim(),
            ),
      );

  Future<void> _writeCi(IosProject project) async {
    final l10n = context.l10n;
    await _saveConfig();
    final config = ref.read(iosConfigProvider);
    final r = widget.ctx.report;
    final pubDir = r == null ? '' : AndroidReader.pubDir(r);
    final files = switch (config.ci) {
      CiProvider.githubActions => {
        '.github/workflows/ios-testflight.yml': githubIosWorkflow(
          iosDir: project.iosDir,
          teamId: config.teamId,
        ),
        '${project.iosDir}/ExportOptions.plist': exportOptionsPlist(
          config.teamId,
        ),
      },
      CiProvider.codemagic => {
        'codemagic.yaml': codemagicYaml(
          bundleId: project.bundleId ?? '',
          appleAppId: config.appleAppId,
          pubDir: pubDir,
        ),
      },
    };
    final set = await ref
        .read(projectWriterProvider)
        .plan(_root, l10n.iosCiLabel(config.ci.label), files);
    if (!mounted) return;
    await previewAndWrite(context, ref, set);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final lang = ref.watch(
      settingsControllerProvider.select((s) => s.language),
    );
    final project = _project();
    if (project == null) return Text(l10n.iosNoModule);
    final linux = ref.watch(hostIsLinuxProvider);
    final config = ref.watch(iosConfigProvider);
    final teamOk = RegExp(r'^[A-Z0-9]{10}$')
        .hasMatch(_teamId.text.trim().toUpperCase());
    final appleIdOk = RegExp(r'^\d{6,12}$').hasMatch(_appleAppId.text.trim());
    final ciReady = switch (config.ci) {
      CiProvider.githubActions => teamOk,
      CiProvider.codemagic => project.bundleId != null,
    };

    Widget bullet(String text) => Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  '),
          Expanded(child: Text(text)),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        // ----------------------------------------------- Limites Linux
        Container(
          key: const ValueKey('ios-limits'),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: palette.statusPedagogy.withValues(alpha: 0.1),
            border: Border.all(
              color: palette.statusPedagogy.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 6,
            children: [
              Text(
                linux ? l10n.iosLimitsTitle : l10n.iosMacTitle,
                style: theme.textTheme.titleMedium,
              ),
              Text(l10n.iosLimitsCannot, style: theme.textTheme.labelLarge),
              bullet(l10n.iosLimit1),
              bullet(l10n.iosLimit2),
              bullet(l10n.iosLimit3),
              bullet(l10n.iosLimit4),
              Text(l10n.iosLimitsCan, style: theme.textTheme.labelLarge),
              bullet(l10n.iosCan1),
              bullet(l10n.iosCan2),
              bullet(l10n.iosCan3),
              Text(
                l10n.iosNeverFake,
                style: TextStyle(color: palette.statusPedagogy),
              ),
            ],
          ),
        ),
        // --------------------------------------------------------- Audit
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.iosAuditTitle, style: theme.textTheme.titleMedium),
              Text(l10n.iosAuditHelp),
              FilledButton.tonalIcon(
                key: const ValueKey('ios-audit'),
                onPressed: _audit,
                icon: const Icon(Icons.fact_check_outlined),
                label: Text(l10n.iosAuditRun),
              ),
              if (_checks case final checks?) ...[
                Text(
                  l10n.webAuditSummary(
                    checks.where((c) => c.status == AuditStatus.failure).length,
                    checks.where((c) => c.status == AuditStatus.warning).length,
                    checks.where((c) => c.status == AuditStatus.ok).length,
                  ),
                  key: const ValueKey('ios-audit-summary'),
                  style: theme.textTheme.titleSmall,
                ),
                for (final area in IosArea.values)
                  if (checks.any((c) => c.area == area)) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        iosAreaLabel(l10n, area),
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    for (final c in checks.where((c) => c.area == area))
                      _IosCheckRow(check: c, text: iosCheckText(c, lang)),
                  ],
              ],
            ],
          ),
        ),
        // ---------------------------------------------------- Info.plist
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.iosPlistTitle, style: theme.textTheme.titleMedium),
              Text(_checks == null ? l10n.iosPlistRunAudit : l10n.iosPlistHelp),
              for (final e in _usage.entries)
                TextField(
                  key: ValueKey('ios-usage-${e.key}'),
                  controller: e.value,
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(labelText: e.key, isDense: true),
                ),
              SwitchListTile(
                key: const ValueKey('ios-encryption'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.iosEncryption),
                subtitle: Text(l10n.iosEncryptionHelp),
                value: _standardEncryption,
                onChanged: (v) => setState(() => _standardEncryption = v),
              ),
              FilledButton.tonalIcon(
                key: const ValueKey('ios-plist-write'),
                onPressed:
                    project.infoPlistPath == null ||
                        (_usage.isEmpty && !_standardEncryption)
                    ? null
                    : () => _writePlist(project),
                icon: const Icon(Icons.difference_outlined),
                label: Text(l10n.contentPreviewWrite),
              ),
            ],
          ),
        ),
        // ------------------------------------- Manifeste de confidentialité
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.iosPrivacyTitle, style: theme.textTheme.titleMedium),
              Text(l10n.iosPrivacyHelp),
              SwitchListTile(
                key: const ValueKey('ios-tracking'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.iosTracking),
                subtitle: Text(l10n.iosTrackingHelp),
                value: _tracking,
                onChanged: (v) => setState(() => _tracking = v),
              ),
              FilledButton.tonalIcon(
                key: const ValueKey('ios-privacy-write'),
                onPressed: project.pbxprojPath == null
                    ? null
                    : () => _writePrivacy(project),
                icon: const Icon(Icons.privacy_tip_outlined),
                label: Text(l10n.iosPrivacyPrepare),
              ),
              if (_pbxOutcome == PbxEditOutcome.unrecognized)
                Text(
                  l10n.iosPbxUnrecognized,
                  style: TextStyle(color: palette.statusWarning),
                ),
              Text(l10n.iosPrivacyNote, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        // --------------------------------------------- Étapes chez Apple
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(l10n.iosAppleTitle, style: theme.textTheme.titleMedium),
              Text(l10n.iosAppleHelp),
              for (final (i, step) in [
                l10n.iosApple1,
                l10n.iosApple2,
                l10n.iosApple3,
                l10n.iosApple4,
                l10n.iosApple5,
                l10n.iosApple6,
              ].indexed)
                Text('${i + 1}. $step', key: ValueKey('ios-apple-$i')),
              Text(l10n.iosCertificates, style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        // ------------------------------------------------------------ CI
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.iosCiTitle, style: theme.textTheme.titleMedium),
              Text(l10n.iosCiHelp),
              SegmentedButton<CiProvider>(
                key: const ValueKey('ios-ci-provider'),
                segments: [
                  for (final c in CiProvider.values)
                    ButtonSegment(value: c, label: Text(c.label)),
                ],
                selected: {config.ci},
                showSelectedIcon: false,
                onSelectionChanged: (s) => ref
                    .read(iosConfigProvider.notifier)
                    .update(config.copyWith(ci: s.first)),
              ),
              TextField(
                key: const ValueKey('ios-team'),
                controller: _teamId,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  labelText: l10n.iosTeamId,
                  helperText: l10n.iosTeamIdHelp,
                  errorText: _teamId.text.isNotEmpty && !teamOk
                      ? l10n.hostingInvalid
                      : null,
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (config.ci == CiProvider.codemagic)
                TextField(
                  key: const ValueKey('ios-apple-id'),
                  controller: _appleAppId,
                  decoration: InputDecoration(
                    labelText: l10n.iosAppleAppId,
                    helperText: l10n.iosAppleAppIdHelp,
                    errorText: _appleAppId.text.isNotEmpty && !appleIdOk
                        ? l10n.hostingInvalid
                        : null,
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              Text(switch (config.ci) {
                CiProvider.githubActions => l10n.iosCiGithubSecrets(
                  githubSecrets.join(', '),
                ),
                CiProvider.codemagic => l10n.iosCiCodemagicSetup,
              }, style: theme.textTheme.bodySmall),
              FilledButton.icon(
                key: const ValueKey('ios-ci-write'),
                onPressed: ciReady ? () => _writeCi(project) : null,
                icon: const Icon(Icons.difference_outlined),
                label: Text(l10n.iosCiPrepare),
              ),
              Text(
                l10n.iosCiNote,
                style: TextStyle(color: palette.statusPedagogy),
              ),
              if (config.ci == CiProvider.githubActions)
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.iosKeyBase64,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.commonCopy,
                      icon: const Icon(Icons.copy, size: 16),
                      onPressed: () {
                        Clipboard.setData(
                          const ClipboardData(
                            text: 'base64 -w0 AuthKey_XXXXXXXXXX.p8',
                          ),
                        );
                        showInfo(
                          ScaffoldMessenger.of(context),
                          l10n.commonCopied,
                        );
                      },
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IosCheckRow extends StatelessWidget {
  const _IosCheckRow({required this.check, required this.text});

  final IosCheck check;
  final IosCheckText text;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = statusStyle(context, check.status);
    return Row(
      key: ValueKey('ios-check-${check.id}-${check.values.firstOrNull ?? ''}'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(text.label),
              if (check.status != AuditStatus.ok && text.fix.isNotEmpty)
                Text(text.fix, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ],
    );
  }
}
