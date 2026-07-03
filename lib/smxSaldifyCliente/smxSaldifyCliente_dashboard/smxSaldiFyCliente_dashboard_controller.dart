import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../smxSaldifyCliente_screens/saldify_compras/smxSaldiFyCliente_compras.dart';
import '../smxSaldifyCliente_screens/saldify_pagos/smxSaldiFyCliente_pagos.dart';
import '../smxSaldiFyCliente_controller.dart';
import 'smxSaldiFyCliente_metricas/smxSaldiFyCliente_metricas_snapshot.dart';

class SmxSaldiFyClienteDashboardController {
  final SmxSaldiFyClienteController clienteController;
  final Future<void> Function()? onRefresh;
  SmxSaldiFyClienteMetricasSnapshot? metricasSnapshot;

  SmxSaldiFyClienteDashboardController({
    required this.clienteController,
    this.onRefresh,
  });

  String get clientName => clienteController.clientName;

  String get anfitrionNombreCompleto =>
      clienteController.anfitrionNombreCompleto;

  String get anfitrionTelefono => clienteController.anfitrionTelefono;

  String get anfitrionCorreo => clienteController.anfitrionCorreo;

  String get anfitrionRelacionEstado =>
      clienteController.anfitrionRelacionEstado;

  int get idSysuser11 => clienteController.idSysuser11;

  int get relaSysuser10Anfitrion => clienteController.relaSysuser10Anfitrion;

  void setMetricasSnapshot(SmxSaldiFyClienteMetricasSnapshot snapshot) {
    metricasSnapshot = snapshot;
  }

  Future<void> refresh() async {
    await onRefresh?.call();
  }

  Future<void> launchWhatsApp(BuildContext context) async {
    final digits = anfitrionTelefono.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El anfitrion no tiene WhatsApp registrado'),
        ),
      );
      return;
    }

    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('No se pudo abrir WhatsApp')));
  }

  Future<void> openClienteAction(BuildContext context, String title) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => title == 'Pagos'
            ? SmxSaldiFyClientePagos(
                clientName: clientName,
                idSysuser11: idSysuser11,
                relaSysuser10Anfitrion: relaSysuser10Anfitrion,
                metricasIniciales: metricasSnapshot,
              )
            : SmxSaldiFyClienteCompras(
                clientName: clientName,
                idSysuser11: idSysuser11,
                relaSysuser10Anfitrion: relaSysuser10Anfitrion,
                metricasIniciales: metricasSnapshot,
              ),
      ),
    );

    if (changed == true) {
      await refresh();
    }
  }
}
