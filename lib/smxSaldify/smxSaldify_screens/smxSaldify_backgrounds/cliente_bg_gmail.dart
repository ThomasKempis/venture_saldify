import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';

import 'cliente_bg_inicio.dart';

const double _gmailCardHeight = 410;

class ClienteBgGmail extends StatelessWidget {
  final Widget field;
  final VoidCallback? onContinue;
  final bool enabled;

  const ClienteBgGmail({
    super.key,
    required this.field,
    required this.onContinue,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.96),
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: _gmailCardHeight,
        child: Ink(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8FCFD), Color(0xFFE7F5F4), Color(0xFFDDF1EA)],
            ),
          ),
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _GmailBgPainter())),
              Padding(
                padding: const EdgeInsets.all(22),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isNarrow = constraints.maxWidth < 560;
                    final bottomInset = isNarrow ? 12.0 : 20.0;

                    return Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: isNarrow ? constraints.maxWidth : 430,
                            ),
                            child: const _GmailCopy(),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: bottomInset,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [Expanded(child: field)],
                              ),
                              const SizedBox(height: 18),
                              Align(
                                alignment: Alignment.centerRight,
                                child: ClienteBgActionButton(
                                  onPressed: enabled ? onContinue : null,
                                  label: 'Continuar',
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: constraints.maxHeight,
                          width: constraints.maxWidth,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GmailCopy extends StatelessWidget {
  const _GmailCopy();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gmail del cliente',
          style: TextStyle(
            color: Color(0xFF123247),
            fontSize: 26,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Saldify usa Gmail para identificarlo e invitarlo. Escribe solo el usuario, sin el dominio.',
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

class _GmailBgPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final red = Paint()..color = const Color(0xFFE84D3D);
    final green = Paint()..color = const Color(0xFF58D69B);
    final blue = Paint()..color = const Color(0xFF14577A);
    final yellow = Paint()..color = const Color(0xFFFFD166);

    canvas.drawCircle(
      Offset(size.width * .82, size.height * .20),
      size.shortestSide * .24,
      Paint()..color = const Color(0xFF58D69B).withValues(alpha: .16),
    );
    canvas.drawCircle(
      Offset(size.width * .72, size.height * .98),
      size.shortestSide * .30,
      Paint()..color = const Color(0xFF14577A).withValues(alpha: .12),
    );

    final mailHeight = (size.height * .20).clamp(80.0, 92.0).toDouble();
    final mailRect = Rect.fromLTWH(
      size.width * .55,
      124,
      size.width * .32,
      mailHeight,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(mailRect, const Radius.circular(24)),
      Paint()..color = SmxColors.whiteAlpha(.88),
    );
    canvas.drawPath(
      Path()
        ..moveTo(mailRect.left + 18, mailRect.top + 28)
        ..lineTo(mailRect.center.dx, mailRect.center.dy + 18)
        ..lineTo(mailRect.right - 18, mailRect.top + 28),
      Paint()
        ..color = const Color(0xFF8AD7C2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );

    final leftVisualSpaceCenter = Offset(
      mailRect.left - 96,
      mailRect.center.dy,
    );
    final badgeCenter = leftVisualSpaceCenter.translate(16, 0);
    canvas.drawCircle(badgeCenter, 26, Paint()..color = SmxColors.white);
    canvas.drawArc(
      Rect.fromCircle(center: badgeCenter, radius: 13),
      .65,
      5,
      false,
      Paint()
        ..color = red.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawLine(
      badgeCenter.translate(4, 0),
      badgeCenter.translate(15, 0),
      Paint()
        ..color = red.color
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(leftVisualSpaceCenter.translate(-48, -10), 10, green);
    canvas.drawCircle(Offset(size.width * .91, size.height * .34), 8, yellow);
    canvas.drawCircle(Offset(size.width * .60, size.height * .80), 7, blue);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
