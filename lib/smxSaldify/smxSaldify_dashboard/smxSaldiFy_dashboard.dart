import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout.dart';

import '../../smxApis/smxConstants.dart';
import 'smxSaldiFy_acciones_rapidas/smxSaldiFy_acciones_rapidas.dart';
import 'smxSaldiFy_clientes/smxSaldiFy_clientes.dart';
import 'smxSaldiFy_clientes/crud/update/smxSaldiFy_cliente_update.dart';
import 'smxSaldiFy_invita_clientes/smxSaldiFy_invita_clientes.dart';
import 'smxSaldiFy_red_clientes/smxSaldiFy_red_clientes.dart';
import '../smxSaldify_screens/smxSaldiFy_screen_tmp.dart';

class SmxSaldiFyDashboard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final topContentInset = SmxLayout.topContentInset(context);
    final bottomContentInset = SmxLayout.bottomContentInset(context);

    return SizedBox.expand(
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: _backgroundGradient),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: RefreshIndicator(
                onRefresh: onRefresh ?? () async {},
                color: SmxColors.brandAccent,
                backgroundColor: SmxColors.white,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        pagePadding.left,
                        pagePadding.top + topContentInset,
                        pagePadding.right,
                        pagePadding.bottom + bottomContentInset,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          _SaldifyHeader(
                            menuButton: menuButton,
                            onRefresh: onRefresh,
                            showRefreshButton:
                                kIsWeb &&
                                !SmxLayout.isWebMobile(context) &&
                                !SmxLayout.isWebStandalone,
                          ),
                          SizedBox(height: isMobile ? 26 : 34),
                          Text(
                            'Hola, $adminName',
                            style: const TextStyle(
                              color: SmxColors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SmxSaldiFyRedClientes(
                            isMobile: isMobile,
                            metricColumnsFor: metricColumnsFor,
                            onHeaderTap: () => _openUnderConstruction(
                              context,
                              'Red de clientes',
                            ),
                            onMetricTap: (title) =>
                                _openUnderConstruction(context, title),
                          ),
                          SizedBox(height: isMobile ? 16 : 20),
                          SmxSaldiFyInvitaClientes(
                            uuidAnfitrion: uuidAnfitrion,
                            anfitrionNombre: adminName,
                          ),
                          SizedBox(height: isMobile ? 24 : 30),
                          SmxSaldiFyAccionesRapidas(
                            isMobile: isMobile,
                            cardWidth: quickActionCardWidth,
                            onActionTap: (title) {
                              if (title == 'Cliente') {
                                title = 'Nuevo Cliente';
                              }

                              _openUnderConstruction(context, title);
                            },
                          ),
                          SizedBox(height: isMobile ? 26 : 30),
                          SmxSaldiFyClientes(
                            isMobile: isMobile,
                            isDesktop: isDesktop,
                            onClientTap: (idSysuser11) async {
                              final saved = await _openClienteUpdate(
                                context,
                                idSysuser11,
                              );
                              if (saved == true) {
                                await onRefresh?.call();
                              }
                            },
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
      ),
    );
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

void _openUnderConstruction(BuildContext context, String title) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => SmxSaldiFyScreenTmp(title: title)),
  );
}

Future<bool?> _openClienteUpdate(BuildContext context, int idSysuser11) async {
  if (idSysuser11 <= 0) {
    _openUnderConstruction(context, 'Cliente sin relacion');
    return false;
  }

  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => SmxSaldiFyClienteUpdate(idSysuser11: idSysuser11),
    ),
  );
}
