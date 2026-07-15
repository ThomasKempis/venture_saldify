import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smx_decision_dialog.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxSaldify/smxSaldify_dashboard/smxSaldiFy_clientes/smxSaldiFy_clientes.dart';
import 'package:venture_saldify/smxLayout/smxBackgrounds/historial_linear_bg.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';

import 'smxSaldiFy_historial_controller.dart';

class SmxSaldiFyHistorial extends StatefulWidget {
  final SmxSaldiFyClientTapData client;

  const SmxSaldiFyHistorial({super.key, required this.client});

  @override
  State<SmxSaldiFyHistorial> createState() => _SmxSaldiFyHistorialState();
}

class _SmxSaldiFyHistorialState extends State<SmxSaldiFyHistorial> {
  Future<void> _rejectPago(
    SmxSaldiFyHistorialController controller,
    int index,
  ) async {
    final motivo = await _showRejectPagoSheet(
      context,
      folio: controller.getFolioAt(index),
      importe: controller.getImporteAt(index),
      fecha: controller.getFechaAt(index),
    );
    if (!mounted || motivo == null) return;

    final updated = await controller.rejectPagoAt(index, motivo);
    if (!mounted) return;
    if (updated) {
      setState(() {});
    }
  }

  Future<void> _showRejectedPagoMotivo({
    required String motivo,
    required String folio,
    required String importe,
    required String fecha,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: SmxColors.transparent,
      builder: (sheetContext) {
        return _RejectedPagoMotivoSheet(
          motivo: motivo,
          folio: folio,
          importe: importe,
          fecha: fecha,
        );
      },
    );
  }

