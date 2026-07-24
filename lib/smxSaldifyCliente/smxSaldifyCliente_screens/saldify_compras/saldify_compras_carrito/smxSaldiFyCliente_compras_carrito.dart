import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxComprasCarrito/smxComprasCarrito.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxComprasCarrito/models/smxComprasCarritoModels.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import '../../../../smxApis/smxConstants.dart';
import 'smxSaldiFyCliente_compras_carrito_controller.dart';

class SmxSaldiFyClienteComprasCarrito extends StatelessWidget {
  final String clientName;
  final int idSysuser11;
  final int relaSysuser10Anfitrion;

  const SmxSaldiFyClienteComprasCarrito({
    super.key,
    required this.clientName,
    required this.idSysuser11,
    required this.relaSysuser10Anfitrion,
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
          disponible: SmxConstants.rstMetricasCliente.getValue(
            'SYSUSER12_DISPONIBLE',
          ),
        ),
      ),
    );
  }
}
