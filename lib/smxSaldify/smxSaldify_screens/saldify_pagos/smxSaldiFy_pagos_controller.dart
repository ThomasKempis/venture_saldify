import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smx_message_dialog.dart';
import 'package:venture_core_connect/smxJson/SmxJsonUtil.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxPagos/smxPagosControllerContract.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

class SmxSaldiFyPagosController extends SmxPagosControllerContract {
  static const String ALIAS_LIST = 'ALIAS_PAGOS_LIST';
  static const String ALIAS_EMPTY = 'SYSUSER50_EMPTY';
  static const String ALIAS_IMAGES = 'SYSUSER50';
  static const String ALIAS_IMAGES_DATA = 'SYSUSER51';
  static const String VIEW_PAGOS = 'QRY_SYSUSER50';
  static const String TABLE_PAGOS = 'SYSUSER50_DET_PAGOS';
  static const String TABLE_IMAGES = 'SYSUSER51_DET_IMAGENES';

  final int idSysuser11;

  late SmxRowSet rstPagos;
  late SmxRowSet rstPago;
  late SmxRowSet rstImages;
  @override
  bool lastSaveOk = false;
  @override
  double lastSavedImporte = 0.0;
  final Map<int, int> _imageVersions = {};

  SmxSaldiFyPagosController({
    required super.alias,
    required super.data,
    required this.idSysuser11,
  });

  @override
  String get imagesAlias => ALIAS_IMAGES;
  @override
  String get imagesTable => TABLE_IMAGES;

  int get rowCount => rstPagos.getRowCount();
  @override
  List<int> get pagosPendientesIndexes => _getPagoIndexes(0);
  @override
  List<int> get pagosConfirmadosIndexes => _getPagoIndexes(1);
  @override
  int get currentPagoId => rstPago.getId();
  @override
  bool get isPagoPersistido => currentPagoId > 0;
  @override
  bool get isPagoNuevo => data.accion == AccionNN.I;
  @override
  bool get isSoloImagenes => isPagoPersistido && data.accion == AccionNN.N;
  @override
  bool get canEditPagoData =>
      _getStatusValue(rstPago.getValue('SYSUSER50_STATUS')) == 0;

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

    final mensajeValidar = getValidateOnlyMessage();
    if (mensajeValidar != null) {
      showSmxValidDialog(context, mensaje: mensajeValidar);
      return;
    }

    if (!canEditPagoData) {
      showSmxValidDialog(
        context,
        mensaje: 'Este pago ya no permite modificar datos.',
      );
      return;
    }

    final isAlta = data.accion == AccionNN.I;
    final importeAnterior = isAlta ? 0.0 : _getPagoImporteFromList();
    final double importe = rstPago.getValue('SYSUSER50_IMPORTE');
    if (importe <= 0) {
      showSmxValidDialog(
        context,
        mensaje: 'Debe ingresar un importe mayor a cero.',
      );
      return;
    }

    final limiteSaldo = saldo;
    if (limiteSaldo != null && importe > limiteSaldo) {
      showSmxValidDialog(
        context,
        mensaje: 'El pago supera el saldo pendiente.',
      );
      return;
    }

    await showDialogWait(context, () async {
      await callTroncalSave(rstPago);
    });

    if (jsonSend.getError() != null) {
      final currentContext = data.context;
      if (currentContext != null && currentContext.mounted) {
        showSmxSystemErrorDialog(currentContext, message: jsonSend.error!);
      }
      return;
    }

