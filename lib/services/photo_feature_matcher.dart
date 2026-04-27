import 'dart:typed_data';
import 'dart:ui' show Color;

import 'package:image/image.dart' as img;

import 'package:ez_trainz/models/avatar_config.dart';

/// Tiny, on-device heuristic that turns an uploaded photo into the
/// closest matching `AvatarConfig` preset.
///
/// This is intentionally simple so it works offline and cheap:
///   1. Decode + scale down the image (for speed).
///   2. Sample pixels from the lower-central region (likely cheek / neck)
///      to estimate skin tone.
///   3. Sample pixels from the top strip (likely hair) to estimate hair
///      color.
///   4. Snap each average to the nearest preset palette entry.
///
/// It will NOT give salon-grade accuracy, but it's enough to make the
/// "Mirror Mode" flow feel personalized while we keep the architecture
/// swappable for a real ML/avatar service later.
class PhotoFeatureMatcher {
  static const int _workingSize = 128;

  /// Returns a best-guess `AvatarConfig` derived from the given image
  /// bytes, or null if the image couldn't be decoded.
  static Future<AvatarConfig?> match(Uint8List bytes,
      {String? displayName}) async {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    // Scale to a predictable working size to make sampling O(1) w.r.t. input.
    final resized = img.copyResize(
      decoded,
      width: _workingSize,
      height: _workingSize,
      interpolation: img.Interpolation.average,
    );

    final skin = _averageRegion(
      resized,
      xStart: 0.30, xEnd: 0.70,
      yStart: 0.55, yEnd: 0.80,
    );
    final hair = _averageRegion(
      resized,
      xStart: 0.25, xEnd: 0.75,
      yStart: 0.05, yEnd: 0.25,
    );

    final skinTone = _snapTo(skin, AvatarPresets.skinTones);
    final hairColor = _snapTo(hair, AvatarPresets.hairColors);

    // Pick a hair style based on brightness of the hair strip: very dark
    // regions ~ long/dense hair; lighter ~ short. This is a cheap proxy
    // for "hair coverage" that works without face detection.
    final hairLuma = _luma(hair);
    final HairStyle style;
    if (hairLuma < 60) {
      style = HairStyle.long;
    } else if (hairLuma < 140) {
      style = HairStyle.bun;
    } else {
      style = HairStyle.short;
    }

    return AvatarConfig(
      skinTone: skinTone,
      hairColor: hairColor,
      hairStyle: style,
      displayName: displayName,
    );
  }

  static Color _averageRegion(
    img.Image image, {
    required double xStart,
    required double xEnd,
    required double yStart,
    required double yEnd,
  }) {
    final x0 = (image.width * xStart).floor();
    final x1 = (image.width * xEnd).ceil();
    final y0 = (image.height * yStart).floor();
    final y1 = (image.height * yEnd).ceil();

    int r = 0, g = 0, b = 0, n = 0;
    for (int y = y0; y < y1; y++) {
      for (int x = x0; x < x1; x++) {
        final px = image.getPixel(x, y);
        r += px.r.toInt();
        g += px.g.toInt();
        b += px.b.toInt();
        n++;
      }
    }
    if (n == 0) return const Color(0xFF808080);
    return Color.fromARGB(255, r ~/ n, g ~/ n, b ~/ n);
  }

  static Color _snapTo(Color target, List<Color> palette) {
    Color best = palette.first;
    double bestDist = double.infinity;
    for (final c in palette) {
      final d = _rgbDistanceSq(target, c);
      if (d < bestDist) {
        bestDist = d;
        best = c;
      }
    }
    return best;
  }

  static double _rgbDistanceSq(Color a, Color b) {
    final dr = _r(a) - _r(b);
    final dg = _g(a) - _g(b);
    final db = _b(a) - _b(b);
    return (dr * dr + dg * dg + db * db).toDouble();
  }

  static int _r(Color c) => (c.r * 255.0).round();
  static int _g(Color c) => (c.g * 255.0).round();
  static int _b(Color c) => (c.b * 255.0).round();

  /// Perceptual luminance (Rec. 601).
  static int _luma(Color c) =>
      (0.299 * _r(c) + 0.587 * _g(c) + 0.114 * _b(c)).round();
}
