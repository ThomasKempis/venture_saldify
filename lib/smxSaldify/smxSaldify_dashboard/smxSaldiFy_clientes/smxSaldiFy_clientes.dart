import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_clientes_controller.dart';

class SmxSaldiFyClientes extends StatefulWidget {
  final bool isMobile;
  final bool isDesktop;
  final ValueChanged<int> onClientTap;

  const SmxSaldiFyClientes({
    super.key,
    required this.isMobile,
    required this.isDesktop,
    required this.onClientTap,
  });

  @override
  State<SmxSaldiFyClientes> createState() => _SmxSaldiFyClientesState();
}

class _SmxSaldiFyClientesState extends State<SmxSaldiFyClientes> {
  bool _showAllClients = false;

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClientesController>(
      controllerBuilder: (context) => SmxSaldiFyClientesController(
        alias: 'SMXSALDIFY_CLIENTES',
        data: SmxControllerSendData(context: context),
      ),
      builder: (context, controller) => _SmxSaldiFyClientesView(
        isMobile: widget.isMobile,
        isDesktop: widget.isDesktop,
        onClientTap: widget.onClientTap,
        controller: controller,
        showAllClients: _showAllClients,
        onShowAllClientsChanged: (value) {
          setState(() {
            _showAllClients = value;
          });
        },
      ),
    );
  }
}

class _SmxSaldiFyClientesView extends StatelessWidget {
  final bool isMobile;
  final bool isDesktop;
  final ValueChanged<int> onClientTap;
  final SmxSaldiFyClientesController controller;
  final bool showAllClients;
  final ValueChanged<bool> onShowAllClientsChanged;

  const _SmxSaldiFyClientesView({
    required this.isMobile,
    required this.isDesktop,
    required this.onClientTap,
    required this.controller,
    required this.showAllClients,
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
          clientes: controller.rstClientes,
          controller: controller,
          showAll: showAllClients,
          onClientTap: onClientTap,
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
  final ValueChanged<int> onClientTap;

  const _ClientCards({
    required this.isMobile,
    required this.isDesktop,
    required this.clientes,
    required this.controller,
    required this.showAll,
    required this.onClientTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCount = showAll
        ? clientes.getRowCount()
        : clientes.getRowCount().clamp(0, 3).toInt();
    final cards = [
      for (var index = 0; index < visibleCount; index++)
        _ClientCard(
          name: _getClientValue(index, controller.getClientName),
          status: _getClientValue(index, controller.getClientStatus),
          statusType: _ClientStatusType.fromValue(
            _getClientValue(index, controller.getClientStatusType),
          ),
          cutDate: _getClientValue(index, controller.getClientCutDate),
          credit: _getClientValue(index, controller.getClientCredit),
          availableCredit: _getClientValue(
            index,
            controller.getClientAvailableCredit,
          ),
          purchases: _getClientValue(index, controller.getClientPurchases),
          payments: _getClientValue(index, controller.getClientPayments),
          balance: _getClientValue(index, controller.getClientBalance),
          onTap: () => onClientTap(
            _getClientIntValue(index, controller.getClientRelationId),
          ),
        ),
    ];

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

    return GridView.count(
      crossAxisCount: isDesktop ? 3 : 2,
      mainAxisSpacing: 14,
      crossAxisSpacing: 14,
      childAspectRatio: isDesktop ? 1.22 : 1.28,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
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
