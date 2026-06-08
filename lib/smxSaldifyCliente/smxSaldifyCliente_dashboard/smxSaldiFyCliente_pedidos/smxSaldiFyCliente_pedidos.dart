import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFyCliente_pedidos_controller.dart';

class SmxSaldiFyClientePedidos extends StatefulWidget {
  final bool isMobile;
  final bool isDesktop;
  final ValueChanged<String> onPedidoTap;

  const SmxSaldiFyClientePedidos({
    super.key,
    required this.isMobile,
    required this.isDesktop,
    required this.onPedidoTap,
  });

  @override
  State<SmxSaldiFyClientePedidos> createState() =>
      _SmxSaldiFyClientePedidosState();
}

class _SmxSaldiFyClientePedidosState extends State<SmxSaldiFyClientePedidos> {
  bool _showAllPedidos = false;

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClientePedidosController>(
      controllerBuilder: (context) => SmxSaldiFyClientePedidosController(
        alias: 'SMXSALDIFY_CLIENTE_PEDIDOS',
        data: SmxControllerSendData(context: context),
      ),
      builder: (context, controller) => _SmxSaldiFyClientePedidosView(
        isMobile: widget.isMobile,
        isDesktop: widget.isDesktop,
        controller: controller,
        showAllPedidos: _showAllPedidos,
        onShowAllPedidosChanged: (value) {
          setState(() {
            _showAllPedidos = value;
          });
        },
        onPedidoTap: widget.onPedidoTap,
      ),
    );
  }
}

class _SmxSaldiFyClientePedidosView extends StatelessWidget {
  final bool isMobile;
  final bool isDesktop;
  final SmxSaldiFyClientePedidosController controller;
  final bool showAllPedidos;
  final ValueChanged<bool> onShowAllPedidosChanged;
  final ValueChanged<String> onPedidoTap;

  const _SmxSaldiFyClientePedidosView({
    required this.isMobile,
    required this.isDesktop,
    required this.controller,
    required this.showAllPedidos,
    required this.onShowAllPedidosChanged,
    required this.onPedidoTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PedidosHeader(
          trailing: showAllPedidos ? 'Ver menos' : 'Ver todos',
          onTrailingTap: () => onShowAllPedidosChanged(!showAllPedidos),
        ),
        const SizedBox(height: 12),
        _PedidoCards(
          isMobile: isMobile,
          isDesktop: isDesktop,
          pedidos: controller.rstPedidos,
          controller: controller,
          showAll: showAllPedidos,
          onPedidoTap: onPedidoTap,
        ),
      ],
    );
  }
}

class _PedidosHeader extends StatelessWidget {
  final String trailing;
  final VoidCallback onTrailingTap;

  const _PedidosHeader({required this.trailing, required this.onTrailingTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Historial de pedidos',
            style: TextStyle(
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

class _PedidoCards extends StatelessWidget {
  final bool isMobile;
  final bool isDesktop;
  final SmxRowSet pedidos;
  final SmxSaldiFyClientePedidosController controller;
  final bool showAll;
  final ValueChanged<String> onPedidoTap;

  const _PedidoCards({
    required this.isMobile,
    required this.isDesktop,
    required this.pedidos,
    required this.controller,
    required this.showAll,
    required this.onPedidoTap,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCount = showAll
        ? pedidos.getRowCount()
        : pedidos.getRowCount().clamp(0, 3).toInt();
    final cards = [
      for (var index = 0; index < visibleCount; index++)
        _PedidoCard(
          producto: _getPedidoValue(index, controller.getPedidoProducto),
          importe: _getPedidoValue(index, controller.getPedidoImporte),
          estado: _getPedidoValue(index, controller.getPedidoEstado),
          estadoTipo: _PedidoStatusType.fromValue(
            _getPedidoValue(index, controller.getPedidoEstadoTipo),
          ),
          fecha: _getPedidoValue(index, controller.getPedidoFecha),
          afectaSaldo: _getPedidoBool(index, controller.getPedidoAfectaSaldo),
          onTap: () =>
              onPedidoTap(_getPedidoValue(index, controller.getPedidoProducto)),
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
      childAspectRatio: isDesktop ? 1.45 : 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }

  String _getPedidoValue(int index, String Function() getValue) {
    pedidos.index(index);
    return getValue();
  }

  bool _getPedidoBool(int index, bool Function() getValue) {
    pedidos.index(index);
    return getValue();
  }
}

enum _PedidoStatusType {
  approved,
  review,
  pending,
  paid;

  static _PedidoStatusType fromValue(String value) {
    return switch (value) {
      'review' => _PedidoStatusType.review,
      'pending' => _PedidoStatusType.pending,
      'paid' => _PedidoStatusType.paid,
      _ => _PedidoStatusType.approved,
    };
  }
}

class _PedidoCard extends StatelessWidget {
  final String producto;
  final String importe;
  final String estado;
  final _PedidoStatusType estadoTipo;
  final String fecha;
  final bool afectaSaldo;
  final VoidCallback onTap;

  const _PedidoCard({
    required this.producto,
    required this.importe,
    required this.estado,
    required this.estadoTipo,
    required this.fecha,
    required this.afectaSaldo,
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
                      producto,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: SmxColors.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _PedidoStatusBadge(label: estado, statusType: estadoTipo),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _PedidoData(label: 'Fecha', value: fecha),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _PedidoData(label: 'Importe', value: importe),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                afectaSaldo
                    ? 'Afecta saldo pendiente'
                    : 'No afecta saldo hasta ser provisto',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: afectaSaldo
                      ? SmxColors.successForeground
                      : SmxColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PedidoStatusBadge extends StatelessWidget {
  final String label;
  final _PedidoStatusType statusType;

  const _PedidoStatusBadge({required this.label, required this.statusType});

  @override
  Widget build(BuildContext context) {
    final colors = switch (statusType) {
      _PedidoStatusType.approved => (
        bg: SmxColors.successBackground,
        fg: SmxColors.successForeground,
      ),
      _PedidoStatusType.review => (
        bg: SmxColors.warningBackground,
        fg: SmxColors.warningForeground,
      ),
      _PedidoStatusType.pending => (
        bg: SmxColors.surfaceData,
        fg: SmxColors.textMuted,
      ),
      _PedidoStatusType.paid => (
        bg: SmxColors.accentAlpha(.22),
        fg: SmxColors.brandPrimary,
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

class _PedidoData extends StatelessWidget {
  final String label;
  final String value;

  const _PedidoData({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: SmxColors.surfaceData,
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
