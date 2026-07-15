import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smx_message_dialog.dart';
import 'package:venture_core_connect/smxJson/SmxJsonUtil.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

class SmxSaldiFyProductosController extends SmxController {
  static const String ALIAS_LIST = "ALIAS_LIST";
  static const String ALIAS_VACIO = "ALIAS_VACIO";
  static const String ALIAS_ADD = "ADD_SYSUSER41";
  static const String ALIAS_IMAGES = "SYSUSER41";
  static const String ALIAS_IMAGES_DATA = "SYSUSER42";
  static const String VIEW_PRODUCTOS = "QRY_SYSUSER41";
  static const String TABLE_PRODUCTOS = "SYSUSER41_DET_PRODUCTOS";
  static const String TABLE_IMAGES = "SYSUSER42_DET_IMAGENES";

  late SmxRowSet rstProductos; // LISTA (Plural)
  late SmxRowSet rstProducto; // TRANSACCIÓN (Singular)
  late SmxRowSet rstImages;

  bool lastSaveOk = false;
  bool lastStatusOk = false;
  double _existenciaActual = 0;
  late bool _teniaCatalogoAlEntrar;
  final Map<int, int> _imageVersions = {};

  SmxSaldiFyProductosController({required super.alias, required super.data});

  int get rowCount => rstProductos.getRowCount();
  bool get isEditing => data.accion == AccionNN.W;
  double get existenciaActual => _existenciaActual;
  List<int> get productosActivosIndexes => _getProductoIndexesByStatus(0);
  List<int> get productosArchivadosIndexes => _getProductoIndexesByStatus(1);

  @override
  Future<void> init() async {
    if (isBeginDB()) return;
    beginDB();

    await _loadProductos();
    _teniaCatalogoAlEntrar = productosActivosIndexes.isNotEmpty;
    await prepareNuevo();
  }

  bool get cambioDisponibilidadCatalogo =>
      _teniaCatalogoAlEntrar != productosActivosIndexes.isNotEmpty;

  Future<void> _loadProductos() async {
    await _ensureProductoVacio();

    final idSysuser10 = SmxConstants.controllerMain.rstSysUser10.getId();
    removeSql(ALIAS_LIST);
    addSql(
      ALIAS_LIST,
      "SELECT * FROM $VIEW_PRODUCTOS WHERE RELA_SYSUSER10 = $idSysuser10 ORDER BY SYSUSER41_STATUS, SYSUSER41_PRODUCTO",
    );
    await getRowSetFuture(ALIAS_LIST);
    rstProductos = getRowset(ALIAS_LIST);
  }

  Future<void> prepareNuevo() async {
    await _ensureProductoVacio();

    rstProducto = _createProductoWriteRow();

    data.accion = AccionNN.I;
    data.tablaTroncalRst = rstProducto;
    data.tablaTroncal = TABLE_PRODUCTOS;

    _setDefaults();
    _existenciaActual = 0;
    _clearInputs();
    _clearImages();
    notifyListeners();
  }

  Future<void> setProductoIndex(int index) async {
    rstProductos.index(index);
    final existencia = rstProductos.getValue('SYSUSER41_EXISTENCIA');
    _existenciaActual = existencia is num
        ? existencia.toDouble()
        : double.tryParse(existencia?.toString() ?? '') ?? 0;

    // Modificación: Siempre sobre copia del vacio para aislar la transacción
    rstProducto = _createProductoWriteRow();

    // Carga manual de valores desde la lista al objeto de transacción
    _copyProductoFromListTo(rstProducto);

    data.accion = AccionNN.W;
    data.tablaTroncalRst = rstProducto;
    data.tablaTroncal = TABLE_PRODUCTOS;
    rstProducto.setAccion(AccionNN.W);

    // Sincronizar Buffers/Widgets
    setText(
      'SYSUSER41_PRODUCTO',
      rstProducto.getValue('SYSUSER41_PRODUCTO') ?? '',
    );
    setNumericDbl(
      'SYSUSER41_INVENTARIO',
      rstProducto.getValue('SYSUSER41_INVENTARIO') ?? 0.0,
    );
    setNumericDbl(
      'SYSUSER41_IMPORTE',
      rstProducto.getValue('SYSUSER41_IMPORTE') ?? 0.0,
    );

    await _loadImagesForProducto(rstProducto.getId());

    notifyListeners();
  }

