import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

import '../../smxApis/smxConstants.dart';
import '../../smxLayout/smxColors.dart';
import '../../smxSaldifyCliente/smxSaldifyCliente_dashboard/smxSaldiFyCliente_anfitrion/smxSaldiFyCliente_anfitrion.dart';
import 'smxSaldiFy_acciones_rapidas/smxSaldiFy_acciones_rapidas.dart';
import 'smxSaldiFy_clientes/smxSaldiFy_clientes.dart';
import 'smxSaldiFy_clientes_pendientes/smxSaldiFy_clientes_pendientes.dart';
import 'smxSaldiFy_dashboard_controller.dart';
import 'smxSaldiFy_invita_clientes/smxSaldiFy_invita_clientes.dart';

class SmxSaldiFyDashboardMain extends StatelessWidget {
  final SmxSaldiFyDashboardController controller;
  final String uuidAnfitrion;
  final String anfitrionNombre;
  final bool isMobile;
  final bool isDesktop;
  final double quickActionCardWidth;
  final Future<void> Function() onRefresh;

  const SmxSaldiFyDashboardMain({
    super.key,
    required this.controller,
    required this.uuidAnfitrion,
    required this.anfitrionNombre,
    required this.isMobile,
    required this.isDesktop,
    required this.quickActionCardWidth,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SmxSaldiFyInvitaClientes(
          uuidAnfitrion: uuidAnfitrion,
          anfitrionNombre: anfitrionNombre,
        ),
        ValueListenableBuilder<int>(
          valueListenable: controller.anfitrionAnteriorRevisionNotifier,
          builder: (context, revision, _) {
            if (revision == 0) {
              return SizedBox(height: isMobile ? 24 : 30);
            }

            final rstMetricas = SmxConstants.rstMetricasAnfitrion;
            final relaSysuser10 = rstMetricas.getValue('RELA_SYSUSER10');
            final relaSysuser11 = rstMetricas.getValue('RELA_SYSUSER11');

            if (relaSysuser10 == 0) {
              return SizedBox(height: isMobile ? 24 : 30);
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: isMobile ? 24 : 30),
                const Text(
                  'Tu anfitrion',
                  style: TextStyle(
                    color: SmxColors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: isMobile ? 16 : 20),
                SmxSaldiFyClienteAnfitrion(
                  desdeDashboardAnfitrion: true,
                  relaSysuser11: relaSysuser11,
                ),
                SizedBox(height: isMobile ? 24 : 30),
              ],
            );
          },
        ),
        SmxSaldiFyAccionesRapidas(
          isMobile: isMobile,
          cardWidth: quickActionCardWidth,
          onActionTap: (title) async {
            if (title == 'Cliente') {
              final saved = await controller.openCliente(context);
              if (saved == true) {
                await onRefresh();
              }
              return;
            }

            if (title == 'Archivados') {
              final changed = await controller.openArchivados(context);
              if (changed == true) {
                await onRefresh();
              }
              return;
            }

            if (title == 'Cobranza') {
              await controller.openCobranza(context);
              return;
            }

            if (title == 'Productos') {
              final cambioCatalogo = await controller.openProductos(context);
              if (cambioCatalogo == true) {
                await onRefresh();
              }
              return;
            }

            if (title == 'Reportes') {
              await controller.openReportes(context);
              return;
            }

            controller.openUnderConstruction(context, title);
          },
        ),
        SizedBox(height: isMobile ? 26 : 30),
        SmxSaldiFyClientes(
          isMobile: isMobile,
          isDesktop: isDesktop,
          onLoaded: controller.onClientesLoadedRst,
          onArchived: controller.onClienteArchivadoRst,
          clientesNotifier: controller.clientesActivosNotifier,
          onClientTap: (client) async {
            final saved = await controller.openClienteActions(context, client);
            if (saved == true) {
              await onRefresh();
            }
          },
          onClientNovedadTap: (client) async {
            final changed = await controller.openClienteHistorial(
              context,
              client,
            );
            if (changed == true) {
              await onRefresh();
            }
          },
        ),
        ValueListenableBuilder<SmxRowSet?>(
          valueListenable: controller.clientesActivosNotifier,
          builder: (context, rstClientes, _) {
            if (rstClientes == null) {
              return const SizedBox.shrink();
            }

            return SmxSaldiFyClientesPendientes(
              isMobile: isMobile,
              isDesktop: isDesktop,
              onLoaded: controller.onClientesPendientesLoadedRst,
              onClientActivated: (rstActivated) {
                controller.onClientePendienteActivated(rstActivated);
              },
              onClientPendienteTap: (client) async {
                final saved = await controller.openCliente(
                  context,
                  relaSysuser10Cliente: client.relaSysuser10Cliente,
                );
                if (saved == true) {
                  await onRefresh();
                }
              },
            );
          },
        ),
      ],
    );
  }
}
