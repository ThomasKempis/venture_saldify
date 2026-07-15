import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxController/smxRowSetTrack.dart';

import '../../../smxApis/smxConstants.dart';

class SmxSaldiFyClienteHistorialController extends SmxController {
  final int relaSysuser10Anfitrion;
  late SmxRowSet rstHistorial;

  SmxSaldiFyClienteHistorialController({
    required super.alias,
    required super.data,
    required this.relaSysuser10Anfitrion,
  });

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    removeSql('QRY_SYSUSER10_HISTORIAL');

    addSql(
      'QRY_SYSUSER10_HISTORIAL',
      'select * from QRY_SYSUSER10_HISTORIAL('
          '${SmxConstants.controllerMain.rstSysUser10.getId()}, '
          '$relaSysuser10Anfitrion)',
    );

    await SmxRowSetTrack.run(
      controller: this,
      call: () => getRowSetFuture('QRY_SYSUSER10_HISTORIAL'),
    );

    rstHistorial = getRowset('QRY_SYSUSER10_HISTORIAL');
    if (rstHistorial.getRowCount() > 0) {
      rstHistorial.first();
    }
  }

  String getMovimientoTipo() {
    return rstHistorial.getValue('SYSUSER90_TIPO')?.toString() ?? '';
  }

  int getMovimientoId() {
    final value = rstHistorial.getValue('ID_SYSUSER90');
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String getMovimientoFolio() {
    final tipo = getMovimientoTipo().trim().toLowerCase();
    final id = getMovimientoId();
    final prefix = tipo == 'pago'
        ? 'P'
        : tipo == 'compra'
        ? 'C'
        : 'M';

    return '$prefix-${id.toString().padLeft(5, '0')}';
  }

  String getMovimientoConcepto() {
    return rstHistorial.getValue('SYSUSER90_CONCEPTO')?.toString() ?? '';
  }

  String getMovimientoImporte() {
    final total = rstHistorial.getValue('SYSUSER90_TOTAL');
    final value = total ?? rstHistorial.getValue('SYSUSER90_IMPORTE');
    final amount = value is num
        ? value.toDouble()
        : double.tryParse(value?.toString() ?? '') ?? 0.0;
    return SmxRowSet.formatAmount(amount);
  }

  String getMovimientoCalculo() {
    if (getMovimientoTipo().toLowerCase() != 'compra') return '';
    final cantidad = rstHistorial.getValue('SYSUSER90_CANTIDAD');
    if (cantidad == null) return '';
    final cantidadText = cantidad is num && cantidad == cantidad.toInt()
        ? cantidad.toInt().toString()
        : cantidad.toString();
    final importe = rstHistorial.getValueFormatAmount('SYSUSER90_IMPORTE');
    return '$cantidadText × $importe';
  }

  String getMovimientoFecha() {
    return _formatDateMeses(rstHistorial.getValue('SYSUSER90_FECHA'));
  }

  int getMovimientoStatus() {
    final value = rstHistorial.getValue('SYSUSER90_STATUS');
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String getMovimientoMotivo() {
    try {
      return rstHistorial.getValue('SYSUSER90_MOTIVO')?.toString().trim() ?? '';
    } catch (_) {
      return '';
    }
  }

  String _formatDateMeses(dynamic value) {
    final date = _toDate(value);
    if (date == null) return value?.toString() ?? '';

    const months = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]}';
  }

  DateTime? _toDate(dynamic value) {
    if (value is DateTime) return value;

    final raw = value?.toString().trim();
    if (raw == null || raw.isEmpty) return null;

    return DateTime.tryParse(raw);
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
