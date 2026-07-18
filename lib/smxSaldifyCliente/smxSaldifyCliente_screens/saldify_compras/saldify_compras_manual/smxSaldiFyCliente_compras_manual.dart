import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxComprasManual/smxComprasManual.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxComprasManual/smxComprasManualModels.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import '../../../smxSaldifyCliente_dashboard/smxSaldiFyCliente_metricas/smxSaldiFyCliente_metricas_snapshot.dart';
import 'smxSaldiFyCliente_compras_manual_controller.dart';

class SmxSaldiFyClienteComprasManual extends StatelessWidget {
  final String clientName;
  final int idSysuser11;
  final SmxSaldiFyClienteMetricasSnapshot? metricasIniciales;

  const SmxSaldiFyClienteComprasManual({
    super.key,
    required this.clientName,
    required this.idSysuser11,
    this.metricasIniciales,
  });

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClienteComprasController>(
      controllerBuilder: (context) => SmxSaldiFyClienteComprasController(
        alias: 'SMXSALDIFY_CLIENTE_COMPRAS',
        data: SmxControllerSendData(context: context),
        idSysuser11: idSysuser11,
      ),
      builder: (context, controller) => SmxComprasManual(
        controller: controller,
        model: SmxComprasManualViewModel(
          clientName: clientName,
          credito: metricasIniciales?.credito ?? 0,
          disponible: metricasIniciales?.disponible ?? 0,
          saldo: metricasIniciales?.saldo ?? 0,
          headerLabel: 'Compras',
          formTitle: 'Solicitar compra',
          formSubtitle: 'Captura la compra para enviarla a tu anfitrion.',
          receivedEmptyText: '',
          keyPrefix: 'cliente_compra',
        ),
      ),
    );
  }
}
