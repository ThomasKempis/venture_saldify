import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout.dart';
import '../smxLogonMovil/logon/smxLogonMovil_controller.dart';
import 'smxSaldify_dashboard/smxSaldiFy_dashboard.dart';
import 'smxSaldiFy_menu_lateral.dart';
import 'smxSaldify_screens/smxSaldiFy_perfil.dart';

class SmxSaldiFy extends StatefulWidget {
  final SmxLogonMovil_controller controllerMain;

  const SmxSaldiFy({super.key, required this.controllerMain});

  @override
  State<SmxSaldiFy> createState() => _SmxSaldiFy();
}

class _SmxSaldiFy extends State<SmxSaldiFy> {
  int _selectedIndex = 0;

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
    return _selectedIndex == 0
        ? SmxSaldiFyDashboard(
            adminName: adminName,
            uuidAnfitrion: widget.controllerMain.getUuid(),
            isMobile: layout.isMobile,
            isDesktop: layout.isDesktop,
            maxContentWidth: layout.saldifyMaxContentWidth,
            pagePadding: layout.saldifyPagePadding,
            metricColumnsFor: layout.saldifyMetricColumnsFor,
            quickActionCardWidth: layout.saldifyQuickActionCardWidth,
            menuButton: menuButton,
          )
        : SmxSaldiFyPerfil(
            controllerMain: widget.controllerMain,
            onNavigateToHome: () => _selectPage(0),
            isMobile: layout.isMobile,
            maxContentWidth: layout.saldifyMaxContentWidth,
            pagePadding: layout.saldifyPagePadding,
            menuButton: menuButton,
          );
  }

  void _selectPage(int index) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAdminName() {
    try {
      final fullName = widget.controllerMain.getNombres().trim();
      if (fullName.isEmpty) return 'Administrador';

      return fullName.split(RegExp(r'\s+')).first;
    } catch (_) {
      return 'Administrador';
    }
  }
}
