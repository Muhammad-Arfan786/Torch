import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  // Create a 1024x1024 icon
  final size = 1024;
  final image = img.Image(width: size, height: size);

  // Background gradient - dark orange to black
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      // Radial gradient from center
      final centerX = size / 2;
      final centerY = size / 2;
      final distance = ((x - centerX) * (x - centerX) + (y - centerY) * (y - centerY));
      final maxDistance = centerX * centerX + centerY * centerY;
      final ratio = distance / maxDistance;

      // Orange to dark gradient
      final r = (255 * (1 - ratio * 0.7)).toInt().clamp(40, 255);
      final g = (140 * (1 - ratio * 0.8)).toInt().clamp(20, 140);
      final b = (30 * (1 - ratio * 0.9)).toInt().clamp(10, 50);

      image.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  // Draw flashlight body (rectangle)
  final bodyLeft = (size * 0.35).toInt();
  final bodyRight = (size * 0.65).toInt();
  final bodyTop = (size * 0.45).toInt();
  final bodyBottom = (size * 0.85).toInt();

  // Flashlight body - dark gray
  for (int y = bodyTop; y < bodyBottom; y++) {
    for (int x = bodyLeft; x < bodyRight; x++) {
      image.setPixelRgba(x, y, 60, 60, 70, 255);
    }
  }

  // Draw flashlight head (wider top)
  final headLeft = (size * 0.28).toInt();
  final headRight = (size * 0.72).toInt();
  final headTop = (size * 0.30).toInt();
  final headBottom = (size * 0.48).toInt();

  for (int y = headTop; y < headBottom; y++) {
    for (int x = headLeft; x < headRight; x++) {
      image.setPixelRgba(x, y, 80, 80, 90, 255);
    }
  }

  // Draw light beam (yellow glow at top)
  final beamCenterX = size / 2;
  final beamCenterY = size * 0.18;
  final beamRadius = size * 0.22;

  for (int y = 0; y < (size * 0.35).toInt(); y++) {
    for (int x = (size * 0.2).toInt(); x < (size * 0.8).toInt(); x++) {
      final dx = x - beamCenterX;
      final dy = y - beamCenterY;
      final dist = (dx * dx + dy * dy);
      final maxDist = beamRadius * beamRadius;

      if (dist < maxDist) {
        final intensity = 1 - (dist / maxDist);
        final alpha = (255 * intensity * intensity).toInt().clamp(0, 255);

        if (alpha > 30) {
          // Blend yellow light
          final existing = image.getPixel(x, y);
          final newR = ((existing.r * (255 - alpha) + 255 * alpha) / 255).toInt().clamp(0, 255);
          final newG = ((existing.g * (255 - alpha) + 230 * alpha) / 255).toInt().clamp(0, 255);
          final newB = ((existing.b * (255 - alpha) + 100 * alpha) / 255).toInt().clamp(0, 255);
          image.setPixelRgba(x, y, newR, newG, newB, 255);
        }
      }
    }
  }

  // Draw lens (glass circle)
  final lensX = size ~/ 2;
  final lensY = (size * 0.38).toInt();
  final lensRadius = (size * 0.12).toInt();

  for (int y = lensY - lensRadius; y < lensY + lensRadius; y++) {
    for (int x = lensX - lensRadius; x < lensX + lensRadius; x++) {
      final dx = x - lensX;
      final dy = y - lensY;
      if (dx * dx + dy * dy < lensRadius * lensRadius) {
        // Light yellow/white for lens
        image.setPixelRgba(x, y, 255, 240, 180, 255);
      }
    }
  }

  // Draw button on body
  final btnX = size ~/ 2;
  final btnY = (size * 0.62).toInt();
  final btnRadius = (size * 0.04).toInt();

  for (int y = btnY - btnRadius; y < btnY + btnRadius; y++) {
    for (int x = btnX - btnRadius; x < btnX + btnRadius; x++) {
      final dx = x - btnX;
      final dy = y - btnY;
      if (dx * dx + dy * dy < btnRadius * btnRadius) {
        image.setPixelRgba(x, y, 255, 180, 50, 255);
      }
    }
  }

  // Add rounded corners effect by making corner pixels transparent
  final cornerRadius = (size * 0.15).toInt();
  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      bool isCorner = false;

      // Top-left corner
      if (x < cornerRadius && y < cornerRadius) {
        final dx = cornerRadius - x;
        final dy = cornerRadius - y;
        if (dx * dx + dy * dy > cornerRadius * cornerRadius) isCorner = true;
      }
      // Top-right corner
      if (x > size - cornerRadius && y < cornerRadius) {
        final dx = x - (size - cornerRadius);
        final dy = cornerRadius - y;
        if (dx * dx + dy * dy > cornerRadius * cornerRadius) isCorner = true;
      }
      // Bottom-left corner
      if (x < cornerRadius && y > size - cornerRadius) {
        final dx = cornerRadius - x;
        final dy = y - (size - cornerRadius);
        if (dx * dx + dy * dy > cornerRadius * cornerRadius) isCorner = true;
      }
      // Bottom-right corner
      if (x > size - cornerRadius && y > size - cornerRadius) {
        final dx = x - (size - cornerRadius);
        final dy = y - (size - cornerRadius);
        if (dx * dx + dy * dy > cornerRadius * cornerRadius) isCorner = true;
      }

      if (isCorner) {
        image.setPixelRgba(x, y, 0, 0, 0, 0);
      }
    }
  }

  // Save the icon
  final pngBytes = img.encodePng(image);
  File('assets/icon.png').writeAsBytesSync(pngBytes);
  print('Icon generated: assets/icon.png');
}
