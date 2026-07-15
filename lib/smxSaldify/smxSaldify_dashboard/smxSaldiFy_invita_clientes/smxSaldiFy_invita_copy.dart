import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smx_message_dialog.dart';
import 'package:flutter/services.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

import 'smxSaldiFy_invita_clientes_models.dart';
import 'smxSaldiFy_invita_service.dart';

class SmxSaldifyInvitaCopy {
  const SmxSaldifyInvitaCopy._();

  static Future<void> copyInvitadoRegistradoLink({
    required BuildContext context,
    required String uuidInvitado,
    bool closeContextOnSuccess = false,
  }) async {
    if (uuidInvitado.trim().isEmpty) {
      showSmxValidDialog(
        context,
        mensaje: 'El cliente no tiene UUID para generar invitacion.',
      );
      return;
    }

    SmxSaldiFyInvitacionGenerada? invitacion;

    await showDialogWait(context, () async {
      invitacion = await SmxSaldifyInvitaService.crearInvitacion(
        controller: SmxConstants.controllerMain,
        parametros: SmxSaldifyInvitacionParametros.invitadoRegistrado(
          uuidAnfitrion: SmxConstants.controllerMain.getUuid(),
          uuidInvitado: uuidInvitado,
        ),
      );
    });

    final error = SmxConstants.controllerMain.jsonSend.getError();
    if (error != null) {
      if (context.mounted) {
        showSmxSystemErrorDialog(context, message: error);
      }
      return;
    }

    final invite = invitacion;
    if (invite == null || !context.mounted) return;

    await Clipboard.setData(ClipboardData(text: invite.link));
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (closeContextOnSuccess) {
      navigator.pop();
    }

    messenger.showSnackBar(
      const SnackBar(content: Text('Link de invitacion copiado.')),
    );
  }
}
