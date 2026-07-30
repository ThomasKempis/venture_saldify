import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:universal_html/html.dart' as html;

import 'smxSaldiFy_reportes_controller.dart';

enum SmxSaldiFyReportesPdfVista { movimientos, clientes, productos }

class SmxSaldiFyReportesPdfMovimiento {
  final String folio;
  final String entidad;
  final String owner;
  final String estado;
  final String producto;
  final double cantidad;
  final double importe;
  final double total;
  final double totalReporte;
  final DateTime fecha;

  const SmxSaldiFyReportesPdfMovimiento({
    required this.folio,
    required this.entidad,
    required this.owner,
    required this.estado,
    required this.producto,
    required this.cantidad,
    required this.importe,
    required this.total,
    required this.totalReporte,
    required this.fecha,
  });
}

class SmxSaldiFyReportesPdf {
  static final _money = NumberFormat.currency(
    locale: 'es_MX',
    symbol: r'$',
    decimalDigits: 0,
  );
  static final _date = DateFormat('dd/MM/yyyy');

  static Future<bool> open({
    required SmxSaldiFyReporteTipo tipo,
    required SmxSaldiFyReportesPdfVista vista,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
    required List<SmxSaldiFyReportesPdfMovimiento> movimientos,
  }) async {
    final bytes = await _build(
      tipo: tipo,
      vista: vista,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      movimientos: movimientos,
    );
    final name = 'saldify_${_tipoLabel(tipo).toLowerCase()}_reporte.pdf';

    if (kIsWeb) {
      return _openWebPdf(bytes, name);
    }

    return Printing.sharePdf(bytes: bytes, filename: name);
  }

  static bool _openWebPdf(Uint8List bytes, String name) {
    final blob = html.Blob([bytes], 'application/pdf');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final link = html.AnchorElement(href: url)
      ..target = '_blank'
      ..rel = 'noopener';
    html.document.body?.append(link);
    link.click();
    link.remove();

    return true;
  }

