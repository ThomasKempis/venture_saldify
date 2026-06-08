import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout.dart';
import 'package:venture_saldify/smxSaldify/smxSaldify_screens/smxSaldiFy_screen_tmp.dart';

import 'smxSaldiFyCliente_negocio/smxSaldiFyCliente_negocio.dart';
import 'smxSaldiFyCliente_pedidos/smxSaldiFyCliente_pedidos.dart';
import 'smxSaldiFyCliente_resumen/smxSaldiFyCliente_resumen.dart';

class SmxSaldiFyClienteDashboard extends StatelessWidget {
  final String clientName;
  final String anfitrionNombreCompleto;
  final bool isMobile;
  final bool isDesktop;
  final double maxContentWidth;
  final EdgeInsets pagePadding;
  final int Function(double width) metricColumnsFor;
  final Widget? menuButton;

  const SmxSaldiFyClienteDashboard({
    super.key,
    required this.clientName,
    required this.anfitrionNombreCompleto,
    required this.isMobile,
    required this.isDesktop,
    required this.maxContentWidth,
    required this.pagePadding,
    required this.metricColumnsFor,
    this.menuButton,
  });

  static const _backgroundGradient = SmxGradients.saldifyBackground;

  @override
  Widget build(BuildContext context) {
    final topContentInset = SmxLayout.topContentInset(context);

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      pagePadding.left,
                      pagePadding.top + topContentInset,
                      pagePadding.right,
                      pagePadding.bottom,
                    ),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _ClienteHeader(menuButton: menuButton),
                        SizedBox(height: isMobile ? 26 : 34),
                        Text(
                          'Hola, $clientName',
                          style: const TextStyle(
                            color: SmxColors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Anfitrion: $anfitrionNombreCompleto',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: SmxColors.white54,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SmxSaldiFyClienteResumen(
                          isMobile: isMobile,
                          metricColumnsFor: metricColumnsFor,
                          onMetricTap: (title) =>
                              _openUnderConstruction(context, title),
                        ),
                        SizedBox(height: isMobile ? 16 : 20),
                        SmxSaldiFyClienteNegocio(
                          onContactTap: () =>
                              _openUnderConstruction(context, 'Contacto'),
                        ),
                        SizedBox(height: isMobile ? 26 : 30),
                        SmxSaldiFyClientePedidos(
                          isMobile: isMobile,
                          isDesktop: isDesktop,
                          onPedidoTap: (title) =>
                              _openUnderConstruction(context, title),
                        ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClienteHeader extends StatelessWidget {
  final Widget? menuButton;

  const _ClienteHeader({this.menuButton});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (menuButton != null) ...[menuButton!, const SizedBox(width: 14)],
        ClipOval(
          child: SizedBox(
            width: 54,
            height: 54,
            child: Image.asset(
              'assets/images/logo_logon.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 14),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SALDIFY',
                style: TextStyle(
                  color: SmxColors.white,
                  fontFamily: 'Segoe UI',
                  fontFamilyFallback: ['Tahoma', 'Geneva', 'Verdana', 'Arial'],
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: 2.6,
                ),
              ),
              SizedBox(height: 5),
              Text(
                'CLIENT CREDIT PORTAL',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: SmxColors.brandAccent,
                  fontFamily: 'Segoe UI',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: .7,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

void _openUnderConstruction(BuildContext context, String title) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => SmxSaldiFyScreenTmp(title: title)),
  );
}
