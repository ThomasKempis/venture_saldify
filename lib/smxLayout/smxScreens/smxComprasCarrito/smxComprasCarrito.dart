import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:universal_html/html.dart' as html;
import 'package:uuid/uuid.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/saldify_circles_background.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';

import 'smxComprasCarritoControllerContract.dart';
import 'smxComprasCarritoModels.dart';

final _cartAmountFormat = NumberFormat.currency(
  locale: 'en_US',
  symbol: r'$',
  decimalDigits: 2,
);

String _formatCartAmount(num value) => _cartAmountFormat.format(value);

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

  _ProductoCatalogo _productoAt(int index) {
    final id = widget.controller.getCatalogoIdAt(index);
    return _ProductoCatalogo(
      id: id,
      nombre: widget.controller.getCatalogoNombreAt(index),
      importe: widget.controller.getCatalogoImporteAt(index),
      imagen: widget.controller.getCatalogoImageUrlAt(index),
      existencia: widget.controller.getCatalogoExistenciaAt(index),
      cantidad: _cantidad(id),
    );
  }

  void _setCantidad(int index, int cantidad) {
    final producto = _productoAt(index);
    final id = producto.id;
    final existing = _carrito.indexOf(id);
    final cantidadFinal = cantidad.clamp(0, producto.existencia).toInt();

    setState(() {
      if (cantidadFinal <= 0) {
        if (existing >= 0) _carrito.items.removeAt(existing);
      } else if (existing < 0) {
        _carrito.items.add(
          _CarritoItem(
            idProducto: id,
            producto: producto.nombre,
            importe: producto.importe,
            imagen: producto.imagen,
            cantidad: cantidadFinal,
          ),
        );
      } else if (existing >= 0) {
        _carrito.items[existing].cantidad = cantidadFinal;
      }
      _carrito.actualizado = DateTime.now();
      _storage.saveDraft(_carrito);
    });
  }

  int _cantidad(int idProducto) {
    final index = _carrito.indexOf(idProducto);
    return index < 0 ? 0 : _carrito.items[index].cantidad;
  }

  int _existenciaById(int idProducto) {
    for (var index = 0; index < widget.controller.catalogoCount; index++) {
      if (widget.controller.getCatalogoIdAt(index) == idProducto) {
        return widget.controller.getCatalogoExistenciaAt(index);
      }
    }
    return 0;
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
                  producto: _productoAt(index),
                  onTap: () => _openProducto(index),
                ),
              ),
          ],
        );
      },
    );
  }

  List<int> _catalogoIndexesOrdenados() {
    final seleccionados = <int>[];
    final disponibles = <int>[];

    for (var index = 0; index < widget.controller.catalogoCount; index++) {
      final id = widget.controller.getCatalogoIdAt(index);
      if (_cantidad(id) > 0) {
        seleccionados.add(index);
      } else {
        disponibles.add(index);
      }
    }

    return [...seleccionados, ...disponibles];
  }

  Future<void> _openProducto(int index) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final producto = _productoAt(index);
        return _ProductoSheet(
          producto: producto,
          onAdd: (cantidad) {
            _setCantidad(index, cantidad);
            Navigator.pop(sheetContext);
          },
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
          existenciaForItem: (item) => _existenciaById(item.idProducto),
          onQuantityChanged: (item, cantidad) {
            setState(() {
              final existencia = _existenciaById(item.idProducto);
              final cantidadFinal = cantidad.clamp(0, existencia).toInt();
              if (cantidadFinal <= 0) {
                _carrito.items.remove(item);
              } else {
                item.cantidad = cantidadFinal;
              }
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
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _CartSheetBackground(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: SmxColors.blackAlpha(.14),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Carritos guardados',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            if (drafts.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 30),
                child: Center(child: Text('No hay carritos pendientes')),
              ),
            for (final draft in drafts)
              _DraftCartCard(
                draft: draft,
                onTap: () {
                  setState(() => _carrito = draft);
                  Navigator.pop(sheetContext);
                  _openCarrito();
                },
              ),
          ],
        ),
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
                  final productos = _catalogoIndexesOrdenados();
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
                      const _CatalogoSectionTitle(
                        title: 'Catalogo de productos',
                        icon: Icons.storefront_outlined,
                      ),
                      const SizedBox(height: 12),
                      if (productos.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 28),
                          child: Center(
                            child: Text(
                              'No hay productos disponibles',
                              style: TextStyle(color: SmxColors.white),
                            ),
                          ),
                        )
                      else
                        _productosGrid(productos, columns),
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
                      '$_unidades unidades  ·  ${_formatCartAmount(_total)}',
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
  final _ProductoCatalogo producto;
  final VoidCallback onTap;

  const _ProductoCard({required this.producto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: .86),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: .96,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ProductImage(imagen: producto.imagen),
                  if (producto.cantidad > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: _SelectedPill(cantidad: producto.cantidad),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 9, 10, 4),
              child: Text(
                producto.nombre,
                softWrap: true,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF202229),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  height: 1.12,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 11),
              child: Row(
                children: [
                  Text(
                    _formatCartAmount(producto.importe),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF17643B),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Spacer(),
                  _StockPill(
                    existencia: producto.existencia,
                    color: _existenciaColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _existenciaColor {
    if (producto.existencia <= 0) return const Color(0xFFD63C32);
    if (producto.existencia <= 5) return const Color(0xFFC47A08);
    return const Color(0xFF168653);
  }
}

class _ProductoSheet extends StatefulWidget {
  final _ProductoCatalogo producto;
  final ValueChanged<int> onAdd;

  const _ProductoSheet({required this.producto, required this.onAdd});

  @override
  State<_ProductoSheet> createState() => _ProductoSheetState();
}

class _ProductoSheetState extends State<_ProductoSheet> {
  late int _cantidad;

  @override
  void initState() {
    super.initState();
    if (widget.producto.existencia <= 0) {
      _cantidad = 0;
    } else if (widget.producto.cantidad > 0) {
      _cantidad = widget.producto.cantidad
          .clamp(1, widget.producto.existencia)
          .toInt();
    } else {
      _cantidad = 1;
    }
  }

  void _change(int delta) {
    final next = (_cantidad + delta)
        .clamp(1, widget.producto.existencia)
        .toInt();
    setState(() => _cantidad = next);
  }

  @override
  Widget build(BuildContext context) {
    final producto = widget.producto;
    final canAdd = producto.existencia > 0 && _cantidad > 0;

    return _CartSheetBackground(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          16,
          20,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: SmxColors.blackAlpha(.14),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox.square(
                    dimension: 88,
                    child: _ProductImage(imagen: producto.imagen),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        producto.nombre,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF152D3F),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          height: 1.08,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _formatCartAmount(producto.importe),
                        style: const TextStyle(
                          color: Color(0xFF168653),
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      _StockPill(
                        existencia: producto.existencia,
                        color: _stockColor(producto.existencia),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text(
                  'Cantidad',
                  style: TextStyle(
                    color: Color(0xFF152D3F),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const Spacer(),
                _QuantityStepper(
                  cantidad: _cantidad,
                  compact: true,
                  onLess: canAdd && _cantidad > 1 ? () => _change(-1) : null,
                  onMore: canAdd && _cantidad < producto.existencia
                      ? () => _change(1)
                      : null,
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: canAdd ? () => widget.onAdd(_cantidad) : null,
              icon: const Icon(Icons.add_shopping_cart_rounded),
              label: Text(
                producto.cantidad > 0
                    ? 'Actualizar carrito'
                    : 'Agregar al carrito',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF168653),
                minimumSize: const Size.fromHeight(54),
                textStyle: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _stockColor(int existencia) {
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

class _SelectedPill extends StatelessWidget {
  final int cantidad;

  const _SelectedPill({required this.cantidad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF168653).withValues(alpha: .72),
        borderRadius: BorderRadius.circular(999),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.16),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_cart_checkout_rounded,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            '$cantidad',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int cantidad;
  final VoidCallback? onLess;
  final VoidCallback? onMore;
  final bool compact;
  final bool dense;

  const _QuantityStepper({
    required this.cantidad,
    required this.onLess,
    required this.onMore,
    this.compact = false,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final stepperWidth = dense ? 96.0 : 126.0;
    final stepperHeight = dense ? 34.0 : 44.0;
    final buttonDimension = dense ? 26.0 : 34.0;

    return Container(
      width: compact ? stepperWidth : null,
      height: compact ? stepperHeight : 38,
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
            dimension: compact ? buttonDimension : 30,
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
            dimension: compact ? buttonDimension : 30,
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

  const _StockPill({required this.existencia, required this.color});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Existencia disponible',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: color.withValues(alpha: .10),
          borderRadius: BorderRadius.circular(999),
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
  final double dimension;

  const _QuantityButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    required this.foregroundColor,
    this.dimension = 30,
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
            dimension: dimension,
            child: Icon(icon, size: 20, color: foregroundColor),
          ),
        ),
      ),
    );
  }
}

class _CartSheetBackground extends StatelessWidget {
  final Widget child;

  const _CartSheetBackground({required this.child});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFBFEFE), Color(0xFFF3FAF9), Color(0xFFEEF7F6)],
          ),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        child: Stack(
          children: [
            const Positioned.fill(
              child: CustomPaint(
                painter: SaldifyCirclesBackgroundPainter(
                  accentColor: SmxColors.brandSecondary,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}

class _DraftCartCard extends StatelessWidget {
  final _CarritoLocal draft;
  final VoidCallback onTap;

  const _DraftCartCard({required this.draft, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: const Color(0xFFF3F7F6),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _DraftImageGrid(items: draft.items),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${draft.items.length} productos',
                        style: const TextStyle(
                          color: Color(0xFF23242A),
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _formatCartAmount(draft.total),
                        style: const TextStyle(
                          color: Color(0xFF17643B),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Continuar compra',
                        style: TextStyle(
                          color: Color(0xFF6A7780),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF6A7780),
                  size: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DraftImageGrid extends StatelessWidget {
  final List<_CarritoItem> items;

  const _DraftImageGrid({required this.items});

  @override
  Widget build(BuildContext context) {
    final visible = items.take(4).toList();

    return SizedBox.square(
      dimension: 72,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: visible.length == 1
            ? _DraftImageTile(item: visible.first, iconSize: 28)
            : GridView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 2,
                  crossAxisSpacing: 2,
                ),
                itemCount: 4,
                itemBuilder: (context, index) {
                  if (index >= visible.length) {
                    return Container(
                      color: Colors.white.withValues(alpha: .72),
                    );
                  }

                  return _DraftImageTile(item: visible[index]);
                },
              ),
      ),
    );
  }
}

class _DraftImageTile extends StatelessWidget {
  final _CarritoItem item;
  final double iconSize;

  const _DraftImageTile({required this.item, this.iconSize = 18});

  @override
  Widget build(BuildContext context) {
    if (item.imagen.isEmpty) {
      return Container(
        color: Colors.white.withValues(alpha: .82),
        child: Icon(
          Icons.inventory_2_outlined,
          size: iconSize,
          color: const Color(0xFF17643B),
        ),
      );
    }

    return Image.network(
      item.imagen,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => Container(
        color: Colors.white.withValues(alpha: .82),
        child: Icon(
          Icons.inventory_2_outlined,
          size: iconSize,
          color: const Color(0xFF17643B),
        ),
      ),
    );
  }
}

class _CarritoSheet extends StatelessWidget {
  final _CarritoLocal carrito;
  final double total;
  final int Function(_CarritoItem item) existenciaForItem;
  final void Function(_CarritoItem item, int cantidad) onQuantityChanged;
  final VoidCallback? onConfirm;

  const _CarritoSheet({
    required this.carrito,
    required this.total,
    required this.existenciaForItem,
    required this.onQuantityChanged,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: .72,
      minChildSize: .45,
      maxChildSize: .92,
      builder: (context, scrollController) => _CartSheetBackground(
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
              _CarritoItemTile(
                item: item,
                existencia: existenciaForItem(item),
                onQuantityChanged: (cantidad) =>
                    onQuantityChanged(item, cantidad),
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
                  _formatCartAmount(total),
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

class _CarritoItemTile extends StatelessWidget {
  final _CarritoItem item;
  final int existencia;
  final ValueChanged<int> onQuantityChanged;

  const _CarritoItemTile({
    required this.item,
    required this.existencia,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox.square(
              dimension: 54,
              child: item.imagen.isEmpty
                  ? const Icon(Icons.inventory_2_outlined)
                  : Image.network(item.imagen, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.producto,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF23242A),
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  _formatCartAmount(item.importe),
                  style: const TextStyle(
                    color: Color(0xFF5D6067),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _QuantityStepper(
                cantidad: item.cantidad,
                compact: true,
                dense: true,
                onLess: () => onQuantityChanged(item.cantidad - 1),
                onMore: item.cantidad < existencia
                    ? () => onQuantityChanged(item.cantidad + 1)
                    : null,
              ),
              const SizedBox(height: 5),
              Text(
                _formatCartAmount(item.importe * item.cantidad),
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: Color(0xFF23242A),
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProductoCatalogo {
  final int id;
  final String nombre;
  final double importe;
  final String imagen;
  final int existencia;
  final int cantidad;

  const _ProductoCatalogo({
    required this.id,
    required this.nombre,
    required this.importe,
    required this.imagen,
    required this.existencia,
    required this.cantidad,
  });
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
