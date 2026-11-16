import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/glass_card.dart';
import '../../changes/application/change_providers.dart';
import '../../changes/domain/change_set.dart';
import '../../detection/domain/detection_report.dart';
import '../application/content_providers.dart';
import '../domain/icons.dart';
import 'content_workspace.dart';

/// Icônes Android, iOS, favicon et PWA à partir d'une image source.
class IconsTab extends ConsumerStatefulWidget {
  const IconsTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  ConsumerState<IconsTab> createState() => _IconsTabState();
}

class _IconsTabState extends ConsumerState<IconsTab> {
  PickedImage? _source;
  SourceIconReport? _report;
  int _background = 0xFFFFFFFF;
  Map<String, Uint8List>? _generated;
  bool _busy = false;

  static const _swatches = [
    0xFFFFFFFF,
    0xFF0B1026,
    0xFF3F4BD1,
    0xFF0F766E,
    0xFFC2410C,
  ];

  /// Fichiers à produire et fichier Contents.json iOS à créer s'il manque.
  (List<IconTarget>, String?, String?) _plan() {
    final c = widget.ctx;
    final writer = ref.read(projectWriterProvider);
    final targets = <IconTarget>[];
    String? contentsPath;
    String? contentsJson;
    if (c.isFlutter && c.selected(PlatformTarget.android)) {
      targets.addAll(androidIcons(c.join(c.pubDir, 'android')));
    }
    if (c.isFlutter && c.selected(PlatformTarget.ios)) {
      final dir = c.join(
        c.pubDir,
        'ios/Runner/Assets.xcassets/AppIcon.appiconset',
      );
      final path = '$dir/Contents.json';
      final existing = writer.readCurrent(c.root, path);
      if (existing != null) {
        targets.addAll(iosIconsFromContents(dir, existing));
      } else {
        final (ios, json) = iosDefaultIcons(dir);
        targets.addAll(ios);
        contentsPath = path;
        contentsJson = json;
      }
    }
    if (c.selected(PlatformTarget.web)) {
      // Flutter : web/ ; outils JavaScript : public/ s'il existe, sinon racine.
      final webDir = c.isFlutter
          ? c.join(c.pubDir, 'web')
          : (writer.readCurrent(c.root, 'public/index.html') != null ||
                    writer.readCurrent(c.root, 'public/robots.txt') != null
                ? 'public'
                : '');
      targets.addAll(webIcons(webDir, flutter: c.isFlutter));
    }
    return (targets, contentsPath, contentsJson);
  }

  Future<void> _pick() async {
    final picked = await ref.read(imagePickerProvider).pickOne();
    if (picked == null || !mounted) return;
    setState(() {
      _source = picked;
      _report = inspectIcon(picked.bytes);
      _generated = null;
    });
  }

  Future<void> _generate(List<IconTarget> targets) async {
    setState(() => _busy = true);
    final out = await ref.read(iconGeneratorProvider)((
      source: _source!.bytes,
      targets: targets,
      background: _background,
    ));
    if (mounted) {
      setState(() {
        _generated = out;
        _busy = false;
      });
    }
  }

  Future<void> _write(String? contentsPath, String? contentsJson) async {
    final l10n = context.l10n;
    final writer = ref.read(projectWriterProvider);
    final binary = await writer.planBinary(
      widget.ctx.root,
      l10n.iconsLabel,
      _generated!,
    );
    final text = contentsPath == null
        ? null
        : await writer.plan(widget.ctx.root, l10n.iconsLabel, {
            contentsPath: contentsJson!,
          });
    final set = ChangeSet(
      label: l10n.iconsLabel,
      files: [...?text?.files, ...binary.files],
    );
    if (!mounted) return;
    await previewAndWrite(context, ref, set);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final (targets, contentsPath, contentsJson) = _plan();
    final report = _report;

    String issueText(IconIssue i) => switch (i) {
      IconIssue.unreadable => l10n.iconsIssueUnreadable,
      IconIssue.tooSmall => l10n.iconsIssueTooSmall,
      IconIssue.belowRecommended => l10n.iconsIssueBelowRecommended,
      IconIssue.notSquare => l10n.iconsIssueNotSquare,
      IconIssue.transparent => l10n.iconsIssueTransparent,
    };

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(l10n.contentIconsEmpty),
          if (targets.isEmpty)
            Text(
              l10n.iconsNoTarget,
              style: TextStyle(color: palette.statusWarning),
            )
          else
            Text(
              l10n.iconsTargets(
                targets.length + (contentsPath == null ? 0 : 1),
              ),
            ),
          FilledButton.tonalIcon(
            key: const ValueKey('icons-pick'),
            onPressed: _pick,
            icon: const Icon(Icons.upload_file),
            label: Text(l10n.iconsChoose),
          ),
          if (_source != null && report != null) ...[
            Row(
              spacing: 16,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.colorScheme.outlineVariant),
                  ),
                  child: Image.memory(
                    _source!.bytes,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(Icons.broken_image),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 4,
                    children: [
                      Text(
                        l10n.iconsSourceInfo(
                          _source!.name,
                          report.width,
                          report.height,
                        ),
                      ),
                      for (final i in report.issues)
                        Text(
                          issueText(i),
                          style: TextStyle(
                            color: report.usable
                                ? palette.statusWarning
                                : palette.statusFailed,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (report.usable && targets.isNotEmpty) ...[
              Text(l10n.iconsBackground, style: theme.textTheme.labelLarge),
              Wrap(
                spacing: 8,
                children: [
                  for (final c in _swatches)
                    InkWell(
                      key: ValueKey('icons-bg-$c'),
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => setState(() {
                        _background = c;
                        _generated = null;
                      }),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(c),
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: _background == c ? 3 : 1,
                            color: _background == c
                                ? theme.colorScheme.primary
                                : theme.colorScheme.outlineVariant,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (_busy)
                Row(
                  spacing: 12,
                  children: [
                    const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    Text(l10n.iconsGenerating),
                  ],
                )
              else
                FilledButton.icon(
                  key: const ValueKey('icons-generate'),
                  onPressed: () => _generate(targets),
                  icon: const Icon(Icons.auto_fix_high),
                  label: Text(l10n.iconsGenerate),
                ),
            ],
          ],
          if (_generated case final generated?) ...[
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final e in generated.entries.take(12))
                  Tooltip(
                    message: e.key,
                    child: Column(
                      children: [
                        SizedBox.square(
                          dimension: 56,
                          child: Image.memory(e.value, fit: BoxFit.contain),
                        ),
                        Text(
                          '${targets.firstWhere((t) => t.path == e.key).size}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            FilledButton.icon(
              key: const ValueKey('icons-write'),
              onPressed: () => _write(contentsPath, contentsJson),
              icon: const Icon(Icons.difference_outlined),
              label: Text(l10n.contentPreviewWrite),
            ),
          ],
        ],
      ),
    );
  }
}
