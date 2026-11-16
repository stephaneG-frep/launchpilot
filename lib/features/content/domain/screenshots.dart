import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Emplacements de captures dans les stores.
enum ScreenshotSlot { playPhone, iphone69, iphone65, ipad13 }

@immutable
class StoreSize {
  const StoreSize(this.width, this.height);
  final int width;
  final int height;

  @override
  String toString() => '$width × $height';
}

/// Tailles exactes acceptées par l'App Store (portrait ; paysage = inversé).
const appStoreSizes = {
  ScreenshotSlot.iphone69: [StoreSize(1320, 2868), StoreSize(1290, 2796)],
  ScreenshotSlot.iphone65: [StoreSize(1284, 2778), StoreSize(1242, 2688)],
  ScreenshotSlot.ipad13: [StoreSize(2064, 2752), StoreSize(2048, 2732)],
};

/// Compatibilité d'une capture avec chaque emplacement.
Map<ScreenshotSlot, bool> checkScreenshot(int width, int height) {
  final short = width < height ? width : height;
  final long = width < height ? height : width;
  bool exact(List<StoreSize> sizes) => sizes.any(
    (s) =>
        (s.width == width && s.height == height) ||
        (s.width == height && s.height == width),
  );
  return {
    // Play Store : côtés de 320 à 3840 px, rapport au plus 2:1.
    ScreenshotSlot.playPhone: short >= 320 && long <= 3840 && long <= 2 * short,
    for (final e in appStoreSizes.entries) e.key: exact(e.value),
  };
}

/// Zone à masquer, en coordonnées relatives (0 à 1).
@immutable
class MaskRect {
  const MaskRect(this.left, this.top, this.right, this.bottom);

  final double left;
  final double top;
  final double right;
  final double bottom;

  MaskRect normalized() => MaskRect(
    (left < right ? left : right).clamp(0.0, 1.0),
    (top < bottom ? top : bottom).clamp(0.0, 1.0),
    (left < right ? right : left).clamp(0.0, 1.0),
    (top < bottom ? bottom : top).clamp(0.0, 1.0),
  );

  bool get isEmpty =>
      (right - left).abs() < 0.005 || (bottom - top).abs() < 0.005;
}

/// Recouvre chaque zone d'un aplat opaque : contrairement à un flou, rien
/// ne peut être reconstitué. Renvoie un PNG.
Uint8List applyMasks(Uint8List bytes, List<MaskRect> masks) {
  final image = img.decodeImage(bytes);
  if (image == null) throw const FormatException('image illisible');
  final color = img.ColorRgba8(32, 36, 56, 255);
  for (final raw in masks) {
    final m = raw.normalized();
    if (m.isEmpty) continue;
    img.fillRect(
      image,
      x1: (m.left * image.width).floor(),
      y1: (m.top * image.height).floor(),
      x2: (m.right * image.width).ceil() - 1,
      y2: (m.bottom * image.height).ceil() - 1,
      color: color,
      alphaBlend: false,
    );
  }
  return img.encodePng(image);
}

/// Dimensions d'une image, ou null si elle est illisible.
(int, int)? imageSize(Uint8List bytes) {
  final image = img.decodeImage(bytes);
  return image == null ? null : (image.width, image.height);
}
