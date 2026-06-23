import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_core_connect/smxJson/SmxJsonUtil.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

class SmxSaldiFyClienteCreditoController extends SmxController {
  final int idSysuser11;

  late SmxRowSet rstSysuser12;
  bool lastSaveOk = false;

  SmxSaldiFyClienteCreditoController({
    required super.alias,
    required super.data,
    required this.idSysuser11,
  });

  bool get isAlta =>
      rstSysuser12.getRowCount() == 0 || rstSysuser12.getId() <= 0;

  int get plan {
    final value = _toInt(rstSysuser12.getValue('SYSUSER12_PLAN'));
    return value == 2 ? 2 : 1;
  }

  int get corteTipo => _toInt(rstSysuser12.getValue('SYSUSER12_CORTE_TIPO'));

  int get corteQuincena {
    final dia = _toInt(rstSysuser12.getValue('SYSUSER12_CORTE_DIA'));
    return dia == 0 ? 2 : 1;
  }

  int get corteDiaMensual {
    final dia = _toInt(rstSysuser12.getValue('SYSUSER12_CORTE_DIA'));
    return dia >= 1 && dia <= 28 ? dia : 5;
  }

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    addSql(
      'SYSUSER12',
      'select * from SYSUSER12_DEP_CLIENTES where RELA_SYSUSER11 = $idSysuser11',
    );

    await getRowSetFuture('SYSUSER12');

    rstSysuser12 = getRowset('SYSUSER12');
    rstSysuser12.tabla = 'SYSUSER12_DEP_CLIENTES';

    if (rstSysuser12.getRowCount() == 0) {
      data.accion = AccionNN.I;
      rstSysuser12.insert();
      _setDefaults();
    } else {
      data.accion = AccionNN.W;
      rstSysuser12.first();
      rstSysuser12.setAccion(AccionNN.W);
      _normalizePlan();
      _normalizeCorte();
    }

    data.tablaTroncalRst = rstSysuser12;
    data.tablaTroncal = 'SYSUSER12_DEP_CLIENTES';
  }

  void setPlan(int value) {
    rstSysuser12.update('SYSUSER12_PLAN', value == 2 ? 2 : 1);
  }

  void setCorteTipo(int value) {
    final previousTipo = corteTipo;
    rstSysuser12.update('SYSUSER12_CORTE_TIPO', value);

    if (value == 1) {
      rstSysuser12.update('SYSUSER12_CORTE_SEMANA', '0');
      final dia = _toInt(rstSysuser12.getValue('SYSUSER12_CORTE_DIA'));
      rstSysuser12.update('SYSUSER12_CORTE_DIA', dia.clamp(1, 28));
      return;
    }

    if (value == 2) {
      rstSysuser12.update('SYSUSER12_CORTE_SEMANA', '0');
      final dia = _toInt(rstSysuser12.getValue('SYSUSER12_CORTE_DIA'));
      final quincenaValida = dia == 0 || dia == 15;
      rstSysuser12.update(
        'SYSUSER12_CORTE_DIA',
        previousTipo == 2 && quincenaValida ? dia : 15,
      );
      return;
    }

    rstSysuser12.update('SYSUSER12_CORTE_DIA', 0);
    final semana =
        rstSysuser12.getValue('SYSUSER12_CORTE_SEMANA')?.toString() ?? '';
    if (!_diasSemana.contains(semana)) {
      rstSysuser12.update('SYSUSER12_CORTE_SEMANA', _diasSemana.first);
    }
  }

  void setCorteSemana(String value) {
    rstSysuser12.update('SYSUSER12_CORTE_SEMANA', value);
    rstSysuser12.update('SYSUSER12_CORTE_DIA', 0);
  }

  void setCorteQuincena(int value) {
    rstSysuser12.update('SYSUSER12_CORTE_SEMANA', '0');
    rstSysuser12.update('SYSUSER12_CORTE_DIA', value == 2 ? 0 : 15);
  }

  void setCorteDiaMensual(int value) {
    rstSysuser12.update('SYSUSER12_CORTE_SEMANA', '0');
    rstSysuser12.update('SYSUSER12_CORTE_DIA', value.clamp(1, 28));
  }

  String get corteSemana {
    final value =
        rstSysuser12.getValue('SYSUSER12_CORTE_SEMANA')?.toString() ?? '';
    return _diasSemana.contains(value) ? value : _diasSemana.first;
  }

  List<String> get diasSemana => _diasSemana;

  @override
  Future<void> save() async {
    lastSaveOk = false;

    final context = data.context;
    if (context == null) return;

    if (!validateWidgets(context)) {
      return;
    }

    if (!_validateCorte(context)) {
      return;
    }

    await showDialogWait(context, () async {
      await callTroncalSave(rstSysuser12);
    });

    lastSaveOk = true;
  }

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}

  void _setDefaults() {
    rstSysuser12.update('RELA_SYSUSER11', idSysuser11);
    rstSysuser12.update('SYSUSER12_CREDITO', 0.0);
    rstSysuser12.update('SYSUSER12_PLAN', 1);
    rstSysuser12.update('SYSUSER12_CORTE_TIPO', 1);
    rstSysuser12.update('SYSUSER12_CORTE_SEMANA', '0');
    rstSysuser12.update('SYSUSER12_CORTE_DIA', 5);
  }

  void _normalizePlan() {
    final value = _toInt(rstSysuser12.getValue('SYSUSER12_PLAN'));
    if (value != 1 && value != 2) {
      setPlan(1);
    }
  }

  void _normalizeCorte() {
    final tipo = corteTipo;
    if (tipo < 1 || tipo > 3) {
      setCorteTipo(1);
      return;
    }

    setCorteTipo(tipo);
  }

  bool _validateCorte(BuildContext context) {
    final credito = _toDouble(rstSysuser12.getValue('SYSUSER12_CREDITO'));
    if (credito <= 0) {
      showValidDialog(
        context,
        mensaje: 'Debe ingresar un credito mayor a cero.',
      );
      return false;
    }

    final tipo = corteTipo;
    if (tipo == 1) {
      final dia = _toInt(rstSysuser12.getValue('SYSUSER12_CORTE_DIA'));
      if (dia < 1 || dia > 28) {
        showValidDialog(
          context,
          mensaje: 'Para corte mensual el dia debe estar entre 1 y 28.',
        );
        return false;
      }
    }

    if (tipo == 2) {
      final dia = _toInt(rstSysuser12.getValue('SYSUSER12_CORTE_DIA'));
      if (dia != 0 && dia != 15) {
        showValidDialog(
          context,
          mensaje: 'Debe seleccionar primera o segunda quincena.',
        );
        return false;
      }
    }

    if (tipo == 3 && !_diasSemana.contains(corteSemana)) {
      showValidDialog(
        context,
        mensaje: 'Debe seleccionar un dia de corte semanal.',
      );
      return false;
    }

    return true;
  }

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse((value?.toString() ?? '').replaceAll(',', '')) ??
        0.0;
  }

  static const _diasSemana = [
    'Lunes',
    'Martes',
    'Miercoles',
    'Jueves',
    'Viernes',
  ];
}
