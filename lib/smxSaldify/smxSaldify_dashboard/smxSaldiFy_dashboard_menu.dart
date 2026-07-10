import 'package:flutter/material.dart';
import 'package:venture_saldify/smxApis/smxConfig.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxSaldifyBackgrounds/cliente_actions_bg.dart';

import 'smxSaldiFy_clientes/smxSaldiFy_clientes.dart';

Future<String?> showSmxSaldiFyDashboardMenu({
  required BuildContext context,
  required SmxSaldiFyClientTapData client,
}) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => _ClienteActionsSheet(client: client),
  );
}

class _ClienteActionsSheet extends StatelessWidget {
  final SmxSaldiFyClientTapData client;

  const _ClienteActionsSheet({required this.client});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * .88,
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFBFEFE), Color(0xFFF3FAF9), Color(0xFFEEF7F6)],
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Stack(
            children: [
              const Positioned.fill(child: ClienteActionsBg()),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: SmxColors.blackAlpha(.14),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SmxConfig.logoCab(
                          width: 72,
                          height: 44,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            client.name,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: SmxColors.textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _ClienteActionItem(
                      icon: Icons.add_shopping_cart_rounded,
                      label: 'Agregar compra',
                      onTap: () => Navigator.of(context).pop('compra'),
                    ),
                    _ClienteActionItem(
                      icon: Icons.payments_rounded,
                      label: 'Registrar pago',
                      onTap: () => Navigator.of(context).pop('pago'),
                    ),
                    _ClienteActionItem(
                      icon: Icons.credit_card_rounded,
                      label: 'Actualizar credito',
                      onTap: () => Navigator.of(context).pop('credito'),
                    ),
                    _ClienteActionItem(
                      icon: Icons.receipt_long_rounded,
                      label: 'Ver historial',
                      onTap: () => Navigator.of(context).pop('historial'),
                    ),
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

class _ClienteActionItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ClienteActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: SmxColors.whiteAlpha(.88),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: SmxColors.brandSecondary.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: SmxColors.brandSecondary, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: SmxColors.textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: SmxColors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
