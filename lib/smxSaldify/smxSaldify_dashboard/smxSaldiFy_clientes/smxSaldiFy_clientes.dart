import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_clientes_controller.dart';
import 'smxSaldiFy_clientes_skeleton.dart';

class SmxSaldiFyClientes extends StatefulWidget {
  final bool isMobile;
  final bool isDesktop;
  final ValueChanged<SmxSaldiFyClientTapData> onClientTap;
  final ValueChanged<SmxRowSet> onLoaded;
  final ValueChanged<SmxRowSet>? onArchived;
  final ValueListenable<SmxRowSet?>? clientesNotifier;

  const SmxSaldiFyClientes({
    super.key,
    required this.isMobile,
    required this.isDesktop,
    required this.onClientTap,
    required this.onLoaded,
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
  final Future<bool> Function(int index, String name) onClientArchive;
  final VoidCallback onClientArchived;

  const _ClientCards({
    required this.isMobile,
    required this.isDesktop,
    required this.clientes,
    required this.controller,
    required this.showAll,
    required this.onClientTap,
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
          onTap: () => onClientTap(
            SmxSaldiFyClientTapData(
              idSysuser11: idSysuser11,
              relaSysuser10Cliente: relaSysuser10Cliente,
              name: name,
              credit: credit,
              availableCredit: availableCredit,
              balance: balance,
            ),
          ),
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
  final VoidCallback onTap;
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
    required this.onTap,
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
          onTap: onTap,
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
  danger;

  static _ClientStatusType fromValue(String? value) {
    return switch (value) {
      'warning' => _ClientStatusType.warning,
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
  final VoidCallback onTap;

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
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.94),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: const TextStyle(
                        color: SmxColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
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
                    child: _ClientData(label: 'Credito', value: credit),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ClientData(
                      label: 'Disponible',
                      value: availableCredit,
                      emphasis: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _ClientData(label: 'Compras', value: purchases),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ClientData(label: 'Pagos', value: payments),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ClientData(label: 'Saldo', value: balance),
                  ),
                ],
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
