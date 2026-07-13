import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxPagos/smxPagos.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxPagos/smxPagosModels.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import '../../smxSaldifyCliente_dashboard/smxSaldiFyCliente_metricas/smxSaldiFyCliente_metricas_snapshot.dart';
import 'smxSaldiFyCliente_pagos_controller.dart';

class SmxSaldiFyClientePagos extends StatelessWidget {
  final String clientName;
  final int idSysuser11;
  final int relaSysuser10Anfitrion;
  final SmxSaldiFyClienteMetricasSnapshot? metricasIniciales;

  const SmxSaldiFyClientePagos({
    super.key,
    required this.clientName,
    required this.idSysuser11,
    required this.relaSysuser10Anfitrion,
    this.metricasIniciales,
  });

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClientePagosController>(
      controllerBuilder: (context) => SmxSaldiFyClientePagosController(
        alias: 'SMXSALDIFY_CLIENTE_PAGOS',
        data: SmxControllerSendData(context: context),
        idSysuser11: idSysuser11,
        relaSysuser10Anfitrion: relaSysuser10Anfitrion,
        metricasIniciales: metricasIniciales,
      ),
      builder: (context, controller) => SmxPagos(
        controller: controller,
        model: SmxPagosViewModel(
          clientName: clientName,
          credito: controller.credito,
          disponible: controller.disponible,
          saldo: controller.saldo,
          formSubtitle:
              'Captura el deposito para que tu anfitrion lo confirme.',
          keyPrefix: 'cliente_pago',
        ),
      ),
    );
  }
}
