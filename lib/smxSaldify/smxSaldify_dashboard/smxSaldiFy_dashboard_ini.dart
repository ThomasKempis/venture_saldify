import 'package:flutter/material.dart';

import '../smxSaldify_screens/smxSaldify_backgrounds/cliente_bg_inicio.dart';

class SmxSaldiFyDashboardIni extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onContinue;
  final VoidCallback onArchivados;

  const SmxSaldiFyDashboardIni({
    super.key,
    required this.isMobile,
    required this.onContinue,
    required this.onArchivados,
  });

  @override
  Widget build(BuildContext context) {
    return ClienteBgInicio(
      isMobile: isMobile,
      onContinue: onContinue,
      onArchivados: onArchivados,
    );
  }
}