  @override
  Future<void> save() async {
    lastSaveOk = false;
    final context = data.context;
    if (context == null) return;

    final mensajeValidar = getValidateOnlyMessage();
    if (mensajeValidar != null) {
      showSmxValidDialog(context, mensaje: mensajeValidar);
      return;
    }

    final isAlta = data.accion == AccionNN.I;

    await showDialogWait(context, () async {
      if (isAlta) {
        await _insertProducto();
      } else {
        await callTroncalSave(rstProducto);
      }
    });

    if (jsonSend.getError() != null) {
      if (context.mounted) {
        showSmxSystemErrorDialog(context, message: jsonSend.error!);
      }
      return;
    }

    lastSaveOk = true;
    if (isAlta) {
      _addProductoToList();
    } else {
      _updateProductoInList();
    }
    await prepareNuevo();
  }

  Future<void> toggleStatus(int index) async {
    lastStatusOk = false;
    rstProductos.index(index);

    final rowTrans = _createProductoWriteRow();
    _copyProductoFromListTo(rowTrans);

    final currentStatus = rstProductos.getValue('SYSUSER41_STATUS') ?? 0;
    rowTrans.update('SYSUSER41_STATUS', currentStatus == 0 ? 1 : 0);

    data.accion = AccionNN.W;
    data.tablaTroncal = TABLE_PRODUCTOS;
    data.tablaTroncalRst = rowTrans;
    rowTrans.setAccion(AccionNN.W);

    final context = data.context;
    if (context != null) {
      await showDialogWait(context, () async {
        await callTroncalSave(rowTrans);
      });
    } else {
      await callTroncalSave(rowTrans);
    }

    if (jsonSend.getError() != null) {
      final currentContext = data.context;
      if (currentContext != null && currentContext.mounted) {
        showSmxSystemErrorDialog(currentContext, message: jsonSend.error!);
      }
      notifyListeners();
      return;
    }

    lastStatusOk = true;
    if (rstProductos.findId(rowTrans.getId())) {
      rstProductos.update(
        'SYSUSER41_STATUS',
        rowTrans.getValue('SYSUSER41_STATUS'),
      );
      rstProductos.setAccion(AccionNN.N);
    }
    notifyListeners();
  }

  Future<void> _insertProducto() async {
    final relaSysuser10 = SmxConstants.controllerMain.rstSysUser10.getId();
    final producto =
        rstProducto.getValue('SYSUSER41_PRODUCTO')?.toString() ?? '';
    final importe = rstProducto.getValue('SYSUSER41_IMPORTE') ?? 0.0;
    final inventario = rstProducto.getValue('SYSUSER41_INVENTARIO') ?? 0.0;

    removeSql(ALIAS_ADD);
    addSTrans(
      ALIAS_ADD,
      "select * from ADD_SYSUSER41("
      "$relaSysuser10, "
      "'${_sql(producto)}', "
      "$importe, "
      "$inventario)",
    );

    await getCallWS();

    if (jsonSend.getError() != null) return;

    final rstAdd = getRowset(ALIAS_ADD);
    if (rstAdd.getRowCount() == 0) {
      jsonSend.error = 'No se recibió el ID del producto nuevo.';
      return;
    }

    rstAdd.first();
    final idReal = rstAdd.getValue('ID_SYSUSER41') ?? rstAdd.getId();

    if (idReal == null || idReal <= 0) {
      jsonSend.error = 'El ID del producto nuevo no es válido.';
      return;
    }

    rstProducto.update('ID_SYSUSER41', idReal);
    rstProducto.setAccion(AccionNN.N);
  }

