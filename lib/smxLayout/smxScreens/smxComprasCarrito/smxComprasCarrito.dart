import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';

import 'smxComprasCarritoControllerContract.dart';
import 'smxComprasCarritoModels.dart';

class SmxComprasCarrito extends StatefulWidget {
  final SmxComprasCarritoControllerContract controller;
  final SmxComprasCarritoViewModel model;

  const SmxComprasCarrito({
    super.key,
    required this.controller,
    required this.model,
  });

  @override
  State<SmxComprasCarrito> createState() => _SmxComprasCarritoState();
}

class _SmxComprasCarritoState extends State<SmxComprasCarrito> {
  late final _CarritoStorage _storage;
  late _CarritoLocal _carrito;
  bool _savedSomething = false;

  @override
  void initState() {
    super.initState();
    _storage = _CarritoStorage(widget.model.idSysuser11);
    _carrito = _CarritoLocal.nuevo();
  }

  int get _unidades =>
      _carrito.items.fold(0, (total, item) => total + item.cantidad);
  double get _total => _carrito.items.fold(
    0,
    (total, item) => total + (item.cantidad * item.importe),
  );
  int get _carritosGuardados => _storage.loadDrafts().length;

  double get _disponible {
    return widget.model.disponible;
  }

  void _cambiarCantidad(int index, int delta) {
    final id = widget.controller.getCatalogoIdAt(index);
    final existing = _carrito.indexOf(id);
    final existencia = widget.controller.getCatalogoExistenciaAt(index);
    final cantidadActual = existing < 0 ? 0 : _carrito.items[existing].cantidad;

    if (delta > 0 && cantidadActual >= existencia) return;

    setState(() {
      if (existing < 0 && delta > 0) {
        _carrito.items.add(
          _CarritoItem(
            idProducto: id,
            producto: widget.controller.getCatalogoNombreAt(index),
            importe: widget.controller.getCatalogoImporteAt(index),
            imagen: widget.controller.getCatalogoImageUrlAt(index),
            cantidad: 1,
          ),
        );
      } else if (existing >= 0) {
        final item = _carrito.items[existing];
        item.cantidad += delta;
        if (item.cantidad <= 0) _carrito.items.removeAt(existing);
      }
      _carrito.actualizado = DateTime.now();
      _storage.saveDraft(_carrito);
    });
  }

  int _cantidad(int idProducto) {
    final index = _carrito.indexOf(idProducto);
    return index < 0 ? 0 : _carrito.items[index].cantidad;
  }

  List<int> _catalogoIndexes({required bool solicitados}) {
    final indexes = <int>[];
    for (var index = 0; index < widget.controller.catalogoCount; index++) {
      final id = widget.controller.getCatalogoIdAt(index);
      final seleccionado = _cantidad(id) > 0;
      if (seleccionado == solicitados) indexes.add(index);
    }
    return indexes;
  }

