import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxSaldifyBackgrounds/saldify_circles_background.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_clientes_controller.dart';
import 'smxSaldiFy_clientes_skeleton.dart';

class SmxSaldiFyClientes extends StatefulWidget {
  final bool isMobile;
  final bool isDesktop;
  final ValueChanged<SmxSaldiFyClientTapData> onClientTap;
  final ValueChanged<SmxSaldiFyClientTapData>? onClientNovedadTap;
  final ValueChanged<SmxRowSet> onLoaded;
  final ValueChanged<SmxRowSet>? onArchived;
  final ValueListenable<SmxRowSet?>? clientesNotifier;

  const SmxSaldiFyClientes({
    super.key,
    required this.isMobile,
    required this.isDesktop,
    required this.onClientTap,
    required this.onLoaded,
    this.onClientNovedadTap,
    this.onArchived,
    this.clientesNotifier,
  });

  @override
  State<SmxSaldiFyClientes> createState() => _SmxSaldiFyClientesState();
}

class _SmxSaldiFyClientesState extends State<SmxSaldiFyClientes> {
  bool _showAllClients = false;
  bool _loadedNotified = false;

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClientesController>(
      controllerBuilder: (context) => SmxSaldiFyClientesController(
        alias: 'SMXSALDIFY_CLIENTES',
        data: SmxControllerSendData(context: context),
      ),
      loadingBuilder: (_) => SmxSaldiFyClientesSkeleton(
        isMobile: widget.isMobile,
        isDesktop: widget.isDesktop,
      ),
      builder: (context, controller) {
        _notifyLoadedOnce(controller.rstClientes);

        Widget buildView(SmxRowSet rstClientes) {
          controller.rstClientes = rstClientes;

          if (rstClientes.getRowCount() == 0) {
            return const SizedBox.shrink();
          }

          return _SmxSaldiFyClientesView(
            isMobile: widget.isMobile,
            isDesktop: widget.isDesktop,
            onClientTap: widget.onClientTap,
            onClientNovedadTap: widget.onClientNovedadTap,
            controller: controller,
            clientes: rstClientes,
            showAllClients: _showAllClients,
            onClientArchive: (index, name) =>
                _archiveCliente(controller, index, name),
            onClientArchived: () => _notifyArchived(controller),
            onShowAllClientsChanged: (value) {
              setState(() {
                _showAllClients = value;
              });
            },
          );
        }

        final clientesNotifier = widget.clientesNotifier;
        if (clientesNotifier == null) {
          return buildView(controller.rstClientes);
        }

        return ValueListenableBuilder<SmxRowSet?>(
          valueListenable: clientesNotifier,
          builder: (context, rstClientes, _) {
            return buildView(rstClientes ?? controller.rstClientes);
          },
        );
      },
    );
  }

  void _notifyLoadedOnce(SmxRowSet rstClientes) {
    if (_loadedNotified) return;

    _loadedNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onLoaded.call(rstClientes);
    });
  }

  Future<bool> _archiveCliente(
    SmxSaldiFyClientesController controller,
    int index,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archivar cliente'),
        content: Text(
          'El cliente saldra de tu lista activa y quedara en Archivados:\n$name',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Archivar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    return controller.archiveClienteAt(index);
  }

  void _notifyArchived(SmxSaldiFyClientesController controller) {
    setState(() {});
    final rstClientes = controller.rstClientes.copy();
    if (widget.onArchived == null) {
      widget.onLoaded.call(rstClientes);
      return;
    }

    widget.onArchived!.call(rstClientes);
  }
}

class _SmxSaldiFyClientesView extends StatelessWidget {
  final bool isMobile;
  final bool isDesktop;
  final ValueChanged<SmxSaldiFyClientTapData> onClientTap;
  final ValueChanged<SmxSaldiFyClientTapData>? onClientNovedadTap;
  final SmxSaldiFyClientesController controller;
  final SmxRowSet clientes;
  final bool showAllClients;
  final Future<bool> Function(int index, String name) onClientArchive;
  final VoidCallback onClientArchived;
  final ValueChanged<bool> onShowAllClientsChanged;

