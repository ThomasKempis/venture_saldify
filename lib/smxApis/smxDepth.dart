import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class SmxDepth extends StatelessWidget {
  final Widget child;
  final double radius;
  final double depth;
  final Color color;
  final double opacity;
  final double blurRadius;
  final bool right;
  final bool bottom;
  final bool fade;

  const SmxDepth({
    super.key,
    required this.child,
    required this.radius,
    this.depth = 8,
    this.color = Colors.white,
    this.opacity = .22,
    this.blurRadius = 14,
    this.right = true,
    this.bottom = true,
    this.fade = false,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SmxDepthPainter(
        radius: radius,
        depth: depth,
        color: color,
        opacity: opacity,
        blurRadius: blurRadius,
        right: right,
        bottom: bottom,
        fade: fade,
      ),
      child: child,
    );
  }
}

class _SmxDepthPainter extends CustomPainter {
  final double radius;
  final double depth;
  final Color color;
  final double opacity;
  final double blurRadius;
  final bool right;
  final bool bottom;
  final bool fade;

  const _SmxDepthPainter({
    required this.radius,
    required this.depth,
    required this.color,
    required this.opacity,
    required this.blurRadius,
    required this.right,
    required this.bottom,
    required this.fade,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (depth <= 0 || opacity <= 0 || (!right && !bottom)) return;

    final baseColor = color.withValues(alpha: opacity);
    final shadowColor = Colors.black.withValues(alpha: opacity * .32);
    final rect = Offset.zero & size;
    final shiftedRect = rect.shift(Offset(depth, depth));
    final baseRRect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final shiftedRRect = RRect.fromRectAndRadius(
      shiftedRect,
      Radius.circular(radius),
    );

    final depthPath = Path()
      ..addRRect(shiftedRRect)
      ..addRRect(baseRRect)
      ..fillType = PathFillType.evenOdd;

    if (!(right && bottom)) {
      final clipPath = Path();
      if (right) {
        clipPath.addRect(
          Rect.fromLTWH(size.width, 0, depth + blurRadius, size.height + depth),
        );
      }
      if (bottom) {
        clipPath.addRect(
          Rect.fromLTWH(0, size.height, size.width + depth, depth + blurRadius),
        );
      }
      canvas.save();
      canvas.clipPath(clipPath);
    }

    if (blurRadius > 0) {
      final shadowPaint = Paint()
        ..color = shadowColor
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius);
      canvas.drawPath(depthPath, shadowPaint);
    }

    final fillPaint = Paint()
      ..shader = fade
          ? ui.Gradient.linear(
              Offset(size.width * .78, size.height * .28),
              Offset(
                size.width + depth + blurRadius,
                size.height + depth + blurRadius,
              ),
              [
                color.withValues(alpha: opacity * .48),
                color.withValues(alpha: opacity * .18),
                color.withValues(alpha: 0),
              ],
              const [.0, .48, 1],
            )
          : ui.Gradient.linear(
              Offset(size.width * .7, size.height * .2),
              Offset(size.width + depth, size.height + depth),
              [color.withValues(alpha: opacity * .55), baseColor],
            );
    canvas.drawPath(depthPath, fillPaint);

    if (!(right && bottom)) {
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _SmxDepthPainter oldDelegate) {
    return radius != oldDelegate.radius ||
        depth != oldDelegate.depth ||
        color != oldDelegate.color ||
        opacity != oldDelegate.opacity ||
        blurRadius != oldDelegate.blurRadius ||
        right != oldDelegate.right ||
        bottom != oldDelegate.bottom ||
        fade != oldDelegate.fade;
  }
}
