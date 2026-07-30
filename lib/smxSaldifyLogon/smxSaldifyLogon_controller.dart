import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:venture_core_connect/smxConstants_core.dart';
import 'package:venture_saldify/smxApis/smxConfig.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';

import '../../smxApis/smxConstants.dart';

class SmxSaldifyLogonController extends SmxController {
  String? codigoError;
  Image? welcomeImage;
  bool? _precachedWelcomeHd;
  bool contentReady = false;
  bool _disposed = false;
  bool _validandoCodigo = false;
  String _uuidAnfitrionValidado = '';

  SmxSaldifyLogonController({required super.alias, required super.data}) {
    SmxConstants_core.instancia = "SALDIFY";
    resetJsonSend();
  }

  static Future<void> warmUpAssets() async {
    await Future.wait([
      rootBundle.load(SmxConfig.logoPath),
      SmxConfig.invitationWelcomeImage(hd: false),
    ]);
  }

  Future<void> precacheAssets(BuildContext context) async {
    final welcomeHd = MediaQuery.sizeOf(context).width >= 900;

    if (_precachedWelcomeHd == welcomeHd) return;

    _precachedWelcomeHd = welcomeHd;
    contentReady = false;
    _notify();

    final logoFuture = precacheImage(AssetImage(SmxConfig.logoPath), context);
    final resolvedWelcomeImage = await SmxConfig.invitationWelcomeImage(
      hd: welcomeHd,
      fit: BoxFit.contain,
    );

    final futures = <Future<void>>[logoFuture];
    if (resolvedWelcomeImage != null) {
      if (!context.mounted) return;
      futures.add(precacheImage(resolvedWelcomeImage.image, context));
    }

    await Future.wait(futures);

    if (_disposed || _precachedWelcomeHd != welcomeHd) return;

    welcomeImage = resolvedWelcomeImage;
    contentReady = true;
    _notify();
  }

  bool get isInvitacionUrlValida => SmxConstants.urlValidator.isValida();

  String get codigoUrl {
    return SmxConstants.urlValidator.codigo;
  }

  String get uuidAnfitrionValidado => _uuidAnfitrionValidado;

  Future<bool> validarInvitacionUrl(
    String correoGoogle, {
    required String uuidUsuario,
  }) async {
    if (_validandoCodigo) return false;
    _validandoCodigo = true;
    _uuidAnfitrionValidado = '';

    try {
      codigoError = await _actualizarInvitacion(
        codigo: codigoUrl,
        correoGoogle: correoGoogle,
        uuidUsuario: uuidUsuario,
      );
    } finally {
      _validandoCodigo = false;
    }

    if (codigoError == null) {
      return true;
    }

    _notify();
    return false;
  }

  Future<String?> _actualizarInvitacion({
    required String codigo,
    required String correoGoogle,
    required String uuidUsuario,
  }) async {
    final alias = 'SYSUSER90';
    final codigoSql = _sql(codigo);
    final uuidSql = _sql(uuidUsuario.trim());
    final correoSql = _sql(correoGoogle.trim().toLowerCase());

    removeSql(alias);

    addSTrans(
      alias,
      "SELECT * FROM UPDATE_SYSUSER90("
      "'$codigoSql', "
      "'$uuidSql', "
      "'$correoSql')",
    );

    try {
      await getCallWS();
      final rst = getRowset(alias);

      if (jsonSend.getError() != null) {
        return jsonSend.error;
      }

      if (rst.getRowCount() == 0) {
        return 'El código de invitación no existe';
      }

      rst.first();

      final uuidAnfitrion = rst.getValue('SYSUSER90_ANFITRION_UUID');
      final correoInvitado = rst.getValue('SYSUSER90_INVITADO_CORREO');
      final uuidInvitado = rst.getValue('SYSUSER90_INVITADO_UUID');

      if (!(uuidAnfitrion.isNotEmpty &&
          correoInvitado.isNotEmpty &&
          uuidInvitado.isNotEmpty)) {
        return 'El código de invitación no tiene datos válidos';
      }

      if (correoInvitado.toLowerCase() != correoGoogle.trim().toLowerCase()) {
        return 'El código no corresponde a la cuenta de Google seleccionada';
      }

      if (uuidInvitado.toLowerCase() != uuidUsuario.trim().toLowerCase()) {
        return 'El código no corresponde al usuario autenticado';
      }

      _uuidAnfitrionValidado = uuidAnfitrion;

      return null;
    } catch (e) {
      return 'Error de conexión con el servidor';
    }
  }

  @override
  Future<void> init() async {}

  @override
  Future<void> save() async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}

  void _notify() {
    if (_disposed) return;
    notifyListeners();
  }

  static String _sql(String value) {
    return value.replaceAll("'", "''");
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
