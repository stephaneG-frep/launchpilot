import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;

import '../../../app/destinations.dart';
import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/glass_card.dart';
import '../../changes/application/change_providers.dart';
import '../../content/presentation/content_workspace.dart';
import '../../detection/domain/detection_report.dart';
import '../application/web_providers.dart';
import '../domain/pwa.dart';
import '../domain/web_build.dart';

/// Manifeste, couleurs, icônes et service worker hors ligne.
class PwaTab extends ConsumerStatefulWidget {
  const PwaTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  ConsumerState<PwaTab> createState() => _PwaTabState();
}

enum _F { name, shortName, description, theme, background }

class _PwaTabState extends ConsumerState<PwaTab> {
  final _c = {for (final f in _F.values) f: TextEditingController()};
  String _display = 'standalone';
  bool _worker = false;
  bool _loaded = false;

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Manifeste existant (détecté) ou emplacement conventionnel.
  String _manifestPath(WebBuildPlan plan) {
    if (plan.isFlutter) return widget.ctx.join(plan.publicDir, 'manifest.json');
    final found = widget.ctx.report
        ?.findingsOf(FindingCategory.pwa)
        .where((f) => f.detail == 'manifest')
        .map((f) => f.path)
        .where(
          (path) =>
              plan.publicDir.isEmpty || path.startsWith('${plan.publicDir}/'),
        )
        .firstOrNull;
    return found ?? widget.ctx.join(plan.publicDir, 'manifest.webmanifest');
  }

  void _load(WebBuildPlan plan) {
    if (_loaded) return;
    _loaded = true;
    final raw = ref
        .read(projectWriterProvider)
        .readCurrent(widget.ctx.root, _manifestPath(plan));
    final s = PwaSettings.fromManifest(
      raw,
      fallbackName: widget.ctx.ws.project.name,
    );
    _c[_F.name]!.text = s.name;
    _c[_F.shortName]!.text = s.shortName;
    _c[_F.description]!.text = s.description;
    _c[_F.theme]!.text = s.themeColor;
    _c[_F.background]!.text = s.backgroundColor;
    _display = PwaSettings.displays.contains(s.display)
        ? s.display
        : 'standalone';
  }

  PwaSettings get _settings => PwaSettings(
    name: _c[_F.name]!.text.trim(),
    shortName: _c[_F.shortName]!.text.trim(),
    description: _c[_F.description]!.text.trim(),
    themeColor: _c[_F.theme]!.text.trim(),
    backgroundColor: _c[_F.background]!.text.trim(),
    display: _display,
  );

