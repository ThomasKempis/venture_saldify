import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxSaldifyBackgrounds/saldify_circles_background.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import '../smxSaldiFy_clientes/smxSaldiFy_clientes.dart';
import 'smxSaldiFy_clientes_pendientes_controller.dart';

class SmxSaldiFyClientesPendientes extends StatefulWidget {
  final bool isMobile;
  final bool isDesktop;
  final ValueChanged<SmxSaldiFyClientTapData> onClientPendienteTap;
  final ValueChanged<SmxRowSet>? onLoaded;
  final ValueChanged<SmxRowSet>? onClientActivated;

  const SmxSaldiFyClientesPendientes({
    super.key,
    required this.isMobile,
    required this.isDesktop,
    required this.onClientPendienteTap,
    this.onLoaded,
    this.onClientActivated,
  });

  @override
  State<SmxSaldiFyClientesPendientes> createState() =>
      _SmxSaldiFyClientesPendientesState();
}

class _SmxSaldiFyClientesPendientesState
    extends State<SmxSaldiFyClientesPendientes> {
  bool _showAllClients = false;
  bool _loadedNotified = false;
  late final SmxSaldiFyClientesPendientesController _controller;
  late final Future<void> _controllerInitialization;

  @override
  void initState() {
    super.initState();
    _controller = SmxSaldiFyClientesPendientesController(
      alias: 'SMXSALDIFY_CLIENTES_PENDIENTES',
      data: SmxControllerSendData(context: context),
    );
    _controllerInitialization = _controller.init();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _controllerInitialization,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.hasError ||
            _controller.jsonSend.getError() != null) {
          return const SizedBox.shrink();
        }

        _notifyLoadedOnce(_controller.rstClientesPendientes);

        if (!_controller.hasClientes) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: widget.isMobile ? 26 : 30),
            _SectionHeader(
              title: 'Clientes Pendientes',
              trailing: _showAllClients ? 'Ver menos' : 'Ver todos',
              onTrailingTap: () {
                setState(() {
                  _showAllClients = !_showAllClients;
                });
              },
            ),
            const SizedBox(height: 12),
            _ClientCards(
              isMobile: widget.isMobile,
              isDesktop: widget.isDesktop,
              clientes: _controller.rstClientesPendientes,
              controller: _controller,
              showAll: _showAllClients,
              onClientTap: widget.onClientPendienteTap,
              onClientActivate: _activatePendiente,
              onClientDelete: _deletePendiente,
              onClientActivated: _notifyActivated,
              onClientDeleted: _notifyDeleted,
            ),
          ],
        );
      },
    );
  }

  void _notifyLoadedOnce(SmxRowSet rstClientes) {
    if (_loadedNotified) return;

    _loadedNotified = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      widget.onLoaded?.call(rstClientes);
    });
  }

  void _notifyDeleted() {
    setState(() {});
    widget.onLoaded?.call(_controller.rstClientesPendientes);
  }

  void _notifyActivated(SmxRowSet rstActivated) {
    setState(() {});
    widget.onClientActivated?.call(rstActivated);
    widget.onLoaded?.call(_controller.rstClientesPendientes);
  }

  Future<SmxRowSet?> _activatePendiente(int index, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activar cliente'),
        content: Text(
          'Este cliente pasara a tu lista activa para asignarle credito:\n$name',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Activar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return null;

    return _controller.activatePendienteAt(index);
  }

  Future<bool> _deletePendiente(int index, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar invitacion'),
        content: Text('Quieres eliminar la invitacion pendiente de:\n$name?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    return _controller.deletePendienteAt(index);
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
  final SmxSaldiFyClientesPendientesController controller;
  final bool showAll;
  final ValueChanged<SmxSaldiFyClientTapData> onClientTap;
  final Future<SmxRowSet?> Function(int index, String name) onClientActivate;
  final Future<bool> Function(int index, String name) onClientDelete;
  final ValueChanged<SmxRowSet> onClientActivated;
  final VoidCallback onClientDeleted;

  const _ClientCards({
    required this.isMobile,
    required this.isDesktop,
    required this.clientes,
    required this.controller,
    required this.showAll,
    required this.onClientTap,
    required this.onClientActivate,
    required this.onClientDelete,
    required this.onClientActivated,
    required this.onClientDeleted,
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
      final email = _getClientValue(index, controller.getClientEmail);
      final phone = _getClientValue(index, controller.getClientPhone);

      cards.add(
        _SlidableClientCard(
          key: ValueKey('cliente_pendiente_$idSysuser11'),
          name: name,
          email: email,
          phone: phone,
          onTap: () => onClientTap(
            SmxSaldiFyClientTapData(
              idSysuser11: idSysuser11,
              relaSysuser10Cliente: relaSysuser10Cliente,
              name: name,
            ),
          ),
          confirmActivate: () => onClientActivate(index, name),
          confirmDelete: () => onClientDelete(index, name),
          onActivated: onClientActivated,
          onDeleted: onClientDeleted,
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
  final String email;
  final String phone;
  final VoidCallback onTap;
  final Future<SmxRowSet?> Function() confirmActivate;
  final Future<bool> Function() confirmDelete;
  final ValueChanged<SmxRowSet> onActivated;
  final VoidCallback onDeleted;

  const _SlidableClientCard({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.onTap,
    required this.confirmActivate,
    required this.confirmDelete,
    required this.onActivated,
    required this.onDeleted,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: key!,
      groupTag: 'clientes_pendientes',
      endActionPane: ActionPane(
        extentRatio: .24,
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              final deleted = await confirmDelete();
              if (deleted) {
                onDeleted();
              }
            },
            autoClose: true,
            backgroundColor: const Color(0xFFE95656),
            foregroundColor: SmxColors.white,
            icon: Icons.delete_outline_rounded,
            label: 'Eliminar',
            borderRadius: BorderRadius.circular(18),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(right: 6),
        child: _ClientCard(
          name: name,
          email: email,
          phone: phone,
          onTap: onTap,
          onActivate: () async {
            final rstActivated = await confirmActivate();
            if (rstActivated != null) {
              onActivated(rstActivated);
            }
          },
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final VoidCallback onTap;
  final Future<void> Function() onActivate;

  const _ClientCard({
    required this.name,
    required this.email,
    required this.phone,
    required this.onTap,
    required this.onActivate,
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
              const Positioned.fill(
                child: CustomPaint(
                  painter: SaldifyCirclesBackgroundPainter(
                    accentColor: SmxColors.brandAccent,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SmxColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _ClientLine(label: 'Correo', value: email),
                    const SizedBox(height: 8),
                    _ClientLine(label: 'Telefono', value: phone),
                    const SizedBox(height: 14),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        onPressed: onActivate,
                        icon: const Icon(Icons.check_circle_outline_rounded),
                        label: const Text('Activar cliente'),
                        style: FilledButton.styleFrom(
                          backgroundColor: SmxColors.brandAccent,
                          foregroundColor: SmxColors.textDark,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
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

class _ClientLine extends StatelessWidget {
  final String label;
  final String value;

  const _ClientLine({required this.label, required this.value});

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
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SmxColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}
