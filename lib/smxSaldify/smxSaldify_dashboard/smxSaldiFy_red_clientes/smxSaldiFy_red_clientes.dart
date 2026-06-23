import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxApis/smxSaldiFy_credito_resumen.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_red_clientes_controller.dart';
import 'smxSaldiFy_red_clientes_skeleton.dart';

class SmxSaldiFyRedClientes extends StatefulWidget {
  final bool isMobile;
  final VoidCallback onHeaderTap;
  final ValueChanged<String> onMetricTap;

  const SmxSaldiFyRedClientes({
    super.key,
    required this.isMobile,
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
      loadingBuilder: (_) =>
          SmxSaldiFyMetricasSkeleton(isMobile: widget.isMobile),
      builder: (context, controller) {
        return _SmxSaldiFyRedClientesView(
          isMobile: widget.isMobile,
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
  final VoidCallback onHeaderTap;
  final ValueChanged<String> onMetricTap;
  final SmxSaldiFyRedClientesController controller;

  const _SmxSaldiFyRedClientesView({
    required this.isMobile,
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
                'Tu red financiera',
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
            final metricas = _MetricasResumen.fromRowSet(rstMetricas);

            return SmxSaldiFyCreditoResumen(
              key: ValueKey(rstMetricas),
              credito: metricas.credito,
              disponible: metricas.disponible,
              compras: metricas.compras,
              pagos: metricas.pagos,
              saldo: metricas.saldo,
              onMetricTap: onMetricTap,
            );
          },
        ),
      ],
    );
  }
}

class _MetricasResumen {
  final double credito;
  final double disponible;
  final double compras;
  final double pagos;
  final double saldo;

  const _MetricasResumen({
    required this.credito,
    required this.disponible,
    required this.compras,
    required this.pagos,
    required this.saldo,
  });

  factory _MetricasResumen.fromRowSet(SmxRowSet? rstMetricas) {
    if (rstMetricas == null || rstMetricas.getRowCount() == 0) {
      return const _MetricasResumen(
        credito: 0,
        disponible: 0,
        compras: 0,
        pagos: 0,
        saldo: 0,
      );
    }

    rstMetricas.first();

    return _MetricasResumen(
      credito: _toDouble(rstMetricas.getValue('SYSUSER12_CREDITO')),
      disponible: _toDouble(rstMetricas.getValue('SYSUSER12_DISPONIBLE')),
      compras: _toDouble(rstMetricas.getValue('SYSUSER12_COMPRAS')),
      pagos: _toDouble(rstMetricas.getValue('SYSUSER12_PAGOS')),
      saldo: _toDouble(rstMetricas.getValue('SYSUSER12_BALANCE')),
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }
}
