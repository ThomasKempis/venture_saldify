import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';

class CreditoConfigBg extends StatelessWidget {
  const CreditoConfigBg({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const CreditoConfigBgPainter());
  }
}

class CreditoConfigBgPainter extends CustomPainter {
  const CreditoConfigBgPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final mint = Paint()
      ..color = SmxColors.brandSecondary.withValues(alpha: .095);
    final blue = Paint()
      ..color = SmxColors.brandPrimary.withValues(alpha: .045);
    final pale = Paint()..color = SmxColors.whiteAlpha(.34);
    final accent = Paint()
      ..color = SmxColors.brandAccent.withValues(alpha: .055);

    canvas.drawCircle(
      Offset(size.width * .92, size.height * .04),
      size.shortestSide * .38,
      mint,
    );
    canvas.drawCircle(
      Offset(size.width * .08, size.height * .30),
      size.shortestSide * .24,
      pale,
    );
    canvas.drawCircle(
      Offset(size.width * .84, size.height * .88),
      size.shortestSide * .30,
      blue,
    );
    canvas.drawCircle(
      Offset(size.width * .16, size.height * .96),
      size.shortestSide * .20,
      accent,
    );

    final linePaint = Paint()
      ..color = SmxColors.brandSecondary.withValues(alpha: .08)
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(size.width * .18, size.height * .18),
      Offset(size.width * .56, size.height * .18),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
