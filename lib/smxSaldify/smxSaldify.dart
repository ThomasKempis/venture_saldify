import 'package:flutter/material.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxLayout/smxScreenTmp.dart';
import '../smxAuth/smxLogonMovil.dart';
import '../smxSaldifyAssistant/smxSaldifyAssistant.dart';
import '../smxSaldifyAssistant/smxSaldifyAssistant_context.dart';
import 'smxSaldify_dashboard/smxSaldiFy_dashboard.dart';
import 'smxSaldify_menu_lateral.dart';
import 'smxSaldify_screens/smxSaldiFy_perfil.dart';

class SmxSaldiFy extends StatefulWidget {
  final SmxLogonMovil controllerMain = SmxConstants.controllerMain;

  SmxSaldiFy({super.key});

  @override
  State<SmxSaldiFy> createState() => _SmxSaldiFy();
}

class _SmxSaldiFy extends State<SmxSaldiFy> {
  int _selectedIndex = 0;
  int _dashboardRefreshRevision = 0;

  @override
  Widget build(BuildContext context) {
    final adminName = _getAdminName();

    return LayoutBuilder(
      builder: (context, constraints) {
        final layout = SmxLayout.sizeFromWidth(constraints.maxWidth);

        if (layout.isMobile) {
          return Scaffold(
            backgroundColor: SmxColors.transparent,
            extendBody: true,
            extendBodyBehindAppBar: true,
            drawer: SmxSaldiFyDrawer(
              selectedIndex: _selectedIndex,
              onSelect: _selectPage,
            ),
            body: Builder(
              builder: (context) {
                final menuButton = SmxSaldiFyMenuButton(
                  onPressed: () => Scaffold.of(context).openDrawer(),
                );

                return _buildPage(
                  adminName: adminName,
                  layout: layout,
                  menuButton: menuButton,
                );
              },
            ),
          );
        }

        final page = _buildPage(adminName: adminName, layout: layout);

        return Scaffold(
          backgroundColor: SmxColors.transparent,
          extendBody: true,
          extendBodyBehindAppBar: true,
          body: Row(
            children: [
              SmxSaldiFyNavigationPanel(
                isDesktop: layout.isDesktop,
                selectedIndex: _selectedIndex,
                onSelect: _selectPage,
              ),
              Expanded(child: page),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPage({
    required String adminName,
    required SmxLayoutSize layout,
    Widget? menuButton,
  }) {
    final pageIndex = _selectedIndex >= 0 && _selectedIndex <= 2
        ? _selectedIndex
        : 0;
    final page = IndexedStack(
      index: pageIndex,
      children: [
        SmxSaldiFyDashboard(
          key: ValueKey('saldify-dashboard-$_dashboardRefreshRevision'),
          adminName: adminName,
          layout: layout,
          menuButton: menuButton,
          onRefresh: _refreshDashboard,
        ),
        SmxSaldiFyPerfil(
          onBackToHome: () => _selectPage(0),
          onAcceptToHome: _selectHomeAndRefreshDashboard,
          layout: layout,
        ),
        SmxSaldiFyScreenTmp(
          title: 'Clientes : ${adminName.toUpperCase()}',
          onMenuBackPressed: () => _selectPage(0),
        ),
      ],
    );

    // Sirve solo para el ChatBot
    final screen = pageIndex == 0
        ? SmxSaldifyAssistantScreen.dashboardAnfitrion
        : SmxSaldifyAssistantScreen.perfilAnfitrion;

    return SmxSaldifyAssistantHost(
      role: SmxSaldifyAssistantRole.anfitrion,
      screen: screen,
      isMobile: layout.isMobile,
      showFloatingLauncher:
          screen != SmxSaldifyAssistantScreen.dashboardAnfitrion,
      child: page,
    );
  }

  void _selectPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _refreshDashboard() async {
    setState(() {
      _dashboardRefreshRevision++;
    });
  }

  void _selectHomeAndRefreshDashboard() {
    setState(() {
      _selectedIndex = 0;
      _dashboardRefreshRevision++;
    });
  }

  String _getAdminName() {
    try {
      final fullName = widget.controllerMain.getNombres().trim();
      if (fullName.isEmpty) return 'Administrador';

      return fullName
          .toLowerCase()
          .split(RegExp(r'\s+'))
          .where((word) => word.isNotEmpty)
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
    } catch (_) {
      return 'Administrador';
    }
  }
}
