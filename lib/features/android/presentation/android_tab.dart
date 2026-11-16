import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/audit_status.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/feedback.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../changes/application/change_providers.dart';
import '../../commands/domain/command_result.dart';
import '../../commands/domain/command_spec.dart';
import '../../commands/presentation/command_preview_dialog.dart';
import '../../content/presentation/content_workspace.dart';
import '../../git/application/git_providers.dart';
import '../../git/domain/gitignore_advisor.dart';
import '../../settings/application/settings_controller.dart';
import '../application/android_providers.dart';
import '../data/android_reader.dart';
import '../domain/android_audit.dart';
import '../domain/android_project.dart';
import '../domain/deliverables.dart';
import '../domain/signing.dart';
import 'android_texts.dart';

String androidAreaLabel(AppLocalizations l10n, AndroidArea a) => switch (a) {
  AndroidArea.identity => l10n.androidAreaIdentity,
  AndroidArea.version => l10n.androidAreaVersion,
  AndroidArea.sdk => l10n.androidAreaSdk,
  AndroidArea.signing => l10n.androidAreaSigning,
  AndroidArea.security => l10n.androidAreaSecurity,
  AndroidArea.permissions => l10n.androidAreaPermissions,
  AndroidArea.icons => l10n.androidAreaIcons,
};

(IconData, Color) statusStyle(BuildContext context, AuditStatus s) {
  final palette = LaunchPalette.of(context);
  return switch (s) {
    AuditStatus.ok => (Icons.check_circle, palette.statusSucceeded),
    AuditStatus.warning => (Icons.warning_amber, palette.statusWarning),
    AuditStatus.failure => (Icons.error, palette.statusFailed),
    AuditStatus.info => (Icons.info_outline, palette.statusPedagogy),
  };
}

/// Environnement, audit, signature, construction et livrables Android.
class AndroidTab extends ConsumerStatefulWidget {
  const AndroidTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  ConsumerState<AndroidTab> createState() => _AndroidTabState();
}

class _AndroidTabState extends ConsumerState<AndroidTab> {
  List<AndroidCheck>? _checks;
  List<DoctorLine>? _doctor;
  String? _java;
  bool _splitPerAbi = false;
  List<Deliverable>? _deliverables;
  bool _inspecting = false;
  SigningEditOutcome? _signingOutcome;

  String get _root => widget.ctx.root;

  AndroidProject? _project() {
    final report = widget.ctx.report;
    return report == null
        ? null
        : ref.read(androidReaderProvider).read(_root, report);
  }

  String get _pubDir {
    final r = widget.ctx.report;
    return r == null ? '' : AndroidReader.pubDir(r);
  }

  String get _pubDirAbs => widget.ctx.join(_root, _pubDir);

  Future<void> _doctorRun() async {
    final result = await previewAndRun(
      context,
      ref,
      CommandSpec(
        executable: 'flutter',
        arguments: const ['doctor', '-v'],
        workingDirectory: _pubDirAbs,
      ),
      openTerminal: false,
    );
    if (result == null || !mounted) return;
    final out = result.text(OutputStream.stdout);
    setState(() {
      _doctor = androidDoctorLines(out);
      _java = doctorJavaVersion(out);
    });
  }

  Future<void> _audit() async {
    final report = widget.ctx.report;
    final project = _project();
    if (report == null || project == null) return;
    final pub = ref.read(androidReaderProvider).pubspec(_root, report);
    final git = ref.read(gitStatusProvider).value;
    Set<String>? ignored;
    if (git != null && git.isRepo) {
      ignored = await ref.read(gitServiceProvider).ignored(_root, [
        if (project.keyPropertiesExists) '${project.androidDir}/key.properties',
        ...project.keystoreFiles,
      ]);
    }
    if (!mounted) return;
    setState(
      () => _checks = auditAndroid(
        project,
        dependencies: pub.dependencies,
        pubVersion: pub.version,
        gitIgnored: ignored,
      ),
    );
  }

  Future<void> _configureSigning(AndroidProject project) async {
    final l10n = context.l10n;
    final writer = ref.read(projectWriterProvider);
    final current = writer.readCurrent(_root, project.gradlePath!);
    if (current == null) return;
    final edit = applyReleaseSigning(current, kts: project.kts);
    setState(() => _signingOutcome = edit.outcome);
    if (edit.outcome != SigningEditOutcome.changed) return;
    final set = await writer.plan(_root, l10n.androidSigningLabel, {
      project.gradlePath!: edit.content!,
    });
    if (!mounted) return;
    if (await previewAndWrite(context, ref, set)) await _audit();
  }

