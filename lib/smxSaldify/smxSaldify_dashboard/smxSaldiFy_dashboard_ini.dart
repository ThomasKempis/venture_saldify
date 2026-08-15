import 'package:flutter/material.dart';

import 'package:venture_saldify/smxLayout/smxBackgrounds/cliente_bg_inicio.dart';
import 'smxSaldiFy_invita_clientes/smxSaldiFy_invita_clientes.dart';

class SmxSaldiFyDashboardIni extends StatelessWidget {
  final bool isMobile;
  final VoidCallback onContinue;
  final VoidCallback onArchivados;
  final String uuidAnfitrion;
  final String anfitrionNombre;

  const SmxSaldiFyDashboardIni({
    super.key,
    required this.isMobile,
    required this.onContinue,
    required this.onArchivados,
    required this.uuidAnfitrion,
    required this.anfitrionNombre,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SmxSaldiFyInvitaClientes(
          uuidAnfitrion: uuidAnfitrion,
          anfitrionNombre: anfitrionNombre,
        ),
        SizedBox(height: isMobile ? 24 : 30),
        ClienteBgInicio(
          isMobile: isMobile,
          onContinue: onContinue,
          onArchivados: onArchivados,
        ),
      ],
    );
  }
}
