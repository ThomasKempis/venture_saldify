import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';

import 'smxSaldiFy_red_clientes_mock.dart';

class SmxSaldiFyRedClientesController extends SmxController {
  late SmxRowSet rstMetricas;

  SmxSaldiFyRedClientesController({required super.alias, required super.data});

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();
    rstMetricas = getRstSmxSaldiFyMetricasMock();
    rstMetricas.first();
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
