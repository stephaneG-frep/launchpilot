import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../domain/screenshots.dart';

/// Dessin de zones à masquer : glisser sur l'image crée un rectangle.
/// Renvoie la liste complète des zones, ou null si annulé.
Future<List<MaskRect>?> showMaskEditor(
  BuildContext context,
  Uint8List image,
  double aspectRatio,
  List<MaskRect> initial,
) => showDialog<List<MaskRect>>(
  context: context,
  builder: (_) => _MaskEditor(image, aspectRatio, initial),
);

class _MaskEditor extends StatefulWidget {
  const _MaskEditor(this.image, this.aspectRatio, this.initial);

  final Uint8List image;
  final double aspectRatio;
  final List<MaskRect> initial;

  @override
  State<_MaskEditor> createState() => _MaskEditorState();
}

class _MaskEditorState extends State<_MaskEditor> {
  late final List<MaskRect> _masks = [...widget.initial];
  Offset? _start;
  Offset? _current;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.shotsMask),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 12,
          children: [
            Text(l10n.shotsMaskHelp),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 480),
              child: AspectRatio(
                aspectRatio: widget.aspectRatio,
                child: LayoutBuilder(
                  builder: (context, box) {
                    MaskRect toMask(Offset a, Offset b) => MaskRect(
                      a.dx / box.maxWidth,
                      a.dy / box.maxHeight,
                      b.dx / box.maxWidth,
                      b.dy / box.maxHeight,
                    ).normalized();
                    final drafts = [
                      ..._masks,
                      if (_start != null && _current != null)
                        toMask(_start!, _current!),
                    ];
                    return GestureDetector(
                      key: const ValueKey('mask-canvas'),
                      onPanStart: (d) => setState(() {
                        _start = d.localPosition;
                        _current = d.localPosition;
                      }),
                      onPanUpdate: (d) =>
                          setState(() => _current = d.localPosition),
                      onPanEnd: (_) => setState(() {
                        final m = toMask(_start!, _current!);
                        if (!m.isEmpty) _masks.add(m);
                        _start = _current = null;
                      }),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.memory(widget.image, fit: BoxFit.fill),
                          for (final m in drafts)
                            Positioned(
                              left: m.left * box.maxWidth,
                              top: m.top * box.maxHeight,
                              width: (m.right - m.left) * box.maxWidth,
                              height: (m.bottom - m.top) * box.maxHeight,
                              child: const ColoredBox(color: Color(0xE0202438)),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            Text(l10n.shotsMaskCount(_masks.length)),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _masks.isEmpty ? null : () => setState(_masks.clear),
          child: Text(l10n.shotsMaskClear),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          key: const ValueKey('mask-apply'),
          onPressed: () => Navigator.of(context).pop(_masks),
          child: Text(l10n.shotsMaskApply),
        ),
      ],
    );
  }
}