  void _addProductoToList() {
    rstProductos.insert();
    rstProductos.update('ID_SYSUSER41', rstProducto.getId());
    rstProductos.update(
      'RELA_SYSUSER10',
      rstProducto.getValue('RELA_SYSUSER10'),
    );
    rstProductos.update(
      'SYSUSER41_PRODUCTO',
      rstProducto.getValue('SYSUSER41_PRODUCTO'),
    );
    rstProductos.update(
      'SYSUSER41_INVENTARIO',
      rstProducto.getValue('SYSUSER41_INVENTARIO'),
    );
    rstProductos.update(
      'SYSUSER41_EXISTENCIA',
      rstProducto.getValue('SYSUSER41_INVENTARIO'),
    );
    rstProductos.update(
      'SYSUSER41_IMPORTE',
      rstProducto.getValue('SYSUSER41_IMPORTE'),
    );
    rstProductos.update(
      'SYSUSER41_STATUS',
      rstProducto.getValue('SYSUSER41_STATUS'),
    );
    rstProductos.update('SYSUSER41_IMAGE', '');
    rstProductos.setAccion(AccionNN.N);
  }

  void _updateProductoInList() {
    final idProducto = rstProducto.getId();
    if (!rstProductos.findId(idProducto)) return;

    rstProductos.update(
      'SYSUSER41_PRODUCTO',
      rstProducto.getValue('SYSUSER41_PRODUCTO'),
    );
    rstProductos.update(
      'SYSUSER41_INVENTARIO',
      rstProducto.getValue('SYSUSER41_INVENTARIO'),
    );
    rstProductos.update(
      'SYSUSER41_EXISTENCIA',
      rstProducto.getValue('SYSUSER41_INVENTARIO'),
    );
    rstProductos.update(
      'SYSUSER41_IMPORTE',
      rstProducto.getValue('SYSUSER41_IMPORTE'),
    );
    rstProductos.update(
      'SYSUSER41_STATUS',
      rstProducto.getValue('SYSUSER41_STATUS'),
    );
    rstProductos.setAccion(AccionNN.N);
  }

  String _sql(String value) {
    return value.replaceAll("'", "''").trim();
  }

  Future<void> _ensureProductoVacio() async {
    if (SmxConstants.rstProductoVacio != null) return;

    removeSql(ALIAS_VACIO);
    addSql(ALIAS_VACIO, 'SELECT * FROM $TABLE_PRODUCTOS WHERE 1 = 0');
    await getRowSetFuture(ALIAS_VACIO);

    SmxConstants.rstProductoVacio = getRowset(ALIAS_VACIO);
    SmxConstants.rstProductoVacio!.tabla = TABLE_PRODUCTOS;
  }

  SmxRowSet _createProductoWriteRow() {
    final row = SmxConstants.rstProductoVacio!.copy();
    row.tabla = TABLE_PRODUCTOS;
    row.insert();
    return row;
  }

  void _copyProductoFromListTo(SmxRowSet row) {
    row.update('ID_SYSUSER41', rstProductos.getId());
    row.update('RELA_SYSUSER10', rstProductos.getValue('RELA_SYSUSER10'));
    row.update(
      'SYSUSER41_PRODUCTO',
      rstProductos.getValue('SYSUSER41_PRODUCTO'),
    );
    row.update(
      'SYSUSER41_INVENTARIO',
      rstProductos.getValue('SYSUSER41_INVENTARIO'),
    );
    row.update('SYSUSER41_IMPORTE', rstProductos.getValue('SYSUSER41_IMPORTE'));
    row.update('SYSUSER41_STATUS', rstProductos.getValue('SYSUSER41_STATUS'));
  }

