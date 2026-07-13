import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxController/smxController.dart';

abstract class SmxComprasManualControllerContract extends SmxController {
  SmxComprasManualControllerContract({
    required super.alias,
    required super.data,
  });

  String get imagesAlias;
  String get imagesTable;
  List<int> get comprasPendientesIndexes;
  List<int> get comprasRecibidasIndexes;
  int get currentCompraId;
  bool get isCompraPersistida;
  bool get isCompraNueva;
  bool get isSoloImagenes;
  bool get canEditCompraData;
  bool get lastSaveOk;
  double get lastSavedImporte;

  Future<void> prepareCompraNueva();
  Future<void> setCompraIndex(int index);
  Future<void> setCompraImagesIndex(int index);
  Future<bool> deleteCompraAt(int index);
  Future<void> save({double? disponible});
  bool syncEditingImageToList();
  SmxRowSet getRstImages();
  int getStatusAt(int index);
  int getCompraIdAt(int index);
  String getProductoAt(int index);
  String getCantidadAt(int index);
  String getImporteAt(int index);
  String getTotalAt(int index);
  double getImporteValueAt(int index);
  String getFechaAt(int index);
  String getStatusLabelAt(int index);
  String getCompraImageUrlAt(int index);
}
