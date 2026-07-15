import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smx_message_dialog.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxController/smxRowSetTrack.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

import '../../../smxApis/smxConstants.dart';

class SmxSaldiFyHistorialController extends SmxController {
  static const int rechazoMotivoMinLength = 30;
  static const int rechazoMotivoMaxLength = 3000;

  final int idCliente;

  SmxRowSet rstHistorial = SmxRowSet.newRowSet([]);
  double saldo = 0.0;
  bool hasChanges = false;

  SmxSaldiFyHistorialController({
    required super.alias,
    required super.data,
    required this.idCliente,
  });

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    addSql(
      'QRY_SYSUSER10_HISTORIAL',
      'select * from QRY_SYSUSER10_HISTORIAL($idCliente, ${SmxConstants.controllerMain.rstSysUser10.getId()})',
    );

    await SmxRowSetTrack.run(
      controller: this,
      call: () => getRowSetFuture('QRY_SYSUSER10_HISTORIAL'),
    );

    rstHistorial = getRowset('QRY_SYSUSER10_HISTORIAL');
    if (rstHistorial.getRowCount() > 0) {
      rstHistorial.first();
    }
    saldo = _sumImportes();
  }

  bool get hasMovimientos => rstHistorial.getRowCount() > 0;

  String getSaldo() {
    return SmxRowSet.formatAmount(saldo);
  }

  String getTipoAt(int index) {
    rstHistorial.index(index);
    return _formatTipo(rstHistorial.getValue('SYSUSER90_TIPO'));
  }

  int getMovimientoIdAt(int index) {
    rstHistorial.index(index);
    return _getIntValue('ID_SYSUSER90');
  }

  String getFolioAt(int index) {
    final tipo = getTipoAt(index).toLowerCase();
    final id = getMovimientoIdAt(index);
    final prefix = tipo == 'pago'
        ? 'P'
        : tipo == 'compra'
        ? 'C'
        : 'M';

    return '$prefix-${id.toString().padLeft(5, '0')}';
  }

  String getConceptoAt(int index) {
    rstHistorial.index(index);
    return rstHistorial.getValue('SYSUSER90_CONCEPTO')?.toString() ?? '';
  }

  String getImporteAt(int index) {
    rstHistorial.index(index);
    return SmxRowSet.formatAmount(_getTotalValue());
  }

  String getCalculoAt(int index) {
    rstHistorial.index(index);
    if (getTipoAt(index).toLowerCase() != 'compra') return '';
    final cantidad = rstHistorial.getValue('SYSUSER90_CANTIDAD');
    if (cantidad == null) return '';
    final cantidadText = cantidad is num && cantidad == cantidad.toInt()
        ? cantidad.toInt().toString()
        : cantidad.toString();
    final importe = rstHistorial.getValueFormatAmount('SYSUSER90_IMPORTE');
    return '$cantidadText × $importe';
  }

  String getFechaAt(int index) {
    rstHistorial.index(index);
    return rstHistorial.getValueFormatDate('SYSUSER90_FECHA');
  }

  String getOwnerAt(int index) {
    rstHistorial.index(index);
    final owner = rstHistorial.getValue('SYSUSER90_OWNER')?.toString() ?? '';
    final clean = owner.trim();
    if (clean.isEmpty) return '';

    return 'Registrado por ${clean.toLowerCase()}';
  }

  String getMotivoAt(int index) {
    rstHistorial.index(index);
    try {
      return rstHistorial.getValue('SYSUSER90_MOTIVO')?.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  int getStatusAt(int index) {
    rstHistorial.index(index);
    return _getIntValue('SYSUSER90_STATUS');
  }

  int getRelaCompraAt(int index) {
    rstHistorial.index(index);
    return _getIntValue('RELA_SYSUSER40');
  }

  int getRelaPagoAt(int index) {
    rstHistorial.index(index);
    return _getIntValue('RELA_SYSUSER50');
  }

  bool canSetCompraPendienteAt(int index) {
    return getTipoAt(index).toLowerCase() == 'compra' &&
        getStatusAt(index) == 0 &&
        getRelaCompraAt(index) > 0;
  }

  bool canSetCompraEntregadaAt(int index) {
    return getTipoAt(index).toLowerCase() == 'compra' &&
        getStatusAt(index) < 2 &&
        getRelaCompraAt(index) > 0;
  }

  bool canConfirmPagoAt(int index) {
    return getTipoAt(index).toLowerCase() == 'pago' &&
        getStatusAt(index) == 0 &&
        getRelaPagoAt(index) > 0;
  }

  bool canRejectPagoAt(int index) {
    return getTipoAt(index).toLowerCase() == 'pago' &&
        getStatusAt(index) == 1 &&
        getRelaPagoAt(index) > 0;
  }

  bool canViewRejectedPagoMotivoAt(int index) {
    return getTipoAt(index).toLowerCase() == 'pago' &&
        getStatusAt(index) == 2 &&
        getMotivoAt(index).isNotEmpty;
  }

  Future<bool> updateMovimientoStatusAt(int index, int status) async {
    final context = data.context;
    if (context == null) return false;

    rstHistorial.index(index);
    final tipo = getTipoAt(index).toLowerCase();
    final accion = tipo == 'compra'
        ? 'C'
        : tipo == 'pago'
        ? 'P'
        : '';
    final id = accion == 'C' ? getRelaCompraAt(index) : getRelaPagoAt(index);

    if (accion.isEmpty || id <= 0) {
      if (context.mounted) {
        showSmxSystemErrorDialog(
          context,
          message: 'No se pudo identificar el movimiento a actualizar.',
        );
      }
      return false;
    }

    final aliasUpdate = 'UPDATE_SYSUSER40_SYSUSER50';
    addSTrans(
      aliasUpdate,
      "select * from UPDATE_SYSUSER40_SYSUSER50('$accion', $id, $status, '')",
    );

    if (!await _sendMovimientoUpdate(context, aliasUpdate)) return false;

    rstHistorial.index(index);
    rstHistorial.update('SYSUSER90_STATUS', status);
    saldo = _sumImportes();
    hasChanges = true;
    return true;
  }

  Future<bool> rejectPagoAt(int index, String motivo) async {
    final context = data.context;
    if (context == null) return false;

    rstHistorial.index(index);
    final id = getRelaPagoAt(index);
    final cleanMotivo = motivo.trim();

    if (!canRejectPagoAt(index) ||
        cleanMotivo.length < rechazoMotivoMinLength ||
        cleanMotivo.length > rechazoMotivoMaxLength) {
      if (context.mounted) {
        showSmxSystemErrorDialog(
          context,
          message:
              'No se pudo identificar un pago confirmado o el motivo es insuficiente.',
        );
      }
      return false;
    }

    final escapedMotivo = _sqlString(cleanMotivo);
    final aliasUpdate = 'UPDATE_SYSUSER40_SYSUSER50';
    addSTrans(
      aliasUpdate,
      "select * from UPDATE_SYSUSER40_SYSUSER50('PR', $id, 2, '$escapedMotivo')",
    );

    if (!await _sendMovimientoUpdate(context, aliasUpdate)) return false;

    rstHistorial.index(index);
    rstHistorial.update('SYSUSER90_STATUS', 2);
    try {
      rstHistorial.update('SYSUSER90_MOTIVO', cleanMotivo);
    } catch (_) {}
    saldo = _sumImportes();
    hasChanges = true;
    return true;
  }

  Future<bool> _sendMovimientoUpdate(
    dynamic context,
    String aliasUpdate,
  ) async {
    await showDialogWait(context, () async {
      await getCallWS();
    });

    if (jsonSend.getError() != null) {
      if (context.mounted) {
        showSmxSystemErrorDialog(context, message: jsonSend.error!);
      }
      return false;
    }

    final rstUpdate = getRowset(aliasUpdate);
    if (rstUpdate.getRowCount() == 0) {
      if (context.mounted) {
        showSmxSystemErrorDialog(
          context,
          message: 'No se recibio confirmacion del cambio.',
        );
      }
      return false;
    }

    rstUpdate.first();
    final result = rstUpdate.getValue('TMPUSER99_STATUS')?.toString() ?? '';
    if (result.toUpperCase() != 'OK') {
      if (context.mounted) {
        showSmxSystemErrorDialog(
          context,
          message: 'No se pudo actualizar el movimiento.',
        );
      }
      return false;
    }

    return true;
  }

  String _sqlString(String value) => value.replaceAll("'", "''");

  String _formatTipo(dynamic value) {
    final tipo = value?.toString().trim() ?? '';
    if (tipo.isEmpty) return '';

    final lower = tipo.toLowerCase();
    if (lower == 'compra') return 'Compra';
    if (lower == 'pago') return 'Pago';

    return tipo[0].toUpperCase() + tipo.substring(1).toLowerCase();
  }

  double _sumImportes() {
    var total = 0.0;

    rstHistorial.beforeFirst();
    while (rstHistorial.next()) {
      final tipo =
          rstHistorial
              .getValue('SYSUSER90_TIPO')
              ?.toString()
              .trim()
              .toLowerCase() ??
          '';
      final status = _getIntValue('SYSUSER90_STATUS');
      if (tipo == 'pago' && status != 1) continue;

      total += _getTotalValue();
    }

    return total;
  }

  double _getTotalValue() {
    final total = rstHistorial.getValue('SYSUSER90_TOTAL');
    final value = total ?? rstHistorial.getValue('SYSUSER90_IMPORTE');
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  int _getIntValue(String field) {
    final value = rstHistorial.getValue(field);
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
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
