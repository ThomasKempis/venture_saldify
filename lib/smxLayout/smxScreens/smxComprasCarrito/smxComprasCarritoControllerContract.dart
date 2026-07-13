import 'package:venture_widgets/smxController/smxController.dart';

abstract class SmxComprasCarritoControllerContract extends SmxController {
  SmxComprasCarritoControllerContract({
    required super.alias,
    required super.data,
  });

  int get catalogoCount;

  int getCatalogoIdAt(int index);

  String getCatalogoNombreAt(int index);

  double getCatalogoImporteAt(int index);

  int getCatalogoExistenciaAt(int index);

  String getCatalogoImageUrlAt(int index);

  Future<bool> confirmarCarrito({
    required String uuid,
    required List<Map<String, dynamic>> items,
    required double disponible,
  });
}
