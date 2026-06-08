import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';

import 'smxSaldiFyCliente_pedidos_mock.dart';

class SmxSaldiFyClientePedidosController extends SmxController {
  late SmxRowSet rstPedidos;

  SmxSaldiFyClientePedidosController({
    required super.alias,
    required super.data,
  });

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();
    rstPedidos = getRstSmxSaldiFyClientePedidosMock();
    rstPedidos.first();
  }

  String getPedidoProducto() {
    return rstPedidos.getValue('PRODUCTO')?.toString() ?? '';
  }

  String getPedidoImporte() {
    return rstPedidos.getValue('IMPORTE')?.toString() ?? '';
  }

  String getPedidoEstado() {
    return rstPedidos.getValue('ESTADO')?.toString() ?? '';
  }

  String getPedidoEstadoTipo() {
    return rstPedidos.getValue('ESTADO_TIPO')?.toString() ?? '';
  }

  String getPedidoFecha() {
    return rstPedidos.getValue('FECHA')?.toString() ?? '';
  }

  bool getPedidoAfectaSaldo() {
    final value = rstPedidos.getValue('AFECTA_SALDO');
    if (value is bool) return value;
    return value?.toString().toLowerCase() == 'si';
  }

  @override
  Future<void> save() async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}
}
