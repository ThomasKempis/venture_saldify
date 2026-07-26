import 'package:flutter/material.dart';
import 'package:venture_saldify/smxApis/smxConfig.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxPerfil/smxPerfil.dart';

import '../../smxApis/smxConstants.dart';
import '../../smxAuth/smxLogonMovil.dart';

class SmxSaldiFyPerfil extends StatelessWidget {
  final SmxLogonMovil controllerMain = SmxConstants.controllerMain;
  final VoidCallback onNavigateToHome;
  final SmxLayoutSize layout;
  final Widget? menuButton;

  SmxSaldiFyPerfil({
    super.key,
    required this.onNavigateToHome,
    required this.layout,
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
              constraints: BoxConstraints(
                maxWidth: layout.saldifyMaxContentWidth,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      layout.saldifyPagePadding.left,
                      layout.saldifyPagePadding.top + topContentInset,
                      layout.saldifyPagePadding.right,
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
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: SizedBox(
            width: 34,
            height: 34,
            child: SmxConfig.logo(fit: BoxFit.contain),
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
