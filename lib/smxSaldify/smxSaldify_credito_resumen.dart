import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

import '../smxLayout/smxColors.dart';

class SmxSaldiFyCreditoResumen extends StatelessWidget {
  final double credito;
  final double disponible;
  final double compras;
  final double pagos;
  final double saldo;
  final bool saldoEnDeuda;

  const SmxSaldiFyCreditoResumen({
    super.key,
    required this.credito,
    required this.disponible,
    required this.compras,
    required this.pagos,
    required this.saldo,
    this.saldoEnDeuda = false,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 660;
        final comprasCard = _ResumenMetricData(
          label: 'Compras',
          value: compras,
          note: 'Realizadas',
          color: const Color(0xFF65B8FF),
        );
        final pagosCard = _ResumenMetricData(
          label: 'Pagos',
          value: pagos,
          note: 'Recibidos',
          color: const Color(0xFF22C55E),
        );
        final saldoCard = _ResumenMetricData(
          label: 'Saldo',
          value: saldo,
          note: saldoEnDeuda ? 'Deudor' : 'Pendiente',
          color: _saldoColor,
        );
        final disponibleCard = _ResumenMetricData(
          label: 'Disponible',
          value: disponible,
          note: 'Para usar',
          color: const Color(0xFF72E6C5),
        );

        if (isCompact) {
          return _CreditoCompactCard(
            credito: credito,
            disponible: disponible,
            saldo: saldo,
            saldoEnDeuda: saldoEnDeuda,
            cards: [comprasCard, pagosCard, saldoCard, disponibleCard],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 9,
              child: _CreditoRadialCard(
                credito: credito,
                disponible: disponible,
                saldo: saldo,
                saldoEnDeuda: saldoEnDeuda,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 11,
              child: _MetricasResumenGrid(
                cards: [comprasCard, pagosCard, saldoCard, disponibleCard],
                columns: 2,
              ),
            ),
          ],
        );
      },
    );
  }

  Color get _saldoColor {
    if (saldoEnDeuda && saldo > 0) return SmxColors.dangerForeground;

    if (credito <= 0 || saldo <= 0) return SmxColors.brandAccent;

    final usage = saldo / credito;
    if (usage >= .9) return SmxColors.dangerForeground;

    return const Color(0xFFFFC857);
  }
}

class _CreditoRadialCard extends StatelessWidget {
  final double credito;
  final double disponible;
  final double saldo;
  final bool saldoEnDeuda;

  const _CreditoRadialCard({
    required this.credito,
    required this.disponible,
    required this.saldo,
    required this.saldoEnDeuda,
  });

  @override
  Widget build(BuildContext context) {
    final disponiblePercent = credito <= 0
        ? 0.0
        : (disponible / credito).clamp(0.0, 1.0).toDouble();
    final usadoPercent = credito <= 0
        ? 0.0
        : (saldo / credito).clamp(0.0, 1.0).toDouble();

    return Container(
      constraints: const BoxConstraints(minHeight: 240),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SmxColors.whiteAlpha(.18)),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.14),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _CreditoRadialVisual(
            credito: credito,
            disponiblePercent: disponiblePercent,
            usadoPercent: usadoPercent,
            usadoColor: saldoEnDeuda
                ? SmxColors.dangerForeground
                : const Color(0xFFFFC857),
            size: 176,
            creditFontSize: 32,
            percentFontSize: 13,
          ),
        ],
      ),
    );
  }
}

class _CreditoCompactCard extends StatelessWidget {
  final double credito;
  final double disponible;
  final double saldo;
  final bool saldoEnDeuda;
  final List<_ResumenMetricData> cards;

  const _CreditoCompactCard({
    required this.credito,
    required this.disponible,
    required this.saldo,
    required this.saldoEnDeuda,
    required this.cards,
  });

