import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxController/smxRowSetTrack.dart';

import '../smxSaldiFyCliente_dashboard_controller.dart';

class SmxSaldiFyClienteAnfitrionController extends SmxController {
  static const String _aliasPlan = 'QRY_SYSUSER12';

  final SmxSaldiFyClienteDashboardController _dashboardController;
  late SmxRowSet rstPlan;

  SmxSaldiFyClienteAnfitrionController({
    required super.alias,
    required super.data,
    required SmxSaldiFyClienteDashboardController dashboardController,
  }) : _dashboardController = dashboardController;

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    addSql(
      _aliasPlan,
      'select * from QRY_SYSUSER12(${_dashboardController.idSysuser11})',
    );

    await SmxRowSetTrack.run(
      controller: this,
      call: () => getRowSetFuture(_aliasPlan),
    );

    rstPlan = getRowset(_aliasPlan);
    if (rstPlan.getRowCount() > 0) {
      rstPlan.first();
    }
  }

  bool get hasPlan => rstPlan.getRowCount() > 0;

  String get nombreAnfitrion => _dashboardController.anfitrionNombreCompleto;

  String get telefonoAnfitrion => _dashboardController.anfitrionTelefono.trim();

  String get correoAnfitrion => _dashboardController.anfitrionCorreo.trim();

  String get estadoRelacionLabel {
    if (!hasPlan) return 'Pendiente';
    return _dashboardController.anfitrionRelacionEstado.trim();
  }

  Future<void> launchWhatsApp(BuildContext context) {
    return _dashboardController.launchWhatsApp(context);
  }

  String get cortePlanLabel {
    if (!hasPlan) return 'Pendiente - Pendiente';
    return '$corteNombre - $planNombre';
  }

  String get planNombre {
    return switch (rstPlan.getValue('SYSUSER12_PLAN')) {
      1 => 'Fondo',
      2 => 'Debito',
      3 => 'Credito',
      _ => 'Pendiente',
    };
  }

  String get planDetalle {
    if (!hasPlan) return 'Pendiente';

    final porcentaje = rstPlan.getValue('SYSUSER12_PORCENTAJE');

    return switch (rstPlan.getValue('SYSUSER12_PLAN')) {
      1 => 'Cada pago libera disponible',
      2 => 'Pago total al corte',
      3 => 'Pago minimo ${porcentaje.toStringAsFixed(0)}%',
      _ => 'Credito pendiente',
    };
  }

  String get corteNombre {
    return switch (rstPlan.getValue('SYSUSER12_CORTE_TIPO')) {
      1 => 'Mensual',
      2 => 'Quincenal',
      3 => 'Semanal',
      _ => 'Pendiente',
    };
  }

  String get fechaCorte {
    if (!hasPlan) return '__/__/____';
    return rstPlan.getValueFormatDate('FECHA_CORTE');
  }

  String get diasVencimientoLabel {
    if (!hasPlan) return 'Pendiente';

    final dias = diasAlVencimiento;
    if (dias == 0) return 'Vence hoy';
    if (dias == 1) return 'Falta 1 dia';
    if (dias > 1) return 'Faltan $dias dias';
    if (dias == -1) return 'Atraso 1 dia';
    return 'Atraso ${dias * -1} dias';
  }

  int get diasAlVencimiento => rstPlan.getValue('DIAS_AL_VTO');

  bool get vencimientoPendiente => !hasPlan;

  bool get vencimientoAlerta => hasPlan && diasAlVencimiento == 0;

  bool get vencimientoVencido => hasPlan && diasAlVencimiento < 0;

  @override
  Future<void> save() async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}
}