  Widget _productosGrid(List<int> indexes, int columns) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: .72,
      ),
      itemCount: indexes.length,
      itemBuilder: (context, position) {
        final index = indexes[position];
        final id = widget.controller.getCatalogoIdAt(index);
        final existencia = widget.controller.getCatalogoExistenciaAt(index);
        final cantidad = _cantidad(id);
        return _ProductoCard(
          nombre: widget.controller.getCatalogoNombreAt(index),
          importe: widget.controller.getCatalogoImporteAt(index),
          imagen: widget.controller.getCatalogoImageUrlAt(index),
          cantidad: cantidad,
          existencia: existencia,
          onLess: () => _cambiarCantidad(index, -1),
          onMore: cantidad >= existencia
              ? null
              : () => _cambiarCantidad(index, 1),
        );
      },
    );
  }

  Future<void> _openCarrito() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, refreshSheet) => _CarritoSheet(
          carrito: _carrito,
          total: _total,
          onRemove: (item) {
            setState(() {
              _carrito.items.remove(item);
              _storage.saveDraft(_carrito);
            });
            refreshSheet(() {});
          },
          onConfirm: _carrito.items.isEmpty
              ? null
              : () async {
                  final confirmado = await widget.controller.confirmarCarrito(
                    uuid: _carrito.uuid,
                    items: _carrito.items.map((item) => item.toJson()).toList(),
                    disponible: _disponible,
                  );
                  if (!confirmado || !mounted) return;

                  _storage.delete(_carrito.uuid);
                  setState(() {
                    _carrito = _CarritoLocal.nuevo();
                    _savedSomething = true;
                  });
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                  ScaffoldMessenger.of(this.context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Compra registrada correctamente. Consulte su seguimiento en Ver historial.',
                      ),
                    ),
                  );
                },
        ),
      ),
    );
  }

  Future<void> _openDrafts() async {
    final drafts = _storage.loadDrafts();
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: SmxColors.white,
      builder: (sheetContext) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Carritos guardados',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          if (drafts.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 30),
              child: Center(child: Text('No hay carritos pendientes')),
            ),
          for (final draft in drafts)
            ListTile(
              leading: const Icon(Icons.shopping_bag_outlined),
              title: Text('${draft.items.length} productos'),
              subtitle: Text(SmxRowSet.formatAmount(draft.total)),
              trailing: IconButton(
                tooltip: 'Eliminar carrito',
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  _storage.delete(draft.uuid);
                  setState(() {
                    if (_carrito.uuid == draft.uuid) {
                      _carrito = _CarritoLocal.nuevo();
                    }
                  });
                  Navigator.pop(sheetContext);
                  _openDrafts();
                },
              ),
              onTap: () {
                setState(() => _carrito = draft);
                Navigator.pop(sheetContext);
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F7F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFF17643B),
        foregroundColor: Colors.white,
        leading: IconButton(
          tooltip: 'Regresar',
          onPressed: () => Navigator.of(context).pop(_savedSomething),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Catalogo',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            Text(
              widget.model.clientName,
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          Badge(
            isLabelVisible: _carritosGuardados > 0,
            label: Text('$_carritosGuardados'),
            child: IconButton(
              tooltip: 'Carritos guardados',
              onPressed: _openDrafts,
              icon: const Icon(Icons.history),
            ),
          ),
          Badge(
            isLabelVisible: _unidades > 0,
            label: Text('$_unidades'),
            child: IconButton(
              tooltip: 'Ver carrito',
              onPressed: _openCarrito,
              icon: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 900
              ? 4
              : constraints.maxWidth >= 620
              ? 3
              : 2;
          final solicitados = _catalogoIndexes(solicitados: true);
          final disponibles = _catalogoIndexes(solicitados: false);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (solicitados.isNotEmpty) ...[
                const _CatalogoSectionTitle(
                  title: 'Productos solicitados',
                  icon: Icons.shopping_cart_checkout,
                ),
                const SizedBox(height: 12),
                _productosGrid(solicitados, columns),
                const SizedBox(height: 26),
              ],
              const _CatalogoSectionTitle(
                title: 'Catalogo de productos',
                icon: Icons.storefront_outlined,
              ),
              const SizedBox(height: 12),
              if (disponibles.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 28),
                  child: Center(
                    child: Text('Todos los productos estan solicitados'),
                  ),
                )
              else
                _productosGrid(disponibles, columns),
            ],
          );
        },
      ),
      bottomNavigationBar: _unidades == 0
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: FilledButton.icon(
                  onPressed: _openCarrito,
                  icon: const Icon(Icons.shopping_cart_checkout),
                  label: Text(
                    '$_unidades unidades  ·  ${SmxRowSet.formatAmount(_total)}',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF11935A),
                    minimumSize: const Size.fromHeight(54),
                  ),
                ),
              ),
            ),
    );
  }
}

