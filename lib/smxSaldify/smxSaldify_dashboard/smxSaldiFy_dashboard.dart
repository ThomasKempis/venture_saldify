import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout.dart';

import '../../smxApis/smxConstants.dart';
import 'smxSaldiFy_acciones_rapidas/smxSaldiFy_acciones_rapidas.dart';
import 'smxSaldiFy_clientes/smxSaldiFy_clientes.dart';
import 'smxSaldiFy_clientes_pendientes/smxSaldiFy_clientes_pendientes.dart';
import 'smxSaldiFy_dashboard_controller.dart';
import 'smxSaldiFy_invita_clientes/smxSaldiFy_invita_clientes.dart';
import 'smxSaldiFy_red_clientes/smxSaldiFy_red_clientes.dart';

class SmxSaldiFyDashboard extends StatefulWidget {
  final String adminName;
  final String uuidAnfitrion = SmxConstants.controllerMain.getUuid();
  final bool isMobile;
  final bool isDesktop;
  final double maxContentWidth;
  final EdgeInsets pagePadding;
  final int Function(double width) metricColumnsFor;
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
    required this.metricColumnsFor,
    required this.quickActionCardWidth,
    this.menuButton,
    this.onRefresh,
  });

  static const _backgroundGradient = SmxGradients.saldifyBackground;

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
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: SmxSaldiFyDashboard._backgroundGradient,
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: widget.maxContentWidth),
              child: RefreshIndicator(
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
                            SmxSaldiFyRedClientes(
                              isMobile: widget.isMobile,
                              metricColumnsFor: widget.metricColumnsFor,
                              onHeaderTap: () =>
                                  _controller.openUnderConstruction(
                                    context,
                                    'Red de clientes',
                                  ),
                              onMetricTap: (title) => _controller
                                  .openUnderConstruction(context, title),
                            ),
                            SizedBox(height: widget.isMobile ? 16 : 20),
                            ValueListenableBuilder<SmxRowSet?>(
                              valueListenable:
                                  _controller.clientesInvitacionNotifier,
                              builder: (context, rstClientes, _) {
                                final enabled = rstClientes != null;

                                return AbsorbPointer(
                                  absorbing: !enabled,
                                  child: Opacity(
                                    opacity: enabled ? 1 : .55,
                                    child: SmxSaldiFyInvitaClientes(
                                      uuidAnfitrion: widget.uuidAnfitrion,
                                      anfitrionNombre: widget.adminName,
                                      clientes: rstClientes,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: widget.isMobile ? 24 : 30),
                            SmxSaldiFyAccionesRapidas(
                              isMobile: widget.isMobile,
                              cardWidth: widget.quickActionCardWidth,
                              onActionTap: (title) async {
                                if (title == 'Cliente') {
                                  final saved = await _controller.openCliente(
                                    context,
                                  );
                                  if (saved == true) {
                                    await _refreshDashboard();
                                  }
                                  return;
                                }

                                _controller.openUnderConstruction(
                                  context,
                                  title,
                                );
                              },
                            ),
                            SizedBox(height: widget.isMobile ? 26 : 30),
                            SmxSaldiFyClientes(
                              isMobile: widget.isMobile,
                              isDesktop: widget.isDesktop,
                              onLoaded: _controller.onClientesLoadedRst,
                              onClientTap: (client) async {
                                final saved = await _controller
                                    .openClienteActions(context, client);
                                if (saved == true) {
                                  await _refreshDashboard();
                                }
                              },
                            ),
                            ValueListenableBuilder<SmxRowSet?>(
                              valueListenable:
                                  _controller.clientesActivosNotifier,
                              builder: (context, rstClientes, _) {
                                if (rstClientes == null) {
                                  return const SizedBox.shrink();
                                }

                                return SmxSaldiFyClientesPendientes(
                                  isMobile: widget.isMobile,
                                  isDesktop: widget.isDesktop,
                                  onLoaded:
                                      _controller.onClientesPendientesLoadedRst,
                                  onClientActivated: (rstActivated) {
                                    setState(() {
                                      _controller.onClientePendienteActivated(
                                        rstActivated,
                                      );
                                    });
                                  },
                                  onClientPendienteTap: (client) async {
                                    final saved = await _controller.openCliente(
                                      context,
                                      relaSysuser10Cliente:
                                          client.relaSysuser10Cliente,
                                    );
                                    if (saved == true) {
                                      await _refreshDashboard();
                                    }
                                  },
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
