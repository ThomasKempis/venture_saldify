import 'package:flutter/material.dart';
import 'package:venture_saldify/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxPerfil/smxPerfil.dart';

import '../../smxApis/smxConstants.dart';
import '../../smxLogonMovil/logon/smxLogonMovil_controller.dart';

class SmxSaldiFyPerfil extends StatelessWidget {
  final SmxLogonMovil_controller controllerMain = SmxConstants.controllerMain;
  final VoidCallback onNavigateToHome;
  final bool isMobile;
  final double maxContentWidth;
  final EdgeInsets pagePadding;
  final Widget? menuButton;

  SmxSaldiFyPerfil({
    super.key,
    required this.onNavigateToHome,
    required this.isMobile,
    required this.maxContentWidth,
    required this.pagePadding,
    this.menuButton,
  });

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
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      pagePadding.left,
                      pagePadding.top + topContentInset,
                      pagePadding.right,
                      0,
                    ),
                    child: _SaldifyPerfilHeader(menuButton: menuButton),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomContentInset),
                      child: SmxPerfil(onNavigateToHome: onNavigateToHome),
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

class _SaldifyPerfilHeader extends StatelessWidget {
  final Widget? menuButton;

  const _SaldifyPerfilHeader({this.menuButton});

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
          child: Text(
            'Perfil',
            style: TextStyle(
              color: SmxColors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}
