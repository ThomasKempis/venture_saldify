import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';

class SmxSaldiFyClienteInvitacionEstado extends StatelessWidget {
  static const String anfitrionUrl = 'https://venture.jars.mx/venture_saldify';

  final String title;
  final String mensaje;

  const SmxSaldiFyClienteInvitacionEstado({
    super.key,
    required this.title,
    required this.mensaje,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SmxColors.transparent,
      body: SmxSaldifyBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 520;
              final maxWidth = compact ? constraints.maxWidth : 760.0;

              final horizontalPadding = compact ? 22.0 : 36.0;
              final topPadding = compact ? 0.0 : 36.0;
              final bottomPadding = compact ? 24.0 : 36.0;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  topPadding,
                  horizontalPadding,
                  bottomPadding,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight -
                        MediaQuery.of(context).padding.vertical -
                        topPadding -
                        bottomPadding,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: maxWidth),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _SaldifyBrand(compact: compact),
                          _InvitationGraphic(compact: compact),
                          _InvitationInfoCard(
                            title: title,
                            mensaje: mensaje,
                            compact: compact,
                          ),
                          SizedBox(height: compact ? 18 : 22),
                          _AnfitrionButton(onTap: _openAnfitrionLink),
                          const SizedBox(height: 12),
                          const _ContactHint(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _openAnfitrionLink() async {
    final uri = Uri.parse(anfitrionUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _SaldifyBrand extends StatelessWidget {
  final bool compact;

  const _SaldifyBrand({required this.compact});

  @override
  Widget build(BuildContext context) {
    final logoSize = compact ? 78.0 : 96.0;
    final logoWidth = logoSize * 266 / 386;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Transform.translate(
          offset: Offset(0, compact ? -7 : -9),
          child: SizedBox(
            width: logoWidth,
            height: logoSize,
            child: Image.asset(
              'assets/images/logo_logon_trimmed.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SALDIFY',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: SmxColors.white,
                fontFamily: 'Segoe UI',
                fontFamilyFallback: const [
                  'Tahoma',
                  'Geneva',
                  'Verdana',
                  'Arial',
                ],
                fontSize: compact ? 38 : 48,
                fontWeight: FontWeight.w800,
                height: .98,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'CLIENT CREDIT PORTAL',
              textAlign: TextAlign.left,
              style: TextStyle(
                color: SmxColors.brandAccent,
                fontFamily: 'Segoe UI',
                fontSize: compact ? 13 : 15,
                fontWeight: FontWeight.w800,
                height: 1.1,
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _InvitationGraphic extends StatelessWidget {
  final bool compact;

  const _InvitationGraphic({required this.compact});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: compact ? 170 : 220,
      child: CustomPaint(painter: _InvitationGraphicPainter()),
    );
  }
}

class _InvitationGraphicPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final unit = size.shortestSide;

    final glow = Paint()
      ..color = SmxColors.whiteAlpha(.16)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);
    canvas.drawCircle(center, unit * .45, glow);

    final nodePaint = Paint()..color = SmxColors.whiteAlpha(.92);
    final nodeStroke = Paint()
      ..color = SmxColors.brandAccent.withValues(alpha: .55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final left = Offset(size.width * .24, size.height * .48);
    final right = Offset(size.width * .76, size.height * .48);

    _drawDottedLine(canvas, left, right);
    canvas.drawCircle(left, unit * .13, nodePaint);
    canvas.drawCircle(right, unit * .13, nodePaint);
    canvas.drawCircle(left, unit * .13, nodeStroke);
    canvas.drawCircle(right, unit * .13, nodeStroke);

    _drawPerson(canvas, left, unit);
    _drawBuilding(canvas, right, unit);

    final cardRect = Rect.fromCenter(
      center: center.translate(0, -unit * .03),
      width: unit * .62,
      height: unit * .42,
    );
    final cardRRect = RRect.fromRectAndRadius(
      cardRect,
      Radius.circular(unit * .07),
    );
    canvas.drawRRect(cardRRect, Paint()..color = const Color(0xFFEAF5F8));
    canvas.drawRRect(
      cardRRect,
      Paint()
        ..color = SmxColors.whiteAlpha(.60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    final linkPaint = Paint()
      ..color = const Color(0xFF14577A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * .035
      ..strokeCap = StrokeCap.round;
    final warningPaint = Paint()
      ..color = SmxColors.warningForeground
      ..style = PaintingStyle.stroke
      ..strokeWidth = unit * .035
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCenter(
        center: center.translate(-unit * .10, 0),
        width: unit * .20,
        height: unit * .15,
      ),
      2.55,
      3.0,
      false,
      linkPaint,
    );
    canvas.drawArc(
      Rect.fromCenter(
        center: center.translate(unit * .10, 0),
        width: unit * .20,
        height: unit * .15,
      ),
      -0.60,
      3.0,
      false,
      linkPaint,
    );
    canvas.drawLine(
      center.translate(-unit * .03, -unit * .13),
      center.translate(unit * .03, unit * .13),
      warningPaint,
    );

    final lockRect = Rect.fromCenter(
      center: center.translate(unit * .27, -unit * .18),
      width: unit * .22,
      height: unit * .18,
    );
    _drawLock(canvas, lockRect);
  }

  void _drawDottedLine(Canvas canvas, Offset start, Offset end) {
    final paint = Paint()
      ..color = SmxColors.whiteAlpha(.42)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const segments = 18;
    for (var i = 0; i < segments; i += 2) {
      final a = Offset.lerp(start, end, i / segments)!;
      final b = Offset.lerp(start, end, (i + 1) / segments)!;
      canvas.drawLine(a, b, paint);
    }
  }

  void _drawPerson(Canvas canvas, Offset center, double unit) {
    final paint = Paint()..color = const Color(0xFF0F7C62);
    canvas.drawCircle(center.translate(0, -unit * .04), unit * .035, paint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: center.translate(0, unit * .05),
          width: unit * .14,
          height: unit * .08,
        ),
        Radius.circular(unit * .04),
      ),
      paint,
    );
  }

  void _drawBuilding(Canvas canvas, Offset center, double unit) {
    final paint = Paint()..color = const Color(0xFF123247);
    final rect = Rect.fromCenter(
      center: center.translate(0, unit * .01),
      width: unit * .13,
      height: unit * .14,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(unit * .015)),
      paint,
    );
    for (var col = -1; col <= 1; col++) {
      for (var row = -1; row <= 1; row++) {
        canvas.drawCircle(
          center.translate(col * unit * .032, row * unit * .030),
          unit * .006,
          Paint()..color = SmxColors.brandAccent,
        );
      }
    }
  }

  void _drawLock(Canvas canvas, Rect rect) {
    final body = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        rect.left,
        rect.top + rect.height * .38,
        rect.width,
        rect.height * .58,
      ),
      Radius.circular(rect.width * .16),
    );
    canvas.drawRRect(body, Paint()..color = SmxColors.warningBackground);
    canvas.drawRRect(
      body,
      Paint()
        ..color = SmxColors.warningForeground
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        rect.left + rect.width * .22,
        rect.top,
        rect.width * .56,
        rect.height * .64,
      ),
      3.14,
      3.14,
      false,
      Paint()
        ..color = SmxColors.warningForeground
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _InvitationInfoCard extends StatelessWidget {
  final String title;
  final String mensaje;
  final bool compact;

  const _InvitationInfoCard({
    required this.title,
    required this.mensaje,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 18 : 24),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF5F8).withValues(alpha: .96),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: SmxColors.whiteAlpha(.65)),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.18),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Ops... lo siento',
            style: TextStyle(
              color: SmxColors.warningForeground,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: SmxColors.textDark,
              fontSize: compact ? 25 : 32,
              height: 1.05,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            mensaje,
            style: const TextStyle(
              color: SmxColors.textDark,
              fontSize: 14,
              height: 1.45,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          const _InfoParagraph(
            text:
                'Saldify es una aplicacion B2B. Para acceder como cliente invitado debe existir un vinculo activo entre una empresa anfitriona y su cliente.',
          ),
          const SizedBox(height: 10),
          const _InfoParagraph(
            text:
                'La plataforma ayuda a empresas y vendedores de bienes o servicios a administrar creditos, compras, pagos y saldos de sus clientes.',
          ),
        ],
      ),
    );
  }
}

class _InfoParagraph extends StatelessWidget {
  final String text;

  const _InfoParagraph({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: SmxColors.textMuted,
        fontSize: 13,
        height: 1.42,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _AnfitrionButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AnfitrionButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.brandAccent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.open_in_new_rounded, color: SmxColors.textDark),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  'Quiero ser anfitrion',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: SmxColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactHint extends StatelessWidget {
  const _ContactHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SmxColors.whiteAlpha(.14)),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, color: SmxColors.white70, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Si recibiste este link de otra persona, comunicate con quien te lo compartio para solicitar una nueva invitacion o la aprobacion correspondiente.',
              style: TextStyle(
                color: SmxColors.white70,
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