  Future<void> _gitignore(AndroidProject project) async {
    final l10n = context.l10n;
    final writer = ref.read(projectWriterProvider);
    final current = writer.readCurrent(_root, '.gitignore');
    final next = gitignoreWithEntries(
      current,
      signingGitignoreEntries(project.androidDir),
    );
    if (next == (current ?? '')) {
      showInfo(ScaffoldMessenger.of(context), l10n.androidGitignoreDone);
      return;
    }
    final set = await writer.plan(_root, l10n.androidGitignoreLabel, {
      '.gitignore': next,
    });
    if (!mounted) return;
    if (await previewAndWrite(context, ref, set)) {
      ref.invalidate(gitStatusProvider);
      await _audit();
    }
  }

  Future<void> _build(List<String> args) => previewAndRun(
    context,
    ref,
    CommandSpec(
      executable: 'flutter',
      arguments: args,
      workingDirectory: _pubDirAbs,
      timeout: const Duration(minutes: 30),
    ),
  );

  Future<void> _inspect() async {
    setState(() => _inspecting = true);
    final list = await ref.read(deliverableInspectorProvider)((
      root: _root,
      paths: deliverableCandidates(_pubDir),
    ));
    if (mounted) {
      setState(() {
        _deliverables = list;
        _inspecting = false;
      });
    }
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    showInfo(ScaffoldMessenger.of(context), context.l10n.commonCopied);
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
    if (project == null) return Text(l10n.androidNoModule);
    const mono = TextStyle(fontFamily: 'monospace');
    final storeFile = '/home/<toi>/upload-keystore.jks';

    Widget codeBlock(String text, String key) => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.colorScheme.surfaceContainerLowest,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SelectableText(
              text,
              key: ValueKey(key),
              style: mono.copyWith(fontSize: 12),
            ),
          ),
          IconButton(
            tooltip: l10n.commonCopy,
            icon: const Icon(Icons.copy, size: 18),
            onPressed: () => _copy(text),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        // ------------------------------------------------- Environnement
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.androidEnvTitle, style: theme.textTheme.titleMedium),
              Text(l10n.androidEnvHelp),
              Text(
                l10n.androidToolVersions(
                  project.gradleVersion ?? '?',
                  project.agpVersion ?? '?',
                  project.kotlinVersion ?? '?',
                ),
                key: const ValueKey('android-tools'),
              ),
              OutlinedButton.icon(
                key: const ValueKey('android-doctor'),
                onPressed: _doctorRun,
                icon: const Icon(Icons.medical_services_outlined),
                label: Text(l10n.androidDoctor),
              ),
              if (_doctor case final lines?) ...[
                if (lines.isEmpty) Text(l10n.androidDoctorEmpty),
                for (final l in lines)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l.status,
                        style: TextStyle(
                          color: switch (l.status) {
                            '✓' => palette.statusSucceeded,
                            '!' => palette.statusWarning,
                            '✗' || '☠' => palette.statusFailed,
                            _ => null,
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(l.text)),
                    ],
                  ),
                if (_java != null) Text(l10n.androidJava(_java!)),
                if (lines.any((l) => l.text.contains('license')))
                  Text(l10n.androidLicenses, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        // --------------------------------------------------------- Audit
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.androidAuditTitle, style: theme.textTheme.titleMedium),
              Text(l10n.androidAuditHelp),
              FilledButton.tonalIcon(
                key: const ValueKey('android-audit'),
                onPressed: _audit,
                icon: const Icon(Icons.fact_check_outlined),
                label: Text(l10n.androidAuditRun),
              ),
              if (_checks case final checks?) ...[
                Text(
                  l10n.webAuditSummary(
                    checks.where((c) => c.status == AuditStatus.failure).length,
                    checks.where((c) => c.status == AuditStatus.warning).length,
                    checks.where((c) => c.status == AuditStatus.ok).length,
                  ),
                  key: const ValueKey('android-audit-summary'),
                  style: theme.textTheme.titleSmall,
                ),
                for (final area in AndroidArea.values)
                  if (checks.any((c) => c.area == area)) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        androidAreaLabel(l10n, area),
                        style: theme.textTheme.labelLarge,
                      ),
                    ),
                    for (final c in checks.where((c) => c.area == area))
                      _CheckRow(check: c, text: androidCheckText(c, lang)),
                  ],
                Text(l10n.androidDataSafety, style: theme.textTheme.bodySmall),
              ],
            ],
          ),
        ),
        // ----------------------------------------------------- Signature
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                l10n.androidSigningTitle,
                style: theme.textTheme.titleMedium,
              ),
              Text(l10n.androidSigningHelp),
              Text(
                project.keyPropertiesExists
                    ? l10n.androidKeyPropertiesPresent
                    : l10n.androidKeyPropertiesMissing,
                key: const ValueKey('android-key-state'),
                style: TextStyle(
                  color: project.keyPropertiesExists
                      ? palette.statusSucceeded
                      : palette.statusWarning,
                ),
              ),
              Text(l10n.androidKeytoolStep, style: theme.textTheme.labelLarge),
              codeBlock(keytoolCommand(), 'android-keytool'),
              Text(
                l10n.androidKeyPropertiesStep,
                style: theme.textTheme.labelLarge,
              ),
              codeBlock(
                keyPropertiesTemplate(storeFile: storeFile),
                'android-key-template',
              ),
              Text(
                l10n.androidPlayAppSigning,
                style: theme.textTheme.bodySmall,
              ),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  FilledButton.tonalIcon(
                    key: const ValueKey('android-signing'),
                    onPressed: project.gradlePath == null
                        ? null
                        : () => _configureSigning(project),
                    icon: const Icon(Icons.difference_outlined),
                    label: Text(l10n.androidSigningConfigure),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('android-gitignore'),
                    onPressed: () => _gitignore(project),
                    icon: const Icon(Icons.visibility_off_outlined),
                    label: Text(l10n.androidGitignore),
                  ),
                ],
              ),
              if (_signingOutcome == SigningEditOutcome.alreadyConfigured)
                Text(
                  l10n.androidSigningAlready,
                  style: TextStyle(color: palette.statusSucceeded),
                ),
              if (_signingOutcome == SigningEditOutcome.unrecognized) ...[
                Text(
                  l10n.androidSigningUnrecognized,
                  style: TextStyle(color: palette.statusWarning),
                ),
                codeBlock(
                  signingSnippet(kts: project.kts),
                  'android-signing-snippet',
                ),
              ],
            ],
          ),
        ),
        // -------------------------------------------------- Construction
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(l10n.androidBuildTitle, style: theme.textTheme.titleMedium),
              Text(l10n.androidBuildHelp),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  FilledButton.icon(
                    key: const ValueKey('android-build-aab'),
                    onPressed: () =>
                        _build(const ['build', 'appbundle', '--release']),
                    icon: const Icon(Icons.inventory_2_outlined),
                    label: Text(l10n.androidBuildAab),
                  ),
                  OutlinedButton.icon(
                    key: const ValueKey('android-build-apk'),
                    onPressed: () => _build([
                      'build',
                      'apk',
                      '--release',
                      if (_splitPerAbi) '--split-per-abi',
                    ]),
                    icon: const Icon(Icons.android),
                    label: Text(l10n.androidBuildApk),
                  ),
                  FilterChip(
                    key: const ValueKey('android-split'),
                    label: Text(l10n.androidSplitPerAbi),
                    selected: _splitPerAbi,
                    onSelected: (v) => setState(() => _splitPerAbi = v),
                  ),
                ],
              ),
            ],
          ),
        ),
        // ---------------------------------------------------- Livrables
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Text(
                l10n.androidDeliverablesTitle,
                style: theme.textTheme.titleMedium,
              ),
              Text(l10n.androidDeliverablesHelp),
              OutlinedButton.icon(
                key: const ValueKey('android-deliverables'),
                onPressed: _inspecting ? null : _inspect,
                icon: const Icon(Icons.fingerprint),
                label: Text(l10n.androidDeliverablesCheck),
              ),
              if (_inspecting) const LinearProgressIndicator(),
              if (_deliverables case final list?) ...[
                if (list.isEmpty) Text(l10n.androidDeliverablesNone),
                for (final d in list)
                  _DeliverableCard(
                    deliverable: d,
                    locale: lang.name,
                    onCopy: _copy,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CheckRow extends StatelessWidget {
  const _CheckRow({required this.check, required this.text});

  final AndroidCheck check;
  final CheckText text;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = statusStyle(context, check.status);
    return Row(
      key: ValueKey(
        'android-check-${check.id}-${check.values.firstOrNull ?? ''}',
      ),
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

class _DeliverableCard extends StatelessWidget {
  const _DeliverableCard({
    required this.deliverable,
    required this.locale,
    required this.onCopy,
  });

  final Deliverable deliverable;
  final String locale;
  final void Function(String) onCopy;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final palette = LaunchPalette.of(context);
    final d = deliverable;
    final (text, color) = switch (d.signing) {
      DeliverableSigning.debug => (
        l10n.androidSignedDebug,
        palette.statusFailed,
      ),
      DeliverableSigning.signed => (
        l10n.androidSignedRelease,
        palette.statusSucceeded,
      ),
      DeliverableSigning.unsigned => (
        l10n.androidUnsigned,
        palette.statusWarning,
      ),
    };
    const mono = TextStyle(fontFamily: 'monospace', fontSize: 12);
    return Container(
      key: ValueKey('deliverable-${d.path}'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          SelectableText(d.path, style: mono),
          Text(
            '${d.kind == DeliverableKind.aab ? 'App Bundle' : 'APK'} · ${formatSize(d.size, locale: locale)}',
          ),
          Row(
            children: [
              Expanded(
                child: SelectableText('SHA-256 ${d.sha256}', style: mono),
              ),
              IconButton(
                tooltip: l10n.commonCopy,
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () => onCopy(d.sha256),
              ),
            ],
          ),
          Text(text, style: TextStyle(color: color)),
        ],
      ),
    );
  }
}
