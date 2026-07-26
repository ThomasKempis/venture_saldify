import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:venture_saldify/smxApis/smxConfig.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';

import '../smxSaldiFyCliente_controller.dart';
import 'smxSaldiFyCliente_acciones_rapidas/smxSaldiFyCliente_acciones_rapidas.dart';
import 'smxSaldiFyCliente_anfitrion/smxSaldiFyCliente_anfitrion.dart';
import 'smxSaldiFyCliente_dashboard_controller.dart';
import 'smxSaldiFyCliente_historial/smxSaldiFyCliente_historial.dart';
import 'smxSaldiFyCliente_metricas/smxSaldiFyCliente_metricas.dart';

class SmxSaldiFyClienteDashboard extends StatefulWidget {
  final SmxSaldiFyClienteController controller;
  final SmxLayoutSize layout;
  final Widget? menuButton;
  final Future<void> Function()? onRefresh;

  const SmxSaldiFyClienteDashboard({
    super.key,
    required this.controller,
    required this.layout,
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

    dashboardController = SmxSaldiFyClienteDashboardController(
      clienteController: widget.controller,
      onRefresh: widget.onRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    final topContentInset = SmxLayout.topContentInset(context);
    final bottomContentInset = SmxLayout.bottomContentInset(context);
    final layout = widget.layout;

    return SizedBox.expand(
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
                          layout.saldifyPagePadding.left,
                          layout.saldifyPagePadding.top + topContentInset,
                          layout.saldifyPagePadding.right,
                          layout.saldifyPagePadding.bottom + bottomContentInset,
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
                            SizedBox(height: layout.isMobile ? 26 : 34),
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
                              isMobile: layout.isMobile,
                              relaSysuser10Anfitrion:
                                  dashboardController.relaSysuser10Anfitrion,
                            ),
                            SizedBox(height: layout.isMobile ? 16 : 20),
                            Text(
                              'Tu anfitrion',
                              style: const TextStyle(
                                color: SmxColors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            SizedBox(height: layout.isMobile ? 16 : 20),
                            SmxSaldiFyClienteAnfitrion(
                              dashboardController: dashboardController,
                            ),
                            SizedBox(height: layout.isMobile ? 16 : 20),
                            SmxSaldiFyClienteAccionesRapidas(
                              isMobile: layout.isMobile,
                              onActionTap: (title) => dashboardController
                                  .openClienteAction(context, title),
                            ),
                            SizedBox(height: layout.isMobile ? 26 : 30),
                            SmxSaldiFyClienteHistorial(
                              isMobile: layout.isMobile,
                              isDesktop: layout.isDesktop,
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
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 34,
            height: 34,
            child: SmxConfig.logo(fit: BoxFit.contain),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                SmxConfig.titulo.toUpperCase(),
                style: const TextStyle(
                  color: SmxColors.white,
                  fontFamily: 'Segoe UI',
                  fontFamilyFallback: ['Tahoma', 'Geneva', 'Verdana', 'Arial'],
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  letterSpacing: 2.6,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                SmxConfig.descripcion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: SmxColors.brandDescription,
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
