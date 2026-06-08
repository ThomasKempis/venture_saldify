import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';

import 'smxSaldiFyCliente_resumen_mock.dart';

class SmxSaldiFyClienteResumenController extends SmxController {
  late SmxRowSet rstResumen;

  SmxSaldiFyClienteResumenController({
    required super.alias,
    required super.data,
  });

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();
    rstResumen = getRstSmxSaldiFyClienteResumenMock();
    rstResumen.first();
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
