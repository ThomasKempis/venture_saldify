import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxSaldify/smxSaldify_dashboard/smxSaldiFy_clientes/smxSaldiFy_clientes.dart';
import 'package:venture_saldify/smxSaldifyBackgrounds/historial_linear_bg.dart';
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

  const _HistorialView({
    required this.controller,
    required this.client,
    required this.onStatusChange,
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
                      _Header(
                        title: client.name,
                        onBack: () =>
                            Navigator.of(context).pop(controller.hasChanges),
                      ),
                      const SizedBox(height: 22),
                      if (!controller.hasMovimientos)
                        const _EmptyState()
                      else
                        _HistorialPanel(
                          controller: controller,
                          onStatusChange: onStatusChange,
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

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({required this.title, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          icon: const Icon(Icons.arrow_back_rounded),
          color: SmxColors.white,
          style: IconButton.styleFrom(
            backgroundColor: SmxColors.whiteAlpha(.12),
            fixedSize: const Size(44, 44),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SmxColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 3),
              const Text(
                'Historial de movimientos',
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

  const _HistorialPanel({
    required this.controller,
    required this.onStatusChange,
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
                      concepto: controller.getConceptoAt(index),
                      importe: controller.getImporteAt(index),
                      fecha: controller.getFechaAt(index),
                      owner: controller.getOwnerAt(index),
                      status: controller.getStatusAt(index),
                      canSetCompraPendiente: controller.canSetCompraPendienteAt(
                        index,
                      ),
                      canSetCompraEntregada: controller.canSetCompraEntregadaAt(
                        index,
                      ),
                      canConfirmPago: controller.canConfirmPagoAt(index),
                      onStatusChange: (status) => onStatusChange(index, status),
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
  final String concepto;
  final String importe;
  final String fecha;
  final String owner;
  final int status;
  final bool canSetCompraPendiente;
  final bool canSetCompraEntregada;
  final bool canConfirmPago;
  final ValueChanged<int> onStatusChange;
  final int index;

  const _HistorialRow({
    required this.tipo,
    required this.concepto,
    required this.importe,
    required this.fecha,
    required this.owner,
    required this.status,
    required this.canSetCompraPendiente,
    required this.canSetCompraEntregada,
    required this.canConfirmPago,
    required this.onStatusChange,
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
          Row(
            children: [
              _TipoBadge(label: tipo, color: accent),
              const SizedBox(width: 10),
              Expanded(
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
              Text(
                fecha,
                maxLines: 1,
                style: const TextStyle(
                  color: SmxColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
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
      return status == 1 ? 'Deposito confirmado' : 'Pendiente confirmar';
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

  const _MovimientoInfo({
    required this.owner,
    required this.statusLabel,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 5,
      children: [
        if (owner.isNotEmpty)
          _InfoPill(label: owner, icon: Icons.person_outline_rounded),
        _InfoPill(label: statusLabel, icon: Icons.flag_outlined, color: color),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const _InfoPill({required this.label, required this.icon, this.color});

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? SmxColors.textMuted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: foreground.withValues(alpha: .09),
        borderRadius: BorderRadius.circular(999),
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
        ],
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

  const _TipoBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 68),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
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
    );
  }
}
