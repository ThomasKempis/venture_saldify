import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxMetricasResumen/smxMetricasResumen.dart';
import 'package:venture_saldify/smxLayout/smxScreens/smxMetricasResumen/smxMetricasResumenSkeleton.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_metricas_controller.dart';

class SmxSaldiFyMetricas extends StatefulWidget {
  final bool isMobile;
  final ValueListenable<int>? refreshNotifier;
  final VoidCallback? onMetricasLoaded;

  const SmxSaldiFyMetricas({
    super.key,
    required this.isMobile,
    this.refreshNotifier,
    this.onMetricasLoaded,
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
        onMetricasLoaded: widget.onMetricasLoaded,
      ),
      loadingBuilder: (_) =>
          SmxMetricasResumenSkeleton(isMobile: widget.isMobile),
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
            final hasMetricas =
                rstMetricas != null && rstMetricas.getRowCount() > 0;

            return SmxMetricasResumen(
              key: ValueKey(rstMetricas),
              credito: hasMetricas
                  ? rstMetricas.getValue('SYSUSER12_CREDITO')
                  : 0,
              disponible: hasMetricas
                  ? rstMetricas.getValue('SYSUSER12_DISPONIBLE')
                  : 0,
              compras: hasMetricas
                  ? rstMetricas.getValue('SYSUSER12_COMPRAS')
                  : 0,
              pagos: hasMetricas ? rstMetricas.getValue('SYSUSER12_PAGOS') : 0,
              saldo: hasMetricas
                  ? rstMetricas.getValue('SYSUSER12_BALANCE')
                  : 0,
            );
          },
        ),
      ],
    );
  }
}
