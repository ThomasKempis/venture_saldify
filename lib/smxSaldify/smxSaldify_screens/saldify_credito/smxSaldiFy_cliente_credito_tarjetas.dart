import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';

class SmxSaldiFyCreditoPlanSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onSelected;

  const SmxSaldiFyCreditoPlanSelector({
    super.key,
    required this.value,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Selecciona como se libera el credito',
          style: TextStyle(
            color: SmxColors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Elige una forma simple para manejar pagos y disponible.',
          style: TextStyle(
            color: SmxColors.white70,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final isSingleColumn = constraints.maxWidth < 720;
            final cards = [
              SmxSaldiFyCreditoPlanCard(
                selected: value == 1,
                title: 'Paga y libera credito',
                description: 'Cada pago aumenta el disponible.',
                example: 'Pago de 500 -> disponible sube 500',
                imageAsset: 'assets/images/saldify_plan_revolvente.png',
                onTap: () => onSelected(1),
              ),
              SmxSaldiFyCreditoPlanCard(
                selected: value == 2,
                title: 'Paga completo en el corte',
                description: 'El credito se libera al liquidar todo.',
                example: 'Debe 1,000 -> paga 1,000 para comprar',
                imageAsset: 'assets/images/saldify_plan_pago_completo.png',
                onTap: () => onSelected(2),
              ),
            ];

            if (isSingleColumn) {
              return Column(
                children: [
                  for (var index = 0; index < cards.length; index++) ...[
                    if (index > 0) const SizedBox(height: 12),
                    cards[index],
                  ],
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 14),
                Expanded(child: cards[1]),
              ],
            );
          },
        ),
      ],
    );
  }
}

class SmxSaldiFyCreditoPlanCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String description;
  final String example;
  final String imageAsset;
  final VoidCallback onTap;

  const SmxSaldiFyCreditoPlanCard({
    super.key,
    required this.selected,
    required this.title,
    required this.description,
    required this.example,
    required this.imageAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          height: 206,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: selected
                  ? const [Color(0xFF0E8C90), Color(0xFF0E4FA6)]
                  : const [Color(0xFFF8FBFC), Color(0xFFEAF1F4)],
            ),
            border: Border.all(
              color: selected
                  ? SmxColors.brandAccent.withValues(alpha: .55)
                  : SmxColors.white.withValues(alpha: .75),
              width: selected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: SmxColors.blackAlpha(selected ? .18 : .08),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _CreditPlanDecorationPainter(selected: selected),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _PlanImageBadge(
                          imageAsset: imageAsset,
                          selected: selected,
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 14, top: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: selected
                                        ? SmxColors.white
                                        : SmxColors.textDark,
                                    fontSize: 18,
                                    height: 1.08,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        _SelectedMark(selected: selected),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selected
                            ? SmxColors.white.withValues(alpha: .78)
                            : SmxColors.textMuted,
                        fontSize: 13,
                        height: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    _PlanExamplePill(example: example, selected: selected),
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

class _PlanImageBadge extends StatelessWidget {
  final String imageAsset;
  final bool selected;

  const _PlanImageBadge({required this.imageAsset, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 72,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected
            ? SmxColors.white.withValues(alpha: .08)
            : SmxColors.brandAccent.withValues(alpha: .06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: selected
              ? SmxColors.white.withValues(alpha: .22)
              : SmxColors.brandAccent.withValues(alpha: .18),
        ),
      ),
      child: Image.asset(
        imageAsset,
        width: 66,
        height: 56,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
      ),
    );
  }
}

class _SelectedMark extends StatelessWidget {
  final bool selected;

  const _SelectedMark({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: selected
            ? SmxColors.brandAccent
            : SmxColors.white.withValues(alpha: .62),
        shape: BoxShape.circle,
      ),
      child: Icon(
        selected ? Icons.check_rounded : Icons.circle_outlined,
        color: selected ? SmxColors.white : SmxColors.textMuted,
        size: selected ? 21 : 18,
      ),
    );
  }
}

class _PlanExamplePill extends StatelessWidget {
  final String example;
  final bool selected;

  const _PlanExamplePill({required this.example, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: selected
            ? SmxColors.white.withValues(alpha: .16)
            : SmxColors.white.withValues(alpha: .74),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        example,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: selected ? SmxColors.white : SmxColors.textDark,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _CreditPlanDecorationPainter extends CustomPainter {
  final bool selected;

  const _CreditPlanDecorationPainter({required this.selected});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = (selected ? SmxColors.white : SmxColors.brandAccent).withValues(
        alpha: selected ? .13 : .18,
      )
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(112, 20, size.width > 190 ? size.width - 174 : 80, 68),
        const Radius.circular(10),
      ),
      linePaint,
    );

    final dotPaint = Paint()
      ..color = (selected ? SmxColors.white : SmxColors.brandSecondary)
          .withValues(alpha: selected ? .14 : .1);
    canvas.drawCircle(Offset(size.width * .9, size.height * .72), 58, dotPaint);
    canvas.drawCircle(Offset(size.width * .12, size.height * .9), 36, dotPaint);

    final stripePaint = Paint()
      ..color = (selected ? SmxColors.white : SmxColors.brandPrimary)
          .withValues(alpha: selected ? .12 : .08)
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * .15, size.height * .62),
      Offset(size.width * .47, size.height * .62),
      stripePaint,
    );
  }

  @override
  bool shouldRepaint(covariant _CreditPlanDecorationPainter oldDelegate) {
    return oldDelegate.selected != selected;
  }
}
