import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import '../../../smxApis/smxConstants.dart';

class SmxSaldiFyClientesController extends SmxController {
  late SmxRowSet rstClientes;

  SmxSaldiFyClientesController({required super.alias, required super.data});

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    addSql(
      'QRY_SYSUSER11',
      "select * from QRY_SYSUSER11(1, ${SmxConstants.controllerMain.rstSysUser10.getId()})",
    );

    await getRowSetFuture('QRY_SYSUSER11');

    rstClientes = getRowset('QRY_SYSUSER11');
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
    return rstClientes.getValue('SYSUSER12_CORTE')?.toString() ?? '';
  }

  String getClientCredit() {
    return rstClientes.getValue('SYSUSER12_CREDITO')?.toString() ?? '';
  }

  String getClientAvailableCredit() {
    return rstClientes.getValue('SYSUSER12_DISPONIBLE')?.toString() ?? '0';
  }

  String getClientPurchases() {
    return rstClientes.getValue('SYSUSER12_COMPRAS')?.toString() ?? '0';
  }

  String getClientPayments() {
    return rstClientes.getValue('SYSUSER12_PAGOS')?.toString() ?? '0';
  }

  String getClientBalance() {
    return rstClientes.getValue('SYSUSER12_BALANCE')?.toString() ?? '';
  }

  int getClientRelationId() {
    return rstClientes.getId();
  }

  int getClientUserId() {
    final value = rstClientes.getValue('RELA_SYSUSER10_CLIENTE');
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? -1;
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
