import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';

class HistorialLinearBg extends StatelessWidget {
  const HistorialLinearBg({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: HistorialLinearBgPainter());
  }
}

class HistorialLinearBgPainter extends CustomPainter {
  const HistorialLinearBgPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final baseRect = Offset.zero & size;
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFAFDFC), Color(0xFFEAF6F3), Color(0xFFE2F2EF)],
      ).createShader(baseRect);

    canvas.drawRect(baseRect, basePaint);

    final green = Paint()
      ..color = const Color(0xFF58D69B).withValues(alpha: .18);
    final blue = Paint()
      ..color = const Color(0xFF14577A).withValues(alpha: .12);
    final white = Paint()..color = SmxColors.whiteAlpha(.40);
    final coral = Paint()
      ..color = const Color(0xFFE84D3D).withValues(alpha: .075);

    const bandHeight = 300.0;
    final bands = (size.height / bandHeight).ceil().clamp(1, 80);

    for (var band = 0; band < bands; band++) {
      final top = band * bandHeight;
      final flip = band.isOdd;

      canvas.drawCircle(
        Offset(size.width * (flip ? .10 : .92), top + bandHeight * .18),
        size.shortestSide * .28,
        green,
      );
      canvas.drawCircle(
        Offset(size.width * (flip ? .86 : .16), top + bandHeight * .78),
        size.shortestSide * .22,
        blue,
      );
      canvas.drawCircle(
        Offset(size.width * (flip ? .30 : .72), top + bandHeight * .45),
        size.shortestSide * .13,
        white,
      );

      if (band % 3 == 1) {
        canvas.drawCircle(
          Offset(size.width * (flip ? .64 : .36), top + bandHeight * .58),
          size.shortestSide * .085,
          coral,
        );
      }
    }

    final glowHeight = (size.height * .28).clamp(120.0, 260.0);
    final topGlow = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [SmxColors.whiteAlpha(.34), SmxColors.whiteAlpha(0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, glowHeight));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, glowHeight), topGlow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
