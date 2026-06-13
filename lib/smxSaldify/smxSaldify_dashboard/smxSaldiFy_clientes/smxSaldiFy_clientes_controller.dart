import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';

import '../../../smxApis/smxConstants.dart';
import 'smxSaldiFy_clientes_mock.dart';

class SmxSaldiFyClientesController extends SmxController {
  late SmxRowSet rstClientes;

  SmxSaldiFyClientesController({required super.alias, required super.data});

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    addSql('QRY_SYSUSER11', "select * from QRY_SYSUSER11(${SmxConstants.controllerMain.rstSysUser10.getId()})");

    await getRowSetFuture('QRY_SYSUSER11');

    rstClientes = getRowset('QRY_SYSUSER11');
    //rstClientes = getRstSmxSaldiFyClientesMock();
    rstClientes.first();
  }

  String getClientName() {
    return rstClientes.getValue('SYSUSER10_INVITADO')?.toString() ?? '';
  }

  String getClientStatus() {
    return rstClientes.getValue('SYSUSER12_STATUS')?.toString() ?? '';
  }

  String getClientStatusType() {
    return rstClientes.getValue('SYSUSER12_STATUS_TIPO')?.toString() ?? '';
  }

  String getClientCutDate() {
    return rstClientes.getValue('CUT_DATE')?.toString() ?? '';
  }

  String getClientCredit() {
    return rstClientes.getValue('SYSUSER12_CREDITO')?.toString() ?? '';
  }

  String getClientBalance() {
    return rstClientes.getValue('SYSUSER12_BALANCE')?.toString() ?? '';
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
