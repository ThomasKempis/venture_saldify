import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';

class ClienteBgInicio extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onContinue;
  final VoidCallback onArchivados;

  const ClienteBgInicio({
    super.key,
    required this.isMobile,
    required this.onContinue,
    required this.onArchivados,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.96),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onContinue,
        child: Ink(
          height: isMobile ? 360 : 330,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF7FBF8), Color(0xFFE7F6F0), Color(0xFFD9F0EC)],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(painter: _PrimerClientePainter()),
              ),
              Positioned(
                left: 22,
                right: isMobile ? 22 : 260,
                top: 24,
                child: const _IntroCopy(),
              ),
              Positioned(
                left: 22,
                bottom: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClienteBgActionButton(
                      onPressed: onArchivados,
                      label: 'Archivados',
                      icon: Icons.archive_outlined,
                      color: const Color(0xFF31566B),
                    ),
                    const SizedBox(height: 10),
                    ClienteBgActionButton(onPressed: onContinue),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ClienteBgActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final IconData icon;
  final Color color;

  const ClienteBgActionButton({
    super.key,
    required this.onPressed,
    this.label = 'Continuar',
    this.icon = Icons.arrow_forward_rounded,
    this.color = const Color(0xFF123247),
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Material(
      color: SmxColors.whiteAlpha(enabled ? .40 : .22),
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: SmxColors.whiteAlpha(.72), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF103848).withValues(alpha: .12),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: enabled ? color : color.withValues(alpha: .42),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                icon,
                color: enabled ? color : color.withValues(alpha: .42),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroCopy extends StatelessWidget {
  const _IntroCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ingresa tu primer cliente',
          style: TextStyle(
            color: Color(0xFF123247),
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Empieza con su cuenta Gmail para llevar credito, compras y pagos.',
          style: TextStyle(
            color: Color(0xFF31566B),
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}

class _PrimerClientePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final mailPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withValues(alpha: .88);
    final mailShadow = Paint()
      ..color = const Color(0xFF0C3C4C).withValues(alpha: .10)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    final accentPaint = Paint()..color = const Color(0xFF58D69B);
    final bluePaint = Paint()..color = const Color(0xFF14577A);
    final softBluePaint = Paint()..color = const Color(0xFFBFE7EF);
    final goldPaint = Paint()..color = const Color(0xFFFFD166);

    canvas.drawCircle(
      Offset(size.width * .80, size.height * .23),
      size.shortestSide * .26,
      Paint()..color = const Color(0xFF59D9A1).withValues(alpha: .18),
    );
    canvas.drawCircle(
      Offset(size.width * .70, size.height * .82),
      size.shortestSide * .30,
      Paint()..color = const Color(0xFF1A78A0).withValues(alpha: .13),
    );

    final mailRect = Rect.fromLTWH(
      size.width * .44,
      size.height * .25,
      size.width * .42,
      size.height * .34,
    );
    final mailRRect = RRect.fromRectAndRadius(
      mailRect,
      const Radius.circular(26),
    );
    canvas.drawRRect(mailRRect.shift(const Offset(0, 12)), mailShadow);
    canvas.drawRRect(mailRRect, mailPaint);

    final flap = Path()
      ..moveTo(mailRect.left + 18, mailRect.top + 26)
      ..lineTo(mailRect.center.dx, mailRect.center.dy + 16)
      ..lineTo(mailRect.right - 18, mailRect.top + 26);
    canvas.drawPath(
      flap,
      Paint()
        ..color = const Color(0xFF9DDCCB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final personCenter = Offset(size.width * .63, size.height * .68);
    canvas.drawCircle(personCenter, size.shortestSide * .105, accentPaint);
    canvas.drawCircle(
      personCenter.translate(0, -size.shortestSide * .11),
      size.shortestSide * .065,
      bluePaint,
    );

    final creditRect = Rect.fromLTWH(
      size.width * .56,
      size.height * .64,
      size.width * .29,
      size.height * .15,
    );
    final creditRRect = RRect.fromRectAndRadius(
      creditRect,
      const Radius.circular(20),
    );
    canvas.drawRRect(creditRRect, softBluePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          creditRect.left + 16,
          creditRect.top + 18,
          creditRect.width * .28,
          10,
        ),
        const Radius.circular(5),
      ),
      goldPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          creditRect.left + 16,
          creditRect.bottom - 28,
          creditRect.width * .58,
          8,
        ),
        const Radius.circular(4),
      ),
      bluePaint..color = const Color(0xFF14577A).withValues(alpha: .42),
    );

    final gmailBadgeCenter = Offset(size.width * .86, size.height * .50);
    canvas.drawCircle(gmailBadgeCenter, 34, Paint()..color = SmxColors.white);
    canvas.drawArc(
      Rect.fromCircle(center: gmailBadgeCenter, radius: 17),
      .65,
      5,
      false,
      Paint()
        ..color = const Color(0xFFE84D3D)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      gmailBadgeCenter.translate(4, 0),
      gmailBadgeCenter.translate(19, 0),
      Paint()
        ..color = const Color(0xFFE84D3D)
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
