import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';

class LogonAccessBg extends StatelessWidget {
  const LogonAccessBg({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: const LogonAccessBgPainter());
  }
}

class LogonAccessBgPainter extends CustomPainter {
  const LogonAccessBgPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final mint = Paint()
      ..color = SmxColors.brandSecondary.withValues(alpha: .10);
    final softMint = Paint()
      ..color = SmxColors.brandSecondary.withValues(alpha: .055);
    final blue = Paint()
      ..color = SmxColors.brandPrimary.withValues(alpha: .045);
    final white = Paint()..color = SmxColors.whiteAlpha(.38);

    canvas.drawCircle(
      Offset(size.width * .90, size.height * .02),
      size.shortestSide * .36,
      mint,
    );
    canvas.drawCircle(
      Offset(size.width * .04, size.height * .32),
      size.shortestSide * .24,
      white,
    );
    canvas.drawCircle(
      Offset(size.width * .88, size.height * .92),
      size.shortestSide * .30,
      blue,
    );
    canvas.drawCircle(
      Offset(size.width * .12, size.height * .94),
      size.shortestSide * .20,
      softMint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
