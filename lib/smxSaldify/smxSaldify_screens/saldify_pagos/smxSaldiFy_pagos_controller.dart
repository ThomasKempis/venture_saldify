import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_core_connect/smxJson/SmxJsonUtil.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

class SmxSaldiFyPagosController extends SmxController {
  final int idSysuser11;

  late SmxRowSet rstPagos;
  late SmxRowSet rstPago;
  bool lastSaveOk = false;
  double lastSavedImporte = 0.0;

  SmxSaldiFyPagosController({
    required super.alias,
    required super.data,
    required this.idSysuser11,
  });

  int get rowCount => rstPagos.getRowCount();

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

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

    final importe = _toDouble(rstPago.getValue('SYSUSER50_IMPORTE'));
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

  String getReferenciaAt(int index) {
    rstPagos.index(index);
    return rstPagos.getValue('SYSUSER50_REFERENCIA')?.toString() ?? '';
  }

  String getFechaAt(int index) {
    rstPagos.index(index);
    return _formatDate(rstPagos.getValue('SYSUSER50_FECHA'));
  }

  String getImporteAt(int index) {
    rstPagos.index(index);
    return _formatMoney(rstPagos.getValue('SYSUSER50_IMPORTE'));
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
  }

  void _clearInputs() {
    setText('SYSUSER50_REFERENCIA', '');
    setNumericDbl('SYSUSER50_IMPORTE', 0.0);
    setDate('SYSUSER50_FECHA', DateTime.now());
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
