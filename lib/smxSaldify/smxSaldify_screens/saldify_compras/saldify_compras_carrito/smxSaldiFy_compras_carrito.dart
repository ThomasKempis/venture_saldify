import 'package:flutter/material.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxComprasCarrito/smxComprasCarrito.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxComprasCarrito/smxComprasCarritoModels.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import '../../../smxSaldify_dashboard/smxSaldiFy_clientes/smxSaldiFy_clientes.dart';
import 'smxSaldiFy_compras_carrito_controller.dart';

class SmxSaldiFyComprasCarrito extends StatelessWidget {
  final SmxSaldiFyClientTapData client;

  const SmxSaldiFyComprasCarrito({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyComprasCarritoController>(
      controllerBuilder: (context) => SmxSaldiFyComprasCarritoController(
        alias: 'SMXSALDIFY_COMPRAS_CARRITO',
        data: SmxControllerSendData(context: context),
        idSysuser11: client.idSysuser11,
        catalogOwnerId: SmxConstants.controllerMain.rstSysUser10.getId(),
      ),
      builder: (context, controller) => SmxComprasCarrito(
        controller: controller,
        model: SmxComprasCarritoViewModel(
          clientName: client.name,
          idSysuser11: client.idSysuser11,
          disponible: _parseAmount(client.availableCredit),
        ),
      ),
    );
  }

  double _parseAmount(String value) {
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.-]'), '')) ?? 0;
  }
}
