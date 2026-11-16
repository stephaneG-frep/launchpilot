import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/glass_card.dart';
import '../../changes/application/change_providers.dart';
import '../domain/version.dart';
import 'content_workspace.dart';

/// Lecture et mise à jour de la version, une ligne modifiée par fichier.
class VersionTab extends ConsumerWidget {
  const VersionTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final writer = ref.watch(projectWriterProvider);
    final manifests = <(VersionFileKind, String)>[
      for (final pkg in ctx.report?.packages ?? const [])
        if (pkg.manager == 'pub')
          (VersionFileKind.pubspec, pkg.manifest)
        else if (const {'npm', 'pnpm', 'yarn', 'bun'}.contains(pkg.manager))
          (VersionFileKind.packageJson, pkg.manifest),
    ];
    if (manifests.isEmpty) {
      for (final (kind, path) in [
        (VersionFileKind.pubspec, 'pubspec.yaml'),
        (VersionFileKind.packageJson, 'package.json'),
      ]) {
        if (writer.readCurrent(ctx.root, path) != null) {
          manifests.add((kind, path));
        }
      }
    }
    if (manifests.isEmpty) return Text(l10n.versionNoManifest);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 16,
      children: [
        Text(l10n.versionBumpHelp),
        for (final (kind, path) in manifests)
          _VersionCard(key: ValueKey(path), ctx: ctx, kind: kind, path: path),
      ],
    );
  }
}

class _VersionCard extends ConsumerStatefulWidget {
  const _VersionCard({
    super.key,
    required this.ctx,
    required this.kind,
    required this.path,
  });

  final ContentContext ctx;
  final VersionFileKind kind;
  final String path;

  @override
  ConsumerState<_VersionCard> createState() => _VersionCardState();
}

class _VersionCardState extends ConsumerState<_VersionCard> {
  VersionBump _bump = VersionBump.patch;
  bool _incrementBuild = true;
  final _custom = TextEditingController();

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  Future<void> _write(String content, SemVer target) async {
    final l10n = context.l10n;
    final next = writeVersion(widget.kind, content, target.toString())!;
    final set = await ref.read(projectWriterProvider).plan(
      widget.ctx.root,
      l10n.versionLabel(target.toString()),
      {widget.path: next},
    );
    if (!mounted) return;
    if (await previewAndWrite(context, ref, set)) setState(_custom.clear);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);
    final content = ref
        .watch(projectWriterProvider)
        .readCurrent(widget.ctx.root, widget.path);
    final raw = content == null ? null : readVersion(widget.kind, content);
    final current = raw == null ? null : SemVer.tryParse(raw);
    final supportsBuild = widget.kind == VersionFileKind.pubspec;
    final session = SemVer.tryParse(widget.ctx.ws.activeSession?.version ?? '');

    final customText = _custom.text.trim();
    final custom = customText.isEmpty ? null : SemVer.tryParse(customText);
    final proposed =
        custom ??
        current?.bumped(
          _bump,
          incrementBuild: supportsBuild && _incrementBuild,
        );

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(
            widget.path,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'monospace',
            ),
          ),
          if (raw == null)
            Text(l10n.versionNoLine)
          else if (current == null)
            Text(l10n.versionUnparsable(raw))
          else
            Text(l10n.versionCurrent(current.toString())),
          if (current != null && content != null) ...[
            SegmentedButton<VersionBump>(
              key: ValueKey('bump-${widget.path}'),
              segments: [
                ButtonSegment(
                  value: VersionBump.major,
                  label: Text(l10n.versionBumpMajor),
                ),
                ButtonSegment(
                  value: VersionBump.minor,
                  label: Text(l10n.versionBumpMinor),
                ),
                ButtonSegment(
                  value: VersionBump.patch,
                  label: Text(l10n.versionBumpPatch),
                ),
                if (supportsBuild && current.build != null)
                  ButtonSegment(
                    value: VersionBump.none,
                    label: Text(l10n.versionBumpNone),
                  ),
              ],
              selected: {_bump},
              showSelectedIcon: false,
              onSelectionChanged: (s) => setState(() {
                _bump = s.first;
                _custom.clear();
              }),
            ),
            if (supportsBuild && current.build != null)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                value: _incrementBuild,
                onChanged: (v) => setState(() => _incrementBuild = v ?? true),
                title: Text(l10n.versionIncrementBuild),
                controlAffinity: ListTileControlAffinity.leading,
              ),
          ],
          if (raw != null)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: TextField(
                key: ValueKey('version-custom-${widget.path}'),
                controller: _custom,
                style: const TextStyle(fontFamily: 'monospace'),
                decoration: InputDecoration(
                  labelText: l10n.versionCustom,
                  hintText: proposed?.toString() ?? '1.0.0',
                  errorText: customText.isNotEmpty && custom == null
                      ? l10n.versionInvalid
                      : null,
                  isDense: true,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          if (session != null && session != proposed && raw != null)
            ActionChip(
              avatar: const Icon(Icons.flag_outlined, size: 18),
              label: Text(l10n.versionUseSession(session.toString())),
              onPressed: () =>
                  setState(() => _custom.text = session.toString()),
            ),
          if (proposed != null && raw != null) ...[
            Text(
              l10n.versionProposed(raw, proposed.toString()),
              key: ValueKey('version-proposed-${widget.path}'),
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
            if (current != null && proposed.compareTo(current) <= 0)
              Text(
                l10n.versionNotHigher,
                style: TextStyle(color: palette.statusWarning),
              ),
            FilledButton.icon(
              key: ValueKey('version-write-${widget.path}'),
              onPressed: () => _write(content!, proposed),
              icon: const Icon(Icons.difference_outlined),
              label: Text(l10n.contentPreviewWrite),
            ),
          ],
        ],
      ),
    );
  }
}
