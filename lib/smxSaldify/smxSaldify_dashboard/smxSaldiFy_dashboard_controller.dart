import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

import '../../smxLayout/smxScreenTmp.dart';
import '../smxSaldify_screens/saldify_cliente/smxSaldiFy_cliente.dart';
import '../smxSaldify_screens/saldify_archivados/smxSaldiFy_archivados.dart';
import '../smxSaldify_screens/saldify_cobranza/smxSaldiFy_cobranza.dart';
import '../smxSaldify_screens/saldify_compras/smxSaldiFy_compras.dart';
import '../smxSaldify_screens/saldify_credito/smxSaldiFy_cliente_credito.dart';
import '../smxSaldify_screens/saldify_historial/smxSaldiFy_historial.dart';
import '../smxSaldify_screens/saldify_mired/smxSaldiFy_mired.dart';
import '../smxSaldify_screens/saldify_pagos/smxSaldiFy_pagos.dart';
import '../smxSaldify_screens/saldify_productos/smxSaldiFy_productos.dart';
import 'smxSaldiFy_clientes/smxSaldiFy_clientes.dart';
import 'smxSaldiFy_dashboard_menu.dart';

class SmxSaldiFyDashboardController {
  final ValueNotifier<SmxRowSet?> clientesActivosNotifier =
      ValueNotifier<SmxRowSet?>(null);
  final ValueNotifier<SmxSaldiFyDashboardContentMode> contentModeNotifier =
      ValueNotifier<SmxSaldiFyDashboardContentMode>(
        SmxSaldiFyDashboardContentMode.loading,
      );
  final ValueNotifier<int> pendingActionsRevisionNotifier = ValueNotifier<int>(
    0,
  );
  final ValueNotifier<int> metricasRevisionNotifier = ValueNotifier<int>(0);

  SmxRowSet? _rstClientesActivos;
  SmxRowSet? _rstClientesPendientes;
  bool _clientesActivosLoaded = false;
  bool _clientesPendientesLoaded = false;

  void dispose() {
    clientesActivosNotifier.dispose();
    contentModeNotifier.dispose();
    pendingActionsRevisionNotifier.dispose();
    metricasRevisionNotifier.dispose();
  }

  void clearClientes() {
    _rstClientesActivos = null;
    _rstClientesPendientes = null;
    _clientesActivosLoaded = false;
    _clientesPendientesLoaded = false;
    clientesActivosNotifier.value = null;
    contentModeNotifier.value = SmxSaldiFyDashboardContentMode.loading;
    _notifyPendingActionsChanged();
  }

  void onClientesLoadedRst(SmxRowSet rstClientes) {
    if (identical(_rstClientesActivos, rstClientes)) return;
    _clientesActivosLoaded = true;
    _setClientesActivos(rstClientes);
    _updateContentMode();
    _notifyPendingActionsChanged();
  }

  void onClienteArchivadoRst(SmxRowSet rstClientes) {
    _clientesActivosLoaded = true;
    _setClientesActivos(rstClientes);
    _updateContentMode();
    _notifyPendingActionsChanged();
    _notifyMetricasChanged();
  }

  void onClientesPendientesLoadedRst(SmxRowSet rstClientes) {
    _rstClientesPendientes = rstClientes;
    _clientesPendientesLoaded = true;
    _updateContentMode();
    _notifyPendingActionsChanged();
  }

  void _setClientesActivos(SmxRowSet rstClientes) {
    _rstClientesActivos = rstClientes;
    clientesActivosNotifier.value = rstClientes;
  }

  void onClientePendienteActivated(SmxRowSet rstActivated) {
    final rstActivos = _rstClientesActivos;
    if (rstActivos == null || rstActivated.getRowCount() == 0) return;

    for (final row in rstActivated.getRowsList()) {
      rstActivos.getRowsList().add(row.clone());
    }

    rstActivos.first();
    _rstClientesActivos = rstActivos.copy();
    clientesActivosNotifier.value = _rstClientesActivos;
    _updateContentMode();
    _notifyPendingActionsChanged();
  }

  bool get hasClientesPendientes =>
      (_rstClientesPendientes?.getRowCount() ?? 0) > 0;

  bool get hasCreditoPendiente => _hasStatusPendiente();

  bool get hasGestionPendiente => _hasGestionPendiente();

  bool get hasCobranzaPendiente => _hasCobranzaPendiente();

  void _updateContentMode() {
    final activos = _rstClientesActivos?.getRowCount() ?? 0;
    final pendientes = _rstClientesPendientes?.getRowCount() ?? 0;

    if (activos > 0 || pendientes > 0) {
      contentModeNotifier.value = SmxSaldiFyDashboardContentMode.main;
      return;
    }

    if (_clientesActivosLoaded && _clientesPendientesLoaded) {
      contentModeNotifier.value = SmxSaldiFyDashboardContentMode.initial;
      return;
    }

    contentModeNotifier.value = SmxSaldiFyDashboardContentMode.loading;
  }

  bool _hasStatusPendiente() {
    if (_rstClientesActivos == null ||
        _rstClientesActivos!.getRowCount() == 0) {
      return false;
    }

    SmxRowSet rstClientes = _rstClientesActivos!;
    rstClientes.beforeFirst();
    while (rstClientes.next()) {
      final status = rstClientes.getValue('SYSUSER12_STATUS');
      if (status == 'Pendiente') {
        rstClientes.first();
        return true;
      }
    }

    return false;
  }

