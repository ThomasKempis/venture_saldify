import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';

import '../../smxApis/smxConstants.dart';
import 'smxSaldiFy_dashboard_controller.dart';
import 'smxSaldiFy_dashboard_ini.dart';
import 'smxSaldiFy_dashboard_main.dart';
import 'smxSaldiFy_metricas/smxSaldiFy_metricas.dart';
import 'smxSaldify_alertas/acciones_pendientes_center.dart';

class SmxSaldiFyDashboard extends StatefulWidget {
  final String adminName;
  final String uuidAnfitrion = SmxConstants.controllerMain.getUuid();
  final bool isMobile;
  final bool isDesktop;
  final double maxContentWidth;
  final EdgeInsets pagePadding;
  final double quickActionCardWidth;
  final Widget? menuButton;
  final Future<void> Function()? onRefresh;

  SmxSaldiFyDashboard({
    super.key,
    required this.adminName,
    required this.isMobile,
    required this.isDesktop,
    required this.maxContentWidth,
    required this.pagePadding,
    required this.quickActionCardWidth,
    this.menuButton,
    this.onRefresh,
  });

  @override
  State<SmxSaldiFyDashboard> createState() => _SmxSaldiFyDashboardState();
}

class _SmxSaldiFyDashboardState extends State<SmxSaldiFyDashboard> {
  final SmxSaldiFyDashboardController _controller =
      SmxSaldiFyDashboardController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
              child: Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _refreshDashboard,
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
                                _SaldifyHeader(
                                  menuButton: widget.menuButton,
                                  onRefresh: widget.onRefresh == null
                                      ? null
                                      : _refreshDashboard,
                                  showRefreshButton:
                                      kIsWeb &&
                                      !SmxLayout.isWebMobile(context) &&
                                      !SmxLayout.isWebStandalone,
                                ),
                                SizedBox(height: widget.isMobile ? 26 : 34),
                                Text(
                                  'Hola, ${widget.adminName}',
                                  style: const TextStyle(
                                    color: SmxColors.white70,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SmxSaldiFyMetricas(
                                  isMobile: widget.isMobile,
                                  refreshNotifier:
                                      _controller.metricasRevisionNotifier,
                                ),
                                SizedBox(height: widget.isMobile ? 16 : 20),
                                ValueListenableBuilder<
                                  SmxSaldiFyDashboardContentMode
                                >(
                                  valueListenable:
                                      _controller.contentModeNotifier,
                                  builder: (context, mode, _) {
                                    final main = SmxSaldiFyDashboardMain(
                                      controller: _controller,
                                      uuidAnfitrion: widget.uuidAnfitrion,
                                      anfitrionNombre: widget.adminName,
                                      isMobile: widget.isMobile,
                                      isDesktop: widget.isDesktop,
                                      quickActionCardWidth:
                                          widget.quickActionCardWidth,
                                      onRefresh: _refreshDashboard,
                                    );

                                    return Stack(
                                      children: [
                                        Offstage(
                                          offstage:
                                              mode !=
                                              SmxSaldiFyDashboardContentMode
                                                  .main,
                                          child: main,
                                        ),
                                        if (mode ==
                                            SmxSaldiFyDashboardContentMode
                                                .initial)
                                          SmxSaldiFyDashboardIni(
                                            isMobile: widget.isMobile,
                                            onContinue: () async {
                                              final saved = await _controller
                                                  .openCliente(context);
                                              if (saved == true) {
                                                await _refreshDashboard();
                                              }
                                            },
                                            onArchivados: () async {
                                              final changed = await _controller
                                                  .openArchivados(context);
                                              if (changed == true) {
                                                await _refreshDashboard();
                                              }
                                            },
                                          ),
                                        if (mode ==
                                            SmxSaldiFyDashboardContentMode
                                                .loading)
                                          SizedBox(
                                            height: widget.isMobile ? 360 : 330,
                                          ),
                                      ],
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: bottomContentInset + (widget.isMobile ? 18 : 24),
                    child: ValueListenableBuilder<int>(
                      valueListenable:
                          _controller.pendingActionsRevisionNotifier,
                      builder: (context, revision, child) {
                        final acciones = [
                          if (_controller.hasClientesPendientes)
                            AccionPendienteTipo.clientesPendientes,
                          if (_controller.hasCreditoPendiente)
                            AccionPendienteTipo.creditoPendiente,
                        ];

                        return AccionesPendientesCenter(
                          acciones: acciones,
                          isMobile: widget.isMobile,
                        );
                      },
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

  Future<void> _refreshDashboard() async {
    _controller.clearClientes();
    await widget.onRefresh?.call();
  }
}

class _SaldifyHeader extends StatelessWidget {
  final Widget? menuButton;
  final Future<void> Function()? onRefresh;
  final bool showRefreshButton;

  const _SaldifyHeader({
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
                'SMART BALANCE & CREDITS CONTROL',
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