  Future<String?> _showRejectPagoSheet(
    BuildContext context, {
    required String folio,
    required String importe,
    required String fecha,
  }) async {
    final motivoController = TextEditingController();

    try {
      return await showModalBottomSheet<String>(
        context: context,
        isScrollControlled: true,
        backgroundColor: SmxColors.transparent,
        builder: (sheetContext) {
          return _RejectPagoSheet(
            controller: motivoController,
            folio: folio,
            importe: importe,
            fecha: fecha,
          );
        },
      );
    } finally {
      motivoController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyHistorialController>(
      controllerBuilder: (context) => SmxSaldiFyHistorialController(
        alias: 'SMXSALDIFY_HISTORIAL',
        data: SmxControllerSendData(context: context),
        idCliente: widget.client.relaSysuser10Cliente,
      ),
      builder: (context, controller) => PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          Navigator.of(context).pop(controller.hasChanges);
        },
        child: _HistorialView(
          controller: controller,
          client: widget.client,
          onRejectPago: (index) => _rejectPago(controller, index),
          onShowRejectedPagoMotivo: _showRejectedPagoMotivo,
          onStatusChange: (index, status) async {
            final updated = await controller.updateMovimientoStatusAt(
              index,
              status,
            );

            if (!mounted) return;
            if (updated) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}

class _HistorialView extends StatelessWidget {
  final SmxSaldiFyHistorialController controller;
  final SmxSaldiFyClientTapData client;
  final Future<void> Function(int index, int status) onStatusChange;
  final ValueChanged<int> onRejectPago;
  final void Function({
    required String motivo,
    required String folio,
    required String importe,
    required String fecha,
  })
  onShowRejectedPagoMotivo;

  const _HistorialView({
    required this.controller,
    required this.client,
    required this.onStatusChange,
    required this.onRejectPago,
    required this.onShowRejectedPagoMotivo,
  });

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
                      SmxSaldifyScreenHeader(
                        title: client.name,
                        sectionLabel: 'Historial de movimientos',
                        onBackPressed: () =>
                            Navigator.of(context).pop(controller.hasChanges),
                      ),
                      const SizedBox(height: 22),
                      if (!controller.hasMovimientos)
                        const _EmptyState()
                      else
                        _HistorialPanel(
                          controller: controller,
                          onStatusChange: onStatusChange,
                          onRejectPago: onRejectPago,
                          onShowRejectedPagoMotivo: onShowRejectedPagoMotivo,
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
          Icon(
            Icons.receipt_long_outlined,
            color: SmxColors.textMuted,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'No hay movimientos',
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

class _HistorialPanel extends StatelessWidget {
  final SmxSaldiFyHistorialController controller;
  final Future<void> Function(int index, int status) onStatusChange;
  final ValueChanged<int> onRejectPago;
  final void Function({
    required String motivo,
    required String folio,
    required String importe,
    required String fecha,
  })
  onShowRejectedPagoMotivo;

  const _HistorialPanel({
    required this.controller,
    required this.onStatusChange,
    required this.onRejectPago,
    required this.onShowRejectedPagoMotivo,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.94),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(child: HistorialLinearBg()),
          Padding(
            padding: const EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Column(
                children: [
                  _SaldoResumen(saldo: controller.getSaldo()),
                  for (
                    var index = 0;
                    index < controller.rstHistorial.getRowCount();
                    index++
                  )
                    _HistorialRow(
                      tipo: controller.getTipoAt(index),
                      folio: controller.getFolioAt(index),
                      concepto: controller.getConceptoAt(index),
                      importe: controller.getImporteAt(index),
                      calculo: controller.getCalculoAt(index),
                      fecha: controller.getFechaAt(index),
                      owner: controller.getOwnerAt(index),
                      motivo: controller.getMotivoAt(index),
                      status: controller.getStatusAt(index),
                      canSetCompraPendiente: controller.canSetCompraPendienteAt(
                        index,
                      ),
                      canSetCompraEntregada: controller.canSetCompraEntregadaAt(
                        index,
                      ),
                      canConfirmPago: controller.canConfirmPagoAt(index),
                      canRejectPago: controller.canRejectPagoAt(index),
                      canViewRejectedPagoMotivo: controller
                          .canViewRejectedPagoMotivoAt(index),
                      onStatusChange: (status) => onStatusChange(index, status),
                      onRejectPago: () => onRejectPago(index),
                      onShowRejectedPagoMotivo:
                          ({
                            required motivo,
                            required folio,
                            required importe,
                            required fecha,
                          }) => onShowRejectedPagoMotivo(
                            motivo: motivo,
                            folio: folio,
                            importe: importe,
                            fecha: fecha,
                          ),
                      index: index,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaldoResumen extends StatelessWidget {
  final String saldo;

  const _SaldoResumen({required this.saldo});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.88),
        border: Border(bottom: BorderSide(color: SmxColors.blackAlpha(.08))),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Saldo actual',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: SmxColors.textDark,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              saldo,
              maxLines: 1,
              style: const TextStyle(
                color: SmxColors.brandPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistorialRow extends StatelessWidget {
  final String tipo;
  final String folio;
  final String concepto;
  final String importe;
  final String calculo;
  final String fecha;
  final String owner;
  final String motivo;
  final int status;
  final bool canSetCompraPendiente;
  final bool canSetCompraEntregada;
  final bool canConfirmPago;
  final bool canRejectPago;
  final bool canViewRejectedPagoMotivo;
  final ValueChanged<int> onStatusChange;
  final VoidCallback onRejectPago;
  final void Function({
    required String motivo,
    required String folio,
    required String importe,
    required String fecha,
  })
  onShowRejectedPagoMotivo;
  final int index;

  const _HistorialRow({
    required this.tipo,
    required this.folio,
    required this.concepto,
    required this.importe,
    required this.calculo,
    required this.fecha,
    required this.owner,
    required this.motivo,
    required this.status,
    required this.canSetCompraPendiente,
    required this.canSetCompraEntregada,
    required this.canConfirmPago,
    required this.canRejectPago,
    required this.canViewRejectedPagoMotivo,
    required this.onStatusChange,
    required this.onRejectPago,
    required this.onShowRejectedPagoMotivo,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final isPago = tipo.toLowerCase() == 'pago';
    final hasActions =
        canSetCompraPendiente || canSetCompraEntregada || canConfirmPago;
    final accent = isPago ? const Color(0xFF168553) : const Color(0xFFE05A47);
    final bg = index.isEven
        ? const Color(0xFFEAF6F3).withValues(alpha: .70)
        : SmxColors.whiteAlpha(.78);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: bg,
        border: Border(bottom: BorderSide(color: SmxColors.blackAlpha(.05))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 440;
              final totalWidth = compact ? 88.0 : 120.0;
              final dateWidth = compact ? 82.0 : 100.0;

              return Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        _TipoBadge(
                          label: folio,
                          color: accent,
                          onTap: canRejectPago ? onRejectPago : null,
                        ),
                        if (calculo.isNotEmpty) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              calculo,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: SmxColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: totalWidth,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          importe,
                          maxLines: 1,
                          style: TextStyle(
                            color: accent,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: dateWidth,
                    child: Text(
                      fecha,
                      maxLines: 1,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        color: SmxColors.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 7),
          Text(
            concepto.isEmpty ? 'Sin concepto' : concepto,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SmxColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.25,
            ),
          ),
          if (owner.isNotEmpty || hasActions) ...[
            const SizedBox(height: 8),
            _MovimientoInfo(
              owner: owner,
              statusLabel: _statusLabel(isPago: isPago, status: status),
              color: accent,
              onStatusTap: canViewRejectedPagoMotivo
                  ? () => onShowRejectedPagoMotivo(
                      motivo: motivo,
                      folio: folio,
                      importe: importe,
                      fecha: fecha,
                    )
                  : null,
            ),
            if (hasActions) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: _MovimientoActions(
                  isPago: isPago,
                  canSetCompraPendiente: canSetCompraPendiente,
                  canSetCompraEntregada: canSetCompraEntregada,
                  canConfirmPago: canConfirmPago,
                  onStatusChange: onStatusChange,
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _statusLabel({required bool isPago, required int status}) {
    if (isPago) {
      return switch (status) {
        1 => 'Deposito confirmado',
        2 => 'Pago rechazado',
        _ => 'Pendiente confirmar',
      };
    }

    return switch (status) {
      1 => 'Compra pendiente',
      2 => 'Compra entregada',
      _ => 'Compra solicitada',
    };
  }
}

class _MovimientoInfo extends StatelessWidget {
  final String owner;
  final String statusLabel;
  final Color color;
  final VoidCallback? onStatusTap;

  const _MovimientoInfo({
    required this.owner,
    required this.statusLabel,
    required this.color,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 5,
      children: [
        if (owner.isNotEmpty)
          _InfoPill(label: owner, icon: Icons.person_outline_rounded),
        _InfoPill(
          label: statusLabel,
          icon: Icons.flag_outlined,
          color: color,
          onTap: onStatusTap,
        ),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const _InfoPill({
    required this.label,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? SmxColors.textMuted;

    final child = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: onTap == null ? .09 : .14),
        borderRadius: BorderRadius.circular(999),
        border: onTap == null
            ? null
            : Border.all(color: foreground.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: foreground,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 3),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 13,
              color: foreground,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return child;

    return Material(
      color: SmxColors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: child,
      ),
    );
  }
}

class _MovimientoActions extends StatelessWidget {
  final bool isPago;
  final bool canSetCompraPendiente;
  final bool canSetCompraEntregada;
  final bool canConfirmPago;
  final ValueChanged<int> onStatusChange;

  const _MovimientoActions({
    required this.isPago,
    required this.canSetCompraPendiente,
    required this.canSetCompraEntregada,
    required this.canConfirmPago,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    if (isPago && canConfirmPago) {
      return _ActionPill(
        label: 'Confirmar deposito',
        icon: Icons.check_rounded,
        color: const Color(0xFF168553),
        onTap: () => onStatusChange(1),
      );
    }

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.end,
      children: [
        if (canSetCompraPendiente)
          _ActionPill(
            label: 'Pendiente',
            icon: Icons.schedule_rounded,
            color: const Color(0xFFB7791F),
            subtle: true,
            onTap: () => onStatusChange(1),
          ),
        if (canSetCompraEntregada)
          _ActionPill(
            label: 'Entregado',
            icon: Icons.check_rounded,
            color: const Color(0xFFE05A47),
            onTap: () => onStatusChange(2),
          ),
      ],
    );
  }
}

class _ActionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool subtle;
  final VoidCallback onTap;

  const _ActionPill({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.subtle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: subtle ? color.withValues(alpha: .10) : color,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: subtle ? color : SmxColors.white),
              const SizedBox(width: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: subtle ? color : SmxColors.white,
                  fontSize: 10,
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

class _TipoBadge extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _TipoBadge({required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    final child = Container(
      constraints: const BoxConstraints(minWidth: 68),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: onTap == null ? .12 : .18),
        borderRadius: BorderRadius.circular(999),
        border: onTap == null
            ? null
            : Border.all(color: color.withValues(alpha: .18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (onTap != null) ...[
            const SizedBox(width: 5),
            Icon(Icons.keyboard_arrow_down_rounded, color: color, size: 14),
          ],
        ],
      ),
    );

    if (onTap == null) return child;

    return Material(
      color: SmxColors.transparent,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: child,
      ),
    );
  }
}

class _RejectPagoSheet extends StatefulWidget {
  final TextEditingController controller;
  final String folio;
  final String importe;
  final String fecha;

  const _RejectPagoSheet({
    required this.controller,
    required this.folio,
    required this.importe,
    required this.fecha,
  });

  @override
  State<_RejectPagoSheet> createState() => _RejectPagoSheetState();
}

class _RejectPagoSheetState extends State<_RejectPagoSheet> {
  int _motivoLength = 0;
  bool get _isValidMotivo =>
      _motivoLength >= SmxSaldiFyHistorialController.rechazoMotivoMinLength;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_syncMotivo);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncMotivo);
    super.dispose();
  }

  void _syncMotivo() {
    final motivoLength = widget.controller.text.trim().length;
    if (motivoLength == _motivoLength) return;
    setState(() {
      _motivoLength = motivoLength;
    });
  }

  Future<void> _confirmReject() async {
    final motivo = widget.controller.text.trim();
    if (motivo.length < SmxSaldiFyHistorialController.rechazoMotivoMinLength ||
        motivo.length > SmxSaldiFyHistorialController.rechazoMotivoMaxLength) {
      return;
    }

    final confirmed = await showSmxDecisionDialog(
      context,
      title: 'Proceso irreversible',
      message:
          'El pago sera rechazado y dejara de afectar el saldo del cliente. Esta accion no se puede deshacer.',
      acceptText: 'Rechazar pago',
      icon: Icons.block_rounded,
      variant: SmxDecisionVariant.danger,
    );

    if (!mounted || !confirmed) return;
    Navigator.of(context).pop(motivo);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: const BoxDecoration(
          color: SmxColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SmxColors.blackAlpha(.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Pago rechazado',
                style: TextStyle(
                  color: SmxColors.textDark,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 12),
              _RejectPagoSummary(
                folio: widget.folio,
                importe: widget.importe,
                fecha: widget.fecha,
              ),
              const SizedBox(height: 8),
              const Text(
                'Documenta el motivo antes de rechazar este pago confirmado.',
                style: TextStyle(
                  color: SmxColors.textMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: widget.controller,
                maxLength: SmxSaldiFyHistorialController.rechazoMotivoMaxLength,
                maxLines: 4,
                minLines: 3,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  labelText: 'Motivo',
                  helperText:
                      'Minimo ${SmxSaldiFyHistorialController.rechazoMotivoMinLength} caracteres',
                  counterText:
                      '$_motivoLength/${SmxSaldiFyHistorialController.rechazoMotivoMaxLength}',
                  alignLabelWithHint: true,
                  filled: true,
                  fillColor: SmxColors.blackAlpha(.04),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: SmxColors.blackAlpha(.12)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: SmxColors.dangerForeground,
                      width: 1.4,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _isValidMotivo ? _confirmReject : null,
                icon: const Icon(Icons.block_rounded),
                label: const Text('Rechazar pago confirmado'),
                style: FilledButton.styleFrom(
                  backgroundColor: SmxColors.dangerForeground,
                  foregroundColor: SmxColors.white,
                  disabledBackgroundColor: SmxColors.blackAlpha(.10),
                  disabledForegroundColor: SmxColors.textMuted,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RejectPagoSummary extends StatelessWidget {
  final String folio;
  final String importe;
  final String fecha;

  const _RejectPagoSummary({
    required this.folio,
    required this.importe,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SmxColors.dangerBackground.withValues(alpha: .70),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: SmxColors.dangerForeground.withValues(alpha: .12),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: SmxColors.whiteAlpha(.72),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              folio,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: SmxColors.dangerForeground,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              importe,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: SmxColors.textDark,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            fecha,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: SmxColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _RejectedPagoMotivoSheet extends StatelessWidget {
  final String motivo;
  final String folio;
  final String importe;
  final String fecha;

  const _RejectedPagoMotivoSheet({
    required this.motivo,
    required this.folio,
    required this.importe,
    required this.fecha,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        color: SmxColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: SmxColors.blackAlpha(.18),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Pago rechazado',
              style: TextStyle(
                color: SmxColors.textDark,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            _RejectPagoSummary(folio: folio, importe: importe, fecha: fecha),
            const SizedBox(height: 12),
            const Text(
              'Motivo',
              style: TextStyle(
                color: SmxColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              constraints: const BoxConstraints(maxHeight: 220),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SmxColors.blackAlpha(.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SmxColors.blackAlpha(.10)),
              ),
              child: SingleChildScrollView(
                child: Text(
                  motivo,
                  style: const TextStyle(
                    color: SmxColors.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 1.35,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              style: FilledButton.styleFrom(
                backgroundColor: SmxColors.brandPrimary,
                foregroundColor: SmxColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}
