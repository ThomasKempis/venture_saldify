import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/saldify_circles_background.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'smxSaldiFy_lealtad_controller.dart';

class SmxLealtadRewardCard extends StatelessWidget {
  final SmxSaldiFyLealtadController controller;

  const SmxLealtadRewardCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final monedas = controller.monedas;
        final estrellas = controller.estrellas;

        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: SmxColors.whiteAlpha(.96),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: SmxColors.blackAlpha(.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: CustomPaint(
                  painter: SaldifyCirclesBackgroundPainter(
                    accentColor: Colors.amber,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _RewardRow(
                      label: 'Crédito Meses:',
                      count: 10, 
                      activeCount: monedas,
                      icon: FontAwesomeIcons.coins,
                      activeColor: Colors.amber,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: Colors.black12, height: 1),
                    ),
                    _RewardRow(
                      label: 'Próximo Mes:',
                      count: 5,
                      activeCount: estrellas,
                      icon: FontAwesomeIcons.solidStar,
                      activeColor: Colors.orange,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RewardRow extends StatelessWidget {
  final String label;
  final int count;
  final int activeCount;
  final IconData icon;
  final Color activeColor;

  const _RewardRow({
    required this.label,
    required this.count,
    required this.activeCount,
    required this.icon,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              color: SmxColors.textDark,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 4,
            children: List.generate(count, (index) {
              final isActive = index < activeCount;
              return FaIcon(
                icon,
                size: 18,
                color: isActive ? activeColor : Colors.grey.withOpacity(0.3),
              );
            }),
          ),
        ),
      ],
    );
  }
}
