import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxSaldify/smxSaldify_screens/saldify_credito/smxSaldiFy_cliente_credito_controller.dart';
import 'package:venture_saldify/smxSaldify/smxSaldify_screens/saldify_credito/smxSaldiFy_cliente_credito_mock.dart';

class SmxSaldiFyCreditoPlanSelector extends StatelessWidget {
  final int value;
  final SmxSaldiFyClienteCreditoController controller;
  final ValueChanged<int> onChanged;
  final ValueChanged<int> onSelected;

  const SmxSaldiFyCreditoPlanSelector({
    super.key,
    required this.value,
    required this.controller,
    required this.onChanged,
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
            final isSingleColumn = constraints.maxWidth < 900;
            final cards = smxSaldiFyCreditoPlanesMock
                .map((plan) {
                  return SmxSaldiFyCreditoPlanCard(
                    selected: value == plan.id,
                    title: plan.title,
                    description: plan.subtitle,
                    example: plan.footerTitle,
                    imageAsset: plan.imageAsset,
                    extraContent: plan.hasPorcentajeMinimo
                        ? _PlanPercentageField(
                            selected: value == plan.id,
                            controller: controller,
                            onSelected: () => onChanged(plan.id),
                          )
                        : null,
                    onTap: () => onSelected(plan.id),
                  );
                })
                .toList(growable: false);

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
                for (var index = 0; index < cards.length; index++) ...[
                  if (index > 0) const SizedBox(width: 14),
                  Expanded(child: cards[index]),
                ],
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
  final Widget? extraContent;
  final VoidCallback onTap;

  const SmxSaldiFyCreditoPlanCard({
    super.key,
    required this.selected,
    required this.title,
    required this.description,
    required this.example,
    required this.imageAsset,
    this.extraContent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isExtended = extraContent != null;

    return Material(
      color: SmxColors.transparent,
      borderRadius: BorderRadius.circular(22),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          height: isExtended ? 230 : 206,
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
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
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
                        ),
                        if (extraContent != null) ...[
                          const SizedBox(width: 12),
                          Transform.translate(
                            offset: const Offset(0, -3),
                            child: extraContent!,
                          ),
                        ],
                      ],
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

class _PlanPercentageField extends StatelessWidget {
  final bool selected;
  final SmxSaldiFyClienteCreditoController controller;
  final VoidCallback onSelected;

  const _PlanPercentageField({
    required this.selected,
    required this.controller,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final selectedValue = _porcentajes.contains(controller.porcentaje.round())
        ? controller.porcentaje.round()
        : _porcentajes.first;

    return SizedBox(
      width: 172,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _PercentageChipRow(
            values: _porcentajes.take(3),
            selected: selected,
            selectedValue: selectedValue,
            onSelected: _selectPorcentaje,
          ),
          const SizedBox(height: 6),
          _PercentageChipRow(
            values: _porcentajes.skip(3),
            selected: selected,
            selectedValue: selectedValue,
            onSelected: _selectPorcentaje,
          ),
        ],
      ),
    );
  }

  void _selectPorcentaje(int porcentaje) {
    controller.setPorcentaje(porcentaje.toDouble());
    onSelected();
  }

  static const _porcentajes = [10, 20, 30, 40, 50, 60];
}

class _PercentageChipRow extends StatelessWidget {
  final Iterable<int> values;
  final bool selected;
  final int selectedValue;
  final ValueChanged<int> onSelected;

  const _PercentageChipRow({
    required this.values,
    required this.selected,
    required this.selectedValue,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (final porcentaje in values) ...[
          if (porcentaje != values.first) const SizedBox(width: 6),
          _PercentageChip(
            selected: selected,
            active: selectedValue == porcentaje,
            label: '$porcentaje%',
            onTap: () => onSelected(porcentaje),
          ),
        ],
      ],
    );
  }
}

class _PercentageChip extends StatelessWidget {
  final bool selected;
  final bool active;
  final String label;
  final VoidCallback onTap;

  const _PercentageChip({
    required this.selected,
    required this.active,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = selected ? SmxColors.white : SmxColors.brandAccent;
    final idleColor = selected
        ? SmxColors.white.withValues(alpha: .14)
        : SmxColors.white;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: active ? activeColor : idleColor,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(
            color: active
                ? activeColor
                : selected
                ? SmxColors.white.withValues(alpha: .24)
                : SmxColors.blackAlpha(.1),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active
                ? selected
                      ? const Color(0xFF0E5F74)
                      : SmxColors.white
                : selected
                ? SmxColors.white.withValues(alpha: .86)
                : SmxColors.textDark,
            fontSize: 11,
            fontWeight: FontWeight.w900,
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
