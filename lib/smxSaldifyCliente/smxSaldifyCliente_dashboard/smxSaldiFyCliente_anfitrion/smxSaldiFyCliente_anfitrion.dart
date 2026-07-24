import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/saldify_circles_background.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import '../smxSaldiFyCliente_dashboard_controller.dart';
import 'smxSaldiFyCliente_anfitrion_controller.dart';
import 'smxSaldiFyCliente_anfitrion_skeleton.dart';

class SmxSaldiFyClienteAnfitrion extends StatelessWidget {
  final SmxSaldiFyClienteDashboardController? dashboardController;
  final bool desdeDashboardAnfitrion;
  final int relaSysuser11;

  const SmxSaldiFyClienteAnfitrion({
    super.key,
    this.dashboardController,
    this.desdeDashboardAnfitrion = false,
    this.relaSysuser11 = -1,
  });

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClienteAnfitrionController>(
      controllerBuilder: (context) => SmxSaldiFyClienteAnfitrionController(
        alias: 'SMXSALDIFY_CLIENTE_ANFITRION',
        data: SmxControllerSendData(context: context),
        dashboardController: dashboardController,
        desdeDashboardAnfitrion: desdeDashboardAnfitrion,
        relaSysuser11: relaSysuser11,
      ),
      loadingBuilder: (_) => const SmxSaldiFyClienteAnfitrionSkeleton(),
      builder: (context, controller) =>
          _SmxSaldiFyClienteAnfitrionView(controller: controller),
    );
  }
}

class _SmxSaldiFyClienteAnfitrionView extends StatelessWidget {
  final SmxSaldiFyClienteAnfitrionController controller;

  const _SmxSaldiFyClienteAnfitrionView({required this.controller});

  @override
  Widget build(BuildContext context) {
    final telefono = controller.telefonoAnfitrion;
    final correo = controller.correoAnfitrion;
    final estadoLabel = controller.estadoRelacionLabel;

    return Container(
      constraints: const BoxConstraints(minHeight: 128),
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
          Positioned.fill(
            child: CustomPaint(
              painter: SaldifyCirclesBackgroundPainter(
                accentColor: controller.hasPlan
                    ? SmxColors.brandSecondary
                    : SmxColors.warningForeground,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: SmxColors.surfaceQr,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SmxColors.white, width: 5),
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: SmxColors.iconDark,
                    size: 38,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.nombreAnfitrion,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: SmxColors.textDark,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          if (estadoLabel.isNotEmpty)
                            _EstadoPill(
                              label: estadoLabel,
                              pendiente: !controller.hasPlan,
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      _ContactLine(
                        telefono: telefono,
                        correo: correo,
                        onTelefonoTap: () => controller.launchWhatsApp(context),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              controller.cortePlanLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: controller.hasPlan
                                    ? SmxColors.textDark
                                    : SmxColors.warningForeground,
                                fontSize: 12,
                                height: 1.35,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            controller.fechaCorte,
                            style: const TextStyle(
                              color: SmxColors.textDark,
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              controller.planDetalle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: SmxColors.textMuted,
                                fontSize: 11,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _InfoPill(
                            label: controller.diasVencimientoLabel,
                            vencido: controller.vencimientoVencido,
                            alerta: controller.vencimientoAlerta,
                            pendiente: controller.vencimientoPendiente,
                          ),
                        ],
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

class _ContactLine extends StatelessWidget {
  final String telefono;
  final String correo;
  final VoidCallback onTelefonoTap;

  const _ContactLine({
    required this.telefono,
    required this.correo,
    required this.onTelefonoTap,
  });

  @override
  Widget build(BuildContext context) {
    final telefonoLabel = telefono.isEmpty
        ? 'Telefono no registrado'
        : telefono;
    final correoLabel = correo.isEmpty ? 'Correo no registrado' : correo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ContactItem(
          icon: Icons.phone_outlined,
          label: telefonoLabel,
          enabled: telefono.isNotEmpty,
          onTap: telefono.isEmpty ? null : onTelefonoTap,
        ),
        const SizedBox(height: 2),
        _ContactItem(
          icon: Icons.mail_outline_rounded,
          label: correoLabel,
          enabled: correo.isNotEmpty,
          onTap: correo.isEmpty ? null : () => _launchMail(correo),
        ),
      ],
    );
  }

  Future<void> _launchMail(String correo) async {
    final uri = Uri(scheme: 'mailto', path: correo);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _ContactItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool enabled;
  final VoidCallback? onTap;

  const _ContactItem({
    required this.icon,
    required this.label,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = enabled ? SmxColors.brandSecondary : SmxColors.textMuted;

    return Material(
      color: SmxColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
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

class _EstadoPill extends StatelessWidget {
  final String label;
  final bool pendiente;

  const _EstadoPill({required this.label, this.pendiente = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: pendiente
            ? SmxColors.warningBackground
            : SmxColors.successBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: pendiente
              ? SmxColors.warningForeground
              : SmxColors.successForeground,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final bool vencido;
  final bool alerta;
  final bool pendiente;

  const _InfoPill({
    required this.label,
    this.vencido = false,
    this.alerta = false,
    this.pendiente = false,
  });

  @override
  Widget build(BuildContext context) {
    final background = vencido
        ? SmxColors.dangerBackground
        : alerta || pendiente
        ? SmxColors.warningBackground
        : SmxColors.successBackground;
    final foreground = vencido
        ? SmxColors.dangerForeground
        : alerta || pendiente
        ? SmxColors.warningForeground
        : SmxColors.successForeground;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
