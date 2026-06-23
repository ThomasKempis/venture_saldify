import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_core_connect/smxJson/SmxJsonUtil.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

import '../../../smxApis/smxConstants.dart';

class SmxSaldiFyClientesPendientesController extends SmxController {
  SmxRowSet rstClientesPendientes = SmxRowSet.newRowSet([]);

  SmxSaldiFyClientesPendientesController({
    required super.alias,
    required super.data,
  });

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    addSql(
      'QRY_SYSUSER11_PENDIENTES',
      "select * from QRY_SYSUSER11(0, ${SmxConstants.controllerMain.rstSysUser10.getId()})",
    );

    await getRowSetFuture('QRY_SYSUSER11_PENDIENTES');

    rstClientesPendientes = getRowset('QRY_SYSUSER11_PENDIENTES');
    rstClientesPendientes.first();
  }

  bool get hasClientes => rstClientesPendientes.getRowCount() > 0;

  String getClientName() {
    return rstClientesPendientes.getValue('SYSUSER10_INVITADO')?.toString() ??
        '';
  }

  String getClientEmail() {
    return rstClientesPendientes.getValue('SYSUSER10_CORREO')?.toString() ?? '';
  }

  String getClientPhone() {
    return rstClientesPendientes.getValue('SYSUSER10_TELEFONO')?.toString() ??
        '';
  }

  int getClientRelationId() {
    return rstClientesPendientes.getId();
  }

  int getClientUserId() {
    final value = rstClientesPendientes.getValue('RELA_SYSUSER10_CLIENTE');
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? -1;
  }

  Future<bool> deletePendienteAt(int index) async {
    final context = data.context;
    if (context == null) return false;

    rstClientesPendientes.index(index);
    final accionAnterior = rstClientesPendientes.getAccion();

    final rstDelete = rstClientesPendientes.copyActive();
    rstDelete.tabla = 'SYSUSER11_DET_CONTACTOS';
    rstDelete.first();
    rstDelete.delete();

    await showDialogWait(context, () async {
      await callDeleteAlt(rstDelete);
    });

    if (jsonSend.getError() != null) {
      rstClientesPendientes.index(index);
      rstClientesPendientes.setAccion(accionAnterior);

      if (context.mounted) {
        showSystemErrorDialog(context, message: jsonSend.error!);
      }
      return false;
    }

    rstClientesPendientes.index(index);
    rstClientesPendientes.deleteBuffer();
    return true;
  }

  Future<SmxRowSet?> activatePendienteAt(int index) async {
    final context = data.context;
    if (context == null) return null;

    rstClientesPendientes.index(index);
    final idSysuser11 = rstClientesPendientes.getId();
    if (idSysuser11 <= 0) return null;

    final aliasUpdate = 'SYSUSER11_ACTIVAR_$idSysuser11';
    addSql(
      aliasUpdate,
      'select * from SYSUSER11_DET_CONTACTOS where ID_SYSUSER11 = $idSysuser11',
    );
    await getRowSetFuture(aliasUpdate);

    if (jsonSend.getError() != null) {
      if (context.mounted) {
        showSystemErrorDialog(context, message: jsonSend.error!);
      }
      return null;
    }

    final rstUpdate = getRowset(aliasUpdate);
    if (rstUpdate.getRowCount() == 0) {
      if (context.mounted) {
        showSystemErrorDialog(
          context,
          message: 'No se encontro la relacion pendiente del cliente.',
        );
      }
      return null;
    }

    data.accion = AccionNN.W;
    rstUpdate.tabla = 'SYSUSER11_DET_CONTACTOS';
    rstUpdate.first();
    rstUpdate.setAccion(AccionNN.W);
    rstUpdate.update('SYSUSER11_STATUS', 1);

    await showDialogWait(context, () async {
      await callTroncalSave(rstUpdate);
    });

    if (jsonSend.getError() != null) {
      if (context.mounted) {
        showSystemErrorDialog(context, message: jsonSend.error!);
      }
      return null;
    }

    rstClientesPendientes.index(index);
    final rstActivated = rstClientesPendientes.copyActive().copy();
    rstActivated.first();
    rstActivated.setAccion(AccionNN.N);
    rstActivated.update('SYSUSER11_STATUS', 1);
    rstActivated.setAccion(AccionNN.N);

    rstClientesPendientes.deleteBuffer();
    return rstActivated;
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
