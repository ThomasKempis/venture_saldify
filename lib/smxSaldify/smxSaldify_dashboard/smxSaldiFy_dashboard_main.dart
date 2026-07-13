import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

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
        ValueListenableBuilder<SmxRowSet?>(
          valueListenable: controller.clientesInvitacionNotifier,
          builder: (context, rstClientes, _) {
            final enabled = rstClientes != null;

            return AbsorbPointer(
              absorbing: !enabled,
              child: Opacity(
                opacity: enabled ? 1 : .55,
                child: SmxSaldiFyInvitaClientes(
                  uuidAnfitrion: uuidAnfitrion,
                  anfitrionNombre: anfitrionNombre,
                  clientes: rstClientes,
                ),
              ),
            );
          },
        ),
        SizedBox(height: isMobile ? 24 : 30),
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
