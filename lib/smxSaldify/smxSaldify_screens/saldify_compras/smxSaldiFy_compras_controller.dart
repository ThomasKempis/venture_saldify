import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_core_connect/smxJson/SmxJsonUtil.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

class SmxSaldiFyComprasController extends SmxController {
  final int idSysuser11;

  late SmxRowSet rstCompras;
  late SmxRowSet rstCompra;
  bool lastSaveOk = false;
  double lastSavedImporte = 0.0;

  SmxSaldiFyComprasController({
    required super.alias,
    required super.data,
    required this.idSysuser11,
  });

  int get rowCount => rstCompras.getRowCount();

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    await _prepareComprasSesion();
    await prepareCompraNueva();
  }

  Future<void> refreshCompras() async {
    await _prepareComprasSesion();
  }

  @override
  Future<void> save({double? disponible}) async {
    lastSaveOk = false;
    lastSavedImporte = 0.0;

    final context = data.context;
    if (context == null) return;

    if (!validateWidgets(context)) {
      return;
    }

    final importe = _toDouble(rstCompra.getValue('SYSUSER40_IMPORTE'));
    if (importe <= 0) {
      showValidDialog(
        context,
        mensaje: 'Debe ingresar un importe mayor a cero.',
      );
      return;
    }

    if (disponible != null && importe > disponible) {
      showValidDialog(
        context,
        mensaje: 'La compra supera el credito disponible.',
      );
      return;
    }

    await showDialogWait(context, () async {
      await callTroncalSave(rstCompra);
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
    _addCompraSesion();
    await prepareCompraNueva();
  }

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}

  String getConceptoAt(int index) {
    rstCompras.index(index);
    return rstCompras.getValue('SYSUSER40_CONCEPTO')?.toString() ?? '';
  }

  String getFechaAt(int index) {
    rstCompras.index(index);
    return _formatDate(rstCompras.getValue('SYSUSER40_FECHA'));
  }

  String getImporteAt(int index) {
    rstCompras.index(index);
    return _formatMoney(rstCompras.getValue('SYSUSER40_IMPORTE'));
  }

  Future<void> _prepareComprasSesion() async {
    await _ensureCompraVacia();

    rstCompras = SmxConstants.rstCompraVacia!.copy();
    rstCompras.tabla = 'SYSUSER40_DET_COMPRAS';
  }

  Future<void> prepareCompraNueva() async {
    await _ensureCompraVacia();

    rstCompra = SmxConstants.rstCompraVacia!.copy();
    rstCompra.tabla = 'SYSUSER40_DET_COMPRAS';
    rstCompra.insert();

    data.accion = AccionNN.I;
    data.tablaTroncalRst = rstCompra;
    data.tablaTroncal = 'SYSUSER40_DET_COMPRAS';

    _setDefaults();
    _clearInputs();
  }

  void _addCompraSesion() {
    rstCompra.first();
    final row = rstCompra.getRowsList().first.clone();
    row.accion = AccionNN.N.toJson();
    rstCompras.getRowsList().add(row);
    rstCompras.last();
  }

  Future<void> _ensureCompraVacia() async {
    if (SmxConstants.rstCompraVacia != null) return;

    removeSql('SYSUSER40_EMPTY');
    addSql(
      'SYSUSER40_EMPTY',
      'select * from SYSUSER40_DET_COMPRAS where 1 = 0',
    );

    await getRowSetFuture('SYSUSER40_EMPTY');

    SmxConstants.rstCompraVacia = getRowset('SYSUSER40_EMPTY');
    SmxConstants.rstCompraVacia!.tabla = 'SYSUSER40_DET_COMPRAS';
  }

  void _setDefaults() {
    rstCompra.update('RELA_SYSUSER11', idSysuser11);
    rstCompra.update(
      'RELA_SYSUSER10_ALTA',
      SmxConstants.controllerMain.rstSysUser10.getId(),
    );
    rstCompra.update('SYSUSER40_CONCEPTO', '');
    rstCompra.update('SYSUSER40_IMPORTE', 0.0);
    rstCompra.update('SYSUSER40_FECHA', DateTime.now());
  }

  void _clearInputs() {
    setText('SYSUSER40_CONCEPTO', '');
    setNumericDbl('SYSUSER40_IMPORTE', 0.0);
    setDate('SYSUSER40_FECHA', DateTime.now());
  }

  String _formatDate(dynamic value) {
    DateTime? date;
    if (value is DateTime) {
      date = value;
    } else if (value != null) {
      date = DateTime.tryParse(value.toString());
    }

    if (date == null) return '';

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String _formatMoney(dynamic value) {
    final amount = _toDouble(value);
    final text = amount.toStringAsFixed(2);
    final parts = text.split('.');
    final entero = parts.first.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (match) => ',',
    );
    return '\$$entero.${parts.last}';
  }

  double _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse((value?.toString() ?? '').replaceAll(',', '')) ??
        0.0;
  }
}
