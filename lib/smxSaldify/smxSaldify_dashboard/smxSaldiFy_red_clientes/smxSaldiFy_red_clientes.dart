import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_red_clientes_controller.dart';
import 'smxSaldiFy_red_clientes_skeleton.dart';

class SmxSaldiFyRedClientes extends StatefulWidget {
  final bool isMobile;
  final int Function(double width) metricColumnsFor;
  final VoidCallback onHeaderTap;
  final ValueChanged<String> onMetricTap;

  const SmxSaldiFyRedClientes({
    super.key,
    required this.isMobile,
    required this.metricColumnsFor,
    required this.onHeaderTap,
    required this.onMetricTap,
  });

  @override
  State<SmxSaldiFyRedClientes> createState() => _SmxSaldiFyRedClientesState();
}

class _SmxSaldiFyRedClientesState extends State<SmxSaldiFyRedClientes> {
  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyRedClientesController>(
      controllerBuilder: (context) => SmxSaldiFyRedClientesController(
        alias: 'SMXSALDIFY_RED_CLIENTES',
        data: SmxControllerSendData(context: context),
      ),
      loadingBuilder: (_) => SmxSaldiFyMetricasSkeleton(
        isMobile: widget.isMobile,
        metricColumnsFor: widget.metricColumnsFor,
      ),
      builder: (context, controller) {
        return _SmxSaldiFyRedClientesView(
          isMobile: widget.isMobile,
          metricColumnsFor: widget.metricColumnsFor,
          onHeaderTap: widget.onHeaderTap,
          onMetricTap: widget.onMetricTap,
          controller: controller,
        );
      },
    );
  }
}

class _SmxSaldiFyRedClientesView extends StatelessWidget {
  final bool isMobile;
  final int Function(double width) metricColumnsFor;
  final VoidCallback onHeaderTap;
  final ValueChanged<String> onMetricTap;
  final SmxSaldiFyRedClientesController controller;

  const _SmxSaldiFyRedClientesView({
    required this.isMobile,
    required this.metricColumnsFor,
    required this.onHeaderTap,
    required this.onMetricTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: SmxColors.transparent,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onHeaderTap,
            borderRadius: BorderRadius.circular(12),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Text(
                'Tu red de clientes al dia',
                style: TextStyle(
                  color: SmxColors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  height: 1.04,
                ),
              ),
            ),
          ),
        ),
        SizedBox(height: isMobile ? 22 : 28),
        ValueListenableBuilder<SmxRowSet?>(
          valueListenable: controller.rstMetricas,
          builder: (context, rstMetricas, _) {
            return _MetricsGrid(
              key: ValueKey(rstMetricas),
              isMobile: isMobile,
              metricColumnsFor: metricColumnsFor,
              metricas: rstMetricas,
              onMetricTap: onMetricTap,
            );
          },
        ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final bool isMobile;
  final int Function(double width) metricColumnsFor;
  final SmxRowSet? metricas;
  final ValueChanged<String> onMetricTap;

  const _MetricsGrid({
    super.key,
    required this.isMobile,
    required this.metricColumnsFor,
    required this.metricas,
    required this.onMetricTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = metricColumnsFor(constraints.maxWidth);
        final cards = _buildMetricCards();

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: isMobile ? 128 : 138,
          ),
          itemCount: cards.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final card = cards[index];

            return _MetricCard(
              label: card.label,
              value: card.value,
              note: card.note,
              onTap: () => onMetricTap(card.label),
            );
          },
        );
      },
    );
  }

  List<_MetricData> _buildMetricCards() {
    final rstMetricas = metricas;

    if (rstMetricas == null || rstMetricas.getRowCount() == 0) {
      return const [
        _MetricData(
          label: 'Credito entregado',
          value: r'$0',
          note: 'Sin datos',
        ),
        _MetricData(label: 'Disponible total', value: r'$0', note: 'Sin datos'),
        _MetricData(
          label: 'Compras realizadas',
          value: r'$0',
          note: 'Sin datos',
        ),
        _MetricData(label: 'Saldo pendiente', value: r'$0', note: 'Sin datos'),
      ];
    }

    rstMetricas.first();

    return [
      _MetricData(
        label: 'Credito entregado',
        value: _formatMoney(rstMetricas.getValue('SYSUSER12_CREDITO')),
        note: 'Credito total',
      ),
      _MetricData(
        label: 'Disponible total',
        value: _formatMoney(rstMetricas.getValue('SYSUSER12_DISPONIBLE')),
        note: 'Disponible',
      ),
      _MetricData(
        label: 'Compras realizadas',
        value: _formatMoney(rstMetricas.getValue('SYSUSER12_COMPRAS')),
        note: 'Compras',
      ),
      _MetricData(
        label: 'Saldo pendiente',
        value: _formatMoney(rstMetricas.getValue('SYSUSER12_BALANCE')),
        note: 'Por cobrar',
      ),
    ];
  }

  String _formatMoney(dynamic value) {
    final amount = _toDouble(value);
    final sign = amount < 0 ? '-' : '';
    final fixed = amount.abs().toStringAsFixed(0);
    final parts = <String>[];

    for (var end = fixed.length; end > 0; end -= 3) {
      final start = end - 3 > 0 ? end - 3 : 0;
      parts.insert(0, fixed.substring(start, end));
    }

    return '$sign\$${parts.join(',')}';
  }

  double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}

class _MetricData {
  final String label;
  final String value;
  final String note;

  const _MetricData({
    required this.label,
    required this.value,
    required this.note,
  });
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String note;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.note,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SmxColors.whiteAlpha(.13),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: SmxColors.whiteAlpha(.18)),
            boxShadow: [
              BoxShadow(
                color: SmxColors.blackAlpha(.14),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SmxColors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    color: SmxColors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ),
              Text(
                note,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SmxColors.brandAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
