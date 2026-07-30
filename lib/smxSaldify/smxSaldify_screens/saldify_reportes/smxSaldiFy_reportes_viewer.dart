import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';

import 'smxSaldiFy_reportes_controller.dart';
import 'smxSaldiFy_reportes_pdf.dart';

enum _ReporteVista { movimientos, clientes, productos }

extension _ReporteVistaPdf on _ReporteVista {
  SmxSaldiFyReportesPdfVista get pdfVista {
    return switch (this) {
      _ReporteVista.movimientos => SmxSaldiFyReportesPdfVista.movimientos,
      _ReporteVista.clientes => SmxSaldiFyReportesPdfVista.clientes,
      _ReporteVista.productos => SmxSaldiFyReportesPdfVista.productos,
    };
  }
}

class SmxSaldiFyReportesViewer extends StatefulWidget {
  final SmxRowSet rowset;
  final SmxSaldiFyReporteTipo reporteTipo;
  final DateTime fechaDesde;
  final DateTime fechaHasta;

  const SmxSaldiFyReportesViewer({
    super.key,
    required this.rowset,
    required this.reporteTipo,
    required this.fechaDesde,
    required this.fechaHasta,
  });

  @override
  State<SmxSaldiFyReportesViewer> createState() =>
      _SmxSaldiFyReportesViewerState();
}

class _SmxSaldiFyReportesViewerState extends State<SmxSaldiFyReportesViewer> {
  late List<_ReporteMovimiento> _movimientos;
  _ReporteVista _vista = _ReporteVista.movimientos;
  String? _grupoAbierto;

  @override
  void initState() {
    super.initState();
    _movimientos = _readMovimientos(widget.rowset, widget.reporteTipo);
  }

