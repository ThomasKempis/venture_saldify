import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';

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
    const spacing = 12.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final index in indexes)
              SizedBox(
                width: cardWidth,
                child: _ProductoCard(
                  nombre: widget.controller.getCatalogoNombreAt(index),
                  importe: widget.controller.getCatalogoImporteAt(index),
                  imagen: widget.controller.getCatalogoImageUrlAt(index),
                  cantidad: _cantidad(widget.controller.getCatalogoIdAt(index)),
                  existencia: widget.controller.getCatalogoExistenciaAt(index),
                  onLess: () => _cambiarCantidad(index, -1),
                  onMore:
                      _cantidad(widget.controller.getCatalogoIdAt(index)) >=
                          widget.controller.getCatalogoExistenciaAt(index)
                      ? null
                      : () => _cambiarCantidad(index, 1),
                ),
              ),
          ],
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
    final layout = SmxLayout.sizeFromWidth(MediaQuery.of(context).size.width);
    final pagePadding = layout.saldifyPagePadding;
    final topContentInset = SmxLayout.topContentInset(context);
    final bottomContentInset = SmxLayout.bottomContentInset(context);

    return SmxSaldifyBackground(
      child: Scaffold(
        backgroundColor: SmxColors.transparent,
        body: SafeArea(
          top: false,
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: layout.saldifyMaxContentWidth,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth >= 900
                      ? 4
                      : constraints.maxWidth >= 620
                      ? 3
                      : 2;
                  final solicitados = _catalogoIndexes(solicitados: true);
                  final disponibles = _catalogoIndexes(solicitados: false);
                  return ListView(
                    padding: EdgeInsets.fromLTRB(
                      pagePadding.left,
                      pagePadding.top + topContentInset,
                      pagePadding.right,
                      pagePadding.bottom + bottomContentInset,
                    ),
                    children: [
                      SmxSaldifyScreenHeader(
                        title: widget.model.clientName,
                        sectionLabel: 'Catalogo',
                        onBackPressed: () =>
                            Navigator.of(context).pop(_savedSomething),
                        actions: [
                          Badge(
                            isLabelVisible: _carritosGuardados > 0,
                            label: Text('$_carritosGuardados'),
                            child: SmxSaldifyHeaderIconButton(
                              tooltip: 'Carritos guardados',
                              icon: Icons.history,
                              onPressed: _openDrafts,
                            ),
                          ),
                          Badge(
                            isLabelVisible: _unidades > 0,
                            label: Text('$_unidades'),
                            child: SmxSaldifyHeaderIconButton(
                              tooltip: 'Ver carrito',
                              icon: Icons.shopping_cart_outlined,
                              onPressed: _openCarrito,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
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
                            child: Text(
                              'Todos los productos estan solicitados',
                              style: TextStyle(color: SmxColors.white),
                            ),
                          ),
                        )
                      else
                        _productosGrid(disponibles, columns),
                    ],
                  );
                },
              ),
            ),
          ),
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
        Icon(icon, color: SmxColors.white),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: SmxColors.white,
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
      color: Colors.white.withValues(alpha: .86),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 1.10,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _ProductImage(imagen: imagen),
                Positioned(
                  left: 8,
                  right: 8,
                  top: 8,
                  child: Row(
                    children: [
                      _ImagePricePill(importe: importe),
                      const Spacer(),
                      _StockPill(
                        existencia: existencia,
                        color: _existenciaColor,
                        elevated: true,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: _QuantityStepper(
                    cantidad: cantidad,
                    onLess: cantidad == 0 ? null : onLess,
                    onMore: onMore,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nombre,
                  softWrap: true,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    height: 1.15,
                  ),
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

class _ProductImage extends StatelessWidget {
  final String imagen;

  const _ProductImage({required this.imagen});

  @override
  Widget build(BuildContext context) {
    final imageUrl = imagen.trim();

    if (imageUrl.isEmpty) {
      return const Icon(
        Icons.inventory_2_outlined,
        size: 42,
        color: Color(0xFF17643B),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) =>
          const Icon(Icons.inventory_2_outlined, size: 42),
    );
  }
}

class _ImagePricePill extends StatelessWidget {
  final double importe;

  const _ImagePricePill({required this.importe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.12),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        SmxRowSet.formatAmount(importe),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFF17643B),
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int cantidad;
  final VoidCallback? onLess;
  final VoidCallback? onMore;

  const _QuantityStepper({
    required this.cantidad,
    required this.onLess,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.14),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _QuantityButton(
            tooltip: 'Quitar',
            icon: Icons.remove_rounded,
            onPressed: onLess,
            backgroundColor: onLess == null
                ? const Color(0xFFE4E6E7)
                : const Color(0xFFE7E7EA),
            foregroundColor: onLess == null
                ? const Color(0xFFB2B6BA)
                : const Color(0xFF6B6F76),
          ),
          Expanded(
            child: Text(
              '$cantidad',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Color(0xFF23242A),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _QuantityButton(
            tooltip: 'Agregar',
            icon: Icons.add_rounded,
            onPressed: onMore,
            backgroundColor: onMore == null
                ? const Color(0xFFE4E6E7)
                : const Color(0xFF168653),
            foregroundColor: onMore == null
                ? const Color(0xFF8F9499)
                : Colors.white,
          ),
        ],
      ),
    );
  }
}

class _StockPill extends StatelessWidget {
  final int existencia;
  final Color color;
  final bool elevated;

  const _StockPill({
    required this.existencia,
    required this.color,
    this.elevated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Existencia disponible',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: elevated
              ? Colors.white.withValues(alpha: .92)
              : color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(999),
          boxShadow: elevated
              ? [
                  BoxShadow(
                    color: SmxColors.blackAlpha(.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              '$existencia',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color foregroundColor;

  const _QuantityButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: backgroundColor,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: SizedBox.square(
            dimension: 30,
            child: Icon(icon, size: 20, color: foregroundColor),
          ),
        ),
      ),
    );
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
