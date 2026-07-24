import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smx_message_dialog.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxComprasCarrito/smxComprasCarritoControllerContract.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

class SmxSaldiFyComprasCarritoController
    extends SmxComprasCarritoControllerContract {
  static const String aliasCatalogo = 'QRY_SYSUSER41_CARRITO';
  static const String aliasCabeceraVacia = 'SYSUSER45_CARRITO_EMPTY';
  static const String aliasDetallesVacios = 'SYSUSER40_CARRITO_EMPTY';
  static const String tablaCabecera = 'SYSUSER45_CAB_CARRITO';
  static const String tablaDetalles = 'SYSUSER40_DET_COMPRAS';

  final int idSysuser11;
  final int catalogOwnerId;
  late SmxRowSet rstCatalogo;
  late SmxRowSet _rstCabeceraVacia;
  late SmxRowSet _rstDetallesVacios;

  SmxSaldiFyComprasCarritoController({
    required super.alias,
    required super.data,
    required this.idSysuser11,
    required this.catalogOwnerId,
  });

  @override
  Future<void> init() async {
    if (isBeginDB()) return;
    beginDB();

    addSql(
      aliasCatalogo,
      'SELECT * FROM QRY_SYSUSER41_CARRITO($catalogOwnerId)',
    );

    final cargarVacios =
        SmxConstants.rstCabeceraVacia == null ||
        SmxConstants.rstDetallesVacios == null;

    if (cargarVacios) {
      addSql(aliasCabeceraVacia, 'SELECT * FROM $tablaCabecera WHERE 1 = 0');
      addSql(aliasDetallesVacios, 'SELECT * FROM $tablaDetalles WHERE 1 = 0');
    }

    await getRowSetFuture(aliasCatalogo);

    rstCatalogo = getRowset(aliasCatalogo);

    if (cargarVacios) {
      SmxConstants.rstCabeceraVacia = getRowset(aliasCabeceraVacia);
      SmxConstants.rstDetallesVacios = getRowset(aliasDetallesVacios);
    }

    _rstCabeceraVacia = SmxConstants.rstCabeceraVacia!.copy()
      ..tabla = tablaCabecera;

    _rstDetallesVacios = SmxConstants.rstDetallesVacios!.copy()
      ..tabla = tablaDetalles;
  }

  @override
  Future<bool> confirmarCarrito({
    required String uuid,
    required List<Map<String, dynamic>> items,
    required double disponible,
  }) async {
    final context = data.context;
    if (context == null || items.isEmpty) return false;

    final total = items.fold<double>(
      0,
      (sum, item) =>
          sum +
          ((item['cantidad'] as num?)?.toDouble() ?? 0) *
              ((item['importe'] as num?)?.toDouble() ?? 0),
    );
    if (total <= 0) {
      showSmxValidDialog(context, mensaje: 'El carrito no contiene compras.');
      return false;
    }
    if (total > disponible) {
      showSmxValidDialog(
        context,
        mensaje: 'El total del carrito supera el saldo disponible.',
      );
      return false;
    }

    final rstCabecera = _rstCabeceraVacia.copy()
      ..tabla = tablaCabecera
      ..insert();
    rstCabecera.update('SYSUSER45_UUID', uuid);

    final rstDetalles = _rstDetallesVacios.copy()..tabla = tablaDetalles;
    final idUsuarioAlta = SmxConstants.controllerMain.rstSysUser10.getId();
    for (final item in items) {
      rstDetalles.insert();
      rstDetalles.update('RELA_SYSUSER11', idSysuser11);
      rstDetalles.update('RELA_SYSUSER10_ALTA', idUsuarioAlta);
      rstDetalles.update('RELA_SYSUSER45', rstCabecera.getId());
      rstDetalles.update('RELA_SYSUSER41', item['idProducto']);
      rstDetalles.update('SYSUSER40_CONCEPTO', item['producto'] ?? '');
      rstDetalles.update('SYSUSER40_CANTIDAD', item['cantidad'] ?? 0);
      rstDetalles.update('SYSUSER40_IMPORTE', item['importe'] ?? 0.0);
      rstDetalles.update('SYSUSER40_FECHA', DateTime.now());
      rstDetalles.update('SYSUSER40_STATUS', 0);
    }

    rstCabecera.setDetTransaction(rstDetalles);
    await showDialogWait(context, () => callTroncalSave(rstCabecera));

    if (jsonSend.getError() != null) {
      if (context.mounted) {
        showSmxSystemErrorDialog(context, message: jsonSend.error!);
      }
      return false;
    }
    return true;
  }

  @override
  int get catalogoCount => rstCatalogo.getRowCount();

  @override
  int getCatalogoIdAt(int index) {
    rstCatalogo.index(index);
    return rstCatalogo.getId();
  }

  @override
  String getCatalogoNombreAt(int index) {
    rstCatalogo.index(index);
    return rstCatalogo.getValue('SYSUSER41_PRODUCTO')?.toString() ?? '';
  }

  @override
  double getCatalogoImporteAt(int index) {
    rstCatalogo.index(index);
    final value = rstCatalogo.getValue('SYSUSER41_IMPORTE');
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  @override
  int getCatalogoExistenciaAt(int index) {
    rstCatalogo.index(index);
    final value = rstCatalogo.getValue('SYSUSER41_EXISTENCIA');
    final existencia = value is num
        ? value.toInt()
        : int.tryParse(value?.toString() ?? '') ?? 0;
    return existencia < 0 ? 0 : existencia;
  }

  @override
  String getCatalogoImageUrlAt(int index) {
    rstCatalogo.index(index);
    final image =
        rstCatalogo.getValue('SYSUSER41_IMAGE')?.toString().trim() ?? '';
    if (image.isEmpty) return '';
    return '${SmxConstants.URL_IMAGES_SALDIFY}$image-MINI.JPG';
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
