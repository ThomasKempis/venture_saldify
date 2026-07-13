import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxComprasCarrito/smxComprasCarrito.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxComprasCarrito/smxComprasCarritoModels.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import '../../../smxSaldifyCliente_dashboard/smxSaldiFyCliente_metricas/smxSaldiFyCliente_metricas_snapshot.dart';
import 'smxSaldiFyCliente_compras_carrito_controller.dart';

class SmxSaldiFyClienteComprasCarrito extends StatelessWidget {
  final String clientName;
  final int idSysuser11;
  final int relaSysuser10Anfitrion;
  final SmxSaldiFyClienteMetricasSnapshot? metricasIniciales;

  const SmxSaldiFyClienteComprasCarrito({
    super.key,
    required this.clientName,
    required this.idSysuser11,
    required this.relaSysuser10Anfitrion,
    this.metricasIniciales,
  });

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClienteComprasCarritoController>(
      controllerBuilder: (context) => SmxSaldiFyClienteComprasCarritoController(
        alias: 'SMXSALDIFY_CLIENTE_COMPRAS_CARRITO',
        data: SmxControllerSendData(context: context),
        idSysuser11: idSysuser11,
        catalogOwnerId: relaSysuser10Anfitrion,
      ),
      builder: (context, controller) => SmxComprasCarrito(
        controller: controller,
        model: SmxComprasCarritoViewModel(
          clientName: clientName,
          idSysuser11: idSysuser11,
          disponible: metricasIniciales?.disponible ?? 0,
        ),
      ),
    );
  }
}
