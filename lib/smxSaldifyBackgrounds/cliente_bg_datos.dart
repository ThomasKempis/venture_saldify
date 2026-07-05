import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';

class ClienteBgDatos extends StatelessWidget {
  final Widget child;

  const ClienteBgDatos({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.96),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF9FBFD), Color(0xFFEAF5F6), Color(0xFFE3F3EA)],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _DatosBgPainter())),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _DatosCopy(),
                  const SizedBox(height: 18),
                  child,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DatosCopy extends StatelessWidget {
  const _DatosCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Datos del cliente',
          style: TextStyle(
            color: Color(0xFF123247),
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Completa su perfil para administrar credito, compras y pagos.',
          style: TextStyle(
            color: Color(0xFF31566B),
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _DatosBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * .86, size.height * .16),
      size.shortestSide * .20,
      Paint()..color = const Color(0xFF58D69B).withValues(alpha: .13),
    );
    canvas.drawCircle(
      Offset(size.width * .78, size.height * .92),
      size.shortestSide * .26,
      Paint()..color = const Color(0xFF14577A).withValues(alpha: .10),
    );

    final personCenter = Offset(size.width * .84, size.height * .30);
    canvas.drawCircle(
      personCenter,
      34,
      Paint()..color = SmxColors.whiteAlpha(.86),
    );
    canvas.drawCircle(
      personCenter.translate(0, -14),
      13,
      Paint()..color = const Color(0xFF14577A),
    );
    canvas.drawCircle(
      personCenter.translate(0, 16),
      21,
      Paint()..color = const Color(0xFF58D69B),
    );

    final cardRect = Rect.fromLTWH(
      size.width * .64,
      size.height * .44,
      size.width * .28,
      74,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cardRect, const Radius.circular(18)),
      Paint()..color = SmxColors.whiteAlpha(.64),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cardRect.left + 14, cardRect.top + 16, 54, 8),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFFFD166),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cardRect.left + 14, cardRect.top + 42, 92, 7),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF14577A).withValues(alpha: .28),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
