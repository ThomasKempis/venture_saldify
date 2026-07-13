import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';

class OperacionBgPanel extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;

  const OperacionBgPanel({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.96),
      borderRadius: BorderRadius.circular(18),
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
            Positioned.fill(
              child: CustomPaint(painter: _OperacionBgPainter(icon: icon)),
            ),
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _OperacionCopy(title: title, subtitle: subtitle),
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

class _OperacionCopy extends StatelessWidget {
  final String title;
  final String subtitle;

  const _OperacionCopy({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Color(0xFF123247),
            fontSize: 22,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          subtitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
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

class _OperacionBgPainter extends CustomPainter {
  final IconData icon;

  const _OperacionBgPainter({required this.icon});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      Offset(size.width * .88, size.height * .16),
      size.shortestSide * .18,
      Paint()..color = const Color(0xFF58D69B).withValues(alpha: .13),
    );
    canvas.drawCircle(
      Offset(size.width * .80, size.height * .94),
      size.shortestSide * .25,
      Paint()..color = const Color(0xFF14577A).withValues(alpha: .10),
    );

    final badgeCenter = Offset(size.width * .84, 54);
    canvas.drawCircle(
      badgeCenter,
      34,
      Paint()..color = SmxColors.whiteAlpha(.72),
    );
    canvas.drawCircle(
      badgeCenter,
      22,
      Paint()..color = const Color(0xFF58D69B).withValues(alpha: .18),
    );

    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          color: const Color(0xFF14577A).withValues(alpha: .38),
          fontSize: 28,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    iconPainter.paint(
      canvas,
      badgeCenter - Offset(iconPainter.width / 2, iconPainter.height / 2),
    );

    final cardRect = Rect.fromLTWH(
      size.width * .66,
      size.height * .48,
      size.width * .25,
      64,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(cardRect, const Radius.circular(16)),
      Paint()..color = SmxColors.whiteAlpha(.52),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cardRect.left + 12, cardRect.top + 14, 48, 7),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFFFD166).withValues(alpha: .88),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cardRect.left + 12, cardRect.top + 38, 78, 6),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFF14577A).withValues(alpha: .22),
    );
  }

  @override
  bool shouldRepaint(covariant _OperacionBgPainter oldDelegate) {
    return oldDelegate.icon != icon;
  }
}
