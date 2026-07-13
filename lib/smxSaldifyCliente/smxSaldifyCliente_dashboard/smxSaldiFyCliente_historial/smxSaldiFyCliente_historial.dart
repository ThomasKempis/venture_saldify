import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/cliente_movimiento_bg.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFyCliente_historial_controller.dart';
import 'smxSaldiFyCliente_historial_skeleton.dart';

class SmxSaldiFyClienteHistorial extends StatefulWidget {
  final bool isMobile;
  final bool isDesktop;
  final int relaSysuser10Anfitrion;

  const SmxSaldiFyClienteHistorial({
    super.key,
    required this.isMobile,
    required this.isDesktop,
    required this.relaSysuser10Anfitrion,
  });

  @override
  State<SmxSaldiFyClienteHistorial> createState() =>
      _SmxSaldiFyClienteHistorialState();
}

class _SmxSaldiFyClienteHistorialState
    extends State<SmxSaldiFyClienteHistorial> {
  bool _showAllMovimientos = false;

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClienteHistorialController>(
      controllerBuilder: (context) => SmxSaldiFyClienteHistorialController(
        alias: 'SMXSALDIFY_CLIENTE_HISTORIAL',
        data: SmxControllerSendData(context: context),
        relaSysuser10Anfitrion: widget.relaSysuser10Anfitrion,
      ),
      loadingBuilder: (_) => SmxSaldiFyClienteHistorialSkeleton(
        isMobile: widget.isMobile,
        isDesktop: widget.isDesktop,
      ),
      builder: (context, controller) => _SmxSaldiFyClienteHistorialView(
        isMobile: widget.isMobile,
        isDesktop: widget.isDesktop,
        controller: controller,
        showAllMovimientos: _showAllMovimientos,
        onShowAllMovimientosChanged: (value) {
          setState(() {
            _showAllMovimientos = value;
          });
        },
      ),
    );
  }
}

class _SmxSaldiFyClienteHistorialView extends StatelessWidget {
  final bool isMobile;
  final bool isDesktop;
  final SmxSaldiFyClienteHistorialController controller;
  final bool showAllMovimientos;
  final ValueChanged<bool> onShowAllMovimientosChanged;

  const _SmxSaldiFyClienteHistorialView({
    required this.isMobile,
    required this.isDesktop,
    required this.controller,
    required this.showAllMovimientos,
    required this.onShowAllMovimientosChanged,
  });

  @override
  Widget build(BuildContext context) {
    final hasMovimientos = controller.rstHistorial.getRowCount() > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HistorialHeader(
          showTrailing: hasMovimientos,
          trailing: showAllMovimientos ? 'Ver menos' : 'Ver todos',
          onTrailingTap: () => onShowAllMovimientosChanged(!showAllMovimientos),
        ),
        const SizedBox(height: 12),
        if (!hasMovimientos)
          const _HistorialEmptyState()
        else
          _MovimientoCards(
            isMobile: isMobile,
            isDesktop: isDesktop,
            historial: controller.rstHistorial,
            controller: controller,
            showAll: showAllMovimientos,
          ),
      ],
    );
  }
}

class _HistorialHeader extends StatelessWidget {
  final bool showTrailing;
  final String trailing;
  final VoidCallback onTrailingTap;

