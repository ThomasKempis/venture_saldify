import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxController/smxController.dart';

abstract class SmxPagosControllerContract extends SmxController {
  SmxPagosControllerContract({required super.alias, required super.data});

  String get imagesAlias;
  String get imagesTable;
  List<int> get pagosPendientesIndexes;
  List<int> get pagosConfirmadosIndexes;
  int get currentPagoId;
  bool get isPagoPersistido;
  bool get isPagoNuevo;
  bool get isSoloImagenes;
  bool get canEditPagoData;
  bool get lastSaveOk;
  double get lastSavedImporte;

  Future<void> preparePagoNuevo();
  Future<void> setPagoIndex(int index);
  Future<void> setPagoImagesIndex(int index);
  Future<bool> deletePagoAt(int index);
  bool syncEditingImageToList();
  Future<void> save({double? saldo});
  SmxRowSet getRstImages();
  int getStatusAt(int index);
  int getPagoIdAt(int index);
  String getReferenciaAt(int index);
  String getImporteAt(int index);
  double getImporteValueAt(int index);
  String getFechaAt(int index);
  String getStatusLabelAt(int index);
  String getPagoImageUrlAt(int index);
}