  Future<void> _loadImagesForProducto(int idProducto) async {
    removeSql(ALIAS_IMAGES_DATA);
    addSql(
      ALIAS_IMAGES_DATA,
      'SELECT * FROM GRD_SYSUSER42 WHERE RELA_SYSUSER41 = $idProducto',
    );
    await getRowSetFuture(ALIAS_IMAGES_DATA);
    rstImages = getRowset(ALIAS_IMAGES_DATA);
    rstImages.tabla = TABLE_IMAGES;
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

  void _setDefaults() {
    rstProducto.update(
      'RELA_SYSUSER10',
      SmxConstants.controllerMain.rstSysUser10.getId(),
    );
    rstProducto.update('SYSUSER41_PRODUCTO', '');
    rstProducto.update('SYSUSER41_INVENTARIO', 0.0);
    rstProducto.update('SYSUSER41_IMPORTE', 0.0);
    rstProducto.update('SYSUSER41_STATUS', 0);
  }

  void _clearInputs() {
    setText('SYSUSER41_PRODUCTO', '');
    setNumericDbl('SYSUSER41_INVENTARIO', 0.0);
    setNumericDbl('SYSUSER41_IMPORTE', 0.0);
  }

  @override
  Future<void> cancel() async {
    await prepareNuevo();
  }

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}

  int getStatusAt(int index) {
    rstProductos.index(index);
    return rstProductos.getValue('SYSUSER41_STATUS') ?? 0;
  }

  String getProductoAt(int index) {
    rstProductos.index(index);
    return (rstProductos.getValue('SYSUSER41_PRODUCTO')?.toString() ?? '')
        .toUpperCase();
  }

  String getImporteAt(int index) {
    rstProductos.index(index);
    return rstProductos.getValueFormatAmount('SYSUSER41_IMPORTE');
  }

  int getExistenciaAt(int index) {
    rstProductos.index(index);
    final value = rstProductos.getValue('SYSUSER41_EXISTENCIA');
    final existencia = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;
    return existencia < 0 ? 0 : existencia;
  }

  String getProductoImageUrlAt(int index) {
    rstProductos.index(index);
    final image = rstProductos.getValue('SYSUSER41_IMAGE')?.toString() ?? '';
    if (image.trim().isEmpty) return '';
    final version = _imageVersions[rstProductos.getId()];
    final cacheSuffix = version == null ? '' : '?v=$version';
    return '${SmxConstants.URL_IMAGES_SALDIFY}${image.trim()}-MINI.JPG$cacheSuffix';
  }

  bool syncEditingImageToList() {
    final idProducto = rstProducto.getId();
    if (idProducto <= 0) return false;

    var uuid = '';
    rstImages.beforeFirst();
    while (rstImages.next(conDeletes: false)) {
      final currentUuid =
          rstImages.getValue('SYSJSON02_UUID')?.toString() ?? '';
      if (currentUuid.trim().isNotEmpty) uuid = currentUuid;
    }

    if (!rstProductos.findId(idProducto)) return false;

    rstProductos.update(
      'SYSUSER41_IMAGE',
      uuid.trim().isEmpty ? '' : '$ALIAS_IMAGES${uuid.trim()}',
    );
    rstProductos.setAccion(AccionNN.N);
    _imageVersions[idProducto] = DateTime.now().millisecondsSinceEpoch;
    notifyListeners();
    return true;
  }

  SmxRowSet getRstImages() {
    return rstImages;
  }

  List<int> _getProductoIndexesByStatus(int status) {
    final indexes = <int>[];

    for (var index = 0; index < rowCount; index++) {
      if (getStatusAt(index) == status) {
        indexes.add(index);
      }
    }

    indexes.sort((a, b) {
      final productoA = getProductoAt(a).trim().toLowerCase();
      final productoB = getProductoAt(b).trim().toLowerCase();
      return productoA.compareTo(productoB);
    });

    return indexes;
  }
}
