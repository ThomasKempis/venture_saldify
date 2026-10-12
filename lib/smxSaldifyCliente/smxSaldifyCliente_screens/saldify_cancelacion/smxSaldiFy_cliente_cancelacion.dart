import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/invita_cliente_card_bg.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_cliente_cancelacion_controller.dart';

class SmxSaldiFyClienteCancelacion extends StatelessWidget {
  final String anfitrionNombre;

  const SmxSaldiFyClienteCancelacion({
    super.key,
    required this.anfitrionNombre,
  });

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClienteCancelacionController>(
      controllerBuilder: (context) => SmxSaldiFyClienteCancelacionController(
        alias: 'SMXSALDIFY_CLIENTE_CANCELACION',
        data: SmxControllerSendData(context: context),
        anfitrionNombre: anfitrionNombre
      ),
      builder: (context, controller) => _CancelacionView(
        controller: controller,
      ),
    );
  }
}

class _CancelacionView extends StatelessWidget {
  final SmxSaldiFyClienteCancelacionController controller;

  const _CancelacionView({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final layout = SmxLayout.sizeFromWidth(MediaQuery.sizeOf(context).width);
    final topInset = SmxLayout.topContentInset(context);
    final bottomInset = SmxLayout.bottomContentInset(context);

    return Scaffold(
      backgroundColor: SmxColors.transparent,
      body: SmxSaldifyBackground(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: layout.saldifyMaxContentWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  layout.saldifyPagePadding.left,
                  layout.saldifyPagePadding.top + topInset,
                  layout.saldifyPagePadding.right,
                  layout.saldifyPagePadding.bottom + bottomInset,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SmxSaldifyScreenHeader(
                      title: 'Cancelación de invitado',
                      sectionLabel: controller.anfitrionNombre,
                      onBackPressed: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(height: 24),
                    _RequirementsCard(controller: controller),
                    const SizedBox(height: 20),
                    _ExplanationCard(controller: controller),
                    const SizedBox(height: 32),
                    _CancelButton(controller: controller),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RequirementsCard extends StatelessWidget {
  final SmxSaldiFyClienteCancelacionController controller;

  const _RequirementsCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.92),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: InvitaClienteCardBg()),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Requisitos para desvinculación',
                  style: TextStyle(
                    color: SmxColors.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 18),
                _CheckItem(label: 'Saldo en cero', isMet: controller.saldoCero),
                _CheckItem(
                  label: 'Sin compras pendientes',
                  isMet: controller.sinComprasPendientes,
                ),
                _CheckItem(
                  label: 'Sin pagos pendientes',
                  isMet: controller.sinPagosPendientes,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String label;
  final bool isMet;

  const _CheckItem({required this.label, required this.isMet});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: isMet ? SmxColors.successForeground : SmxColors.dangerForeground,
            size: 22,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: isMet ? SmxColors.textDark : SmxColors.textMuted,
              fontSize: 15,
              fontWeight: isMet ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationCard extends StatelessWidget {
  final SmxSaldiFyClienteCancelacionController controller;

  const _ExplanationCard({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.92),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: InvitaClienteCardBg()),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '¿Por qué te desvinculas?',
                  style: TextStyle(
                    color: SmxColors.textDark,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: controller.explicacionController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Cuéntanos brevemente el motivo...',
                    filled: true,
                    fillColor: SmxColors.whiteAlpha(.82),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: SmxColors.blackAlpha(.08)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: SmxColors.blackAlpha(.08)),
                    ),
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

class _CancelButton extends StatelessWidget {
  final SmxSaldiFyClienteCancelacionController controller;

  const _CancelButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    final enabled = controller.puedeCancelar;

    return ElevatedButton(
      onPressed: enabled ? () => controller.cancelarVinculo(context) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: SmxColors.dangerForeground,
        foregroundColor: SmxColors.white,
        disabledBackgroundColor: SmxColors.textMuted.withValues(alpha: .24),
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        elevation: 0,
      ),
      child: const Text(
        'Confirmar Cancelación',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
      ),
    );
  }
}
