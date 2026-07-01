import 'package:flutter/foundation.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxController/smxRowSetTrack.dart';

import '../../../smxApis/smxConstants.dart';

class SmxSaldiFyClienteMetricasController extends SmxController {
  final int relaSysuser10Anfitrion;
  final ValueNotifier<SmxRowSet?> rstMetricas = ValueNotifier<SmxRowSet?>(null);
  bool _refreshingMetricas = false;

  SmxSaldiFyClienteMetricasController({
    required super.alias,
    required super.data,
    required this.relaSysuser10Anfitrion,
  });

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    _prepareMetricasSql();

    await SmxRowSetTrack.run(controller: this, call: () => _loadMetricas());
  }

  Future<void> refreshMetricasBackground() async {
    if (_refreshingMetricas) return;

    _refreshingMetricas = true;
    try {
      _prepareMetricasSql();
      await _loadMetricas();
    } catch (_) {
      return;
    } finally {
      _refreshingMetricas = false;
    }
  }

  void _prepareMetricasSql() {
    removeSql('QRY_SYSUSER11_SALDOS_INVITADO');

    addSql(
      'QRY_SYSUSER11_SALDOS_INVITADO',
      'select * from QRY_SYSUSER11_SALDOS_INVITADO('
          '${SmxConstants.controllerMain.rstSysUser10.getId()}, '
          '$relaSysuser10Anfitrion)',
    );
  }

  Future<void> _loadMetricas() async {
    await getRowSetFuture('QRY_SYSUSER11_SALDOS_INVITADO');

    rstMetricas.value = getRowset('QRY_SYSUSER11_SALDOS_INVITADO');
    rstMetricas.value!.first();
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
