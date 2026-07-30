import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_reportes_controller.dart';
import 'smxSaldiFy_reportes_viewer.dart';

class SmxSaldiFyReportes extends StatelessWidget {
  const SmxSaldiFyReportes({super.key});

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyReportesController>(
      controllerBuilder: (context) => SmxSaldiFyReportesController(
        alias: 'SMXSALDIFY_REPORTES',
        data: SmxControllerSendData(context: context),
      ),
      builder: (context, controller) => _ReportesView(controller: controller),
    );
  }
}

class _ReportesView extends StatefulWidget {
  final SmxSaldiFyReportesController controller;

  const _ReportesView({required this.controller});

  @override
  State<_ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<_ReportesView> {
  int _selectedReporteIndex = 0;
  bool _hasGeneratedReport = false;

  SmxSaldiFyReportesController get controller => widget.controller;

  static const _reportes = [
    _ReporteCardData(
      title: 'Ventas',
      icon: Icons.point_of_sale_rounded,
      color: Color(0xFF65B8FF),
    ),
    _ReporteCardData(
      title: 'Cobros',
      icon: Icons.payments_rounded,
      color: Color(0xFF22C55E),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final layout = SmxLayout.sizeFromWidth(MediaQuery.of(context).size.width);
    final pagePadding = layout.saldifyPagePadding;
    final topContentInset = SmxLayout.topContentInset(context);
    final bottomContentInset = SmxLayout.bottomContentInset(context);

    return Scaffold(
      backgroundColor: SmxColors.transparent,
      body: SizedBox.expand(
        child: SmxSaldifyBackground(
          child: SafeArea(
            top: false,
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: layout.saldifyMaxContentWidth,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    pagePadding.left,
                    pagePadding.top + topContentInset,
                    pagePadding.right,
                    pagePadding.bottom + bottomContentInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SmxSaldifyScreenHeader(
                        title: 'Reportes',
                        sectionLabel: 'Resumen operativo',
                        onBackPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(height: 16),
                      _ReportesSelectorCard(
                        reportes: _reportes,
                        selectedIndex: _selectedReporteIndex,
                        onSelected: (index) {
                          setState(() {
                            _selectedReporteIndex = index;
                            _hasGeneratedReport = false;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      _FechasReporteCard(
                        desde: controller.fechaDesde,
                        hasta: controller.fechaHasta,
                        onDesdeTap: _pickFechaDesde,
                        onHastaTap: _pickFechaHasta,
                        onGenerarTap: _generarReporte,
                      ),
                      if (_hasGeneratedReport) ...[
                        const SizedBox(height: 14),
                        SmxSaldiFyReportesViewer(
                          rowset: controller.rstReportes,
                          reporteTipo: controller.reporteTipo,
                          fechaDesde: controller.fechaDesde,
                          fechaHasta: controller.fechaHasta,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickFechaDesde() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.fechaDesde,
      firstDate: DateTime(2020),
      lastDate: controller.fechaHasta,
    );

    if (picked == null) return;

    setState(() {
      controller.setFechaDesde(picked);
      _hasGeneratedReport = false;
    });
  }

  Future<void> _pickFechaHasta() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.fechaHasta,
      firstDate: controller.fechaDesde,
      lastDate: today,
    );

    if (picked == null) return;

    setState(() {
      controller.setFechaHasta(picked);
      _hasGeneratedReport = false;
    });
  }

  Future<void> _generarReporte() async {
    controller.setReporteTipo(
      _selectedReporteIndex == 0
          ? SmxSaldiFyReporteTipo.ventas
          : SmxSaldiFyReporteTipo.cobros,
    );

    final ok = await controller.generarReporte();
    if (!mounted) return;

    setState(() {
      _hasGeneratedReport = ok;
    });

    final reporte = _reportes[_selectedReporteIndex].title;
    final count = controller.rstReportes.getRowCount();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Reporte de $reporte listo: $count movimientos'
              : 'No se pudo generar el reporte de $reporte',
        ),
      ),
    );
  }
}

class _ReportesSelectorCard extends StatelessWidget {
  final List<_ReporteCardData> reportes;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _ReportesSelectorCard({
    required this.reportes,
    required this.selectedIndex,
    required this.onSelected,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 10.0;
          final columns = reportes.length == 1 ? 1 : 2;
          final cardWidth =
              (constraints.maxWidth - (spacing * (columns - 1))) / columns;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (var index = 0; index < reportes.length; index++)
                SizedBox(
                  width: cardWidth,
                  child: _ReporteCard(
                    data: reportes[index],
                    selected: index == selectedIndex,
                    onTap: () => onSelected(index),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ReporteCard extends StatelessWidget {
  final _ReporteCardData data;
  final bool selected;
  final VoidCallback onTap;

  const _ReporteCard({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.transparent,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOutCubic,
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: selected
                ? SmxColors.whiteAlpha(.78)
                : SmxColors.whiteAlpha(.9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? SmxColors.blackAlpha(.10)
                  : SmxColors.whiteAlpha(.24),
            ),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: SmxColors.blackAlpha(.18),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: SmxColors.blackAlpha(.08),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
          ),
          transform: Matrix4.translationValues(0, selected ? 2 : 0, 0),
          child: Row(
            children: [
              Icon(data.icon, color: data.color, size: 18),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  data.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: SmxColors.textDark,
                    fontSize: selected ? 15 : 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                width: 5,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? data.color : SmxColors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FechasReporteCard extends StatelessWidget {
  final DateTime desde;
  final DateTime hasta;
  final VoidCallback onDesdeTap;
  final VoidCallback onHastaTap;
  final VoidCallback onGenerarTap;

  const _FechasReporteCard({
    required this.desde,
    required this.hasta,
    required this.onDesdeTap,
    required this.onHastaTap,
    required this.onGenerarTap,
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 10.0;
          const columns = 2;
          final tileWidth =
              (constraints.maxWidth - (spacing * (columns - 1))) / columns;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  SizedBox(
                    width: tileWidth,
                    child: _FechaTile(
                      label: 'Desde',
                      value: _formatDate(desde),
                      icon: Icons.event_available_rounded,
                      onTap: onDesdeTap,
                    ),
                  ),
                  SizedBox(
                    width: tileWidth,
                    child: _FechaTile(
                      label: 'Hasta',
                      value: _formatDate(hasta),
                      icon: Icons.event_rounded,
                      onTap: onHastaTap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerRight,
                child: _GenerarReporteButton(onTap: onGenerarTap),
              ),
            ],
          );
        },
      ),
    );
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }
}

class _GenerarReporteButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GenerarReporteButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.brandAccent,
      borderRadius: BorderRadius.circular(999),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.query_stats_rounded,
                color: SmxColors.textDark,
                size: 17,
              ),
              SizedBox(width: 7),
              Text(
                'Generar reporte',
                style: TextStyle(
                  color: SmxColors.textDark,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FechaTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _FechaTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.92),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: [
              Icon(icon, color: SmxColors.brandInteractive, size: 18),
              const SizedBox(width: 7),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: SmxColors.textMuted,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      value,
                      style: const TextStyle(
                        color: SmxColors.textDark,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: SmxColors.textMuted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReporteCardData {
  final String title;
  final IconData icon;
  final Color color;

  const _ReporteCardData({
    required this.title,
    required this.icon,
    required this.color,
  });
}