  @override
  void didUpdateWidget(covariant SmxSaldiFyReportesViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.rowset, widget.rowset) ||
        oldWidget.reporteTipo != widget.reporteTipo) {
      _movimientos = _readMovimientos(widget.rowset, widget.reporteTipo);
      _vista = _ReporteVista.movimientos;
      _grupoAbierto = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_movimientos.isEmpty) return const _ReporteVacio();

    final clientes = _movimientos.map((item) => item.entidad).toSet().length;
    final total = _movimientos.fold<double>(
      0,
      (sum, item) => sum + item.totalReporte,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReporteResumen(
          movimientos: _movimientos.length,
          clientes: clientes,
          total: total,
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: SmxColors.whiteAlpha(.12),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SmxColors.whiteAlpha(.14)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _VistaSelector(
                vista: _vista,
                onSelected: (vista) {
                  setState(() {
                    _vista = vista;
                    _grupoAbierto = null;
                  });
                },
              ),
              const SizedBox(height: 10),
              Stack(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    child: _vista == _ReporteVista.movimientos
                        ? _AtomicGrid(
                            key: const ValueKey('movimientos'),
                            movimientos: _movimientos,
                            onClienteTap: (cliente) =>
                                _openGroup(_ReporteVista.clientes, cliente),
                            onProductoTap: (producto) =>
                                _openGroup(_ReporteVista.productos, producto),
                          )
                        : _GroupedGrid(
                            key: ValueKey(_vista),
                            grupos: _buildGrupos(),
                            vista: _vista,
                            grupoAbierto: _grupoAbierto,
                            onGroupTap: (grupo) {
                              setState(() {
                                _grupoAbierto = _grupoAbierto == grupo
                                    ? null
                                    : grupo;
                              });
                            },
                            onFechaTap: () {
                              setState(() {
                                _vista = _ReporteVista.movimientos;
                                _grupoAbierto = null;
                              });
                            },
                          ),
                  ),
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _PdfFloatingButton(onTap: _openPdf),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _openGroup(_ReporteVista vista, String grupo) {
    setState(() {
      _vista = vista;
      _grupoAbierto = grupo;
    });
  }

  Future<void> _openPdf() async {
    try {
      await SmxSaldiFyReportesPdf.open(
        tipo: widget.reporteTipo,
        vista: _vista.pdfVista,
        fechaDesde: widget.fechaDesde,
        fechaHasta: widget.fechaHasta,
        movimientos: _movimientos.map((movimiento) {
          return SmxSaldiFyReportesPdfMovimiento(
            folio: movimiento.folio,
            entidad: movimiento.entidad,
            owner: movimiento.owner,
            estado: movimiento.statusLabel,
            producto: movimiento.concepto,
            cantidad: movimiento.cantidad,
            importe: movimiento.importe,
            total: movimiento.total,
            totalReporte: movimiento.totalReporte,
            fecha: movimiento.fecha,
          );
        }).toList(),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No se pudo abrir el PDF')));
    }
  }

  List<_ReporteGrupo> _buildGrupos() {
    final values = <String, List<_ReporteMovimiento>>{};
    for (final movimiento in _movimientos) {
      final key = _vista == _ReporteVista.clientes
          ? movimiento.entidad
          : movimiento.concepto;
      values.putIfAbsent(key, () => []).add(movimiento);
    }

    final grupos = values.entries.map((entry) {
      return _ReporteGrupo(nombre: entry.key, movimientos: entry.value);
    }).toList();
    grupos.sort((a, b) => b.total.compareTo(a.total));
    return grupos;
  }

  List<_ReporteMovimiento> _readMovimientos(
    SmxRowSet source,
    SmxSaldiFyReporteTipo reporteTipo,
  ) {
    final rowset = source.copy();
    final movimientos = <_ReporteMovimiento>[];
    final tipoReporte = reporteTipo.tipoMovimiento;

    for (var index = 0; index < rowset.getRowCount(); index++) {
      rowset.index(index);
      movimientos.add(
        _ReporteMovimiento(
          id: _toInt(rowset.getValue('ID_SYSUSER90')),
          tipo: tipoReporte,
          entidad: _cleanText(
            rowset.getValue('SYSUSER90_ENTIDAD'),
            fallback: 'Sin cliente',
          ),
          concepto: _cleanText(
            rowset.getValue('SYSUSER90_CONCEPTO'),
            fallback: 'Sin concepto',
          ),
          cantidad: _toDouble(rowset.getValue('SYSUSER90_CANTIDAD')),
          importe: _toDouble(rowset.getValue('SYSUSER90_IMPORTE')),
          total: _toDouble(
            rowset.getValue('SYSUSER90_TOTAL') ??
                rowset.getValue('SYSUSER90_IMPORTE'),
          ),
          fecha: _toDate(rowset.getValue('SYSUSER90_FECHA')),
          status: _toInt(rowset.getValue('SYSUSER90_STATUS')),
          owner: _cleanText(rowset.getValue('SYSUSER90_OWNER')),
        ),
      );
    }

    movimientos.sort((a, b) => b.fecha.compareTo(a.fecha));
    return movimientos;
  }

  static String _cleanText(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static int _toInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  static DateTime _toDate(dynamic value) {
    if (value is DateTime) return value;
    return DateTime.tryParse(value?.toString() ?? '') ?? DateTime(1900);
  }
}

class _ReporteResumen extends StatelessWidget {
  final int movimientos;
  final int clientes;
  final double total;

  const _ReporteResumen({
    required this.movimientos,
    required this.clientes,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SmxColors.whiteAlpha(.14)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ResumenTile(
              value: movimientos.toString(),
              label: 'Movimientos',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ResumenTile(value: clientes.toString(), label: 'Clientes'),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ResumenTile(
              value: SmxRowSet.formatAmount(total),
              label: 'Total',
              accent: SmxColors.brandPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenTile extends StatelessWidget {
  final String value;
  final String label;
  final Color? accent;

  const _ResumenTile({required this.value, required this.label, this.accent});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 66,
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 8),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              maxLines: 1,
              style: TextStyle(
                color: accent ?? SmxColors.textDark,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SmxColors.textMuted,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _VistaSelector extends StatelessWidget {
  final _ReporteVista vista;
  final ValueChanged<_ReporteVista> onSelected;

  const _VistaSelector({required this.vista, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _VistaButton(
          label: 'Movimientos',
          selected: vista == _ReporteVista.movimientos,
          onTap: () => onSelected(_ReporteVista.movimientos),
        ),
        const SizedBox(width: 7),
        _VistaButton(
          label: 'Clientes',
          selected: vista == _ReporteVista.clientes,
          onTap: () => onSelected(_ReporteVista.clientes),
        ),
        const SizedBox(width: 7),
        _VistaButton(
          label: 'Productos',
          selected: vista == _ReporteVista.productos,
          onTap: () => onSelected(_ReporteVista.productos),
        ),
      ],
    );
  }
}

class _PdfFloatingButton extends StatelessWidget {
  final VoidCallback onTap;

  const _PdfFloatingButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.94),
      elevation: 6,
      shadowColor: SmxColors.blackAlpha(.24),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: const SizedBox(
          width: 54,
          height: 54,
          child: Icon(
            Icons.picture_as_pdf_rounded,
            color: SmxColors.dangerForeground,
            size: 24,
          ),
        ),
      ),
    );
  }
}

class _VistaButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _VistaButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        color: selected ? SmxColors.brandAccent : SmxColors.whiteAlpha(.86),
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            height: 34,
            child: Center(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SmxColors.textDark,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AtomicGrid extends StatelessWidget {
  final List<_ReporteMovimiento> movimientos;
  final ValueChanged<String> onClienteTap;
  final ValueChanged<String> onProductoTap;

  const _AtomicGrid({
    super.key,
    required this.movimientos,
    required this.onClienteTap,
    required this.onProductoTap,
  });

  @override
  Widget build(BuildContext context) {
    return _HorizontalGrid(
      minWidth: 972,
      builder: (factor) => Column(
        children: [
          _GridHeader(
            cells: [
              _GridCellData('Cliente', 200 * factor),
              _GridCellData('Folio', 90 * factor),
              _GridCellData('Estado', 140 * factor),
              _GridCellData('Producto', 150 * factor),
              _GridCellData('Cantidad', 82 * factor),
              _GridCellData('P. unitario', 100 * factor, alignRight: true),
              _GridCellData('Total', 105 * factor, alignRight: true),
              _GridCellData('Fecha', 105 * factor),
            ],
          ),
          for (var index = 0; index < movimientos.length; index++)
            _MovimientoRow(
              movimiento: movimientos[index],
              shaded: index.isOdd,
              widthFactor: factor,
              onClienteTap: () => onClienteTap(movimientos[index].entidad),
              onProductoTap: () => onProductoTap(movimientos[index].concepto),
            ),
        ],
      ),
    );
  }
}

class _GroupedGrid extends StatelessWidget {
  final List<_ReporteGrupo> grupos;
  final _ReporteVista vista;
  final String? grupoAbierto;
  final ValueChanged<String> onGroupTap;
  final VoidCallback onFechaTap;

  const _GroupedGrid({
    super.key,
    required this.grupos,
    required this.vista,
    required this.grupoAbierto,
    required this.onGroupTap,
    required this.onFechaTap,
  });

  @override
  Widget build(BuildContext context) {
    return _HorizontalGrid(
      minWidth: 765,
      builder: (factor) => Column(
        children: [
          _GridHeader(
            cells: [
              _GridCellData(
                vista == _ReporteVista.clientes ? 'Cliente' : 'Producto',
                210 * factor,
              ),
              _GridCellData('Folio', 90 * factor),
              _GridCellData('Estado', 135 * factor),
              _GridCellData('Cantidad', 100 * factor),
              _GridCellData('Total', 120 * factor, alignRight: true),
              _GridCellData('Último', 110 * factor),
            ],
          ),
          for (var index = 0; index < grupos.length; index++) ...[
            _GrupoRow(
              grupo: grupos[index],
              expanded: grupoAbierto == grupos[index].nombre,
              shaded: index.isOdd,
              widthFactor: factor,
              onTap: () => onGroupTap(grupos[index].nombre),
              onFechaTap: onFechaTap,
            ),
            if (grupoAbierto == grupos[index].nombre)
              for (final movimiento in grupos[index].movimientos)
                _DetalleGrupoRow(
                  movimiento: movimiento,
                  vista: vista,
                  widthFactor: factor,
                  onFechaTap: onFechaTap,
                ),
          ],
        ],
      ),
    );
  }
}

class _HorizontalGrid extends StatelessWidget {
  final double minWidth;
  final Widget Function(double widthFactor) builder;

  const _HorizontalGrid({required this.minWidth, required this.builder});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth > minWidth
            ? constraints.maxWidth
            : minWidth;
        final factor = width / minWidth;
        final height = _gridMaxHeight(context);

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: const {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: SizedBox(width: width, child: builder(factor)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double _gridMaxHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * .56;
    return maxHeight.clamp(320.0, 620.0);
  }
}

class _GridHeader extends StatelessWidget {
  final List<_GridCellData> cells;

  const _GridHeader({required this.cells});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      color: SmxColors.brandInteractive.withValues(alpha: .9),
      child: Row(
        children: [
          for (final cell in cells)
            SizedBox(
              width: cell.width,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 9),
                child: Text(
                  cell.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: cell.alignRight ? TextAlign.right : TextAlign.left,
                  style: const TextStyle(
                    color: SmxColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _MovimientoRow extends StatelessWidget {
  final _ReporteMovimiento movimiento;
  final bool shaded;
  final double widthFactor;
  final VoidCallback onClienteTap;
  final VoidCallback onProductoTap;

  const _MovimientoRow({
    required this.movimiento,
    required this.shaded,
    required this.widthFactor,
    required this.onClienteTap,
    required this.onProductoTap,
  });

  @override
  Widget build(BuildContext context) {
    double w(double value) => value * widthFactor;

    return Container(
      height: 52,
      color: shaded ? SmxColors.surfaceData : SmxColors.whiteAlpha(.94),
      child: Row(
        children: [
          _GridCell(
            width: w(200),
            value: movimiento.entidad,
            detail: movimiento.owner,
            onTap: onClienteTap,
            accent: true,
          ),
          _GridCell(width: w(90), value: movimiento.folio, strong: true),
          _GridCell(
            width: w(140),
            value: movimiento.statusLabel,
            textColor: movimiento.statusColor,
            strong: true,
          ),
          _GridCell(
            width: w(150),
            value: movimiento.concepto,
            onTap: onProductoTap,
            accent: true,
          ),
          _GridCell(width: w(82), value: _formatQuantity(movimiento.cantidad)),
          _GridCell(
            width: w(100),
            value: _amount(movimiento.importe),
            alignRight: true,
          ),
          _GridCell(
            width: w(105),
            value: _amount(movimiento.total),
            strong: true,
            alignRight: true,
          ),
          _GridCell(
            width: w(105),
            value: _formatDate(movimiento.fecha),
            onTap: () {},
            accent: true,
          ),
        ],
      ),
    );
  }
}

class _GrupoRow extends StatelessWidget {
  final _ReporteGrupo grupo;
  final bool expanded;
  final bool shaded;
  final double widthFactor;
  final VoidCallback onTap;
  final VoidCallback onFechaTap;

  const _GrupoRow({
    required this.grupo,
    required this.expanded,
    required this.shaded,
    required this.widthFactor,
    required this.onTap,
    required this.onFechaTap,
  });

  @override
  Widget build(BuildContext context) {
    double w(double value) => value * widthFactor;

    return Container(
      height: 50,
      color: expanded
          ? SmxColors.accentAlpha(.28)
          : shaded
          ? SmxColors.surfaceData
          : SmxColors.whiteAlpha(.94),
      child: Row(
        children: [
          _GridCell(
            width: w(210),
            value: grupo.nombre,
            detail: '${grupo.movimientos.length} movimientos',
            leading: expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            onTap: onTap,
            strong: true,
            accent: true,
          ),
          _GridCell(width: w(90), value: ''),
          _GridCell(width: w(135), value: ''),
          _GridCell(width: w(100), value: _formatQuantity(grupo.cantidad)),
          _GridCell(
            width: w(120),
            value: _amount(grupo.total),
            strong: true,
            alignRight: true,
          ),
          _GridCell(
            width: w(110),
            value: _formatDate(grupo.ultimaFecha),
            onTap: onFechaTap,
            accent: true,
          ),
        ],
      ),
    );
  }
}

class _DetalleGrupoRow extends StatelessWidget {
  final _ReporteMovimiento movimiento;
  final _ReporteVista vista;
  final double widthFactor;
  final VoidCallback onFechaTap;

  const _DetalleGrupoRow({
    required this.movimiento,
    required this.vista,
    required this.widthFactor,
    required this.onFechaTap,
  });

  @override
  Widget build(BuildContext context) {
    double w(double value) => value * widthFactor;
    final detail = vista == _ReporteVista.clientes
        ? movimiento.concepto
        : movimiento.entidad;
    return Container(
      height: 44,
      color: SmxColors.whiteAlpha(.82),
      child: Row(
        children: [
          _GridCell(width: w(210), value: detail, indent: true),
          _GridCell(width: w(90), value: movimiento.folio, strong: true),
          _GridCell(
            width: w(135),
            value: movimiento.statusLabel,
            textColor: movimiento.statusColor,
            strong: true,
          ),
          _GridCell(width: w(100), value: _formatQuantity(movimiento.cantidad)),
          _GridCell(
            width: w(120),
            value: _amount(movimiento.total),
            alignRight: true,
          ),
          _GridCell(
            width: w(110),
            value: _formatDate(movimiento.fecha),
            onTap: onFechaTap,
            accent: true,
          ),
        ],
      ),
    );
  }
}

class _GridCell extends StatelessWidget {
  final double width;
  final String value;
  final String detail;
  final VoidCallback? onTap;
  final IconData? leading;
  final bool strong;
  final bool accent;
  final bool indent;
  final bool alignRight;
  final Color? textColor;

  const _GridCell({
    required this.width,
    required this.value,
    this.detail = '',
    this.onTap,
    this.leading,
    this.strong = false,
    this.accent = false,
    this.indent = false,
    this.alignRight = false,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: EdgeInsets.only(
        left: indent ? 22 : 9,
        right: 9,
        top: 5,
        bottom: 5,
      ),
      child: Row(
        children: [
          if (leading != null) ...[
            Icon(leading, size: 15, color: SmxColors.brandInteractive),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: alignRight
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: alignRight ? TextAlign.right : TextAlign.left,
                  style: TextStyle(
                    color:
                        textColor ??
                        (accent
                            ? SmxColors.brandInteractive
                            : SmxColors.textDark),
                    fontSize: 10,
                    fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
                  ),
                ),
                if (detail.isNotEmpty)
                  Text(
                    detail,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: SmxColors.textMuted,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );

    return SizedBox(
      width: width,
      child: onTap == null
          ? content
          : Material(
              color: SmxColors.transparent,
              child: InkWell(onTap: onTap, child: content),
            ),
    );
  }
}

class _ReporteVacio extends StatelessWidget {
  const _ReporteVacio();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_off_rounded, color: SmxColors.textMuted, size: 24),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'No hay movimientos en el rango seleccionado',
              style: TextStyle(
                color: SmxColors.textDark,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReporteMovimiento {
  final int id;
  final String tipo;
  final String entidad;
  final String concepto;
  final double cantidad;
  final double importe;
  final double total;
  final DateTime fecha;
  final int status;
  final String owner;

  const _ReporteMovimiento({
    required this.id,
    required this.tipo,
    required this.entidad,
    required this.concepto,
    required this.cantidad,
    required this.importe,
    required this.total,
    required this.fecha,
    required this.status,
    required this.owner,
  });

  bool get isPago => tipo == 'pago' || tipo.contains('pago');

  String get folio {
    final prefix = isPago
        ? 'P'
        : tipo == 'compra' || tipo.contains('compra')
        ? 'C'
        : 'M';
    return '$prefix-${id.toString().padLeft(5, '0')}';
  }

  String get statusLabel {
    if (isPago) {
      return SmxSaldiFyPagoStatus.fromValue(status).label;
    }

    return SmxSaldiFyCompraStatus.fromValue(status).label;
  }

  Color get statusColor {
    if (isPago) {
      return switch (status) {
        1 => const Color(0xFF1D4ED8),
        2 => SmxColors.dangerForeground,
        _ => const Color(0xFF0369A1),
      };
    }

    return switch (status) {
      1 => SmxColors.warningForeground,
      2 => SmxColors.successForeground,
      _ => SmxColors.textMuted,
    };
  }

  bool get excluidoDeTotales => isPago && status == 2;

  double get totalReporte => excluidoDeTotales ? 0 : total;
}

class _ReporteGrupo {
  final String nombre;
  final List<_ReporteMovimiento> movimientos;

  const _ReporteGrupo({required this.nombre, required this.movimientos});

  double get cantidad => movimientos.fold<double>(
    0,
    (sum, movimiento) => sum + movimiento.cantidad,
  );

  double get total => movimientos.fold<double>(
    0,
    (sum, movimiento) => sum + movimiento.totalReporte,
  );

  DateTime get ultimaFecha => movimientos.first.fecha;
}

class _GridCellData {
  final String label;
  final double width;
  final bool alignRight;

  const _GridCellData(this.label, this.width, {this.alignRight = false});
}

String _amount(double value) => SmxRowSet.formatAmount(value);

String _formatQuantity(double value) {
  return value == value.truncateToDouble()
      ? value.toInt().toString()
      : value.toStringAsFixed(2);
}

String _formatDate(DateTime value) {
  if (value.year == 1900) return '';
  return DateFormat('dd/MM/yyyy').format(value);
}
