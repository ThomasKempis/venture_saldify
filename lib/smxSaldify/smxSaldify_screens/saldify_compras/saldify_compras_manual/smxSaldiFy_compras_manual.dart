import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxComprasManual/smxComprasManual.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxComprasManual/smxComprasManualModels.dart';
import 'package:venture_saldify/smxSaldify/smxSaldify_dashboard/smxSaldiFy_clientes/smxSaldiFy_clientes.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_compras_manual_controller.dart';

class SmxSaldiFyComprasManual extends StatelessWidget {
  final SmxSaldiFyClientTapData client;

  const SmxSaldiFyComprasManual({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyComprasManualController>(
      controllerBuilder: (context) => SmxSaldiFyComprasManualController(
        alias: 'SMXSALDIFY_COMPRAS_MANUAL',
        data: SmxControllerSendData(context: context),
        idSysuser11: client.idSysuser11,
      ),
      builder: (context, controller) => SmxComprasManual(
        controller: controller,
        model: SmxComprasManualViewModel(
          clientName: client.name,
          credito: _toDouble(client.credit),
          disponible: _toDouble(client.availableCredit),
          saldo: _toDouble(client.balance),
          headerLabel: 'Productos',
          formTitle: 'Registrar compra',
          formSubtitle: 'Agrega una compra al saldo del cliente.',
          receivedEmptyText: 'No tienes compras recibidas.',
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
