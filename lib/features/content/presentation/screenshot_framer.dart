import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum FrameStyle { none, indigo, light, sunset }

enum ExportFormat {
  play(1080, 1920),
  iphone(1290, 2796),
  ipad(2048, 2732);

  const ExportFormat(this.width, this.height);
  final int width;
  final int height;
}

/// Met une capture en scène pour les stores (fond, légende, coins arrondis).
abstract interface class ScreenshotFramer {
  Future<Uint8List> frame(
    Uint8List png, {
    required FrameStyle style,
    required ExportFormat format,
    String caption = '',
  });
}

/// Rendu avec le moteur de Flutter : les légendes accentuées s'affichent
/// correctement, contrairement aux polices bitmap.
class UiScreenshotFramer implements ScreenshotFramer {
  const UiScreenshotFramer();

  static (List<Color>, Color) _palette(FrameStyle s) => switch (s) {
    FrameStyle.indigo => (
      const [Color(0xFF0E1433), Color(0xFF3F4BD1)],
      Colors.white,
    ),
    FrameStyle.light => (
      const [Color(0xFFF6F7FD), Color(0xFFDDE1FF)],
      const Color(0xFF141833),
    ),
    FrameStyle.sunset => (
      const [Color(0xFFC2410C), Color(0xFF7C3AED)],
      Colors.white,
    ),
    FrameStyle.none => (const [Colors.black, Colors.black], Colors.white),
  };

  @override
  Future<Uint8List> frame(
    Uint8List png, {
    required FrameStyle style,
    required ExportFormat format,
    String caption = '',
  }) async {
    // Sans cadre, la capture (éventuellement masquée) reste telle quelle.
    if (style == FrameStyle.none) return png;

    final codec = await ui.instantiateImageCodec(png);
    final shot = (await codec.getNextFrame()).image;
    final w = format.width.toDouble();
    final h = format.height.toDouble();
    final (colors, textColor) = _palette(style);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()..shader = ui.Gradient.linear(Offset.zero, Offset(w, h), colors),
    );

    var top = h * 0.06;
    if (caption.trim().isNotEmpty) {
      final painter = TextPainter(
        text: TextSpan(
          text: caption.trim(),
          style: TextStyle(
            color: textColor,
            fontSize: w * 0.06,
            fontWeight: FontWeight.w700,
            height: 1.2,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
        maxLines: 3,
        ellipsis: '…',
      )..layout(maxWidth: w * 0.86);
      painter.paint(canvas, Offset((w - painter.width) / 2, top));
      top += painter.height + h * 0.04;
    }

    // La capture tient dans la zone restante, proportions conservées.
    final areaW = w * 0.86;
    final areaH = h - top - h * 0.05;
    final scale = [
      areaW / shot.width,
      areaH / shot.height,
    ].reduce((a, b) => a < b ? a : b);
    final dw = shot.width * scale;
    final dh = shot.height * scale;
    final dst = Rect.fromLTWH((w - dw) / 2, top, dw, dh);
    canvas
      ..save()
      ..clipRRect(RRect.fromRectAndRadius(dst, Radius.circular(w * 0.04)))
      ..drawImageRect(
        shot,
        Rect.fromLTWH(0, 0, shot.width.toDouble(), shot.height.toDouble()),
        dst,
        Paint()..filterQuality = FilterQuality.high,
      )
      ..restore();

    final image = await recorder.endRecording().toImage(
      format.width,
      format.height,
    );
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data!.buffer.asUint8List();
  }
}
