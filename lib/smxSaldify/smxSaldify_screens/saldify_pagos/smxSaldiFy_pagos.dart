import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxPagos/smxPagos.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxPagos/smxPagosModels.dart';
import 'package:venture_saldify/smxSaldify/smxSaldify_dashboard/smxSaldiFy_clientes/smxSaldiFy_clientes.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_pagos_controller.dart';

class SmxSaldiFyPagos extends StatelessWidget {
  final SmxSaldiFyClientTapData client;

  const SmxSaldiFyPagos({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyPagosController>(
      controllerBuilder: (context) => SmxSaldiFyPagosController(
        alias: 'SMXSALDIFY_PAGOS',
        data: SmxControllerSendData(context: context),
        idSysuser11: client.idSysuser11,
      ),
      builder: (context, controller) => SmxPagos(
        controller: controller,
        model: SmxPagosViewModel(
          clientName: client.name,
          credito: _toDouble(client.credit),
          disponible: _toDouble(client.availableCredit),
          saldo: _toDouble(client.balance),
          formSubtitle:
              'Registra un pago para actualizar el saldo del cliente.',
        ),
      ),
    );
  }

  double _toDouble(String value) {
    final clean = value
        .replaceAll(r'$', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    return double.tryParse(clean) ?? 0.0;
  }
}
