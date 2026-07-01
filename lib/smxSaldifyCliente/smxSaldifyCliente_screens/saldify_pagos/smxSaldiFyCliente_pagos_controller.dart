import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_core_connect/smxJson/SmxJsonUtil.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

import '../../smxSaldifyCliente_dashboard/smxSaldiFyCliente_metricas/smxSaldiFyCliente_metricas_snapshot.dart';

class SmxSaldiFyClientePagosController extends SmxController {
  final int idSysuser11;
  final int relaSysuser10Anfitrion;
  final SmxSaldiFyClienteMetricasSnapshot? metricasIniciales;

  late SmxRowSet rstPagos;
  late SmxRowSet rstPago;
  SmxRowSet? rstMetricas;
  bool lastSaveOk = false;
  double lastSavedImporte = 0.0;

  SmxSaldiFyClientePagosController({
    required super.alias,
    required super.data,
    required this.idSysuser11,
    required this.relaSysuser10Anfitrion,
    this.metricasIniciales,
  });

  int get rowCount => rstPagos.getRowCount();

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    if (metricasIniciales == null) {
      await _loadMetricas();
    }
    await _preparePagosSesion();
    await preparePagoNuevo();
  }

  @override
  Future<void> save({double? saldo}) async {
    lastSaveOk = false;
    lastSavedImporte = 0.0;

    final context = data.context;
    if (context == null) return;

    if (!validateWidgets(context)) {
      return;
    }

    final double importe = rstPago.getValue('SYSUSER50_IMPORTE');
    if (importe <= 0) {
      showValidDialog(
        context,
        mensaje: 'Debe ingresar un importe mayor a cero.',
      );
      return;
    }

    if (saldo != null && importe > saldo) {
      showValidDialog(context, mensaje: 'El pago supera el saldo pendiente.');
      return;
    }

    await showDialogWait(context, () async {
      await callTroncalSave(rstPago);
    });

    if (jsonSend.getError() != null) {
      final currentContext = data.context;
      if (currentContext != null && currentContext.mounted) {
        showSystemErrorDialog(currentContext, message: jsonSend.error!);
      }
      return;
    }

    lastSaveOk = true;
    lastSavedImporte = importe;
    _addPagoSesion();
    await preparePagoNuevo();
  }

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}

  double get credito => _getMetrica('SYSUSER12_CREDITO');

  double get disponible => _getMetrica('SYSUSER12_DISPONIBLE');

  double get saldo => _getMetrica('SYSUSER12_BALANCE');

  String getReferenciaAt(int index) {
    rstPagos.index(index);
    return rstPagos.getValue('SYSUSER50_REFERENCIA')?.toString() ?? '';
  }

  String getFechaAt(int index) {
    rstPagos.index(index);
    return rstPagos.getValueFormatDate('SYSUSER50_FECHA');
  }

  String getImporteAt(int index) {
    rstPagos.index(index);
    return rstPagos.getValueFormatAmount('SYSUSER50_IMPORTE');
  }

  Future<void> _loadMetricas() async {
    removeSql('QRY_SYSUSER11_SALDOS_INVITADO');

    addSql(
      'QRY_SYSUSER11_SALDOS_INVITADO',
      'select * from QRY_SYSUSER11_SALDOS_INVITADO('
          '${SmxConstants.controllerMain.rstSysUser10.getId()}, '
          '$relaSysuser10Anfitrion)',
    );

    await getRowSetFuture('QRY_SYSUSER11_SALDOS_INVITADO');

    rstMetricas = getRowset('QRY_SYSUSER11_SALDOS_INVITADO');
    if (rstMetricas!.getRowCount() > 0) {
      rstMetricas!.first();
    }
  }

  Future<void> _preparePagosSesion() async {
    await _ensurePagoVacio();

    rstPagos = SmxConstants.rstPagoVacio!.copy();
    rstPagos.tabla = 'SYSUSER50_DET_PAGOS';
  }

  Future<void> preparePagoNuevo() async {
    await _ensurePagoVacio();

    rstPago = SmxConstants.rstPagoVacio!.copy();
    rstPago.tabla = 'SYSUSER50_DET_PAGOS';
    rstPago.insert();

    data.accion = AccionNN.I;
    data.tablaTroncalRst = rstPago;
    data.tablaTroncal = 'SYSUSER50_DET_PAGOS';

    _setDefaults();
    _clearInputs();
  }

  void _addPagoSesion() {
    rstPago.first();
    final row = rstPago.getRowsList().first.clone();
    row.accion = AccionNN.N.toJson();
    rstPagos.getRowsList().add(row);
    rstPagos.last();
  }

  Future<void> _ensurePagoVacio() async {
    if (SmxConstants.rstPagoVacio != null) return;

    removeSql('SYSUSER50_EMPTY');
    addSql('SYSUSER50_EMPTY', 'select * from SYSUSER50_DET_PAGOS where 1 = 0');

    await getRowSetFuture('SYSUSER50_EMPTY');

    SmxConstants.rstPagoVacio = getRowset('SYSUSER50_EMPTY');
    SmxConstants.rstPagoVacio!.tabla = 'SYSUSER50_DET_PAGOS';
  }

  void _setDefaults() {
    rstPago.update('RELA_SYSUSER11', idSysuser11);
    rstPago.update(
      'RELA_SYSUSER10_ALTA',
      SmxConstants.controllerMain.rstSysUser10.getId(),
    );
    rstPago.update('SYSUSER50_REFERENCIA', '');
    rstPago.update('SYSUSER50_IMPORTE', 0.0);
    rstPago.update('SYSUSER50_FECHA', DateTime.now());
    rstPago.update('SYSUSER50_STATUS', 0);
  }

  void _clearInputs() {
    setText('SYSUSER50_REFERENCIA', '');
    setNumericDbl('SYSUSER50_IMPORTE', 0.0);
    setDate('SYSUSER50_FECHA', DateTime.now());
  }

  double _getMetrica(String field) {
    final metricas = metricasIniciales;
    if (metricas != null) {
      return switch (field) {
        'SYSUSER12_CREDITO' => metricas.credito,
        'SYSUSER12_DISPONIBLE' => metricas.disponible,
        'SYSUSER12_BALANCE' => metricas.saldo,
        _ => 0.0,
      };
    }

    final rowSet = rstMetricas;
    if (rowSet == null || rowSet.getRowCount() == 0) return 0.0;

    return rowSet.getValue(field);
  }
}