  static Future<Uint8List> _build({
    required SmxSaldiFyReporteTipo tipo,
    required SmxSaldiFyReportesPdfVista vista,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
    required List<SmxSaldiFyReportesPdfMovimiento> movimientos,
  }) async {
    final doc = pw.Document();
    final total = movimientos.fold<double>(
      0,
      (sum, movimiento) => sum + movimiento.totalReporte,
    );
    final clientes = movimientos.map((item) => item.entidad).toSet().length;

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          _header(
            tipo: tipo,
            vista: vista,
            fechaDesde: fechaDesde,
            fechaHasta: fechaHasta,
          ),
          pw.SizedBox(height: 16),
          _summary(
            movimientos: movimientos.length,
            clientes: clientes,
            total: total,
          ),
          pw.SizedBox(height: 18),
          _table(vista: vista, movimientos: movimientos),
        ],
      ),
    );

    return doc.save();
  }

  static pw.Widget _header({
    required SmxSaldiFyReporteTipo tipo,
    required SmxSaldiFyReportesPdfVista vista,
    required DateTime fechaDesde,
    required DateTime fechaHasta,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Saldify',
              style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Reporte de ${_tipoLabel(tipo)}',
              style: pw.TextStyle(
                fontSize: 15,
                color: PdfColors.green800,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              _vistaLabel(vista),
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              _date.format(DateTime.now()),
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Rango: ${_date.format(fechaDesde)} - ${_date.format(fechaHasta)}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _summary({
    required int movimientos,
    required int clientes,
    required double total,
  }) {
    return pw.Row(
      children: [
        _summaryBox('Movimientos', movimientos.toString()),
        pw.SizedBox(width: 8),
        _summaryBox('Clientes', clientes.toString()),
        pw.SizedBox(width: 8),
        _summaryBox('Total', _money.format(total)),
      ],
    );
  }

  static pw.Widget _summaryBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: pw.BoxDecoration(
          color: PdfColors.grey100,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: PdfColors.grey300),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 3),
            pw.Text(
              label,
              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _table({
    required SmxSaldiFyReportesPdfVista vista,
    required List<SmxSaldiFyReportesPdfMovimiento> movimientos,
  }) {
    return switch (vista) {
      SmxSaldiFyReportesPdfVista.movimientos => _movimientosTable(movimientos),
      SmxSaldiFyReportesPdfVista.clientes => _gruposTable(
        label: 'Cliente',
        movimientos: movimientos,
        key: (movimiento) => movimiento.entidad,
      ),
      SmxSaldiFyReportesPdfVista.productos => _gruposTable(
        label: 'Producto',
        movimientos: movimientos,
        key: (movimiento) => movimiento.producto,
      ),
    };
  }

  static pw.Widget _movimientosTable(
    List<SmxSaldiFyReportesPdfMovimiento> movimientos,
  ) {
    return pw.TableHelper.fromTextArray(
      headers: const [
        'Cliente',
        'Folio',
        'Estado',
        'Producto',
        'Cantidad',
        'P. unitario',
        'Total',
        'Fecha',
      ],
      data: movimientos.map((movimiento) {
        return [
          movimiento.entidad,
          movimiento.folio,
          movimiento.estado,
          movimiento.producto,
          _quantity(movimiento.cantidad),
          _money.format(movimiento.importe),
          _money.format(movimiento.total),
          _date.format(movimiento.fecha),
        ];
      }).toList(),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 8,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      columnWidths: const {
        0: pw.FlexColumnWidth(1.55),
        1: pw.FlexColumnWidth(.72),
        2: pw.FlexColumnWidth(1.1),
        3: pw.FlexColumnWidth(1.3),
        4: pw.FlexColumnWidth(.62),
        5: pw.FlexColumnWidth(.86),
        6: pw.FlexColumnWidth(.82),
        7: pw.FlexColumnWidth(.82),
      },
    );
  }

  static pw.Widget _gruposTable({
    required String label,
    required List<SmxSaldiFyReportesPdfMovimiento> movimientos,
    required String Function(SmxSaldiFyReportesPdfMovimiento movimiento) key,
  }) {
    final grupos = <String, List<SmxSaldiFyReportesPdfMovimiento>>{};
    for (final movimiento in movimientos) {
      grupos.putIfAbsent(key(movimiento), () => []).add(movimiento);
    }

    final rows = grupos.entries.map((entry) {
      final cantidad = entry.value.fold<double>(
        0,
        (sum, movimiento) => sum + movimiento.cantidad,
      );
      final total = entry.value.fold<double>(
        0,
        (sum, movimiento) => sum + movimiento.totalReporte,
      );
      final ultima = entry.value
          .map((movimiento) => movimiento.fecha)
          .reduce((a, b) => a.isAfter(b) ? a : b);

      return _PdfGrupoRow(
        nombre: entry.key,
        movimientos: entry.value.length,
        cantidad: cantidad,
        total: total,
        ultimaFecha: ultima,
      );
    }).toList();

    rows.sort((a, b) => b.total.compareTo(a.total));

    return pw.TableHelper.fromTextArray(
      headers: [label, 'Movimientos', 'Cantidad', 'Total', 'Ultimo'],
      data: rows.map((row) {
        return [
          row.nombre,
          row.movimientos.toString(),
          _quantity(row.cantidad),
          _money.format(row.total),
          _date.format(row.ultimaFecha),
        ];
      }).toList(),
      headerStyle: pw.TextStyle(
        color: PdfColors.white,
        fontSize: 9,
        fontWeight: pw.FontWeight.bold,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.green800),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellPadding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      columnWidths: const {
        0: pw.FlexColumnWidth(2.3),
        1: pw.FlexColumnWidth(.8),
        2: pw.FlexColumnWidth(.8),
        3: pw.FlexColumnWidth(.9),
        4: pw.FlexColumnWidth(.9),
      },
    );
  }

  static String _tipoLabel(SmxSaldiFyReporteTipo tipo) {
    return switch (tipo) {
      SmxSaldiFyReporteTipo.ventas => 'Ventas',
      SmxSaldiFyReporteTipo.cobros => 'Cobros',
    };
  }

  static String _vistaLabel(SmxSaldiFyReportesPdfVista vista) {
    return switch (vista) {
      SmxSaldiFyReportesPdfVista.movimientos => 'Movimientos',
      SmxSaldiFyReportesPdfVista.clientes => 'Clientes',
      SmxSaldiFyReportesPdfVista.productos => 'Productos',
    };
  }

  static String _quantity(double value) {
    return value == value.truncateToDouble()
        ? value.toInt().toString()
        : value.toStringAsFixed(2);
  }
}

class _PdfGrupoRow {
  final String nombre;
  final int movimientos;
  final double cantidad;
  final double total;
  final DateTime ultimaFecha;

  const _PdfGrupoRow({
    required this.nombre,
    required this.movimientos,
    required this.cantidad,
    required this.total,
    required this.ultimaFecha,
  });
}
