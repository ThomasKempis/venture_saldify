import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smx_message_dialog.dart';
import 'package:venture_core_connect/smxJson/SmxJsonUtil.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxComprasManual/smxComprasManualControllerContract.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

class SmxSaldiFyComprasManualController
    extends SmxComprasManualControllerContract {
  static const String ALIAS_LIST = 'ALIAS_LIST';
  static const String ALIAS_EMPTY = 'SYSUSER40_EMPTY';
  static const String ALIAS_IMAGES = 'SYSUSER40';
  static const String ALIAS_IMAGES_DATA = 'SYSUSER43';
  static const String VIEW_COMPRAS = 'QRY_SYSUSER40';
  static const String TABLE_COMPRAS = 'SYSUSER40_DET_COMPRAS';
  static const String TABLE_IMAGES = 'SYSUSER43_DET_IMAGENES';

  final int idSysuser11;

  late SmxRowSet rstCompras;
  late SmxRowSet rstCompra;
  late SmxRowSet rstImages;
  @override
  bool lastSaveOk = false;
  @override
  double lastSavedImporte = 0.0;
  final Map<int, int> _imageVersions = {};

  SmxSaldiFyComprasManualController({
    required super.alias,
    required super.data,
    required this.idSysuser11,
  });

  @override
  String get imagesAlias => ALIAS_IMAGES;
  @override
  String get imagesTable => TABLE_IMAGES;

  int get rowCount => rstCompras.getRowCount();
  @override
  List<int> get comprasPendientesIndexes =>
      _getCompraIndexes((status) => status == 0);
  @override
  List<int> get comprasRecibidasIndexes =>
      _getCompraIndexes((status) => status != 0);
  @override
  int get currentCompraId => rstCompra.getId();
  @override
  bool get isCompraPersistida => rstCompra.getId() > 0;
  @override
  bool get isCompraNueva => data.accion == AccionNN.I;
  @override
  bool get isSoloImagenes => isCompraPersistida && data.accion == AccionNN.N;
  @override
  bool get canEditCompraData {
    return _getStatusValue(rstCompra.getValue('SYSUSER40_STATUS')) == 0;
  }

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

    final mensajeValidar = getValidateOnlyMessage();
    if (mensajeValidar != null) {
      showSmxValidDialog(context, mensaje: mensajeValidar);
      return;
    }

    if (!canEditCompraData) {
      showSmxValidDialog(
        context,
        mensaje: 'Esta compra ya no permite modificar datos.',
      );
      return;
    }

    final isAlta = data.accion == AccionNN.I;
    final totalAnterior = isAlta ? 0.0 : _getCompraTotalFromList();
    final double importe = rstCompra.getValue('SYSUSER40_IMPORTE');
    final int cantidad = _getCantidadCompra();
    final total = cantidad * importe;
    if (cantidad <= 0) {
      showSmxValidDialog(
        context,
        mensaje: 'Debe ingresar una cantidad mayor a cero.',
      );
      return;
    }

    if (importe <= 0) {
      showSmxValidDialog(
        context,
        mensaje: 'Debe ingresar un importe mayor a cero.',
      );
      return;
    }

    final limiteDisponible = disponible == null
        ? null
        : disponible + (isAlta ? 0.0 : totalAnterior);
    if (limiteDisponible != null && total > limiteDisponible) {
      showSmxValidDialog(
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
        showSmxSystemErrorDialog(currentContext, message: jsonSend.error!);
      }
      return;
    }

    lastSaveOk = true;
    lastSavedImporte = total - totalAnterior;
    if (isAlta) {
      await _prepareComprasSesion();
    } else {
      _updateCompraSesion();
      await _loadImagesForCompra(rstCompra.getId());
      rstCompra.setAccion(AccionNN.N);
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
  String getProductoAt(int index) {
    rstCompras.index(index);
    return (rstCompras.getValue('SYSUSER40_CONCEPTO')?.toString() ?? '')
        .toUpperCase();
  }

  @override
  String getFechaAt(int index) {
    rstCompras.index(index);
    return rstCompras.getValueFormatDate('SYSUSER40_FECHA');
  }

  @override
  String getCantidadAt(int index) {
    rstCompras.index(index);
    return (rstCompras.getValue('SYSUSER40_CANTIDAD') ?? 0).toString();
  }

  @override
  String getImporteAt(int index) {
    rstCompras.index(index);
    return rstCompras.getValueFormatAmount('SYSUSER40_IMPORTE');
  }

  @override
  String getTotalAt(int index) {
    rstCompras.index(index);
    return rstCompras.getValueFormatAmount('SYSUSER40_TOTAL');
  }

  @override
  int getStatusAt(int index) {
    rstCompras.index(index);
    return _getStatusValue(rstCompras.getValue('SYSUSER40_STATUS'));
  }

  @override
  String getStatusLabelAt(int index) {
    switch (getStatusAt(index)) {
      case 0:
        return 'Solicitada';
      case 1:
        return 'Pendiente';
      case 2:
        return 'Entregada';
      default:
        return 'Sin estado';
    }
  }

  @override
  int getCompraIdAt(int index) {
    rstCompras.index(index);
    return rstCompras.getId();
  }

  @override
  double getImporteValueAt(int index) {
    rstCompras.index(index);
    final total = rstCompras.getValue('SYSUSER40_TOTAL');
    if (total is num) return total.toDouble();
    return double.tryParse('$total') ?? 0.0;
  }

  int _getStatusValue(dynamic status) {
    if (status is num) return status.toInt();
    return int.tryParse('$status') ?? 0;
  }

  List<int> _getCompraIndexes(bool Function(int status) include) {
    final indexes = <int>[];
    for (var index = 0; index < rowCount; index++) {
      if (include(getStatusAt(index))) indexes.add(index);
    }
    return indexes;
  }

  @override
  String getCompraImageUrlAt(int index) {
    rstCompras.index(index);
    final image = rstCompras.getValue('SYSUSER40_IMAGE')?.toString() ?? '';
    if (image.trim().isEmpty) return '';
    final version = _imageVersions[rstCompras.getId()];
    final cacheSuffix = version == null ? '' : '?v=$version';
    return '${SmxConstants.URL_IMAGES_SALDIFY}${image.trim()}-MINI.JPG$cacheSuffix';
  }

  Future<void> _prepareComprasSesion() async {
    await _ensureCompraVacia();

    removeSql(ALIAS_LIST);
    addSql(
      ALIAS_LIST,
      'SELECT * FROM $VIEW_COMPRAS WHERE RELA_SYSUSER11 = $idSysuser11 ORDER BY SYSUSER40_FAPL DESC',
    );
    await getRowSetFuture(ALIAS_LIST);
    rstCompras = getRowset(ALIAS_LIST);
  }

  @override
  Future<void> prepareCompraNueva() async {
    await _ensureCompraVacia();

    rstCompra = _createCompraWriteRow();

    data.accion = AccionNN.I;
    data.tablaTroncalRst = rstCompra;
    data.tablaTroncal = TABLE_COMPRAS;

    _setDefaults();
    _clearInputs();
    _clearImages();
    notifyListeners();
  }

  @override
  Future<void> setCompraIndex(int index) async {
    await _setCompraIndex(index, readOnlyData: false);
  }

  @override
  Future<void> setCompraImagesIndex(int index) async {
    await _setCompraIndex(index, readOnlyData: true);
  }

  Future<void> _setCompraIndex(int index, {required bool readOnlyData}) async {
    rstCompras.index(index);

    rstCompra = _createCompraWriteRow();
    _copyCompraFromListTo(rstCompra);

    data.accion = readOnlyData ? AccionNN.N : AccionNN.W;
    data.tablaTroncalRst = rstCompra;
    data.tablaTroncal = TABLE_COMPRAS;
    rstCompra.setAccion(readOnlyData ? AccionNN.N : AccionNN.W);

    setText(
      'SYSUSER40_CONCEPTO',
      rstCompra.getValue('SYSUSER40_CONCEPTO') ?? '',
    );
    setNumericInt('SYSUSER40_CANTIDAD', _getCantidadCompra());
    setNumericDbl(
      'SYSUSER40_IMPORTE',
      rstCompra.getValue('SYSUSER40_IMPORTE') ?? 0.0,
    );
    setDate('SYSUSER40_FECHA', rstCompra.getValue('SYSUSER40_FECHA'));

    await _loadImagesForCompra(rstCompra.getId());
    notifyListeners();
  }

  void _updateCompraSesion() {
    final idCompra = rstCompra.getId();
    if (!rstCompras.findId(idCompra)) return;

    rstCompras.update(
      'SYSUSER40_CONCEPTO',
      rstCompra.getValue('SYSUSER40_CONCEPTO'),
    );
    rstCompras.update(
      'SYSUSER40_CANTIDAD',
      rstCompra.getValue('SYSUSER40_CANTIDAD'),
    );
    rstCompras.update(
      'SYSUSER40_IMPORTE',
      rstCompra.getValue('SYSUSER40_IMPORTE'),
    );
    rstCompras.update('SYSUSER40_FECHA', rstCompra.getValue('SYSUSER40_FECHA'));
    rstCompras.update(
      'SYSUSER40_STATUS',
      rstCompra.getValue('SYSUSER40_STATUS'),
    );
    rstCompras.update(
      'SYSUSER40_TOTAL',
      _getCantidadCompra() * _getDoubleValue('SYSUSER40_IMPORTE'),
    );
    rstCompras.setAccion(AccionNN.N);
  }

  double _getCompraTotalFromList() {
    final idCompra = rstCompra.getId();
    if (idCompra <= 0 || !rstCompras.findId(idCompra)) return 0.0;
    final total = rstCompras.getValue('SYSUSER40_TOTAL');
    if (total is num) return total.toDouble();
    return double.tryParse('$total') ?? 0.0;
  }

  double _getDoubleValue(String field) {
    final value = rstCompra.getValue(field);
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0.0;
  }

  Future<void> _ensureCompraVacia() async {
    if (SmxConstants.rstCompraVacia != null) return;

    removeSql(ALIAS_EMPTY);
    addSql(ALIAS_EMPTY, 'select * from $TABLE_COMPRAS where 1 = 0');

    await getRowSetFuture(ALIAS_EMPTY);

    SmxConstants.rstCompraVacia = getRowset(ALIAS_EMPTY);
    SmxConstants.rstCompraVacia!.tabla = TABLE_COMPRAS;
  }

  SmxRowSet _createCompraWriteRow() {
    final row = SmxConstants.rstCompraVacia!.copy();
    row.tabla = TABLE_COMPRAS;
    row.insert();
    return row;
  }

  void _copyCompraFromListTo(SmxRowSet row) {
    row.update('ID_SYSUSER40', rstCompras.getId());
    row.update('RELA_SYSUSER11', rstCompras.getValue('RELA_SYSUSER11'));
    row.update(
      'RELA_SYSUSER10_ALTA',
      rstCompras.getValue('RELA_SYSUSER10_ALTA'),
    );
    row.update('SYSUSER40_CONCEPTO', rstCompras.getValue('SYSUSER40_CONCEPTO'));
    row.update('SYSUSER40_CANTIDAD', rstCompras.getValue('SYSUSER40_CANTIDAD'));
    row.update('SYSUSER40_IMPORTE', rstCompras.getValue('SYSUSER40_IMPORTE'));
    row.update('SYSUSER40_FECHA', rstCompras.getValue('SYSUSER40_FECHA'));
    row.update('SYSUSER40_STATUS', rstCompras.getValue('SYSUSER40_STATUS'));
  }

  void _setDefaults() {
    rstCompra.update('RELA_SYSUSER11', idSysuser11);
    rstCompra.update(
      'RELA_SYSUSER10_ALTA',
      SmxConstants.controllerMain.rstSysUser10.getId(),
    );
    rstCompra.update('SYSUSER40_CONCEPTO', '');
    rstCompra.update('SYSUSER40_CANTIDAD', 1);
    rstCompra.update('SYSUSER40_IMPORTE', 0.0);
    rstCompra.update('SYSUSER40_FECHA', DateTime.now());
    rstCompra.update('SYSUSER40_STATUS', 0);
  }

  void _clearInputs() {
    setText('SYSUSER40_CONCEPTO', '');
    setNumericInt('SYSUSER40_CANTIDAD', 1);
    setNumericDbl('SYSUSER40_IMPORTE', 0.0);
    setDate('SYSUSER40_FECHA', DateTime.now());
  }

  int _getCantidadCompra() {
    final rawCantidad = rstCompra.getValue('SYSUSER40_CANTIDAD');
    if (rawCantidad is num) return rawCantidad.toInt();
    return int.tryParse('$rawCantidad') ?? 0;
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

  Future<void> _loadImagesForCompra(int idCompra) async {
    removeSql(ALIAS_IMAGES_DATA);
    addSql(
      ALIAS_IMAGES_DATA,
      'SELECT * FROM GRD_SYSUSER43 WHERE RELA_SYSUSER40 = $idCompra',
    );
    await getRowSetFuture(ALIAS_IMAGES_DATA);
    rstImages = getRowset(ALIAS_IMAGES_DATA);
    rstImages.tabla = TABLE_IMAGES;
  }

  @override
  Future<bool> deleteCompraAt(int index) async {
    final context = data.context;
    if (context == null) return false;
    if (getStatusAt(index) != 0) return false;

    rstCompras.index(index);
    final idCompra = rstCompras.getId();
    final rstDelete = rstCompras.copyActive();
    rstDelete.tabla = TABLE_COMPRAS;
    rstDelete.first();
    rstDelete.delete();

    await showDialogWait(context, () async {
      await callDeleteAlt(rstDelete);
    });

    if (jsonSend.getError() != null) {
      if (context.mounted) {
        showSmxSystemErrorDialog(context, message: jsonSend.error!);
      }
      return false;
    }

    rstCompras.getRowsList().removeWhere((row) => row.getId() == idCompra);
    notifyListeners();
    return true;
  }

  @override
  bool syncEditingImageToList() {
    final idCompra = rstCompra.getId();
    if (idCompra <= 0) return false;

    var uuid = '';
    rstImages.beforeFirst();
    while (rstImages.next(conDeletes: false)) {
      final currentUuid =
          rstImages.getValue('SYSJSON02_UUID')?.toString() ?? '';
      if (currentUuid.trim().isNotEmpty) uuid = currentUuid;
    }

    if (!rstCompras.findId(idCompra)) return false;

    rstCompras.update(
      'SYSUSER40_IMAGE',
      uuid.trim().isEmpty ? '' : '$ALIAS_IMAGES${uuid.trim()}',
    );
    rstCompras.setAccion(AccionNN.N);
    _imageVersions[idCompra] = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
    return true;
  }

  @override
  SmxRowSet getRstImages() {
    return rstImages;
  }
}
