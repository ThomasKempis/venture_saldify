import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_widgets/smxCallBaseStateful.dart';
import 'package:venture_widgets/smxController/smxControllerSendData.dart';
import '../smxSaldify/smxSaldify_screens/smxSaldiFy_perfil.dart';
import '../smxSaldifyAssistant/smxSaldifyAssistant.dart';
import '../smxSaldifyAssistant/smxSaldifyAssistant_context.dart';
import 'package:venture_saldify/smxSaldify/smxSaldify_screens/saldify_lealtad/smxSaldiFy_lealtad.dart';
import 'smxSaldiFyCliente_controller.dart';
import 'smxSaldiFyCliente_menu_lateral.dart';
import 'smxSaldifyCliente_dashboard/smxSaldiFyCliente_dashboard.dart';
import 'smxSaldifyCliente_screens/saldify_invitacion/smx_saldify_cliente_invitacion_estado.dart';

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
          return SmxSaldiFyClienteInvitacionEstado(
            title: controller.tituloValidacion,
            mensaje: mensajeValidacion,
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
    final pageIndex = _selectedIndex >= 0 && _selectedIndex <= 2
        ? _selectedIndex
        : 0;

    return SmxSaldifyAssistantHost(
      role: SmxSaldifyAssistantRole.invitado,
      screen: pageIndex == 0
          ? SmxSaldifyAssistantScreen.dashboardCliente
          : SmxSaldifyAssistantScreen.perfilCliente,
      isMobile: layout.isMobile,
      showFloatingLauncher: pageIndex != 0,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Dashboard del cliente: Persistente para que el botón atrás sea instantáneo
          Offstage(
            offstage: pageIndex != 0,
            child: SmxSaldiFyClienteDashboard(
              key: ValueKey(
                  'saldify-cliente-dashboard-$_dashboardRefreshRevision'),
              controller: controller,
              layout: layout,
              menuButton: menuButton,
              onRefresh: _refreshDashboard,
            ),
          ),

          // Perfil: Atómico (se destruye al salir)
          if (pageIndex == 1)
            SmxSaldiFyPerfil(
              onBackToHome: () => _selectPage(0),
              onAcceptToHome: _selectHomeAndRefreshDashboard,
              layout: layout,
            ),

          // Lealtad: Atómico (se destruye al salir)
          if (pageIndex == 2)
            SmxSaldiFyLealtad(
              onBackPressed: () => _selectPage(0),
            ),
        ],
      ),
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

    await Future<void>.delayed(const Duration(milliseconds: 350));
  }

  void _selectHomeAndRefreshDashboard() {
    setState(() {
      _selectedIndex = 0;
      _dashboardRefreshRevision++;
    });
  }
}
