import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_red_clientes_controller.dart';

class SmxSaldiFyRedClientes extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyRedClientesController>(
      controllerBuilder: (context) => SmxSaldiFyRedClientesController(
        alias: 'SMXSALDIFY_RED_CLIENTES',
        data: SmxControllerSendData(context: context),
      ),
      builder: (context, controller) => _SmxSaldiFyRedClientesView(
        isMobile: isMobile,
        metricColumnsFor: metricColumnsFor,
        onHeaderTap: onHeaderTap,
        onMetricTap: onMetricTap,
        controller: controller,
      ),
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
        _MetricsGrid(
          isMobile: isMobile,
          metricColumnsFor: metricColumnsFor,
          metricas: controller.rstMetricas,
          onMetricTap: onMetricTap,
        ),
      ],
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  final bool isMobile;
  final int Function(double width) metricColumnsFor;
  final SmxRowSet metricas;
  final ValueChanged<String> onMetricTap;

  const _MetricsGrid({
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

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            mainAxisExtent: isMobile ? 128 : 138,
          ),
          itemCount: metricas.getRowCount(),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            metricas.index(index);
            final label = metricas.getValue('LABEL')?.toString() ?? '';

            return _MetricCard(
              label: label,
              value: metricas.getValue('VALUE')?.toString() ?? '',
              note: metricas.getValue('NOTE')?.toString() ?? '',
              onTap: () => onMetricTap(label),
            );
          },
        );
      },
    );
  }
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
