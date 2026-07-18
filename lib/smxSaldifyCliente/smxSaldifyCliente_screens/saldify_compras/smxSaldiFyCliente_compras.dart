import 'package:flutter/material.dart';

import '../../smxSaldifyCliente_dashboard/smxSaldiFyCliente_metricas/smxSaldiFyCliente_metricas_snapshot.dart';
import 'saldify_compras_carrito/smxSaldiFyCliente_compras_carrito.dart';
import 'saldify_compras_manual/smxSaldiFyCliente_compras_manual.dart';

class SmxSaldiFyClienteCompras extends StatelessWidget {
  final String clientName;
  final int idSysuser11;
  final int relaSysuser10Anfitrion;
  final bool conCatalogo;
  final SmxSaldiFyClienteMetricasSnapshot? metricasIniciales;

  const SmxSaldiFyClienteCompras({
    super.key,
    required this.clientName,
    required this.idSysuser11,
    required this.relaSysuser10Anfitrion,
    required this.conCatalogo,
    this.metricasIniciales,
  });

  @override
  Widget build(BuildContext context) {
    if (conCatalogo) {
      return SmxSaldiFyClienteComprasCarrito(
        clientName: clientName,
        idSysuser11: idSysuser11,
        relaSysuser10Anfitrion: relaSysuser10Anfitrion,
        metricasIniciales: metricasIniciales,
      );
    }

    return SmxSaldiFyClienteComprasManual(
      clientName: clientName,
      idSysuser11: idSysuser11,
      metricasIniciales: metricasIniciales,
    );
  }
}
