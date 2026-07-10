import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxSaldifyBackgrounds/saldify_circles_background.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_archivados_controller.dart';

class SmxSaldiFyArchivados extends StatelessWidget {
  const SmxSaldiFyArchivados({super.key});

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyArchivadosController>(
      controllerBuilder: (context) => SmxSaldiFyArchivadosController(
        alias: 'SMXSALDIFY_ARCHIVADOS',
        data: SmxControllerSendData(context: context),
      ),
      builder: (context, controller) => _ArchivadosView(controller: controller),
    );
  }
}

class _ArchivadosView extends StatefulWidget {
  final SmxSaldiFyArchivadosController controller;

  const _ArchivadosView({required this.controller});

  @override
  State<_ArchivadosView> createState() => _ArchivadosViewState();
}

class _ArchivadosViewState extends State<_ArchivadosView> {
  bool _changed = false;

  SmxSaldiFyArchivadosController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    final layout = SmxLayout.sizeFromWidth(MediaQuery.of(context).size.width);
    final pagePadding = layout.saldifyPagePadding;
    final topContentInset = SmxLayout.topContentInset(context);
    final bottomContentInset = SmxLayout.bottomContentInset(context);

    return Scaffold(
      backgroundColor: SmxColors.transparent,
      body: SizedBox.expand(
        child: SmxSaldifyBackground(
          child: SafeArea(
            top: false,
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: layout.saldifyMaxContentWidth,
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    pagePadding.left,
                    pagePadding.top + topContentInset,
                    pagePadding.right,
                    pagePadding.bottom + bottomContentInset,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Header(changed: _changed),
                      const SizedBox(height: 22),
                      if (!controller.hasArchivados)
                        const _EmptyState()
                      else
                        _ArchivadosList(
                          controller: controller,
                          onReactivate: _reactivateArchivado,
                          onReactivated: () {
                            setState(() {
                              _changed = true;
                            });
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _reactivateArchivado(int index, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reactivar cliente'),
        content: Text('Este cliente volvera a tu lista activa:\n$name'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Reactivar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return false;

    return controller.reactivateArchivadoAt(index);
  }
}

class _Header extends StatelessWidget {
  final bool changed;

  const _Header({required this.changed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(changed),
          icon: const Icon(Icons.arrow_back_rounded),
          color: SmxColors.white,
          style: IconButton.styleFrom(
            backgroundColor: SmxColors.whiteAlpha(.12),
            fixedSize: const Size(44, 44),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clientes archivados',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: SmxColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Reactivar clientes',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: SmxColors.brandAccent,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.94),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(Icons.archive_outlined, color: SmxColors.textMuted, size: 42),
          SizedBox(height: 12),
          Text(
            'No hay clientes archivados',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: SmxColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ArchivadosList extends StatelessWidget {
  final SmxSaldiFyArchivadosController controller;
  final Future<bool> Function(int index, String name) onReactivate;
  final VoidCallback onReactivated;

  const _ArchivadosList({
    required this.controller,
    required this.onReactivate,
    required this.onReactivated,
  });

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[];

    for (
      var index = 0;
      index < controller.rstArchivados.getRowCount();
      index++
    ) {
      controller.rstArchivados.index(index);
      final idSysuser11 = controller.getClientRelationId();
      final name = controller.getClientName();
      final status = controller.getClientStatus();
      final statusType = _ClientStatusType.fromValue(
        controller.getClientStatusType(),
      );
      final cutDate = controller.getClientCutDate();
      final credit = controller.getClientCredit();
      final availableCredit = controller.getClientAvailableCredit();
      final purchases = controller.getClientPurchases();
      final payments = controller.getClientPayments();
      final balance = controller.getClientBalance();

      cards.add(
        _SlidableClientCard(
          key: ValueKey('cliente_archivado_$idSysuser11'),
          name: name,
          status: status,
          statusType: statusType,
          cutDate: cutDate,
          credit: credit,
          availableCredit: availableCredit,
          purchases: purchases,
          payments: payments,
          balance: balance,
          confirmReactivate: () => onReactivate(index, name),
          onReactivated: onReactivated,
        ),
      );
    }

    return Column(
      children: [
        for (var index = 0; index < cards.length; index++) ...[
          if (index > 0) const SizedBox(height: 12),
          cards[index],
        ],
      ],
    );
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
  final Future<bool> Function() confirmReactivate;
  final VoidCallback onReactivated;

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
    required this.confirmReactivate,
    required this.onReactivated,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: key!,
      groupTag: 'clientes_archivados',
      endActionPane: ActionPane(
        extentRatio: .24,
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) async {
              final reactivated = await confirmReactivate();
              if (reactivated) {
                onReactivated();
              }
            },
            autoClose: true,
            backgroundColor: SmxColors.brandAccent,
            foregroundColor: SmxColors.textDark,
            icon: Icons.unarchive_outlined,
            label: 'Reactivar',
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
        ),
      ),
    );
  }
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
  });

  @override
  Widget build(BuildContext context) {
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
          ],
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
      _ClientStatusType.alert => (
        bg: SmxColors.alertBackground,
        fg: SmxColors.alertForeground,
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