    lastSaveOk = true;
    lastSavedImporte = importe - importeAnterior;
    if (isAlta) {
      await _preparePagosSesion();
    } else {
      _updatePagoSesion();
      await _loadImagesForPago(currentPagoId);
      rstPago.setAccion(AccionNN.N);
      data.accion = AccionNN.W;
    }
    notifyListeners();
  }

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}

  @override
  String getReferenciaAt(int index) {
    rstPagos.index(index);
    return rstPagos.getValue('SYSUSER50_REFERENCIA')?.toString() ?? '';
  }

  @override
  String getFechaAt(int index) {
    rstPagos.index(index);
    return rstPagos.getValueFormatDate('SYSUSER50_FECHA');
  }

  @override
  String getImporteAt(int index) {
    rstPagos.index(index);
    return rstPagos.getValueFormatAmount('SYSUSER50_IMPORTE');
  }

  @override
  int getStatusAt(int index) {
    rstPagos.index(index);
    return _getStatusValue(rstPagos.getValue('SYSUSER50_STATUS'));
  }

  @override
  String getStatusLabelAt(int index) =>
      getStatusAt(index) == 0 ? 'Pendiente' : 'Depósito confirmado';

  @override
  int getPagoIdAt(int index) {
    rstPagos.index(index);
    return rstPagos.getId();
  }

  @override
  double getImporteValueAt(int index) {
    rstPagos.index(index);
    return _toDouble(rstPagos.getValue('SYSUSER50_IMPORTE'));
  }

  @override
  String getPagoImageUrlAt(int index) {
    rstPagos.index(index);
    final image = rstPagos.getValue('SYSUSER50_IMAGE')?.toString() ?? '';
    if (image.trim().isEmpty) return '';
    final version = _imageVersions[rstPagos.getId()];
    return '${SmxConstants.URL_IMAGES_SALDIFY}${image.trim()}-MINI.JPG${version == null ? '' : '?v=$version'}';
  }

  Future<void> _preparePagosSesion() async {
    await _ensurePagoVacio();

    removeSql(ALIAS_LIST);
    addSql(
      ALIAS_LIST,
      'SELECT * FROM $VIEW_PAGOS WHERE RELA_SYSUSER11 = $idSysuser11 ORDER BY SYSUSER50_FAPL DESC',
    );
    await getRowSetFuture(ALIAS_LIST);
    rstPagos = getRowset(ALIAS_LIST);
  }

  @override
  Future<void> preparePagoNuevo() async {
    await _ensurePagoVacio();

    rstPago = _createPagoWriteRow();

    data.accion = AccionNN.I;
    data.tablaTroncalRst = rstPago;
    data.tablaTroncal = TABLE_PAGOS;

    _setDefaults();
    _clearInputs();
    _clearImages();
    notifyListeners();
  }

  @override
  Future<void> setPagoIndex(int index) async {
    await _setPagoIndex(index, readOnlyData: false);
  }

  @override
  Future<void> setPagoImagesIndex(int index) async {
    await _setPagoIndex(index, readOnlyData: true);
  }

  Future<void> _setPagoIndex(int index, {required bool readOnlyData}) async {
    rstPagos.index(index);
    rstPago = _createPagoWriteRow();
    _copyPagoFromListTo(rstPago);
    data.accion = readOnlyData ? AccionNN.N : AccionNN.W;
    data.tablaTroncalRst = rstPago;
    data.tablaTroncal = TABLE_PAGOS;
    rstPago.setAccion(readOnlyData ? AccionNN.N : AccionNN.W);
    setText(
      'SYSUSER50_REFERENCIA',
      rstPago.getValue('SYSUSER50_REFERENCIA') ?? '',
    );
    setNumericDbl(
      'SYSUSER50_IMPORTE',
      rstPago.getValue('SYSUSER50_IMPORTE') ?? 0.0,
    );
    setDate('SYSUSER50_FECHA', rstPago.getValue('SYSUSER50_FECHA'));
    await _loadImagesForPago(currentPagoId);
    notifyListeners();
  }

  Future<void> _ensurePagoVacio() async {
    if (SmxConstants.rstPagoVacio != null) return;

    removeSql(ALIAS_EMPTY);
    addSql(ALIAS_EMPTY, 'select * from $TABLE_PAGOS where 1 = 0');

    await getRowSetFuture(ALIAS_EMPTY);

    SmxConstants.rstPagoVacio = getRowset(ALIAS_EMPTY);
    SmxConstants.rstPagoVacio!.tabla = TABLE_PAGOS;
  }

  SmxRowSet _createPagoWriteRow() {
    final row = SmxConstants.rstPagoVacio!.copy();
    row.tabla = TABLE_PAGOS;
    row.insert();
    return row;
  }

  void _copyPagoFromListTo(SmxRowSet row) {
    for (final field in [
      'ID_SYSUSER50',
      'RELA_SYSUSER11',
      'RELA_SYSUSER10_ALTA',
      'SYSUSER50_REFERENCIA',
      'SYSUSER50_IMPORTE',
      'SYSUSER50_FECHA',
      'SYSUSER50_STATUS',
    ]) {
      row.update(field, rstPagos.getValue(field));
    }
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

  void _updatePagoSesion() {
    if (!rstPagos.findId(currentPagoId)) return;
    for (final field in [
      'SYSUSER50_REFERENCIA',
      'SYSUSER50_IMPORTE',
      'SYSUSER50_FECHA',
      'SYSUSER50_STATUS',
    ]) {
      rstPagos.update(field, rstPago.getValue(field));
    }
    rstPagos.setAccion(AccionNN.N);
  }

  double _getPagoImporteFromList() {
    if (currentPagoId <= 0 || !rstPagos.findId(currentPagoId)) return 0.0;
    return _toDouble(rstPagos.getValue('SYSUSER50_IMPORTE'));
  }

  int _getStatusValue(dynamic value) =>
      value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  double _toDouble(dynamic value) =>
      value is num ? value.toDouble() : double.tryParse('$value') ?? 0.0;

  List<int> _getPagoIndexes(int status) {
    final indexes = <int>[];
    for (var index = 0; index < rowCount; index++) {
      if (getStatusAt(index) == status) indexes.add(index);
    }
    return indexes;
  }

  void _clearImages() {
    rstImages = SmxRowSet(
      alias: ALIAS_IMAGES_DATA,
      sql: '',
      rowset: [],
      maxrows: 0,
      headers: {},
    );
    rstImages.tabla = TABLE_IMAGES;
  }

  Future<void> _loadImagesForPago(int idPago) async {
    removeSql(ALIAS_IMAGES_DATA);
    addSql(
      ALIAS_IMAGES_DATA,
      'SELECT * FROM GRD_SYSUSER51 WHERE RELA_SYSUSER50 = $idPago',
    );
    await getRowSetFuture(ALIAS_IMAGES_DATA);
    rstImages = getRowset(ALIAS_IMAGES_DATA);
    rstImages.tabla = TABLE_IMAGES;
  }

  @override
  Future<bool> deletePagoAt(int index) async {
    final context = data.context;
    if (context == null || getStatusAt(index) != 0) return false;
    rstPagos.index(index);
    final idPago = rstPagos.getId();
    final row = rstPagos.copyActive();
    row.tabla = TABLE_PAGOS;
    row.first();
    row.delete();
    await showDialogWait(context, () async => callDeleteAlt(row));
    if (jsonSend.getError() != null) {
      if (context.mounted) {
        showSmxSystemErrorDialog(context, message: jsonSend.error!);
      }
      return false;
    }
    rstPagos.getRowsList().removeWhere((item) => item.getId() == idPago);
    notifyListeners();
    return true;
  }

  @override
  bool syncEditingImageToList() {
    if (currentPagoId <= 0) return false;
    var uuid = '';
    rstImages.beforeFirst();
    while (rstImages.next(conDeletes: false)) {
      final value = rstImages.getValue('SYSJSON02_UUID')?.toString() ?? '';
      if (value.trim().isNotEmpty) uuid = value;
    }
    if (!rstPagos.findId(currentPagoId)) return false;
    rstPagos.update(
      'SYSUSER50_IMAGE',
      uuid.trim().isEmpty ? '' : '$ALIAS_IMAGES${uuid.trim()}',
    );
    rstPagos.setAccion(AccionNN.N);
    _imageVersions[currentPagoId] = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
    return true;
  }

  @override
  SmxRowSet getRstImages() => rstImages;
}
