import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';

import 'smxSaldiFy_clientes_mock.dart';

class SmxSaldiFyClientesController extends SmxController {
  late SmxRowSet rstClientes;

  SmxSaldiFyClientesController({required super.alias, required super.data});

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();
    rstClientes = getRstSmxSaldiFyClientesMock();
    rstClientes.first();
  }

  String getClientName() {
    return rstClientes.getValue('NAME')?.toString() ?? '';
  }

  String getClientStatus() {
    return rstClientes.getValue('STATUS')?.toString() ?? '';
  }

  String getClientStatusType() {
    return rstClientes.getValue('STATUS_TYPE')?.toString() ?? '';
  }

  String getClientCutDate() {
    return rstClientes.getValue('CUT_DATE')?.toString() ?? '';
  }

  String getClientCredit() {
    return rstClientes.getValue('CREDIT')?.toString() ?? '';
  }

  String getClientBalance() {
    return rstClientes.getValue('BALANCE')?.toString() ?? '';
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
