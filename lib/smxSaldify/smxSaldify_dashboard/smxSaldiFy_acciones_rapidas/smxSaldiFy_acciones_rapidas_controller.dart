import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';

import 'smxSaldiFy_acciones_rapidas_mock.dart';

class SmxSaldiFyAccionesRapidasController extends SmxController {
  late SmxRowSet rstAcciones;

  SmxSaldiFyAccionesRapidasController({
    required super.alias,
    required super.data,
  });

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    rstAcciones = getRstSmxSaldiFyAccionesRapidasMock();
    rstAcciones.first();
  }

  IconData getActionIcon() {
    final iconKey = rstAcciones.getValue('ICON_KEY')?.toString() ?? '';

    return switch (iconKey) {
      'CLIENTE' => Icons.add_rounded,
      'PRODUCTOS' => Icons.inventory_2_rounded,
      'COBRANZA' => Icons.bar_chart_rounded,
      'ARCHIVADOS' => Icons.archive_outlined,
      _ => Icons.touch_app_rounded,
    };
  }

  String getActionLabel() {
    return rstAcciones.getValue('LABEL')?.toString() ?? '';
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
