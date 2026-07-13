import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/saldify_circles_background.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_invita_clientes_controller.dart';
import 'smxSaldiFy_invita_clientes_models.dart';

class SmxSaldiFyInvitaClientes extends StatelessWidget {
  final String uuidAnfitrion;
  final String anfitrionNombre;
  final SmxRowSet? clientes;

  const SmxSaldiFyInvitaClientes({
    super.key,
    required this.uuidAnfitrion,
    required this.anfitrionNombre,
    this.clientes,
  });

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyInvitaClientesController>(
      controllerBuilder: (context) => SmxSaldiFyInvitaClientesController(
        alias: 'SMXSALDIFY_INVITA_CLIENTES',
        data: SmxControllerSendData(context: context),
      ),
      loadingBuilder: (_) => const SizedBox.shrink(),
      builder: (context, controller) => _SmxSaldiFyInvitaClientesView(
        controller: controller,
        uuidAnfitrion: uuidAnfitrion,
        anfitrionNombre: anfitrionNombre,
        clientes: clientes,
      ),
    );
  }
}

class _SmxSaldiFyInvitaClientesView extends StatelessWidget {
  final SmxSaldiFyInvitaClientesController controller;
  final String uuidAnfitrion;
  final String anfitrionNombre;
  final SmxRowSet? clientes;

  const _SmxSaldiFyInvitaClientesView({
    required this.controller,
    required this.uuidAnfitrion,
    required this.anfitrionNombre,
    required this.clientes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.22),
            blurRadius: 34,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(
              painter: SaldifyCirclesBackgroundPainter(
                accentColor: SmxColors.brandSecondary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 92,
                  height: 92,
                  decoration: BoxDecoration(
                    color: SmxColors.surfaceQr,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SmxColors.white, width: 8),
                  ),
                  child: const Icon(
                    Icons.qr_code_2_rounded,
                    color: SmxColors.iconDark,
                    size: 70,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Invita clientes',
                        style: TextStyle(
                          color: SmxColors.textDark,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Comparte tu QR o link para invitar a tus clientes a tu plataforma. Evitaras cargar compras y pagos.',
                        style: TextStyle(
                          color: SmxColors.textMuted,
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      AnimatedBuilder(
                        animation: controller,
                        builder: (context, _) {
                          final action = controller.selectedAction;

                          return Row(
                            children: [
                              _InvitePill(
                                label: 'Copiar link',
                                filled:
                                    action == SmxSaldiFyInvitaAction.copiarLink,
                                onTap: () => controller.openCopyLinkModal(
                                  context: context,
                                  uuidAnfitrion: uuidAnfitrion,
                                  anfitrionNombre: anfitrionNombre,
                                  clientes: clientes,
                                ),
                              ),
                              const SizedBox(width: 8),
                              _InvitePill(
                                label: 'WhatsApp',
                                filled:
                                    action == SmxSaldiFyInvitaAction.whatsApp,
                                onTap: () => controller.openWhatsAppModal(
                                  context: context,
                                  uuidAnfitrion: uuidAnfitrion,
                                  anfitrionNombre: anfitrionNombre,
                                  clientes: clientes,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InvitePill extends StatelessWidget {
  final String label;
  final bool filled;
  final VoidCallback onTap;

  const _InvitePill({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? SmxColors.brandSecondary : SmxColors.surfacePill,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: filled ? SmxColors.white : SmxColors.brandPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
