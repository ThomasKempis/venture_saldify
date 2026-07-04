import 'package:flutter/material.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

import '../../../smxSaldifyLogon/smxSaldifyCodeInvitado.dart';
import 'smxSaldiFy_invita_clientes_models.dart';
import 'smxSaldiFy_invita_modal.dart';

class SmxSaldiFyInvitaClientesController extends SmxController {
  static const String _aliasAddCodigo = 'ADD_SYSUSER90_SALDIFY';
  static const int _maxIntentosCodigo = 5;
  static const String saldifyInviteBaseUrl =
      'https://venture.jars.mx/venture_saldify';

  SmxSaldiFyInvitaAction selectedAction = SmxSaldiFyInvitaAction.copiarLink;

  SmxSaldiFyInvitaClientesController({
    required super.alias,
    required super.data,
  });

  @override
  Future<void> init() async {
    if (isBeginDB()) return;
    beginDB();
  }

  Future<void> openCopyLinkModal({
    required BuildContext context,
    required String uuidAnfitrion,
    required String anfitrionNombre,
    required SmxRowSet? clientes,
  }) async {
    _setAction(SmxSaldiFyInvitaAction.copiarLink);

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
    _setAction(SmxSaldiFyInvitaAction.whatsApp);

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
      onCreateInvite: crearInvitacion,
    );
  }

  Future<SmxSaldiFyInvitacionGenerada?> crearInvitacion({
    required String uuidAnfitrion,
    String correoInvitado = '',
    String uuidInvitado = '',
    String telefono = '',
  }) async {
    final context = data.context;
    if (context == null) return null;

    final uuidAnfitrionClean = uuidAnfitrion.trim();
    final correoInvitadoClean = correoInvitado.trim().toLowerCase();
    final uuidInvitadoClean = uuidInvitado.trim();

    if (uuidAnfitrionClean.isEmpty) {
      showValidDialog(context, mensaje: 'No se encontro el anfitrion.');
      return null;
    }

    final hasCorreo = correoInvitadoClean.isNotEmpty;
    final hasUuid = uuidInvitadoClean.isNotEmpty;
    if (hasCorreo == hasUuid) {
      showValidDialog(
        context,
        mensaje: 'Debe enviar correo o UUID del invitado.',
      );
      return null;
    }

    SmxSaldiFyInvitacionGenerada? invitacion;

    await showDialogWait(context, () async {
      invitacion = await _crearInvitacionLoop(
        uuidAnfitrion: uuidAnfitrionClean,
        correoInvitado: correoInvitadoClean,
        uuidInvitado: uuidInvitadoClean,
        telefono: telefono,
      );
    });

    if (jsonSend.getError() != null) {
      if (context.mounted) {
        showSystemErrorDialog(context, message: jsonSend.error!);
      }
      return null;
    }

    if (invitacion == null && context.mounted) {
      showSystemErrorDialog(
        context,
        message: 'No se pudo generar el codigo de invitacion.',
      );
    }

    return invitacion;
  }

  Future<SmxSaldiFyInvitacionGenerada?> _crearInvitacionLoop({
    required String uuidAnfitrion,
    required String correoInvitado,
    required String uuidInvitado,
    required String telefono,
  }) async {
    for (var intento = 0; intento < _maxIntentosCodigo; intento++) {
      final codigo = SmxCodeInvitado.generar();
      final status = await _reservarCodigoInvitacion(
        codigo: codigo,
        uuidAnfitrion: uuidAnfitrion,
        correoInvitado: correoInvitado,
        uuidInvitado: uuidInvitado,
      );

      if (jsonSend.getError() != null) return null;

      if (status == 'OK') {
        return _buildInvitacionGenerada(codigo: codigo, telefono: telefono);
      }

      if (status == 'DUPLICADO') {
        continue;
      }

      return null;
    }

    return null;
  }

  Future<String> _reservarCodigoInvitacion({
    required String codigo,
    required String uuidAnfitrion,
    required String correoInvitado,
    required String uuidInvitado,
  }) async {
    addSTrans(
      _aliasAddCodigo,
      "select * from ADD_SYSUSER90_SALDIFY("
      "'${_sql(codigo)}', "
      "'${_sql(uuidAnfitrion)}', "
      "'${_sql(correoInvitado)}', "
      "'${_sql(uuidInvitado)}')",
    );

    await getCallWS();

    if (jsonSend.getError() != null) return '';

    final rst = getRowset(_aliasAddCodigo);
    if (rst.getRowCount() == 0) return '';

    rst.first();
    return rst.getValue('TMPUSER99_STATUS');
  }

  SmxSaldiFyInvitacionGenerada _buildInvitacionGenerada({
    required String codigo,
    required String telefono,
  }) {
    final codigoNormalizado = SmxCodeInvitado.normalizar(codigo);

    return SmxSaldiFyInvitacionGenerada(
      codigo: codigoNormalizado,
      codigoFormato: SmxCodeInvitado.format(codigoNormalizado),
      link: _buildCodigoInviteLink(codigoNormalizado),
      telefono: telefono,
    );
  }

  String _buildCodigoInviteLink(String codigo) {
    return Uri.parse(saldifyInviteBaseUrl)
        .replace(queryParameters: {SmxConstants.codigoInvitacionKey: codigo})
        .toString();
  }

  String _sql(String value) {
    return value.trim().replaceAll("'", "''");
  }

  void _setAction(SmxSaldiFyInvitaAction action) {
    selectedAction = action;
    notifyListeners();
  }

  @override
  Future<void> save() async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}
}
