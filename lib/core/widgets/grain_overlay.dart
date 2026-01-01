import 'dart:math';

import 'package:flutter/material.dart';

/// A programmatic film grain texture overlay for atmospheric effect.
///
/// Creates a subtle noise pattern using random pixels to simulate
/// analog film grain. Optimized for performance with controllable
/// opacity and grain density.
class GrainOverlay extends StatefulWidget {
  /// Opacity of the grain effect (0.0 to 1.0).
  /// Recommended: 0.02 - 0.05 for subtle effect.
  final double opacity;

  /// Density of grain particles (0.0 to 1.0).
  /// Higher values create more visible grain.
  /// Recommended: 0.3 - 0.5 for balanced effect.
  final double density;

  const GrainOverlay({super.key, this.opacity = 0.03, this.density = 0.4});

  @override
  State<GrainOverlay> createState() => _GrainOverlayState();
}

class _GrainOverlayState extends State<GrainOverlay> {
  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: Opacity(
          opacity: widget.opacity,
          child: CustomPaint(painter: _GrainPainter(density: widget.density)),
        ),
      ),
    );
  }
}

class _GrainPainter extends CustomPainter {
  final double density;
  final Random _random = Random(42); // Fixed seed for consistent pattern

  _GrainPainter({required this.density});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Calculate grain count based on screen size and density
    // ~1 grain per 4x4 pixels at density 1.0
    final grainCount = (size.width * size.height * density / 16).toInt();

    // Draw random grain particles
    for (int i = 0; i < grainCount; i++) {
      final x = _random.nextDouble() * size.width;
      final y = _random.nextDouble() * size.height;
      final brightness = _random.nextDouble();

      // Use varying shades of gray for natural film grain look
      paint.color = Color.fromRGBO(
        (brightness * 255).toInt(),
        (brightness * 255).toInt(),
        (brightness * 255).toInt(),
        1.0,
      );

      // Draw small grain particle (1x1 or 2x2 pixels)
      final particleSize = _random.nextBool() ? 1.0 : 2.0;
      canvas.drawRect(Rect.fromLTWH(x, y, particleSize, particleSize), paint);
    }
  }

  @override
  bool shouldRepaint(_GrainPainter oldDelegate) {
    return density != oldDelegate.density;
  }
}
