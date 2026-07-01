import 'package:flutter/foundation.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxController/smxRowSetTrack.dart';
import '../../../smxApis/smxConstants.dart';

class SmxSaldiFyMetricasController extends SmxController {
  final ValueNotifier<SmxRowSet?> rstMetricas = ValueNotifier<SmxRowSet?>(null);
  bool _refreshingMetricas = false;

  SmxSaldiFyMetricasController({required super.alias, required super.data});

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
    removeSql('QRY_SYSUSER11_SALDOS_ANFITRION');

    addSql(
      'QRY_SYSUSER11_SALDOS_ANFITRION',
      'select * from QRY_SYSUSER11_SALDOS_ANFITRION(${SmxConstants.controllerMain.rstSysUser10.getId()})',
    );
  }

  Future<void> _loadMetricas() async {
    await getRowSetFuture('QRY_SYSUSER11_SALDOS_ANFITRION');

    rstMetricas.value = getRowset('QRY_SYSUSER11_SALDOS_ANFITRION');
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
