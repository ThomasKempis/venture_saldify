import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxApis/smxDepth.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smx_decision_dialog.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/saldify_circles_background.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import '../smx_saldify_client_search.dart';
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
  final TextEditingController _searchController = TextEditingController();
  bool _showAllClients = false;
  bool _loadedNotified = false;
  int? _expandedClientId;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
            searchQuery: _searchQuery,
            searchController: _searchController,
            expandedClientId: _expandedClientId,
            onClientArchive: (index, name) =>
                _archiveCliente(controller, index, name),
            onClientArchived: () => _notifyArchived(controller),
            onClientExpansionChanged: (idSysuser11) {
              setState(() {
                _expandedClientId = _expandedClientId == idSysuser11
                    ? null
                    : idSysuser11;
              });
            },
            onShowAllClientsChanged: (value) {
              setState(() {
                _showAllClients = value;
                if (!value) {
                  _searchController.clear();
                  _searchQuery = '';
                }
              });
            },
            onSearchChanged: (value) {
              setState(() {
                _searchQuery = value;
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
    final confirmed = await showSmxDecisionDialog(
      context,
      title: 'Archivar cliente',
      message:
          'El cliente saldra de tu lista activa y quedara en Archivados:\n$name',
      acceptText: 'Archivar',
      icon: Icons.inventory_2_outlined,
      variant: SmxDecisionVariant.warning,
    );

    if (!confirmed) return false;

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
  final String searchQuery;
  final TextEditingController searchController;
  final int? expandedClientId;
  final Future<bool> Function(int index, String name) onClientArchive;
  final VoidCallback onClientArchived;
  final ValueChanged<int> onClientExpansionChanged;
  final ValueChanged<bool> onShowAllClientsChanged;
  final ValueChanged<String> onSearchChanged;

  const _SmxSaldiFyClientesView({
    required this.isMobile,
    required this.isDesktop,
    required this.onClientTap,
    required this.onClientNovedadTap,
    required this.controller,
    required this.clientes,
    required this.showAllClients,
    required this.searchQuery,
    required this.searchController,
    required this.expandedClientId,
    required this.onClientArchive,
    required this.onClientArchived,
    required this.onClientExpansionChanged,
    required this.onShowAllClientsChanged,
    required this.onSearchChanged,
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
        if (showAllClients) ...[
          SmxSaldiFyClientSearchField(
            controller: searchController,
            query: searchQuery,
            onChanged: onSearchChanged,
          ),
          const SizedBox(height: 12),
        ],
        _ClientCards(
          isMobile: isMobile,
          isDesktop: isDesktop,
          clientes: clientes,
          controller: controller,
          showAll: showAllClients,
          searchQuery: searchQuery,
          expandedClientId: expandedClientId,
          onClientTap: onClientTap,
          onClientNovedadTap: onClientNovedadTap,
          onClientArchive: onClientArchive,
          onClientArchived: onClientArchived,
          onClientExpansionChanged: onClientExpansionChanged,
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
  final String searchQuery;
  final int? expandedClientId;
  final ValueChanged<SmxSaldiFyClientTapData> onClientTap;
  final ValueChanged<SmxSaldiFyClientTapData>? onClientNovedadTap;
  final Future<bool> Function(int index, String name) onClientArchive;
  final VoidCallback onClientArchived;
  final ValueChanged<int> onClientExpansionChanged;

  const _ClientCards({
    required this.isMobile,
    required this.isDesktop,
    required this.clientes,
    required this.controller,
    required this.showAll,
    required this.searchQuery,
    required this.expandedClientId,
    required this.onClientTap,
    required this.onClientNovedadTap,
    required this.onClientArchive,
    required this.onClientArchived,
    required this.onClientExpansionChanged,
  });

  @override
  Widget build(BuildContext context) {
    final clientIndexes = _visibleClientIndexes();
    final cards = <Widget>[];

    for (final index in clientIndexes) {
      final idSysuser11 = _getClientIntValue(
        index,
        controller.getClientRelationId,
      );
      final relaSysuser10Cliente = _getClientIntValue(
        index,
        controller.getClientUserId,
      );
      final uuidInvitado = _getClientValue(index, controller.getClientUuid);
      final name = _getClientValue(index, controller.getClientName);
      final email = _getClientValue(index, controller.getClientEmail);
      final phone = _getClientValue(index, controller.getClientPhone);
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
      final conCatalogo = _getClientIntValue(
        index,
        controller.getClientConCatalogo,
      );
      final clientTapData = SmxSaldiFyClientTapData(
        idSysuser11: idSysuser11,
        relaSysuser10Cliente: relaSysuser10Cliente,
        uuidInvitado: uuidInvitado,
        conCatalogo: conCatalogo == 1,
        name: name,
        credit: credit,
        availableCredit: availableCredit,
        balance: balance,
      );

      cards.add(
        _SlidableClientCard(
          key: ValueKey('cliente_activo_$idSysuser11'),
          name: name,
          email: email,
          phone: phone,
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
          expanded: expandedClientId == idSysuser11,
          onExpansionTap: () => onClientExpansionChanged(idSysuser11),
          onTap: () => onClientTap(clientTapData),
          onNovedadTap: onClientNovedadTap == null
              ? null
              : () => onClientNovedadTap!(clientTapData),
          confirmArchive: () => onClientArchive(index, name),
          onArchived: onClientArchived,
        ),
      );
    }

    if (cards.isEmpty) {
      return const SmxSaldiFyClientSearchEmpty();
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
        final columns = cards.length.clamp(1, maxColumns).toInt();
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

  List<int> _visibleClientIndexes() {
    return smxVisibleClientIndexes(
      rowCount: clientes.getRowCount(),
      showAll: showAll,
      searchQuery: searchQuery,
      searchableTextAt: (index) {
        clientes.index(index);
        return [
          controller.getClientName(),
          controller.getClientEmail(),
          controller.getClientPhone(),
          controller.getClientStatus(),
        ].join();
      },
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

class _SlidableClientCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
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
  final bool expanded;
  final VoidCallback onExpansionTap;
  final VoidCallback onTap;
  final VoidCallback? onNovedadTap;
  final Future<bool> Function() confirmArchive;
  final VoidCallback onArchived;

  const _SlidableClientCard({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
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
    required this.expanded,
    required this.onExpansionTap,
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
        padding: EdgeInsets.zero,
        child: SmxDepth(
          radius: 20,
          depth: 3,
          opacity: .14,
          blurRadius: 7,
          child: _ClientCard(
            name: name,
            email: email,
            phone: phone,
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
            expanded: expanded,
            onExpansionTap: onExpansionTap,
            onTap: onTap,
            onNovedadTap: onNovedadTap,
          ),
        ),
      ),
    );
  }
}

class SmxSaldiFyClientTapData {
  final int idSysuser11;
  final int relaSysuser10Cliente;
  final String uuidInvitado;
  final String name;
  final String credit;
  final String availableCredit;
  final String balance;
  final bool conCatalogo;

  const SmxSaldiFyClientTapData({
    required this.idSysuser11,
    required this.relaSysuser10Cliente,
    required this.name,
    this.uuidInvitado = '',
    this.conCatalogo = false,
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
  final String email;
  final String phone;
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
  final bool expanded;
  final VoidCallback onExpansionTap;
  final VoidCallback onTap;
  final VoidCallback? onNovedadTap;

  const _ClientCard({
    required this.name,
    required this.email,
    required this.phone,
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
    required this.expanded,
    required this.onExpansionTap,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      hasNovedades ? 14 : 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Flexible(
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
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: SmxColors.textDark,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            _StatusBadge(
                              label: status,
                              statusType: statusType,
                              expanded: expanded,
                              onTap: onExpansionTap,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        _ClientContactLine(
                          label: 'Correo',
                          value: email,
                          onTap: email.isEmpty
                              ? null
                              : () => _launchContact(
                                  context,
                                  Uri(scheme: 'mailto', path: email),
                                  'No se pudo abrir el correo.',
                                ),
                        ),
                        const SizedBox(height: 8),
                        _ClientContactLine(
                          label: 'Telefono',
                          value: phone,
                          onTap: phone.isEmpty
                              ? null
                              : () => _launchContact(
                                  context,
                                  Uri(scheme: 'tel', path: phone),
                                  'No se pudo abrir el telefono.',
                                ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _ClientSummaryMetric(
                                label: 'Saldo',
                                value: SmxRowSet.formatAmount(balance),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ClientSummaryMetric(
                                label: 'Disponible',
                                value: SmxRowSet.formatAmount(availableCredit),
                                emphasis: true,
                              ),
                            ),
                          ],
                        ),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          alignment: Alignment.topCenter,
                          child: expanded
                              ? Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: _ClientDetails(
                                    cutDate: cutDate,
                                    credit: credit,
                                    purchases: purchases,
                                    payments: payments,
                                  ),
                                )
                              : const SizedBox.shrink(),
                        ),
                      ],
                    ),
                  ),
                  if (hasNovedades) ...[
                    Divider(height: 1, color: SmxColors.blackAlpha(.12)),
                    _NovedadesLine(
                      compras: noveCompras,
                      pagos: novePagos,
                      onTap: onNovedadTap,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchContact(
    BuildContext context,
    Uri uri,
    String errorMessage,
  ) async {
    if (await launchUrl(uri)) return;
    if (!context.mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(errorMessage)));
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final _ClientStatusType statusType;
  final bool expanded;
  final VoidCallback onTap;

  const _StatusBadge({
    required this.label,
    required this.statusType,
    required this.expanded,
    required this.onTap,
  });

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

    return Semantics(
      button: true,
      label: '$label. ${expanded ? 'Ocultar' : 'Mostrar'} detalles',
      child: Material(
        color: colors.bg,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.fg,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 2),
                AnimatedRotation(
                  turns: expanded ? .5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colors.fg,
                    size: 17,
                  ),
                ),
              ],
            ),
          ),
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
    final detalle = [
      if (compras > 0) '$compras ${compras == 1 ? 'compra' : 'compras'}',
      if (pagos > 0) '$pagos ${pagos == 1 ? 'pago' : 'pagos'}',
    ].join(' · ');

    return Material(
      color: SmxColors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              const SizedBox(
                width: 28,
                height: 28,
                child: Center(
                  child: Text('🔔', style: TextStyle(fontSize: 20)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  detalle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SmxColors.dangerForeground,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: SmxColors.textDark,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClientContactLine extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;

  const _ClientContactLine({
    required this.label,
    required this.value,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 62,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SmxColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Material(
            color: SmxColors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  value.isEmpty ? 'Sin registro' : value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: onTap == null
                        ? SmxColors.textMuted
                        : SmxColors.brandInteractive,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    decoration: onTap == null
                        ? TextDecoration.none
                        : TextDecoration.underline,
                    decorationColor: SmxColors.brandInteractive,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ClientSummaryMetric extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasis;

  const _ClientSummaryMetric({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: emphasis ? SmxColors.accentAlpha(.16) : SmxColors.surfaceData,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: SmxColors.textMuted,
                fontSize: 10,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                value,
                style: const TextStyle(
                  color: SmxColors.textDark,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientDetails extends StatelessWidget {
  final String cutDate;
  final String credit;
  final String purchases;
  final String payments;

  const _ClientDetails({
    required this.cutDate,
    required this.credit,
    required this.purchases,
    required this.payments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Divider(height: 1, color: SmxColors.blackAlpha(.12)),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _ClientDetailValue(label: 'Corte', value: cutDate),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ClientDetailValue(
                label: 'Credito',
                value: SmxRowSet.formatAmount(credit),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ClientDetailValue(
                label: 'Compras',
                value: SmxRowSet.formatAmount(purchases),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ClientDetailValue(
                label: 'Pagos',
                value: SmxRowSet.formatAmount(payments),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ClientDetailValue extends StatelessWidget {
  final String label;
  final String value;

  const _ClientDetailValue({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: SmxColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: SmxColors.textDark,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }
}
