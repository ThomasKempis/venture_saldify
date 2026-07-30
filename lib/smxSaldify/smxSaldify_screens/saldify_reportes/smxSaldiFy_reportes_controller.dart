import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

import '../../../smxApis/smxConstants.dart';

enum SmxSaldiFyReporteTipo { ventas, cobros }

enum SmxSaldiFyCompraStatus {
  solicitada(0, 'Compra solicitada'),
  pendiente(1, 'Compra pendiente'),
  entregada(2, 'Compra entregada');

  final int value;
  final String label;

  const SmxSaldiFyCompraStatus(this.value, this.label);

  static SmxSaldiFyCompraStatus fromValue(int value) {
    return SmxSaldiFyCompraStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => SmxSaldiFyCompraStatus.solicitada,
    );
  }
}

enum SmxSaldiFyPagoStatus {
  pendienteConfirmar(0, 'Pendiente confirmar'),
  depositoConfirmado(1, 'Deposito confirmado'),
  depositoRechazado(2, 'Deposito Rechazado');

  final int value;
  final String label;

  const SmxSaldiFyPagoStatus(this.value, this.label);

  static SmxSaldiFyPagoStatus fromValue(int value) {
    return SmxSaldiFyPagoStatus.values.firstWhere(
      (item) => item.value == value,
      orElse: () => SmxSaldiFyPagoStatus.pendienteConfirmar,
    );
  }
}

class SmxSaldiFyReportesController extends SmxController {
  static const aliasReportes = 'QRY_SYSUSER10_HISTORIAL_REP';

  SmxSaldiFyReporteTipo reporteTipo = SmxSaldiFyReporteTipo.ventas;
  late DateTime fechaDesde;
  late DateTime fechaHasta;
  SmxRowSet rstReportes = SmxRowSet.newRowSet([]);

  SmxSaldiFyReportesController({required super.alias, required super.data});

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    final today = DateUtils.dateOnly(DateTime.now());
    fechaHasta = today;
    fechaDesde = today.subtract(const Duration(days: 7));
  }

  void setReporteTipo(SmxSaldiFyReporteTipo value) {
    reporteTipo = value;
  }

  void setFechaDesde(DateTime value) {
    fechaDesde = DateUtils.dateOnly(value);
  }

  void setFechaHasta(DateTime value) {
    fechaHasta = DateUtils.dateOnly(value);
  }

  Future<bool> generarReporte() async {
    final context = data.context;
    if (context == null) return false;

    final idAnfitrion = SmxConstants.controllerMain.rstSysUser10.getId();
    final desde = _formatSqlDate(fechaDesde);
    final hasta = _formatSqlDate(fechaHasta);
    final tipo = reporteTipo.tipoMovimiento;

    removeSql(aliasReportes);
    addSTrans(
      aliasReportes,
      "select * from QRY_SYSUSER10_HISTORIAL_REP($idAnfitrion, '$desde', '$hasta', '$tipo')",
    );

    await showDialogWait(context, () async {
      await getCallWS();
    });

    if (jsonSend.getError() != null) return false;

    rstReportes = getRowset(aliasReportes);
    if (rstReportes.getRowCount() > 0) {
      rstReportes.first();
    }

    notifyListeners();
    return true;
  }

  String _formatSqlDate(DateTime date) {
    final cleanDate = DateUtils.dateOnly(date);
    final month = cleanDate.month.toString().padLeft(2, '0');
    final day = cleanDate.day.toString().padLeft(2, '0');

    return '${cleanDate.year}-$month-$day';
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

extension SmxSaldiFyReporteTipoDb on SmxSaldiFyReporteTipo {
  String get tipoMovimiento {
    return switch (this) {
      SmxSaldiFyReporteTipo.ventas => 'compra',
      SmxSaldiFyReporteTipo.cobros => 'pago',
    };
  }
}
