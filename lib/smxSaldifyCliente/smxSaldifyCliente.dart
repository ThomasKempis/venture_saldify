import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';
import '../smxLayout/smxScreenTmp.dart';
import '../smxSaldify/smxSaldify_screens/smxSaldiFy_perfil.dart';
import 'smxSaldiFyCliente_controller.dart';
import 'smxSaldiFyCliente_menu_lateral.dart';
import 'smxSaldifyCliente_dashboard/smxSaldiFyCliente_dashboard.dart';

class SmxSaldiFyCliente extends StatefulWidget {
  const SmxSaldiFyCliente({super.key});

  @override
  State<SmxSaldiFyCliente> createState() => _SmxSaldiFyClienteState();
}

class _SmxSaldiFyClienteState extends State<SmxSaldiFyCliente> {
  int _selectedIndex = 0;
  int _dashboardRefreshRevision = 0;

  @override
  Widget build(BuildContext context) {
    return SmxCallBaseStateful<SmxSaldiFyClienteController>(
      controllerBuilder: (context) => SmxSaldiFyClienteController(
        alias: 'SMXSALDIFY_CLIENTE',
        data: SmxControllerSendData(context: context),
      ),
      builder: (context, controller) {
        final mensajeValidacion = controller.mensajeValidacion;

        if (mensajeValidacion != null) {
          return SmxSaldiFyScreenTmp(
            title: 'Validacion de invitacion',
            mensaje: mensajeValidacion,
            btoBack: false,
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final layout = SmxLayout.sizeFromWidth(constraints.maxWidth);

            if (layout.isMobile) {
              return Scaffold(
                backgroundColor: SmxColors.transparent,
                extendBody: true,
                extendBodyBehindAppBar: true,
                drawer: SmxSaldiFyClienteDrawer(
                  selectedIndex: _selectedIndex,
                  onSelect: _selectPage,
                ),
                body: Builder(
                  builder: (context) {
                    final menuButton = SmxSaldiFyClienteMenuButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    );

                    return _buildPage(
                      controller: controller,
                      layout: layout,
                      menuButton: menuButton,
                    );
                  },
                ),
              );
            }

            final page = _buildPage(controller: controller, layout: layout);

            return Scaffold(
              backgroundColor: SmxColors.transparent,
              extendBody: true,
              extendBodyBehindAppBar: true,
              body: Row(
                children: [
                  SmxSaldiFyClienteNavigationPanel(
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
      },
    );
  }

  Widget _buildPage({
    required SmxSaldiFyClienteController controller,
    required SmxLayoutSize layout,
    Widget? menuButton,
  }) {
    return _selectedIndex == 0
        ? SmxSaldiFyClienteDashboard(
            key: ValueKey(
              'saldify-cliente-dashboard-$_dashboardRefreshRevision',
            ),
            controller: controller,
            isMobile: layout.isMobile,
            isDesktop: layout.isDesktop,
            maxContentWidth: layout.saldifyMaxContentWidth,
            pagePadding: layout.saldifyPagePadding,
            menuButton: menuButton,
            onRefresh: _refreshDashboard,
          )
        : SmxSaldiFyPerfil(
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

  Future<void> _refreshDashboard() async {
    setState(() {
      _dashboardRefreshRevision++;
    });

    await Future<void>.delayed(const Duration(milliseconds: 350));
  }
}