  bool _hasGestionPendiente() {
    if (_rstClientesActivos == null ||
        _rstClientesActivos!.getRowCount() == 0) {
      return false;
    }

    final rstClientes = _rstClientesActivos!;
    rstClientes.beforeFirst();
    while (rstClientes.next()) {
      final compras = _getIntValue(rstClientes, 'NOVE_COMPRAS');
      final pagos = _getIntValue(rstClientes, 'NOVE_PAGOS');

      if (compras + pagos > 0) {
        rstClientes.first();
        return true;
      }
    }

    return false;
  }

  bool _hasCobranzaPendiente() {
    if (_rstClientesActivos == null ||
        _rstClientesActivos!.getRowCount() == 0) {
      return false;
    }

    final rstClientes = _rstClientesActivos!;
    rstClientes.beforeFirst();
    while (rstClientes.next()) {
      final status = rstClientes.getValue('SYSUSER12_STATUS')?.toString();
      final statusType = rstClientes
          .getValue('SYSUSER12_STATUS_TIPO')
          ?.toString();

      if (_isCobranzaPendienteStatus(status, statusType)) {
        rstClientes.first();
        return true;
      }
    }

    return false;
  }

  bool _isCobranzaPendienteStatus(String? status, String? statusType) {
    final normalizedStatus = (status ?? '').trim().toLowerCase();
    final normalizedType = (statusType ?? '').trim().toLowerCase();

    if (normalizedStatus == 'pendiente') return false;
    if (normalizedStatus == 'al dia' || normalizedStatus == 'al día') {
      return false;
    }

    if (normalizedStatus.isNotEmpty) return true;

    return normalizedType == 'warning' ||
        normalizedType == 'alert' ||
        normalizedType == 'danger';
  }

  int _getIntValue(SmxRowSet rst, String field) {
    try {
      final value = rst.getValue(field);
      if (value is int) return value;
      if (value is double) return value.toInt();
      return int.tryParse(value?.toString() ?? '') ?? 0;
    } catch (_) {
      return 0;
    }
  }

  void _notifyPendingActionsChanged() {
    pendingActionsRevisionNotifier.value++;
  }

  void _notifyMetricasChanged() {
    metricasRevisionNotifier.value++;
  }

  void openUnderConstruction(BuildContext context, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SmxSaldiFyScreenTmp(title: title),
      ),
    );
  }

  Future<bool?> openCliente(
    BuildContext context, {
    int relaSysuser10Cliente = -1,
  }) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            SmxSaldiFyCliente(relaSysuser10Cliente: relaSysuser10Cliente),
      ),
    );
  }

  Future<bool?> openArchivados(BuildContext context) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SmxSaldiFyArchivados()),
    );
  }

  Future<void> openCobranza(BuildContext context) {
    return Navigator.of(
      context,
    ).push<void>(MaterialPageRoute(builder: (_) => const SmxSaldiFyCobranza()));
  }

  Future<bool?> openProductos(BuildContext context) {
    return Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => const SmxSaldiFyProductos()),
    );
  }

  Future<bool?> openClienteCredito(
    BuildContext context,
    SmxSaldiFyClientTapData client,
  ) async {
    if (client.idSysuser11 <= 0) {
      openUnderConstruction(context, 'Cliente sin relacion');
      return false;
    }

    return Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => SmxSaldiFyClienteCredito(client: client),
      ),
    );
  }

  Future<bool?> openClienteCompras(
    BuildContext context,
    SmxSaldiFyClientTapData client,
  ) async {
    if (client.idSysuser11 <= 0) {
      openUnderConstruction(context, 'Cliente sin relacion');
      return false;
    }

    return Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => SmxSaldiFyCompras(client: client)),
    );
  }

  Future<bool?> openClientePagos(
    BuildContext context,
    SmxSaldiFyClientTapData client,
  ) async {
    if (client.idSysuser11 <= 0) {
      openUnderConstruction(context, 'Cliente sin relacion');
      return false;
    }

    return Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => SmxSaldiFyPagos(client: client)),
    );
  }

  Future<bool?> openClienteHistorial(
    BuildContext context,
    SmxSaldiFyClientTapData client,
  ) async {
    if (client.relaSysuser10Cliente <= 0) {
      openUnderConstruction(context, 'Cliente sin relacion');
      return false;
    }

    return Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => SmxSaldiFyHistorial(client: client)),
    );
  }

  Future<void> openClienteMiRed(
    BuildContext context,
    SmxSaldiFyClientTapData client,
  ) async {
    if (client.idSysuser11 <= 0) {
      openUnderConstruction(context, 'Cliente sin relacion');
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => SmxSaldiFyMiRed(client: client)),
    );
  }

  Future<bool?> openClienteActions(
    BuildContext context,
    SmxSaldiFyClientTapData client,
  ) async {
    final action = await showSmxSaldiFyDashboardMenu(
      context: context,
      client: client,
    );

    if (action == null || !context.mounted) {
      return false;
    }

    if (action == 'compra') {
      return openClienteCompras(context, client);
    }

    if (action == 'pago') {
      return openClientePagos(context, client);
    }

    if (action == 'historial') {
      return openClienteHistorial(context, client);
    }

    if (action == 'credito') {
      return openClienteCredito(context, client);
    }

    if (action == 'mired') {
      await openClienteMiRed(context, client);
      return false;
    }

    return false;
  }
}

enum SmxSaldiFyDashboardContentMode { loading, initial, main }
