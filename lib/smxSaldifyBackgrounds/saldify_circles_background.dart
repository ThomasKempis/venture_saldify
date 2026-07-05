import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';

class SaldifyCirclesBackgroundPainter extends CustomPainter {
  final Color accentColor;

  const SaldifyCirclesBackgroundPainter({required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final accent = Paint()..color = accentColor.withValues(alpha: .08);
    final softAccent = Paint()..color = accentColor.withValues(alpha: .04);
    final light = Paint()..color = SmxColors.whiteAlpha(.30);
    final muted = Paint()
      ..color = const Color(0xFF14577A).withValues(alpha: .045);

    canvas.drawCircle(
      Offset(size.width * .90, size.height * .08),
      size.shortestSide * .42,
      accent,
    );
    canvas.drawCircle(
      Offset(size.width * .78, size.height * .96),
      size.shortestSide * .36,
      muted,
    );
    canvas.drawCircle(
      Offset(size.width * .18, size.height * .12),
      size.shortestSide * .24,
      light,
    );
    canvas.drawCircle(
      Offset(size.width * .04, size.height * .86),
      size.shortestSide * .28,
      softAccent,
    );
  }

  @override
  bool shouldRepaint(covariant SaldifyCirclesBackgroundPainter oldDelegate) {
    return oldDelegate.accentColor != accentColor;
  }
}