  Future<void> _write(WebBuildPlan plan) async {
    final l10n = context.l10n;
    final writer = ref.read(projectWriterProvider);
    final root = widget.ctx.root;
    final s = _settings;
    final manifestPath = _manifestPath(plan);
    final files = <String, String>{
      manifestPath: updateManifest(
        writer.readCurrent(root, manifestPath),
        s,
        flutter: plan.isFlutter,
      ),
    };
    if (_worker) {
      final now = DateTime.now();
      files[widget.ctx.join(plan.publicDir, 'sw.js')] = serviceWorkerJs(
        version:
            '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.hour}${now.minute}',
      );
    }
    final index = plan.sourceIndex;
    final html = index == null ? null : writer.readCurrent(root, index);
    if (index != null && html != null) {
      // Le dossier public est servi à la racine du site.
      final href = plan.publicDir.isEmpty
          ? manifestPath
          : p.posix.relative(manifestPath, from: plan.publicDir);
      final next = applyPwaTags(
        html,
        manifestHref: href,
        themeColor: s.themeColor,
        registerWorker: _worker,
      );
      if (next != null) files[index] = next;
    }
    final set = await writer.plan(root, l10n.pwaLabel, files);
    if (!mounted) return;
    await previewAndWrite(context, ref, set);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final plan = ref.watch(webBuildPlanProvider);
    if (plan == null) return Text(l10n.webNoPlan);
    _load(plan);
    final s = _settings;
    final problems = s.problems;
    final manifestPath = _manifestPath(plan);
    final iconDir = widget.ctx.join(plan.publicDir, 'icons');
    final writer = ref.read(projectWriterProvider);
    final hasIcons = [
      if (plan.isFlutter) 'Icon-192.png' else 'icon-192.png',
      if (plan.isFlutter) 'Icon-512.png' else 'icon-512.png',
    ].every((f) => writer.exists(widget.ctx.root, widget.ctx.join(iconDir, f)));

    Widget colorField(_F f, String label) {
      final value = _c[f]!.text.trim();
      final valid = isHexColor(value);
      Color? color;
      if (valid) {
        final hex = value.length == 4
            ? value.substring(1).split('').map((c) => '$c$c').join()
            : value.substring(1);
        color = Color(int.parse('FF$hex', radix: 16));
      }
      return Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: theme.colorScheme.outline),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: ValueKey('pwa-${f.name}'),
              controller: _c[f],
              style: const TextStyle(fontFamily: 'monospace'),
              decoration: InputDecoration(
                labelText: label,
                errorText: valid ? null : l10n.pwaColorInvalid,
                isDense: true,
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              Text(l10n.pwaHelp),
              Text(
                manifestPath,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
              TextField(
                key: const ValueKey('pwa-name'),
                controller: _c[_F.name],
                decoration: InputDecoration(
                  labelText: l10n.pwaName,
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                key: const ValueKey('pwa-shortName'),
                controller: _c[_F.shortName],
                decoration: InputDecoration(
                  labelText: l10n.pwaShortName,
                  helperText: l10n.pwaShortNameHint,
                  counterText: '${s.shortName.length} / 12',
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
              TextField(
                controller: _c[_F.description],
                decoration: InputDecoration(
                  labelText: l10n.pwaDescription,
                  isDense: true,
                ),
              ),
              colorField(_F.theme, l10n.pwaThemeColor),
              colorField(_F.background, l10n.pwaBackgroundColor),
              Text(l10n.pwaDisplay, style: theme.textTheme.labelLarge),
              SegmentedButton<String>(
                segments: [
                  for (final d in PwaSettings.displays)
                    ButtonSegment(value: d, label: Text(d)),
                ],
                selected: {_display},
                showSelectedIcon: false,
                onSelectionChanged: (v) => setState(() => _display = v.first),
              ),
              Row(
                children: [
                  Icon(
                    hasIcons ? Icons.check_circle : Icons.warning_amber,
                    color: hasIcons
                        ? palette.statusSucceeded
                        : palette.statusWarning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      hasIcons ? l10n.pwaIconsOk : l10n.pwaIconsMissing,
                    ),
                  ),
                  if (!hasIcons)
                    TextButton(
                      onPressed: () => context.go(
                        '${AppDestination.content.path}?tab=icons',
                      ),
                      child: Text(l10n.checklistOpenTool),
                    ),
                ],
              ),
              SwitchListTile(
                key: const ValueKey('pwa-worker'),
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.pwaWorker),
                subtitle: Text(
                  plan.isFlutter ? l10n.pwaWorkerFlutter : l10n.pwaWorkerHelp,
                ),
                value: _worker,
                onChanged: (v) => setState(() => _worker = v),
              ),
              if (_worker)
                Text(l10n.pwaOfflineTest, style: theme.textTheme.bodySmall),
              if (problems.isNotEmpty)
                Text(
                  l10n.pwaProblems(problems.join(', ')),
                  style: TextStyle(color: palette.statusWarning),
                ),
              FilledButton.icon(
                key: const ValueKey('pwa-write'),
                onPressed: problems.any((p) => p != 'short_name_length')
                    ? null
                    : () => _write(plan),
                icon: const Icon(Icons.difference_outlined),
                label: Text(l10n.contentPreviewWrite),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