  const _HistorialHeader({
    required this.showTrailing,
    required this.trailing,
    required this.onTrailingTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Text(
            'Movimientos',
            style: TextStyle(
              color: SmxColors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        if (showTrailing)
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

class _MovimientoCards extends StatelessWidget {
  final bool isMobile;
  final bool isDesktop;
  final SmxRowSet historial;
  final SmxSaldiFyClienteHistorialController controller;
  final bool showAll;

  const _MovimientoCards({
    required this.isMobile,
    required this.isDesktop,
    required this.historial,
    required this.controller,
    required this.showAll,
  });

  @override
  Widget build(BuildContext context) {
    final visibleCount = showAll
        ? historial.getRowCount()
        : historial.getRowCount().clamp(0, 5).toInt();
    final cards = [
      for (var index = 0; index < visibleCount; index++)
        _MovimientoCard(
          movimientoId: _getMovimientoId(index),
          tipo: _getMovimientoValue(index, controller.getMovimientoTipo),
          concepto: _getMovimientoValue(
            index,
            controller.getMovimientoConcepto,
          ),
          importe: _getMovimientoValue(index, controller.getMovimientoImporte),
          calculo: _getMovimientoValue(index, controller.getMovimientoCalculo),
          fecha: _getMovimientoValue(index, controller.getMovimientoFecha),
          status: _getMovimientoStatus(index),
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
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: isDesktop ? 2.55 : 2.25,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: cards,
    );
  }

  String _getMovimientoValue(int index, String Function() getValue) {
    historial.index(index);
    return getValue();
  }

  int _getMovimientoStatus(int index) {
    historial.index(index);
    return controller.getMovimientoStatus();
  }

  int _getMovimientoId(int index) {
    historial.index(index);
    return controller.getMovimientoId();
  }
}

class _MovimientoCard extends StatelessWidget {
  final int movimientoId;
  final String tipo;
  final String concepto;
  final String importe;
  final String calculo;
  final String fecha;
  final int status;

  const _MovimientoCard({
    required this.movimientoId,
    required this.tipo,
    required this.concepto,
    required this.importe,
    required this.calculo,
    required this.fecha,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final data = _MovimientoStatusData.from(
      tipo: tipo,
      status: status,
      movimientoId: movimientoId,
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: data.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: data.borderColor),
        boxShadow: [
          BoxShadow(
            color: SmxColors.blackAlpha(.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClienteMovimientoBg(accentColor: data.barColor),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 9,
                  height: 52,
                  decoration: BoxDecoration(
                    color: data.barColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              concepto.isEmpty ? data.typeLabel : concepto,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: SmxColors.textDark,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _MovimientoStatusBadge(data: data),
                        ],
                      ),
                      if (calculo.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          calculo,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SmxColors.textMuted,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.event_outlined,
                            color: SmxColors.textMuted,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            fecha,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: SmxColors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              data.typeLabel,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: data.typeColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 88),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerRight,
                    child: Text(
                      importe,
                      maxLines: 1,
                      style: const TextStyle(
                        color: SmxColors.textDark,
                        fontSize: 16,
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
    );
  }
}

class _MovimientoStatusBadge extends StatelessWidget {
  final _MovimientoStatusData data;

  const _MovimientoStatusBadge({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: data.badgeBackground,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        data.statusLabel,
        style: TextStyle(
          color: data.badgeForeground,
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _HistorialEmptyState extends StatelessWidget {
  const _HistorialEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.13),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SmxColors.whiteAlpha(.16)),
      ),
      child: const Text(
        'Todavia no hay movimientos.',
        style: TextStyle(
          color: SmxColors.white70,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MovimientoStatusData {
  final String typeLabel;
  final String statusLabel;
  final Color badgeBackground;
  final Color badgeForeground;
  final Color barColor;
  final Color typeColor;
  final Color cardBackground;
  final Color borderColor;

  const _MovimientoStatusData({
    required this.typeLabel,
    required this.statusLabel,
    required this.badgeBackground,
    required this.badgeForeground,
    required this.barColor,
    required this.typeColor,
    required this.cardBackground,
    required this.borderColor,
  });

  factory _MovimientoStatusData.from({
    required String tipo,
    required int status,
    required int movimientoId,
  }) {
    final normalized = tipo.trim().toLowerCase();
    final isPago = normalized == 'pago' || normalized.contains('pago');
    final barColor = isPago
        ? _stableColor(_pagoBarColors, movimientoId)
        : _stableColor(_compraBarColors, movimientoId);

    if (isPago) {
      return switch (status) {
        1 => _MovimientoStatusData(
          typeLabel: 'Pago',
          statusLabel: 'Confirmado',
          badgeBackground: const Color(0xFFE8F2FF),
          badgeForeground: const Color(0xFF1D4ED8),
          barColor: barColor,
          typeColor: const Color(0xFF1D4ED8),
          cardBackground: const Color(0xFFE6F0FF),
          borderColor: const Color(0xFFD9E8FF),
        ),
        _ => _MovimientoStatusData(
          typeLabel: 'Pago',
          statusLabel: 'Por confirmar',
          badgeBackground: const Color(0xFFEAF6FF),
          badgeForeground: const Color(0xFF0369A1),
          barColor: barColor,
          typeColor: const Color(0xFF0369A1),
          cardBackground: const Color(0xFFE6F0FF),
          borderColor: const Color(0xFFD9E8FF),
        ),
      };
    }

    return switch (status) {
      2 => _MovimientoStatusData(
        typeLabel: 'Compra',
        statusLabel: 'Entregada',
        badgeBackground: SmxColors.successBackground,
        badgeForeground: SmxColors.successForeground,
        barColor: barColor,
        typeColor: barColor,
        cardBackground: SmxColors.whiteAlpha(.94),
        borderColor: SmxColors.whiteAlpha(.35),
      ),
      1 => _MovimientoStatusData(
        typeLabel: 'Compra',
        statusLabel: 'Pendiente',
        badgeBackground: SmxColors.warningBackground,
        badgeForeground: SmxColors.warningForeground,
        barColor: barColor,
        typeColor: barColor,
        cardBackground: SmxColors.whiteAlpha(.94),
        borderColor: SmxColors.whiteAlpha(.35),
      ),
      _ => _MovimientoStatusData(
        typeLabel: 'Compra',
        statusLabel: 'Solicitada',
        badgeBackground: SmxColors.surfaceData,
        badgeForeground: SmxColors.textMuted,
        barColor: barColor,
        typeColor: barColor,
        cardBackground: SmxColors.whiteAlpha(.94),
        borderColor: SmxColors.whiteAlpha(.35),
      ),
    };
  }

  static const _compraBarColors = [
    Color(0xFFD47B13),
    Color(0xFFB86A0E),
    Color(0xFFE0A11B),
    Color(0xFF9A5B00),
  ];

  static const _pagoBarColors = [
    Color(0xFF1D4ED8),
    Color(0xFF2563EB),
    Color(0xFF0284C7),
    Color(0xFF0891B2),
  ];

  static Color _stableColor(List<Color> colors, int seed) {
    final index = seed.abs() % colors.length;
    return colors[index];
  }
}
