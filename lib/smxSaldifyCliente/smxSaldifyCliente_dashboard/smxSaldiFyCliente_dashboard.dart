import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';

import '../smxSaldiFyCliente_controller.dart';
import 'smxSaldiFyCliente_acciones_rapidas/smxSaldiFyCliente_acciones_rapidas.dart';
import 'smxSaldiFyCliente_anfitrion/smxSaldiFyCliente_anfitrion.dart';
import 'smxSaldiFyCliente_dashboard_controller.dart';
import 'smxSaldiFyCliente_historial/smxSaldiFyCliente_historial.dart';
import 'smxSaldiFyCliente_metricas/smxSaldiFyCliente_metricas.dart';

class SmxSaldiFyClienteDashboard extends StatefulWidget {
  final SmxSaldiFyClienteController controller;
  final bool isMobile;
  final bool isDesktop;
  final double maxContentWidth;
  final EdgeInsets pagePadding;
  final Widget? menuButton;
  final Future<void> Function()? onRefresh;

  const SmxSaldiFyClienteDashboard({
    super.key,
    required this.controller,
    required this.isMobile,
    required this.isDesktop,
    required this.maxContentWidth,
    required this.pagePadding,
    this.menuButton,
    this.onRefresh,
  });

  @override
  State<SmxSaldiFyClienteDashboard> createState() =>
      _SmxSaldiFyClienteDashboardState();
}

class _SmxSaldiFyClienteDashboardState
    extends State<SmxSaldiFyClienteDashboard> {
  late SmxSaldiFyClienteDashboardController dashboardController;

  @override
  void initState() {
    super.initState();
    dashboardController = SmxSaldiFyClienteDashboardController(
      clienteController: widget.controller,
      onRefresh: widget.onRefresh,
    );
  }

  @override
  void didUpdateWidget(SmxSaldiFyClienteDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.controller == widget.controller &&
        oldWidget.onRefresh == widget.onRefresh) {
      return;
    }

    final metricasSnapshot = dashboardController.metricasSnapshot;
    dashboardController = SmxSaldiFyClienteDashboardController(
      clienteController: widget.controller,
      onRefresh: widget.onRefresh,
    )..metricasSnapshot = metricasSnapshot;
  }

  @override
  Widget build(BuildContext context) {
    final topContentInset = SmxLayout.topContentInset(context);
    final bottomContentInset = SmxLayout.bottomContentInset(context);

    return SizedBox.expand(
      child: SmxSaldifyBackground(
        child: SafeArea(
          top: false,
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.maxContentWidth),
              child: RefreshIndicator(
                onRefresh: dashboardController.refresh,
                color: SmxColors.brandAccent,
                backgroundColor: SmxColors.white,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          widget.pagePadding.left,
                          widget.pagePadding.top + topContentInset,
                          widget.pagePadding.right,
                          widget.pagePadding.bottom + bottomContentInset,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _ClienteHeader(
                              menuButton: widget.menuButton,
                              onRefresh: dashboardController.refresh,
                              showRefreshButton:
                                  kIsWeb &&
                                  !SmxLayout.isWebMobile(context) &&
                                  !SmxLayout.isWebStandalone,
                            ),
                            SizedBox(height: widget.isMobile ? 26 : 34),
                            Text(
                              'Hola, ${dashboardController.clientName}',
                              style: const TextStyle(
                                color: SmxColors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SmxSaldiFyClienteMetricas(
                              isMobile: widget.isMobile,
                              relaSysuser10Anfitrion:
                                  dashboardController.relaSysuser10Anfitrion,
                              onMetricasChanged:
                                  dashboardController.setMetricasSnapshot,
                            ),
                            SizedBox(height: widget.isMobile ? 16 : 20),
                            SmxSaldiFyClienteAnfitrion(
                              nombreAnfitrion:
                                  dashboardController.anfitrionNombreCompleto,
                              telefonoAnfitrion:
                                  dashboardController.anfitrionTelefono,
                              estadoRelacion:
                                  dashboardController.anfitrionRelacionEstado,
                              onContactTap: () =>
                                  dashboardController.launchWhatsApp(context),
                            ),
                            SizedBox(height: widget.isMobile ? 16 : 20),
                            SmxSaldiFyClienteAccionesRapidas(
                              isMobile: widget.isMobile,
                              onActionTap: (title) => dashboardController
                                  .openClienteAction(context, title),
                            ),
                            SizedBox(height: widget.isMobile ? 26 : 30),
                            SmxSaldiFyClienteHistorial(
                              isMobile: widget.isMobile,
                              isDesktop: widget.isDesktop,
                              relaSysuser10Anfitrion:
                                  dashboardController.relaSysuser10Anfitrion,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
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
  final Future<void> Function()? onRefresh;
  final bool showRefreshButton;

  const _ClienteHeader({
    this.menuButton,
    this.onRefresh,
    required this.showRefreshButton,
  });

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
        if (showRefreshButton && onRefresh != null) ...[
          const SizedBox(width: 12),
          Tooltip(
            message: 'Refrescar',
            child: IconButton(
              onPressed: () => onRefresh?.call(),
              icon: const Icon(Icons.refresh_rounded),
              color: SmxColors.white,
              style: IconButton.styleFrom(
                backgroundColor: SmxColors.whiteAlpha(.12),
                hoverColor: SmxColors.whiteAlpha(.18),
                fixedSize: const Size(44, 44),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
