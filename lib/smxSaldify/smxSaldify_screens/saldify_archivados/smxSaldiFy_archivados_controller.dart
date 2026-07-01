import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_core_connect/smxJson/SmxJsonUtil.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxController/smxRowSetTrack.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

import '../../../smxApis/smxConstants.dart';

class SmxSaldiFyArchivadosController extends SmxController {
  static const int statusActivo = 1;
  static const int statusArchivado = 2;

  SmxRowSet rstArchivados = SmxRowSet.newRowSet([]);

  SmxSaldiFyArchivadosController({required super.alias, required super.data});

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    addSql(
      'QRY_SYSUSER11_ARCHIVADOS',
      'select * from QRY_SYSUSER11($statusArchivado, ${SmxConstants.controllerMain.rstSysUser10.getId()})',
    );

    await SmxRowSetTrack.run(
      controller: this,
      call: () => getRowSetFuture('QRY_SYSUSER11_ARCHIVADOS'),
    );

    rstArchivados = getRowset('QRY_SYSUSER11_ARCHIVADOS');
    rstArchivados.first();
  }

  bool get hasArchivados => rstArchivados.getRowCount() > 0;

  String getClientName() {
    return rstArchivados.getValue('SYSUSER10_INVITADO')?.toString() ?? '';
  }

  String getClientStatus() {
    return rstArchivados.getValue('SYSUSER12_STATUS')?.toString() ?? '';
  }

  String getClientStatusType() {
    return rstArchivados.getValue('SYSUSER12_STATUS_TIPO')?.toString() ?? '';
  }

  String getClientCutDate() {
    return rstArchivados.getValue('SYSUSER12_CORTE')?.toString() ?? '';
  }

  String getClientCredit() {
    return rstArchivados.getValue('SYSUSER12_CREDITO')?.toString() ?? '';
  }

  String getClientAvailableCredit() {
    return rstArchivados.getValue('SYSUSER12_DISPONIBLE')?.toString() ?? '0';
  }

  String getClientPurchases() {
    return rstArchivados.getValue('SYSUSER12_COMPRAS')?.toString() ?? '0';
  }

  String getClientPayments() {
    return rstArchivados.getValue('SYSUSER12_PAGOS')?.toString() ?? '0';
  }

  String getClientBalance() {
    return rstArchivados.getValue('SYSUSER12_BALANCE')?.toString() ?? '';
  }

  int getClientRelationId() {
    return rstArchivados.getId();
  }

  Future<bool> reactivateArchivadoAt(int index) async {
    final context = data.context;
    if (context == null) return false;

    rstArchivados.index(index);
    final idSysuser11 = rstArchivados.getId();
    if (idSysuser11 <= 0) return false;

    final aliasUpdate = 'SYSUSER11_REACTIVAR_$idSysuser11';
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
          message: 'No se encontro la relacion archivada del cliente.',
        );
      }
      return false;
    }

    data.accion = AccionNN.W;
    rstUpdate.tabla = 'SYSUSER11_DET_CONTACTOS';
    rstUpdate.first();
    rstUpdate.setAccion(AccionNN.W);
    rstUpdate.update('SYSUSER11_STATUS', statusActivo);

    if (!context.mounted) return false;
    await showDialogWait(context, () async {
      await callTroncalSave(rstUpdate);
    });

    if (jsonSend.getError() != null) {
      if (context.mounted) {
        showSystemErrorDialog(context, message: jsonSend.error!);
      }
      return false;
    }

    rstArchivados.index(index);
    rstArchivados.deleteBuffer();
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