  const _SmxSaldiFyClientesView({
    required this.isMobile,
    required this.isDesktop,
    required this.onClientTap,
    required this.onClientNovedadTap,
    required this.controller,
    required this.clientes,
    required this.showAllClients,
    required this.onClientArchive,
    required this.onClientArchived,
    required this.onShowAllClientsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: 'Clientes',
          trailing: showAllClients ? 'Ver menos' : 'Ver todos',
          onTrailingTap: () {
            onShowAllClientsChanged(!showAllClients);
          },
        ),
        const SizedBox(height: 12),
        _ClientCards(
          isMobile: isMobile,
          isDesktop: isDesktop,
          clientes: clientes,
          controller: controller,
          showAll: showAllClients,
          onClientTap: onClientTap,
          onClientNovedadTap: onClientNovedadTap,
          onClientArchive: onClientArchive,
          onClientArchived: onClientArchived,
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String trailing;
  final VoidCallback? onTrailingTap;

  const _SectionHeader({
    required this.title,
    required this.trailing,
    this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: SmxColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        InkWell(
          onTap: onTrailingTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Text(
              trailing,
              style: const TextStyle(
                color: SmxColors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClientCards extends StatelessWidget {
  final bool isMobile;
  final bool isDesktop;
  final SmxRowSet clientes;
  final SmxSaldiFyClientesController controller;
  final bool showAll;
  final ValueChanged<SmxSaldiFyClientTapData> onClientTap;
  final ValueChanged<SmxSaldiFyClientTapData>? onClientNovedadTap;
  final Future<bool> Function(int index, String name) onClientArchive;
  final VoidCallback onClientArchived;

  const _ClientCards({
    required this.isMobile,
    required this.isDesktop,
    required this.clientes,
    required this.controller,
    required this.showAll,
    required this.onClientTap,
    required this.onClientNovedadTap,
    required this.onClientArchive,
    required this.onClientArchived,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCount = showAll
        ? clientes.getRowCount()
        : clientes.getRowCount().clamp(0, 5).toInt();
    final cards = <Widget>[];

    for (var index = 0; index < visibleCount; index++) {
      final idSysuser11 = _getClientIntValue(
        index,
        controller.getClientRelationId,
      );
      final relaSysuser10Cliente = _getClientIntValue(
        index,
        controller.getClientUserId,
      );
      final name = _getClientValue(index, controller.getClientName);
      final status = _getClientValue(index, controller.getClientStatus);
      final statusType = _ClientStatusType.fromValue(
        _getClientValue(index, controller.getClientStatusType),
      );
      final cutDate = _getClientValue(index, controller.getClientCutDate);
      final credit = _getClientValue(index, controller.getClientCredit);
      final availableCredit = _getClientValue(
        index,
        controller.getClientAvailableCredit,
      );
      final purchases = _getClientValue(index, controller.getClientPurchases);
      final payments = _getClientValue(index, controller.getClientPayments);
      final balance = _getClientValue(index, controller.getClientBalance);
      final noveCompras = _getClientIntValue(
        index,
        controller.getClientNoveCompras,
      );
      final novePagos = _getClientIntValue(
        index,
        controller.getClientNovePagos,
      );
      final clientTapData = SmxSaldiFyClientTapData(
        idSysuser11: idSysuser11,
        relaSysuser10Cliente: relaSysuser10Cliente,
        name: name,
        credit: credit,
        availableCredit: availableCredit,
        balance: balance,
      );

      cards.add(
        _SlidableClientCard(
          key: ValueKey('cliente_activo_$idSysuser11'),
          name: name,
          status: status,
          statusType: statusType,
          cutDate: cutDate,
          credit: credit,
          availableCredit: availableCredit,
          purchases: purchases,
          payments: payments,
          balance: balance,
          noveCompras: noveCompras,
          novePagos: novePagos,
          onTap: () => onClientTap(clientTapData),
          onNovedadTap: onClientNovedadTap == null
              ? null
              : () => onClientNovedadTap!(clientTapData),
          confirmArchive: () => onClientArchive(index, name),
          onArchived: onClientArchived,
        ),
      );
    }

    if (isMobile) {
      return Column(
        children: [
          for (var index = 0; index < cards.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            cards[index],
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final maxColumns = _getMaxColumns(constraints.maxWidth);
        final columns = visibleCount.clamp(1, maxColumns).toInt();
        final cardWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final card in cards) SizedBox(width: cardWidth, child: card),
          ],
        );
      },
    );
  }

  int _getMaxColumns(double width) {
    if (isDesktop && width >= 1180) return 4;
    if (isDesktop && width >= 820) return 3;
    return 2;
  }

  String _getClientValue(int index, String Function() getValue) {
    clientes.index(index);
    return getValue();
  }

  int _getClientIntValue(int index, int Function() getValue) {
    clientes.index(index);
    return getValue();
  }
}

class _SlidableClientCard extends StatelessWidget {
  final String name;
  final String status;
  final _ClientStatusType statusType;
  final String cutDate;
  final String credit;
  final String availableCredit;
  final String purchases;
  final String payments;
  final String balance;
  final int noveCompras;
  final int novePagos;
  final VoidCallback onTap;
  final VoidCallback? onNovedadTap;
  final Future<bool> Function() confirmArchive;
  final VoidCallback onArchived;

  const _SlidableClientCard({
    super.key,
    required this.name,
    required this.status,
    required this.statusType,
    required this.cutDate,
    required this.credit,
    required this.availableCredit,
    required this.purchases,
    required this.payments,
    required this.balance,
    required this.noveCompras,
    required this.novePagos,
    required this.onTap,
    this.onNovedadTap,
    required this.confirmArchive,
    required this.onArchived,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: key!,
      groupTag: 'clientes_activos',
      endActionPane: ActionPane(
        extentRatio: .24,
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              final archived = await confirmArchive();
              if (archived) {
                onArchived();
              }
            },
            autoClose: true,
            backgroundColor: SmxColors.brandAccent,
            foregroundColor: SmxColors.textDark,
            icon: Icons.archive_outlined,
            label: 'Archivar',
            borderRadius: BorderRadius.circular(18),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: _ClientCard(
          name: name,
          status: status,
          statusType: statusType,
          cutDate: cutDate,
          credit: credit,
          availableCredit: availableCredit,
          purchases: purchases,
          payments: payments,
          balance: balance,
          noveCompras: noveCompras,
          novePagos: novePagos,
          onTap: onTap,
          onNovedadTap: onNovedadTap,
        ),
      ),
    );
  }
}

class SmxSaldiFyClientTapData {
  final int idSysuser11;
  final int relaSysuser10Cliente;
  final String name;
  final String credit;
  final String availableCredit;
  final String balance;

  const SmxSaldiFyClientTapData({
    required this.idSysuser11,
    required this.relaSysuser10Cliente,
    required this.name,
    this.credit = '0',
    this.availableCredit = '0',
    this.balance = '0',
  });
}

enum _ClientStatusType {
  ok,
  warning,
  alert,
  danger;

  static _ClientStatusType fromValue(String? value) {
    return switch (value) {
      'warning' => _ClientStatusType.warning,
      'alert' => _ClientStatusType.alert,
      'danger' => _ClientStatusType.danger,
      _ => _ClientStatusType.ok,
    };
  }
}

class _ClientCard extends StatelessWidget {
  final String name;
  final String status;
  final _ClientStatusType statusType;
  final String cutDate;
  final String credit;
  final String availableCredit;
  final String purchases;
  final String payments;
  final String balance;
  final int noveCompras;
  final int novePagos;
  final VoidCallback onTap;
  final VoidCallback? onNovedadTap;

  const _ClientCard({
    required this.name,
    required this.status,
    required this.statusType,
    required this.cutDate,
    required this.credit,
    required this.availableCredit,
    required this.purchases,
    required this.payments,
    required this.balance,
    required this.noveCompras,
    required this.novePagos,
    required this.onTap,
    this.onNovedadTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasNovedades = noveCompras > 0 || novePagos > 0;
    final accentColor = switch (statusType) {
      _ClientStatusType.ok => SmxColors.successForeground,
      _ClientStatusType.warning => SmxColors.warningForeground,
      _ClientStatusType.alert => SmxColors.alertForeground,
      _ClientStatusType.danger => SmxColors.dangerForeground,
    };

    return Material(
      color: SmxColors.whiteAlpha(.94),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: SmxColors.blackAlpha(.14),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: SaldifyCirclesBackgroundPainter(
                    accentColor: accentColor,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: SmxColors.textDark,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        _StatusBadge(label: status, statusType: statusType),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ClientData(label: 'Corte', value: cutDate),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ClientData(
                            label: 'Credito',
                            value: SmxRowSet.formatAmount(credit),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ClientData(
                            label: 'Disponible',
                            value: SmxRowSet.formatAmount(availableCredit),
                            emphasis: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _ClientData(
                            label: 'Compras',
                            value: SmxRowSet.formatAmount(purchases),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ClientData(
                            label: 'Pagos',
                            value: SmxRowSet.formatAmount(payments),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ClientData(
                            label: 'Saldo',
                            value: SmxRowSet.formatAmount(balance),
                          ),
                        ),
                      ],
                    ),
                    if (hasNovedades) ...[
                      const SizedBox(height: 16),
                      Divider(height: 1, color: SmxColors.blackAlpha(.12)),
                      const SizedBox(height: 12),
                      _NovedadesLine(
                        compras: noveCompras,
                        pagos: novePagos,
                        onTap: onNovedadTap,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final _ClientStatusType statusType;

  const _StatusBadge({required this.label, required this.statusType});

  @override
  Widget build(BuildContext context) {
    final colors = switch (statusType) {
      _ClientStatusType.ok => (
        bg: SmxColors.successBackground,
        fg: SmxColors.successForeground,
      ),
      _ClientStatusType.warning => (
        bg: SmxColors.warningBackground,
        fg: SmxColors.warningForeground,
      ),
      _ClientStatusType.alert => (
        bg: SmxColors.alertBackground,
        fg: SmxColors.alertForeground,
      ),
      _ClientStatusType.danger => (
        bg: SmxColors.dangerBackground,
        fg: SmxColors.dangerForeground,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colors.fg,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _NovedadesLine extends StatelessWidget {
  final int compras;
  final int pagos;
  final VoidCallback? onTap;

  const _NovedadesLine({
    required this.compras,
    required this.pagos,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final total = compras + pagos;
    final detalle = [
      if (compras > 0) '$compras ${compras == 1 ? 'compra' : 'compras'}',
      if (pagos > 0) '$pagos ${pagos == 1 ? 'pago' : 'pagos'}',
    ].join('  •  ');

    return Material(
      color: SmxColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Align(
            alignment: Alignment.centerRight,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: SmxColors.whiteAlpha(.78),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      color: SmxColors.dangerForeground,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$total ${total == 1 ? 'gestion pendiente' : 'gestiones pendientes'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SmxColors.dangerForeground,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          detalle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SmxColors.textMuted,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: SmxColors.textDark,
                    size: 32,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClientData extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasis;

  const _ClientData({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: emphasis ? SmxColors.accentAlpha(.16) : SmxColors.surfaceData,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SmxColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: SmxColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
