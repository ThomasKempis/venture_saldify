import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';

class SmxSaldiFyClienteAccionesRapidas extends StatelessWidget {
  final bool isMobile;
  final ValueChanged<String> onActionTap;

  const SmxSaldiFyClienteAccionesRapidas({
    super.key,
    required this.isMobile,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final actions = [
      const _ClienteQuickActionData(
        icon: Icons.shopping_bag_outlined,
        label: 'Compras',
      ),
      const _ClienteQuickActionData(
        icon: Icons.payments_outlined,
        label: 'Pagos',
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _ActionsHeader(),
        const SizedBox(height: 12),
        isMobile
            ? Row(
                children: [
                  for (var index = 0; index < actions.length; index++) ...[
                    Expanded(
                      child: _QuickActionCard(
                        data: actions[index],
                        onTap: () => onActionTap(actions[index].label),
                      ),
                    ),
                    if (index < actions.length - 1) const SizedBox(width: 12),
                  ],
                ],
              )
            : Row(
                children: [
                  for (var index = 0; index < actions.length; index++) ...[
                    SizedBox(
                      width: 178,
                      child: _QuickActionCard(
                        data: actions[index],
                        onTap: () => onActionTap(actions[index].label),
                      ),
                    ),
                    if (index < actions.length - 1) const SizedBox(width: 12),
                  ],
                ],
              ),
      ],
    );
  }
}

class _ActionsHeader extends StatelessWidget {
  const _ActionsHeader();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Acciones rápidas',
      style: TextStyle(
        color: SmxColors.white,
        fontSize: 22,
        fontWeight: FontWeight.w900,
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final _ClienteQuickActionData data;
  final VoidCallback onTap;

  const _QuickActionCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.13),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 108,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SmxColors.whiteAlpha(.16)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: SmxColors.accentAlpha(.22),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(data.icon, color: SmxColors.brandAccent, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SmxColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClienteQuickActionData {
  final IconData icon;
  final String label;

  const _ClienteQuickActionData({required this.icon, required this.label});
}
