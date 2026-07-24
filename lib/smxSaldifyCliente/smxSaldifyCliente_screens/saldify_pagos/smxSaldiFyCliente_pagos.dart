import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxPagos/smxPagos.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxPagos/smxPagosModels.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import '../../../smxApis/smxConstants.dart';
import 'smxSaldiFyCliente_pagos_controller.dart';

class SmxSaldiFyClientePagos extends StatelessWidget {
  final String clientName;
  final int idSysuser11;

  const SmxSaldiFyClientePagos({
    super.key,
    required this.clientName,
    required this.idSysuser11,
  });

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClientePagosController>(
      controllerBuilder: (context) => SmxSaldiFyClientePagosController(
        alias: 'SMXSALDIFY_CLIENTE_PAGOS',
        data: SmxControllerSendData(context: context),
        idSysuser11: idSysuser11,
      ),
      builder: (context, controller) => SmxPagos(
        controller: controller,
        model: SmxPagosViewModel(
          clientName: clientName,
          credito: SmxConstants.rstMetricasCliente.getValue(
            'SYSUSER12_CREDITO',
          ),
          disponible: SmxConstants.rstMetricasCliente.getValue(
            'SYSUSER12_DISPONIBLE',
          ),
          saldo: SmxConstants.rstMetricasCliente.getValue('SYSUSER12_BALANCE'),
          formSubtitle:
              'Captura el deposito para que tu anfitrion lo confirme.',
          keyPrefix: 'cliente_pago',
        ),
      ),
    );
  }
}
