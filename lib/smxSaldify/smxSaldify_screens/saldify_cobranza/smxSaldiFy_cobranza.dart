import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';
import 'package:venture_widgets/smxViewMap/smxViewMap.dart';

import 'smxSaldiFy_cobranza_controller.dart';

class SmxSaldiFyCobranza extends StatelessWidget {
  const SmxSaldiFyCobranza({super.key});

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyCobranzaController>(
      controllerBuilder: (context) => SmxSaldiFyCobranzaController(
        alias: 'SMXSALDIFY_COBRANZA',
        data: SmxControllerSendData(context: context),
      ),
      builder: (context, controller) => _CobranzaView(controller: controller),
    );
  }
}

class _CobranzaView extends StatelessWidget {
  final SmxSaldiFyCobranzaController controller;

  const _CobranzaView({required this.controller});

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
          child: Stack(
            children: [
              SafeArea(
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
                          const _Header(),
                          const SizedBox(height: 20),
                          _ResumenBar(clientes: controller.clientes),
                          const SizedBox(height: 18),
                          if (!controller.hasClientes)
                            const _EmptyState()
                          else
                            _CobranzaList(
                              controller: controller,
                              isMobile: layout.isMobile,
                            ),
                        ],
                      ),
                    ),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
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
                'Cobranza',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: SmxColors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Clientes con seguimiento pendiente',
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

class _ResumenBar extends StatelessWidget {
  final List<SmxSaldiFyCobranzaCliente> clientes;

  const _ResumenBar({required this.clientes});

