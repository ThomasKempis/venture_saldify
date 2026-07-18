import 'package:uuid/uuid.dart';

class SmxProductoCatalogo {
  final int id;
  final String nombre;
  final double importe;
  final String imagen;
  final int existencia;
  final int cantidad;

  const SmxProductoCatalogo({
    required this.id,
    required this.nombre,
    required this.importe,
    required this.imagen,
    required this.existencia,
    required this.cantidad,
  });
}

class SmxCarritoLocal {
  final String uuid;
  DateTime actualizado;
  final List<SmxCarritoItem> items;

  SmxCarritoLocal({
    required this.uuid,
    required this.actualizado,
    required this.items,
  });

  factory SmxCarritoLocal.nuevo() => SmxCarritoLocal(
    uuid: const Uuid().v4(),
    actualizado: DateTime.now(),
    items: [],
  );

  factory SmxCarritoLocal.fromJson(Map<String, dynamic> json) =>
      SmxCarritoLocal(
        uuid: json['uuid']?.toString() ?? const Uuid().v4(),
        actualizado:
            DateTime.tryParse(json['actualizado']?.toString() ?? '') ??
            DateTime.now(),
        items: (json['items'] as List<dynamic>? ?? [])
            .map(
              (value) => SmxCarritoItem.fromJson(value as Map<String, dynamic>),
            )
            .toList(),
      );

  int indexOf(int idProducto) =>
      items.indexWhere((item) => item.idProducto == idProducto);

  double get total =>
      items.fold(0, (sum, item) => sum + item.importe * item.cantidad);

  Map<String, dynamic> toJson() => {
    'uuid': uuid,
    'actualizado': actualizado.toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
  };
}

class SmxCarritoItem {
  final int idProducto;
  final String producto;
  final double importe;
  final String imagen;
  int cantidad;

  SmxCarritoItem({
    required this.idProducto,
    required this.producto,
    required this.importe,
    required this.imagen,
    required this.cantidad,
  });

  factory SmxCarritoItem.fromJson(Map<String, dynamic> json) => SmxCarritoItem(
    idProducto: (json['idProducto'] as num?)?.toInt() ?? -1,
    producto: json['producto']?.toString() ?? '',
    importe: (json['importe'] as num?)?.toDouble() ?? 0,
    imagen: json['imagen']?.toString() ?? '',
    cantidad: (json['cantidad'] as num?)?.toInt() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'idProducto': idProducto,
    'producto': producto,
    'importe': importe,
    'imagen': imagen,
    'cantidad': cantidad,
  };
}
