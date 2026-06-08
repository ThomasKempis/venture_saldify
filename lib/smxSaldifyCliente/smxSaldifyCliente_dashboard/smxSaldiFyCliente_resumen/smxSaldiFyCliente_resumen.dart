import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFyCliente_resumen_controller.dart';

class SmxSaldiFyClienteResumen extends StatelessWidget {
  final bool isMobile;
  final int Function(double width) metricColumnsFor;
  final ValueChanged<String> onMetricTap;

  const SmxSaldiFyClienteResumen({
    super.key,
    required this.isMobile,
    required this.metricColumnsFor,
    required this.onMetricTap,
  });

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClienteResumenController>(
      controllerBuilder: (context) => SmxSaldiFyClienteResumenController(
        alias: 'SMXSALDIFY_CLIENTE_RESUMEN',
        data: SmxControllerSendData(context: context),
      ),
      builder: (context, controller) => _SmxSaldiFyClienteResumenView(
        isMobile: isMobile,
        metricColumnsFor: metricColumnsFor,
        onMetricTap: onMetricTap,
        resumen: controller.rstResumen,
      ),
    );
  }
}

class _SmxSaldiFyClienteResumenView extends StatelessWidget {
  final bool isMobile;
  final int Function(double width) metricColumnsFor;
  final ValueChanged<String> onMetricTap;
  final SmxRowSet resumen;

  const _SmxSaldiFyClienteResumenView({
    required this.isMobile,
    required this.metricColumnsFor,
    required this.onMetricTap,
    required this.resumen,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Mi credito y pedidos',
          style: TextStyle(
            color: SmxColors.white,
            fontSize: 32,
            fontWeight: FontWeight.w900,
            height: 1.04,
          ),
        ),
        SizedBox(height: isMobile ? 22 : 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = metricColumnsFor(constraints.maxWidth);

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: isMobile ? 128 : 138,
              ),
              itemCount: resumen.getRowCount(),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                resumen.index(index);
                final label = resumen.getValue('LABEL')?.toString() ?? '';

                return _ClienteMetricCard(
                  label: label,
                  value: resumen.getValue('VALUE')?.toString() ?? '',
                  note: resumen.getValue('NOTE')?.toString() ?? '',
                  onTap: () => onMetricTap(label),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ClienteMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final String note;
  final VoidCallback onTap;

  const _ClienteMetricCard({
    required this.label,
    required this.value,
    required this.note,
    required this.onTap,
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
