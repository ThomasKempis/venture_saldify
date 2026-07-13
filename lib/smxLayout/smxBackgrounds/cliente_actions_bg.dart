import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';

class ClienteActionsBg extends StatelessWidget {
  const ClienteActionsBg({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: ClienteActionsBgPainter());
  }
}

class ClienteActionsBgPainter extends CustomPainter {
  const ClienteActionsBgPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * .90, size.height * .06),
      size.shortestSide * .34,
      Paint()..color = SmxColors.brandSecondary.withValues(alpha: .10),
    );
    canvas.drawCircle(
      Offset(size.width * .82, size.height * .94),
      size.shortestSide * .30,
      Paint()..color = SmxColors.brandPrimary.withValues(alpha: .045),
    );
    canvas.drawCircle(
      Offset(size.width * .10, size.height * .32),
      size.shortestSide * .22,
      Paint()..color = SmxColors.whiteAlpha(.38),
    );
    canvas.drawCircle(
      Offset(size.width * .16, size.height * .94),
      size.shortestSide * .18,
      Paint()..color = SmxColors.brandSecondary.withValues(alpha: .05),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
