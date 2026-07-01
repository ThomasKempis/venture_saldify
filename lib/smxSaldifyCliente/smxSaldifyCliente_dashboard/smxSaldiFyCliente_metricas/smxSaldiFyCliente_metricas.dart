import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxApis/smxSaldiFy_credito_resumen.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFyCliente_metricas_controller.dart';
import 'smxSaldiFyCliente_metricas_snapshot.dart';
import 'smxSaldiFyCliente_metricas_skeleton.dart';

class SmxSaldiFyClienteMetricas extends StatefulWidget {
  final bool isMobile;
  final int relaSysuser10Anfitrion;
  final ValueListenable<int>? refreshNotifier;
  final ValueChanged<SmxSaldiFyClienteMetricasSnapshot>? onMetricasChanged;

  const SmxSaldiFyClienteMetricas({
    super.key,
    required this.isMobile,
    required this.relaSysuser10Anfitrion,
    this.refreshNotifier,
    this.onMetricasChanged,
  });

  @override
  State<SmxSaldiFyClienteMetricas> createState() =>
      _SmxSaldiFyClienteMetricasState();
}

class _SmxSaldiFyClienteMetricasState extends State<SmxSaldiFyClienteMetricas> {
  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClienteMetricasController>(
      controllerBuilder: (context) => SmxSaldiFyClienteMetricasController(
        alias: 'SMXSALDIFY_CLIENTE_METRICAS',
        data: SmxControllerSendData(context: context),
        relaSysuser10Anfitrion: widget.relaSysuser10Anfitrion,
      ),
      loadingBuilder: (_) =>
          SmxSaldiFyClienteMetricasSkeleton(isMobile: widget.isMobile),
      builder: (context, controller) {
        return _SmxSaldiFyClienteMetricasRefreshListener(
          controller: controller,
          refreshNotifier: widget.refreshNotifier,
          child: _SmxSaldiFyClienteMetricasView(
            isMobile: widget.isMobile,
            controller: controller,
            onMetricasChanged: widget.onMetricasChanged,
          ),
        );
      },
    );
  }
}

class _SmxSaldiFyClienteMetricasRefreshListener extends StatefulWidget {
  final SmxSaldiFyClienteMetricasController controller;
  final ValueListenable<int>? refreshNotifier;
  final Widget child;

  const _SmxSaldiFyClienteMetricasRefreshListener({
    required this.controller,
    required this.refreshNotifier,
    required this.child,
  });

  @override
  State<_SmxSaldiFyClienteMetricasRefreshListener> createState() =>
      _SmxSaldiFyClienteMetricasRefreshListenerState();
}

class _SmxSaldiFyClienteMetricasRefreshListenerState
    extends State<_SmxSaldiFyClienteMetricasRefreshListener> {
  int _lastRefreshRevision = 0;

  @override
  void initState() {
    super.initState();
    _lastRefreshRevision = widget.refreshNotifier?.value ?? 0;
    widget.refreshNotifier?.addListener(_refreshMetricas);
  }

  @override
  void didUpdateWidget(_SmxSaldiFyClienteMetricasRefreshListener oldWidget) {
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

class _SmxSaldiFyClienteMetricasView extends StatelessWidget {
  final bool isMobile;
  final SmxSaldiFyClienteMetricasController controller;
  final ValueChanged<SmxSaldiFyClienteMetricasSnapshot>? onMetricasChanged;

  const _SmxSaldiFyClienteMetricasView({
    required this.isMobile,
    required this.controller,
    this.onMetricasChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ValueListenableBuilder<SmxRowSet?>(
          valueListenable: controller.rstMetricas,
          builder: (context, rstMetricas, _) {
            final metricas = SmxSaldiFyClienteMetricasSnapshot.fromRowSet(
              rstMetricas,
            );
            final hasMetricas =
                rstMetricas != null && rstMetricas.getRowCount() > 0;

            if (hasMetricas && onMetricasChanged != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onMetricasChanged?.call(metricas);
              });
            }

            return SmxSaldiFyCreditoResumen(
              key: ValueKey(rstMetricas),
              credito: metricas.credito,
              disponible: metricas.disponible,
              compras: metricas.compras,
              pagos: metricas.pagos,
              saldo: metricas.saldo,
              saldoEnDeuda: metricas.deudor > 0,
            );
          },
        ),
      ],
    );
  }
}