class _CatalogoSectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;

  const _CatalogoSectionTitle({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF17643B)),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF17364A),
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _ProductoCard extends StatelessWidget {
  final String nombre;
  final double importe;
  final String imagen;
  final int cantidad;
  final int existencia;
  final VoidCallback onLess;
  final VoidCallback? onMore;

  const _ProductoCard({
    required this.nombre,
    required this.importe,
    required this.imagen,
    required this.cantidad,
    required this.existencia,
    required this.onLess,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: imagen.isEmpty
                ? const ColoredBox(
                    color: Color(0xFFE5F2EC),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 46,
                      color: Color(0xFF17643B),
                    ),
                  )
                : Image.network(
                    imagen,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.inventory_2_outlined, size: 46),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        SmxRowSet.formatAmount(importe),
                        style: const TextStyle(
                          color: Color(0xFF17643B),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Tooltip(
                      message: 'Existencia disponible',
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 17,
                            color: _existenciaColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$existencia',
                            style: TextStyle(
                              color: _existenciaColor,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton.filledTonal(
                      tooltip: 'Quitar',
                      onPressed: cantidad == 0 ? null : onLess,
                      icon: const Icon(Icons.remove),
                    ),
                    Text(
                      '$cantidad',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    IconButton.filled(
                      tooltip: 'Agregar',
                      onPressed: onMore,
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color get _existenciaColor {
    if (existencia <= 0) return const Color(0xFFD63C32);
    if (existencia <= 5) return const Color(0xFFC47A08);
    return const Color(0xFF168653);
  }
}

class _CarritoSheet extends StatelessWidget {
  final _CarritoLocal carrito;
  final double total;
  final ValueChanged<_CarritoItem> onRemove;
  final VoidCallback? onConfirm;

  const _CarritoSheet({
    required this.carrito,
    required this.total,
    required this.onRemove,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .72,
      minChildSize: .45,
      maxChildSize: .92,
      builder: (context, scrollController) => Material(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        child: ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(20),
          children: [
            const Text(
              'Tu carrito',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            if (carrito.items.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: Center(child: Text('Aun no agregas productos')),
              ),
            for (final item in carrito.items)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: item.imagen.isEmpty
                    ? const Icon(Icons.inventory_2_outlined)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          item.imagen,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                        ),
                      ),
                title: Text(
                  item.producto,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  '${item.cantidad} × ${SmxRowSet.formatAmount(item.importe)}',
                ),
                trailing: IconButton(
                  tooltip: 'Quitar producto',
                  onPressed: () => onRemove(item),
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                Text(
                  SmxRowSet.formatAmount(total),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onConfirm,
              icon: const Icon(Icons.check),
              label: const Text('Confirmar carrito'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CarritoStorage {
  final int idSysuser11;

  const _CarritoStorage(this.idSysuser11);

  String get _key => 'saldify_carritos_$idSysuser11';

  List<_CarritoLocal> loadDrafts() {
    final raw = html.window.localStorage[_key];
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final result = list
          .map((value) => _CarritoLocal.fromJson(value as Map<String, dynamic>))
          .toList();
      result.sort((a, b) => b.actualizado.compareTo(a.actualizado));
      return result;
    } catch (_) {
      return [];
    }
  }

  void saveDraft(_CarritoLocal cart) {
    final drafts = loadDrafts();
    drafts.removeWhere((item) => item.uuid == cart.uuid);
    if (cart.items.isNotEmpty) drafts.add(cart);
    html.window.localStorage[_key] = jsonEncode(
      drafts.map((item) => item.toJson()).toList(),
    );
  }

  void delete(String uuid) {
    final drafts = loadDrafts()..removeWhere((item) => item.uuid == uuid);
    html.window.localStorage[_key] = jsonEncode(
      drafts.map((item) => item.toJson()).toList(),
    );
  }
}

class _CarritoLocal {
  final String uuid;
  DateTime actualizado;
  final List<_CarritoItem> items;

  _CarritoLocal({
    required this.uuid,
    required this.actualizado,
    required this.items,
  });

  factory _CarritoLocal.nuevo() => _CarritoLocal(
    uuid: const Uuid().v4(),
    actualizado: DateTime.now(),
    items: [],
  );

  factory _CarritoLocal.fromJson(Map<String, dynamic> json) => _CarritoLocal(
    uuid: json['uuid']?.toString() ?? const Uuid().v4(),
    actualizado:
        DateTime.tryParse(json['actualizado']?.toString() ?? '') ??
        DateTime.now(),
    items: (json['items'] as List<dynamic>? ?? [])
        .map((value) => _CarritoItem.fromJson(value as Map<String, dynamic>))
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

class _CarritoItem {
  final int idProducto;
  final String producto;
  final double importe;
  final String imagen;
  int cantidad;

  _CarritoItem({
    required this.idProducto,
    required this.producto,
    required this.importe,
    required this.imagen,
    required this.cantidad,
  });

  factory _CarritoItem.fromJson(Map<String, dynamic> json) => _CarritoItem(
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
