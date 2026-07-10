import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';

class AssistantHeaderBg extends StatelessWidget {
  const AssistantHeaderBg({super.key});

  @override
  Widget build(BuildContext context) {
    return const CustomPaint(painter: _AssistantHeaderBgPainter());
  }
}

class _AssistantHeaderBgPainter extends CustomPainter {
  const _AssistantHeaderBgPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final accent = Paint()
      ..color = SmxColors.brandAccent.withValues(alpha: .08);
    final softAccent = Paint()
      ..color = SmxColors.brandAccent.withValues(alpha: .04);
    final light = Paint()..color = SmxColors.whiteAlpha(.30);
    final muted = Paint()
      ..color = const Color(0xFF14577A).withValues(alpha: .045);

    canvas.drawCircle(
      Offset(size.width * .92, size.height * .14),
      size.shortestSide * .42,
      accent,
    );
    canvas.drawCircle(
      Offset(size.width * .78, size.height * .96),
      size.shortestSide * .36,
      muted,
    );
    canvas.drawCircle(
      Offset((size.width * .34) + 100, size.height * -.02),
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
  bool shouldRepaint(covariant _AssistantHeaderBgPainter oldDelegate) {
    return false;
  }
}
