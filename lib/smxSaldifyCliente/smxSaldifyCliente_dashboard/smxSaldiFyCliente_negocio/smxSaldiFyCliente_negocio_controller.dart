import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';

import 'smxSaldiFyCliente_negocio_mock.dart';

class SmxSaldiFyClienteNegocioController extends SmxController {
  late SmxRowSet rstNegocio;

  SmxSaldiFyClienteNegocioController({
    required super.alias,
    required super.data,
  });

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();
    rstNegocio = getRstSmxSaldiFyClienteNegocioMock();
    rstNegocio.first();
  }

  String get negocio => rstNegocio.getValue('NEGOCIO')?.toString() ?? '';
  String get estado => rstNegocio.getValue('ESTADO')?.toString() ?? '';
  String get corte => rstNegocio.getValue('CORTE')?.toString() ?? '';
  String get contacto => rstNegocio.getValue('CONTACTO')?.toString() ?? '';
  String get mensaje => rstNegocio.getValue('MENSAJE')?.toString() ?? '';

  @override
  Future<void> save() async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}
}
