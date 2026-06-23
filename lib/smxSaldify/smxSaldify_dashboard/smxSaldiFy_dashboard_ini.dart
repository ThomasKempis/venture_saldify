import 'package:flutter/material.dart';

import '../smxSaldify_screens/smxSaldify_backgrounds/cliente_bg_inicio.dart';

class SmxSaldiFyDashboardIni extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onContinue;

  const SmxSaldiFyDashboardIni({
    super.key,
    required this.isMobile,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return ClienteBgInicio(isMobile: isMobile, onContinue: onContinue);
  }
}