  @override
  Widget build(BuildContext context) {
    final vencidos = clientes.where((c) => c.status == 'Vencido').length;
    final hoy = clientes.where((c) => c.status == 'Vence hoy').length;
    final porVencer = clientes.where((c) => c.status == 'Por vencer').length;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SmxColors.whiteAlpha(.14)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ResumenPill(
              label: 'Vencidos',
              value: vencidos.toString(),
              color: SmxColors.dangerForeground,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ResumenPill(
              label: 'Hoy',
              value: hoy.toString(),
              color: SmxColors.alertForeground,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _ResumenPill(
              label: 'Por vencer',
              value: porVencer.toString(),
              color: SmxColors.warningForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ResumenPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ResumenPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.88),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 19,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: SmxColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: SmxColors.whiteAlpha(.94),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.fact_check_outlined,
            color: SmxColors.successForeground,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'No hay cobranza pendiente',
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

class _CobranzaList extends StatelessWidget {
  final SmxSaldiFyCobranzaController controller;
  final bool isMobile;

  const _CobranzaList({required this.controller, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    if (isMobile) {
      return Column(
        children: [
          for (var index = 0; index < controller.clientes.length; index++) ...[
            if (index > 0) const SizedBox(height: 12),
            _CobranzaCard(
              cliente: controller.clientes[index],
              controller: controller,
              compact: true,
            ),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 14.0;
        final columns = constraints.maxWidth >= 960 ? 2 : 1;
        final cardWidth =
            (constraints.maxWidth - (spacing * (columns - 1))) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final cliente in controller.clientes)
              SizedBox(
                width: cardWidth,
                child: _CobranzaCard(
                  cliente: cliente,
                  controller: controller,
                  compact: false,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CobranzaCard extends StatelessWidget {
  final SmxSaldiFyCobranzaCliente cliente;
  final SmxSaldiFyCobranzaController controller;
  final bool compact;

  const _CobranzaCard({
    required this.cliente,
    required this.controller,
    required this.compact,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.whiteAlpha(.95),
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: SmxColors.blackAlpha(.14),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _LocationColumn(
              cliente: cliente,
              controller: controller,
              size: compact ? 70 : 78,
            ),
            const SizedBox(width: 12),
            Expanded(child: _CobranzaInfo(cliente: cliente)),
          ],
        ),
      ),
    );
  }
}

class _LocationColumn extends StatelessWidget {
  final SmxSaldiFyCobranzaCliente cliente;
  final SmxSaldiFyCobranzaController controller;
  final double size;

  const _LocationColumn({
    required this.cliente,
    required this.controller,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      child: Column(
        children: [
          _LocationTile(cliente: cliente, controller: controller, size: size),
          const SizedBox(height: 8),
          _DiasTile(
            dias: cliente.dias,
            statusType: _StatusType.fromValue(cliente.statusType),
          ),
        ],
      ),
    );
  }
}

class _LocationTile extends StatelessWidget {
  final SmxSaldiFyCobranzaCliente cliente;
  final SmxSaldiFyCobranzaController controller;
  final double size;

  const _LocationTile({
    required this.cliente,
    required this.controller,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = cliente.hasLocation;

    return Material(
      color: enabled ? SmxColors.accentAlpha(.18) : SmxColors.surfaceData,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: enabled ? () => _showMap(context) : null,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _MiniLocationPainter(enabled: enabled),
                ),
              ),
              Center(
                child: Icon(
                  enabled
                      ? Icons.location_on_rounded
                      : Icons.location_off_outlined,
                  color: enabled
                      ? SmxColors.brandSecondary
                      : SmxColors.textMuted,
                  size: 30,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMap(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: SmxColors.transparent,
      builder: (context) {
        final height = MediaQuery.of(context).size.height * .68;

        return Container(
          height: height,
          margin: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: SmxColors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 10, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        cliente.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: SmxColors.textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SmxViewMap(
                        geolocacion: cliente.location,
                        controller: controller,
                        onLine: false,
                        isInvitar: false,
                      ),
                    ),
                    Positioned(
                      right: 14,
                      bottom: 14,
                      child: _GoogleMapsButton(
                        onTap: () => _launchGoogleMaps(cliente.location),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _launchGoogleMaps(String location) async {
    final query = location.replaceAll(' ', '');
    if (query.isEmpty) return;

    final uri = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': query,
    });

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _GoogleMapsButton extends StatelessWidget {
  final VoidCallback onTap;

  const _GoogleMapsButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Abrir en Google Maps',
      child: Material(
        color: SmxColors.white,
        elevation: 8,
        shadowColor: SmxColors.blackAlpha(.18),
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: const SizedBox(
            width: 48,
            height: 48,
            child: Center(child: _GoogleMapsGlyph()),
          ),
        ),
      ),
    );
  }
}

class _GoogleMapsGlyph extends StatelessWidget {
  const _GoogleMapsGlyph();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(30, 30),
      painter: _GoogleMapsGlyphPainter(),
    );
  }
}

class _GoogleMapsGlyphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * .18;
    final rect = Rect.fromLTWH(
      stroke,
      stroke,
      size.width - stroke * 2,
      size.height - stroke * 2,
    );

    Paint segment(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.butt;

    double deg(double value) => value * math.pi / 180;

    canvas.drawArc(
      rect,
      deg(205),
      deg(74),
      false,
      segment(const Color(0xFFEA4335)),
    );
    canvas.drawArc(
      rect,
      deg(279),
      deg(87),
      false,
      segment(const Color(0xFF4285F4)),
    );
    canvas.drawArc(
      rect,
      deg(26),
      deg(105),
      false,
      segment(const Color(0xFF34A853)),
    );
    canvas.drawArc(
      rect,
      deg(131),
      deg(74),
      false,
      segment(const Color(0xFFFBBC05)),
    );

    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.square;

    canvas.drawLine(
      Offset(size.width * .52, size.height * .50),
      Offset(size.width * .86, size.height * .50),
      barPaint,
    );
    canvas.drawLine(
      Offset(size.width * .86, size.height * .50),
      Offset(size.width * .86, size.height * .66),
      barPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DiasTile extends StatelessWidget {
  final int dias;
  final _StatusType statusType;

  const _DiasTile({required this.dias, required this.statusType});

  @override
  Widget build(BuildContext context) {
    final colors = switch (statusType) {
      _StatusType.danger => (
        bg: SmxColors.dangerBackground,
        fg: SmxColors.dangerForeground,
      ),
      _StatusType.alert => (
        bg: SmxColors.alertBackground,
        fg: SmxColors.alertForeground,
      ),
      _StatusType.warning => (
        bg: SmxColors.warningBackground,
        fg: SmxColors.warningForeground,
      ),
      _StatusType.ok => (
        bg: SmxColors.successBackground,
        fg: SmxColors.successForeground,
      ),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 7),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.fg.withValues(alpha: .14)),
      ),
      child: Column(
        children: [
          Text(
            dias.toString(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.fg,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            dias.abs() == 1 ? 'dia' : 'dias',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: colors.fg.withValues(alpha: .78),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniLocationPainter extends CustomPainter {
  final bool enabled;

  const _MiniLocationPainter({required this.enabled});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = (enabled ? SmxColors.brandSecondary : SmxColors.textMuted)
          .withValues(alpha: .18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawLine(
      Offset(size.width * .18, size.height * .20),
      Offset(size.width * .86, size.height * .36),
      linePaint,
    );
    canvas.drawLine(
      Offset(size.width * .18, size.height * .74),
      Offset(size.width * .86, size.height * .56),
      linePaint,
    );
    canvas.drawCircle(
      Offset(size.width * .25, size.height * .48),
      4,
      Paint()
        ..color = (enabled ? SmxColors.brandAccent : SmxColors.textMuted)
            .withValues(alpha: .58),
    );
  }

  @override
  bool shouldRepaint(covariant _MiniLocationPainter oldDelegate) {
    return oldDelegate.enabled != enabled;
  }
}

class _CobranzaInfo extends StatelessWidget {
  final SmxSaldiFyCobranzaCliente cliente;

  const _CobranzaInfo({required this.cliente});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                cliente.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SmxColors.textDark,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _StatusBadge(
              label: cliente.status,
              statusType: _StatusType.fromValue(cliente.statusType),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _DataPill(
              icon: Icons.payments_outlined,
              label: 'Saldo',
              value: cliente.balanceText,
              emphasis: true,
            ),
            _DataPill(
              icon: Icons.event_outlined,
              label: 'Corte',
              value: cliente.cutDate,
            ),
          ],
        ),
        const SizedBox(height: 10),
        _ContactRow(
          icon: Icons.phone_outlined,
          value: cliente.phone.isEmpty ? 'Sin telefono' : cliente.phone,
          enabled: cliente.phone.isNotEmpty,
          onTap: cliente.phone.isEmpty
              ? null
              : () => _launchWhatsApp(cliente.phone),
        ),
        const SizedBox(height: 6),
        _ContactRow(
          icon: Icons.mail_outline_rounded,
          value: cliente.email.isEmpty ? 'Sin correo' : cliente.email,
          enabled: cliente.email.isNotEmpty,
          onTap: cliente.email.isEmpty
              ? null
              : () => _launchUri('mailto:${cliente.email}'),
        ),
      ],
    );
  }

  Future<void> _launchUri(String value) async {
    final uri = Uri.parse(value);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchWhatsApp(String phone) async {
    final digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return;

    final uri = Uri.parse('https://wa.me/$digits');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _DataPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool emphasis;

  const _DataPill({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: emphasis ? SmxColors.accentAlpha(.18) : SmxColors.surfaceData,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: SmxColors.textMuted, size: 16),
          const SizedBox(width: 6),
          Text(
            '$label ',
            style: const TextStyle(
              color: SmxColors.textMuted,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: SmxColors.textDark,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String value;
  final bool enabled;
  final VoidCallback? onTap;

  const _ContactRow({
    required this.icon,
    required this.value,
    required this.enabled,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: SmxColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
          child: Row(
            children: [
              Icon(
                icon,
                color: enabled ? SmxColors.textMuted : SmxColors.white38,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: enabled ? SmxColors.textDark : SmxColors.textMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
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

enum _StatusType {
  ok,
  warning,
  alert,
  danger;

  static _StatusType fromValue(String? value) {
    return switch (value) {
      'warning' => _StatusType.warning,
      'alert' => _StatusType.alert,
      'danger' => _StatusType.danger,
      _ => _StatusType.ok,
    };
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final _StatusType statusType;

  const _StatusBadge({required this.label, required this.statusType});

  @override
  Widget build(BuildContext context) {
    final colors = switch (statusType) {
      _StatusType.ok => (
        bg: SmxColors.successBackground,
        fg: SmxColors.successForeground,
      ),
      _StatusType.warning => (
        bg: SmxColors.warningBackground,
        fg: SmxColors.warningForeground,
      ),
      _StatusType.alert => (
        bg: SmxColors.alertBackground,
        fg: SmxColors.alertForeground,
      ),
      _StatusType.danger => (
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