  @override
  Widget build(BuildContext context) {
    final disponiblePercent = credito <= 0
        ? 0.0
        : (disponible / credito).clamp(0.0, 1.0).toDouble();
    final usadoPercent = credito <= 0
        ? 0.0
        : (saldo / credito).clamp(0.0, 1.0).toDouble();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.13),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: SmxColors.whiteAlpha(.18)),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.14),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _CreditoRadialVisual(
            credito: credito,
            disponiblePercent: disponiblePercent,
            usadoPercent: usadoPercent,
            usadoColor: saldoEnDeuda
                ? SmxColors.dangerForeground
                : const Color(0xFFFFC857),
            size: 132,
            creditFontSize: 22,
            percentFontSize: 10,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                mainAxisExtent: 62,
              ),
              itemCount: cards.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final card = cards[index];

                return _ResumenMetricCard(
                  data: card,
                  compact: true,
                  showNote: false,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CreditoRadialVisual extends StatelessWidget {
  final double credito;
  final double disponiblePercent;
  final double usadoPercent;
  final Color usadoColor;
  final double size;
  final double creditFontSize;
  final double percentFontSize;

  const _CreditoRadialVisual({
    required this.credito,
    required this.disponiblePercent,
    required this.usadoPercent,
    required this.usadoColor,
    required this.size,
    required this.creditFontSize,
    required this.percentFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: _CreditoRadialPainter(
          disponiblePercent: disponiblePercent,
          usadoPercent: usadoPercent,
          usadoColor: usadoColor,
        ),
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(size * .2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Credito',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: SmxColors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: size * .04),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      SmxRowSet.formatAmount(credito),
                      style: TextStyle(
                        color: SmxColors.white,
                        fontSize: creditFontSize,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                  ),
                  SizedBox(height: size * .04),
                  Text(
                    '${(disponiblePercent * 100).round()}% disponible',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: SmxColors.brandAccent,
                      fontSize: percentFontSize,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MetricasResumenGrid extends StatelessWidget {
  final List<_ResumenMetricData> cards;
  final int columns;

  const _MetricasResumenGrid({required this.cards, required this.columns});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 114,
      ),
      itemCount: cards.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final card = cards[index];

        return _ResumenMetricCard(data: card);
      },
    );
  }
}

class _ResumenMetricCard extends StatelessWidget {
  final _ResumenMetricData data;
  final bool compact;
  final bool showNote;

  const _ResumenMetricCard({
    required this.data,
    this.compact = false,
    this.showNote = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.13),
        borderRadius: BorderRadius.circular(compact ? 14 : 18),
        border: Border.all(color: SmxColors.whiteAlpha(.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: compact ? 8 : 9,
                height: compact ? 8 : 9,
                decoration: BoxDecoration(
                  color: data.color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: data.color.withValues(alpha: .42),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: SmxColors.white70,
                    fontSize: compact ? 11 : 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              SmxRowSet.formatAmount(data.value),
              style: TextStyle(
                color: SmxColors.white,
                fontSize: compact ? 20 : 26,
                fontWeight: FontWeight.w900,
                height: 1,
              ),
            ),
          ),
          if (showNote)
            Text(
              data.note,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: data.color,
                fontSize: compact ? 11 : 12,
                fontWeight: FontWeight.w900,
              ),
            ),
        ],
      ),
    );
  }
}

class _CreditoRadialPainter extends CustomPainter {
  final double disponiblePercent;
  final double usadoPercent;
  final Color usadoColor;

  const _CreditoRadialPainter({
    required this.disponiblePercent,
    required this.usadoPercent,
    required this.usadoColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = math.min(size.width, size.height);
    final strokeWidth = shortest * .085;
    final radius = (shortest - strokeWidth) / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    const fullSweep = math.pi * 2;

    final basePaint = Paint()
      ..color = SmxColors.whiteAlpha(.14)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final disponiblePaint = Paint()
      ..color = const Color(0xFF72E6C5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final usadoPaint = Paint()
      ..color = usadoColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * .72
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, fullSweep, false, basePaint);

    if (disponiblePercent > 0) {
      canvas.drawArc(
        rect,
        startAngle,
        fullSweep * disponiblePercent,
        false,
        disponiblePaint,
      );
    }

    if (usadoPercent > 0) {
      canvas.drawArc(
        rect.deflate(strokeWidth * .9),
        startAngle + fullSweep * disponiblePercent + .18,
        fullSweep * usadoPercent,
        false,
        usadoPaint,
      );
    }

    final glowPaint = Paint()
      ..color = SmxColors.brandAccent.withValues(alpha: .08)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * .62, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _CreditoRadialPainter oldDelegate) {
    return oldDelegate.disponiblePercent != disponiblePercent ||
        oldDelegate.usadoPercent != usadoPercent ||
        oldDelegate.usadoColor != usadoColor;
  }
}

class _ResumenMetricData {
  final String label;
  final double value;
  final String note;
  final Color color;

  const _ResumenMetricData({
    required this.label,
    required this.value,
    required this.note,
    required this.color,
  });
}
