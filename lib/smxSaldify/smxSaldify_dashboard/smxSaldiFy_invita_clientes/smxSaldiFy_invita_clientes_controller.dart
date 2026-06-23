import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

import 'smxSaldiFy_invita_modal.dart';

class SmxSaldiFyInvitaClientesController {
  final ValueNotifier<SmxSaldiFyInvitaAction> actionNotifier =
      ValueNotifier<SmxSaldiFyInvitaAction>(SmxSaldiFyInvitaAction.copiarLink);

  void dispose() {
    actionNotifier.dispose();
  }

  Future<void> openCopyLinkModal({
    required BuildContext context,
    required String uuidAnfitrion,
    required String anfitrionNombre,
    required SmxRowSet? clientes,
  }) async {
    actionNotifier.value = SmxSaldiFyInvitaAction.copiarLink;

    await _openInviteModal(
      context: context,
      uuidAnfitrion: uuidAnfitrion,
      anfitrionNombre: anfitrionNombre,
      action: SmxSaldiFyInvitaAction.copiarLink,
      clientes: clientes,
    );
  }

  Future<void> openWhatsAppModal({
    required BuildContext context,
    required String uuidAnfitrion,
    required String anfitrionNombre,
    required SmxRowSet? clientes,
  }) async {
    actionNotifier.value = SmxSaldiFyInvitaAction.whatsApp;

    await _openInviteModal(
      context: context,
      uuidAnfitrion: uuidAnfitrion,
      anfitrionNombre: anfitrionNombre,
      action: SmxSaldiFyInvitaAction.whatsApp,
      clientes: clientes,
    );
  }

  Future<void> _openInviteModal({
    required BuildContext context,
    required String uuidAnfitrion,
    required String anfitrionNombre,
    required SmxSaldiFyInvitaAction action,
    required SmxRowSet? clientes,
  }) {
    return showSmxSaldiFyInvitaModal(
      context: context,
      uuidAnfitrion: uuidAnfitrion,
      anfitrionNombre: anfitrionNombre,
      action: action,
      clientes: clientes,
    );
  }
}
