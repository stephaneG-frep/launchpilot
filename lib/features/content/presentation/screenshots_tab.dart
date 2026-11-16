import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/launch_palette.dart';
import '../../../core/widgets/badges.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../l10n/app_localizations.dart';
import '../../changes/application/change_providers.dart';
import '../application/content_providers.dart';
import '../domain/screenshots.dart';
import 'content_workspace.dart';
import 'mask_editor.dart';
import 'screenshot_framer.dart';

final screenshotFramerProvider = Provider<ScreenshotFramer>(
  (ref) => const UiScreenshotFramer(),
);

class _Shot {
  _Shot(this.image, this.size);

  final PickedImage image;
  final (int, int) size;
  List<MaskRect> masks = const [];
  String caption = '';
}

String slotLabel(AppLocalizations l10n, ScreenshotSlot s) => switch (s) {
  ScreenshotSlot.playPhone => l10n.slotPlay,
  ScreenshotSlot.iphone69 => l10n.slotIphone69,
  ScreenshotSlot.iphone65 => l10n.slotIphone65,
  ScreenshotSlot.ipad13 => l10n.slotIpad13,
};

/// Captures importées : contrôle des dimensions, masquage des données
/// personnelles, cadre et légende, puis export avec aperçu.
class ScreenshotsTab extends ConsumerStatefulWidget {
  const ScreenshotsTab(this.ctx, {super.key});

  final ContentContext ctx;

  @override
  ConsumerState<ScreenshotsTab> createState() => _ScreenshotsTabState();
}

class _ScreenshotsTabState extends ConsumerState<ScreenshotsTab> {
  final _shots = <_Shot>[];
  FrameStyle _style = FrameStyle.indigo;
  ExportFormat _format = ExportFormat.play;
  bool _busy = false;

  Future<void> _import() async {
    final picked = await ref.read(imagePickerProvider).pickMany();
    setState(() {
      for (final p in picked) {
        final size = imageSize(p.bytes);
        if (size != null) _shots.add(_Shot(p, size));
      }
    });
  }

  Future<void> _export() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    final framer = ref.read(screenshotFramerProvider);
    final files = <String, Uint8List>{};
    for (final (i, s) in _shots.indexed) {
      final masked = s.masks.isEmpty
          ? s.image.bytes
          : applyMasks(s.image.bytes, s.masks);
      files['store_assets/screenshots/${_format.name}/${i + 1}.png'] =
          await framer.frame(
            masked,
            style: _style,
            format: _format,
            caption: s.caption,
          );
    }
    final set = await ref
        .read(projectWriterProvider)
        .planBinary(widget.ctx.root, l10n.shotsLabel, files);
    if (!mounted) return;
    setState(() => _busy = false);
    await previewAndWrite(context, ref, set);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final palette = LaunchPalette.of(context);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          Text(l10n.contentScreenshotsEmpty),
          FilledButton.tonalIcon(
            key: const ValueKey('shots-import'),
            onPressed: _import,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(l10n.shotsImport),
          ),
          for (final (i, s) in _shots.indexed)
            Container(
              key: ValueKey('shot-$i'),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.colorScheme.outlineVariant),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 12,
                children: [
                  SizedBox(
                    width: 60,
                    height: 100,
                    child: Image.memory(s.image.bytes, fit: BoxFit.contain),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 6,
                      children: [
                        Text('${s.image.name} · ${s.size.$1} × ${s.size.$2}'),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final e in checkScreenshot(
                              s.size.$1,
                              s.size.$2,
                            ).entries)
                              Pill(
                                label: slotLabel(l10n, e.key),
                                color: e.value
                                    ? palette.statusSucceeded
                                    : palette.statusTodo,
                                icon: e.value ? Icons.check : Icons.close,
                              ),
                          ],
                        ),
                        TextField(
                          key: ValueKey('shot-caption-$i'),
                          decoration: InputDecoration(
                            labelText: l10n.shotsCaption,
                            isDense: true,
                          ),
                          onChanged: (v) => s.caption = v,
                        ),
                        Wrap(
                          spacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            OutlinedButton.icon(
                              key: ValueKey('shot-mask-$i'),
                              onPressed: () async {
                                final masks = await showMaskEditor(
                                  context,
                                  s.image.bytes,
                                  s.size.$1 / s.size.$2,
                                  s.masks,
                                );
                                if (masks != null) {
                                  setState(() => s.masks = masks);
                                }
                              },
                              icon: const Icon(Icons.format_color_fill),
                              label: Text(l10n.shotsMask),
                            ),
                            Text(l10n.shotsMaskCount(s.masks.length)),
                            TextButton(
                              onPressed: () =>
                                  setState(() => _shots.removeAt(i)),
                              child: Text(l10n.shotsRemove),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (_shots.isNotEmpty) ...[
            Text(l10n.shotsFrame, style: theme.textTheme.labelLarge),
            SegmentedButton<FrameStyle>(
              segments: [
                ButtonSegment(
                  value: FrameStyle.none,
                  label: Text(l10n.frameNone),
                ),
                ButtonSegment(
                  value: FrameStyle.indigo,
                  label: Text(l10n.frameIndigo),
                ),
                ButtonSegment(
                  value: FrameStyle.light,
                  label: Text(l10n.frameLight),
                ),
                ButtonSegment(
                  value: FrameStyle.sunset,
                  label: Text(l10n.frameSunset),
                ),
              ],
              selected: {_style},
              showSelectedIcon: false,
              onSelectionChanged: (v) => setState(() => _style = v.first),
            ),
            Text(l10n.shotsFormat, style: theme.textTheme.labelLarge),
            SegmentedButton<ExportFormat>(
              segments: [
                ButtonSegment(
                  value: ExportFormat.play,
                  label: Text(l10n.formatPlay),
                ),
                ButtonSegment(
                  value: ExportFormat.iphone,
                  label: Text(l10n.formatIphone),
                ),
                ButtonSegment(
                  value: ExportFormat.ipad,
                  label: Text(l10n.formatIpad),
                ),
              ],
              selected: {_format},
              showSelectedIcon: false,
              onSelectionChanged: (v) => setState(() => _format = v.first),
            ),
            FilledButton.icon(
              key: const ValueKey('shots-export'),
              onPressed: _busy ? null : _export,
              icon: const Icon(Icons.difference_outlined),
              label: Text(l10n.shotsExport),
            ),
          ],
        ],
      ),
    );
  }
}
