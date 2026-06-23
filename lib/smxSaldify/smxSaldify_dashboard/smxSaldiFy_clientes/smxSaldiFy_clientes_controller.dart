import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_core_connect/smxJson/SmxJsonUtil.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxController/smxRowSetTrack.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

import '../../../smxApis/smxConstants.dart';

class SmxSaldiFyClientesController extends SmxController {
  static const int statusArchivado = 2;

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

    await SmxRowSetTrack.run(
      controller: this,
      call: () => getRowSetFuture('QRY_SYSUSER11'),
    );

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

  Future<bool> archiveClienteAt(int index) async {
    final context = data.context;
    if (context == null) return false;

    rstClientes.index(index);
    final idSysuser11 = rstClientes.getId();
    if (idSysuser11 <= 0) return false;

    final aliasUpdate = 'SYSUSER11_ARCHIVAR_$idSysuser11';
    addSql(
      aliasUpdate,
      'select * from SYSUSER11_DET_CONTACTOS where ID_SYSUSER11 = $idSysuser11',
    );
    await getRowSetFuture(aliasUpdate);

    if (jsonSend.getError() != null) {
      if (context.mounted) {
        showSystemErrorDialog(context, message: jsonSend.error!);
      }
      return false;
    }

    final rstUpdate = getRowset(aliasUpdate);
    if (rstUpdate.getRowCount() == 0) {
      if (context.mounted) {
        showSystemErrorDialog(
          context,
          message: 'No se encontro la relacion activa del cliente.',
        );
      }
      return false;
    }

    data.accion = AccionNN.W;
    rstUpdate.tabla = 'SYSUSER11_DET_CONTACTOS';
    rstUpdate.first();
    rstUpdate.setAccion(AccionNN.W);
    rstUpdate.update('SYSUSER11_STATUS', statusArchivado);

    await showDialogWait(context, () async {
      await callTroncalSave(rstUpdate);
    });

    if (jsonSend.getError() != null) {
      if (context.mounted) {
        showSystemErrorDialog(context, message: jsonSend.error!);
      }
      return false;
    }

    rstClientes.index(index);
    rstClientes.deleteBuffer();
    return true;
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
