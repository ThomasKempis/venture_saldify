import 'package:flutter/material.dart';
import 'package:venture_saldify/smxApis/smxConfig.dart';
import 'package:venture_saldify/smxLayout/smxColors.dart';
import 'package:venture_saldify/smxLayout/smxLayout.dart';
import 'package:venture_saldify/smxPerfil/smxPerfil.dart';

import '../../smxApis/smxConstants.dart';
import '../../smxAuth/smxLogonMovil.dart';

class SmxSaldiFyPerfil extends StatelessWidget {
  final SmxLogonMovil controllerMain = SmxConstants.controllerMain;
  final VoidCallback onBackToHome;
  final VoidCallback onAcceptToHome;
  final SmxLayoutSize layout;

  SmxSaldiFyPerfil({
    super.key,
    required this.onBackToHome,
    required this.onAcceptToHome,
    required this.layout,
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
                    child: _SaldifyPerfilHeader(onBackPressed: onBackToHome),
                  ),
                  const SizedBox(height: 18),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomContentInset),
                      child: SmxPerfil(onNavigateToHome: onAcceptToHome),
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
  final VoidCallback onBackPressed;

  const _SaldifyPerfilHeader({required this.onBackPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SmxSaldifyHeaderIconButton(
          tooltip: 'Regresar',
          icon: Icons.arrow_back_rounded,
          onPressed: onBackPressed,
        ),
        const SizedBox(width: 14),
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
