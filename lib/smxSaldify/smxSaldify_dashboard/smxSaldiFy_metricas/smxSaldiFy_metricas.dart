import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxApis/smxSaldiFy_credito_resumen.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_metricas_controller.dart';
import 'smxSaldiFy_metricas_skeleton.dart';

class SmxSaldiFyMetricas extends StatefulWidget {
  final bool isMobile;
  final ValueListenable<int>? refreshNotifier;

  const SmxSaldiFyMetricas({
    super.key,
    required this.isMobile,
    this.refreshNotifier,
  });

  @override
  State<SmxSaldiFyMetricas> createState() => _SmxSaldiFyMetricasState();
}

class _SmxSaldiFyMetricasState extends State<SmxSaldiFyMetricas> {
  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyMetricasController>(
      controllerBuilder: (context) => SmxSaldiFyMetricasController(
        alias: 'SMXSALDIFY_RED_CLIENTES',
        data: SmxControllerSendData(context: context),
      ),
      loadingBuilder: (_) =>
          SmxSaldiFyMetricasSkeleton(isMobile: widget.isMobile),
      builder: (context, controller) {
        return _SmxSaldiFyMetricasRefreshListener(
          controller: controller,
          refreshNotifier: widget.refreshNotifier,
          child: _SmxSaldiFyMetricasView(
            isMobile: widget.isMobile,
            controller: controller,
          ),
        );
      },
    );
  }
}

class _SmxSaldiFyMetricasRefreshListener extends StatefulWidget {
  final SmxSaldiFyMetricasController controller;
  final ValueListenable<int>? refreshNotifier;
  final Widget child;

  const _SmxSaldiFyMetricasRefreshListener({
    required this.controller,
    required this.refreshNotifier,
    required this.child,
  });

  @override
  State<_SmxSaldiFyMetricasRefreshListener> createState() =>
      _SmxSaldiFyMetricasRefreshListenerState();
}

class _SmxSaldiFyMetricasRefreshListenerState
    extends State<_SmxSaldiFyMetricasRefreshListener> {
  int _lastRefreshRevision = 0;

  @override
  void initState() {
    super.initState();
    _lastRefreshRevision = widget.refreshNotifier?.value ?? 0;
    widget.refreshNotifier?.addListener(_refreshMetricas);
  }

  @override
  void didUpdateWidget(_SmxSaldiFyMetricasRefreshListener oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.refreshNotifier == widget.refreshNotifier) return;

    oldWidget.refreshNotifier?.removeListener(_refreshMetricas);
    _lastRefreshRevision = widget.refreshNotifier?.value ?? 0;
    widget.refreshNotifier?.addListener(_refreshMetricas);
  }

  @override
  void dispose() {
    widget.refreshNotifier?.removeListener(_refreshMetricas);
    super.dispose();
  }

  void _refreshMetricas() {
    final revision = widget.refreshNotifier?.value ?? 0;
    if (revision == _lastRefreshRevision) return;

    _lastRefreshRevision = revision;
    unawaited(widget.controller.refreshMetricasBackground());
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _SmxSaldiFyMetricasView extends StatelessWidget {
  final bool isMobile;
  final SmxSaldiFyMetricasController controller;

  const _SmxSaldiFyMetricasView({
    required this.isMobile,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
      credito: rstMetricas.getValue('SYSUSER12_CREDITO'),
      disponible: rstMetricas.getValue('SYSUSER12_DISPONIBLE'),
      compras: rstMetricas.getValue('SYSUSER12_COMPRAS'),
      pagos: rstMetricas.getValue('SYSUSER12_PAGOS'),
      saldo: rstMetricas.getValue('SYSUSER12_BALANCE'),
    );
  }
}
