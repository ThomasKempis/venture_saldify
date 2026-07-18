import 'package:flutter/material.dart';
import 'package:venture_saldify/smxLayout/smx_message_dialog.dart';
import 'package:flutter/services.dart';
import 'package:venture_core_connect/smxConstants_core.dart';
import 'package:venture_saldify/smxApis/smxConfig.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';
import 'package:universal_html/html.dart' as html;

import '../../smxApis/smxConstants.dart';
import '../smxSaldify/smxSaldify_dashboard/smxSaldiFy_invita_clientes/smxSaldiFy_invita_service.dart';

class SmxSaldifyLogonController extends SmxController {
  static const welcomeAsset = 'assets/images/saldify_invitation_welcome.png';
  static const welcomeAssetHd =
      'assets/images/saldify_invitation_welcome_hd.png';
  static const _codigoStorageKey = 'saldify_codigo_invitado';
  static const _uuidAnfitrionStorageKey = 'saldify_uuid_anfitrion';
  static const _correoInvitadoStorageKey = 'saldify_correo_invitado';
  static const _uuidInvitadoStorageKey = 'saldify_uuid_invitado';

  late final TextEditingController codigoController;

  String? codigoError;
  String? _precachedWelcomeAsset;
  bool contentReady = false;
  bool _disposed = false;
  bool hasCodigoInicialValido = false;
  bool _validandoCodigo = false;

  SmxSaldifyLogonController({
    required super.alias,
    required super.data,
    String codigoInicial = '',
  }) {
    SmxConstants_core.instancia = "SALDIFY";
    resetJsonSend();

    hasCodigoInicialValido = SmxCodeInvitado.isValid(codigoInicial);

    final codigoInicialTmp = hasCodigoInicialValido
        ? SmxCodeInvitado.normalizar(codigoInicial)
        : _codigoGuardado;

    codigoController = TextEditingController(text: codigoInicialTmp);
  }

  static Future<void> warmUpAssets() async {
    await Future.wait([
      rootBundle.load(SmxConfig.logoPath),
      rootBundle.load(welcomeAsset),
    ]);
  }

  String getWelcomeAsset(double width) {
    return width < 900 ? welcomeAsset : welcomeAssetHd;
  }

  Future<void> precacheAssets(BuildContext context) async {
    final welcomeAsset = getWelcomeAsset(MediaQuery.sizeOf(context).width);

    if (_precachedWelcomeAsset == welcomeAsset) return;

    _precachedWelcomeAsset = welcomeAsset;
    contentReady = false;
    _notify();

    await Future.wait([
      precacheImage(AssetImage(SmxConfig.logoPath), context),
      precacheImage(AssetImage(welcomeAsset), context),
    ]);

    if (_disposed || _precachedWelcomeAsset != welcomeAsset) return;

    contentReady = true;
    _notify();
  }

  void clearCodigoError() {
    if (codigoError == null) return;
    codigoError = null;
    _notify();
  }

  String? validarFormatoCodigo() {
    final codigo = SmxCodeInvitado.normalizar(codigoController.text);

    if (!SmxCodeInvitado.isValid(codigo)) {
      codigoError = 'Ingresa un código válido';
      _notify();
      return null;
    }

    codigoController.text = codigo;
    codigoError = null;
    _notify();
    return codigo;
  }

  Future<bool> validarCodigoAutenticado(
    String codigo,
    String correoGoogle, {
    required String uuidUsuario,
  }) async {
    if (_validandoCodigo) return false;
    _validandoCodigo = true;

    try {
      await showDialogWait(data.context!, () async {
        codigoError = await isValidaIntoDataBase(
          codigo,
          correoGoogle: correoGoogle,
          uuidUsuario: uuidUsuario,
        );
      });
    } finally {
      _validandoCodigo = false;
    }

    if (codigoError == null) {
      return true;
    }

    _notify();
    return false;
  }

  bool cargarInvitadoGuardado(BuildContext context) {
    final codigo = _codigoGuardado;
    final uuidAnfitrion =
        html.window.localStorage[_uuidAnfitrionStorageKey]?.trim() ?? '';
    final correoInvitado =
        html.window.localStorage[_correoInvitadoStorageKey]?.trim() ?? '';
    final uuidInvitado =
        html.window.localStorage[_uuidInvitadoStorageKey]?.trim() ?? '';

    if (codigo.isEmpty ||
        uuidAnfitrion.isEmpty ||
        (correoInvitado.isEmpty && uuidInvitado.isEmpty) ||
        (correoInvitado.isNotEmpty && uuidInvitado.isNotEmpty)) {
      SmxConstants.clearClienteInvitado();
      showSmxValidDialog(
        context,
        mensaje: 'No hay datos de cliente invitado guardados.',
      );
      return false;
    }

    SmxConstants.setClienteInvitado(
      uuidAnfitrion: uuidAnfitrion,
      correoInvitado: correoInvitado,
      uuidInvitado: uuidInvitado,
    );
    return true;
  }

  Future<String?> isValidaIntoDataBase(
    String codigo, {
    String? correoGoogle,
    String? uuidUsuario,
  }) async {
    final alias = 'SYSUSER90';
    final codigoNormalizado = SmxCodeInvitado.normalizar(codigo);
    final codigoSql = _sql(codigoNormalizado);
    final uuidSql = _sql(uuidUsuario?.trim() ?? '');
    final correoSql = _sql(correoGoogle?.trim().toLowerCase() ?? '');

    SmxConstants.clearClienteInvitado();
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

      final uuidAnfitrion =
          rst.getValue('SYSUSER90_ANFITRION_UUID')?.toString().trim() ?? '';
      final correoInvitado =
          rst.getValue('SYSUSER90_INVITADO_CORREO')?.toString().trim() ?? '';
      final uuidInvitado =
          rst.getValue('SYSUSER90_INVITADO_UUID')?.toString().trim() ?? '';

      final correoAutenticado = correoGoogle?.trim().toLowerCase() ?? '';

      if (correoInvitado.isNotEmpty &&
          correoAutenticado.isNotEmpty &&
          correoInvitado.toLowerCase() != correoAutenticado) {
        SmxConstants.clearClienteInvitado();
        return 'El código no corresponde a la cuenta de Google seleccionada';
      }

      final uuidAutenticado = uuidUsuario?.trim().toLowerCase() ?? '';
      if (uuidInvitado.isNotEmpty &&
          uuidAutenticado.isNotEmpty &&
          uuidInvitado.toLowerCase() != uuidAutenticado) {
        SmxConstants.clearClienteInvitado();
        return 'El código no corresponde al usuario autenticado';
      }

      if (uuidAnfitrion.isEmpty ||
          (correoInvitado.isEmpty && uuidInvitado.isEmpty)) {
        SmxConstants.clearClienteInvitado();
        return 'El código de invitación no tiene datos válidos';
      }

      SmxConstants.setClienteInvitado(
        uuidAnfitrion: uuidAnfitrion,
        correoInvitado: correoInvitado,
        uuidInvitado: uuidInvitado,
      );
      _guardarInvitado(
        codigo: codigoNormalizado,
        uuidAnfitrion: uuidAnfitrion,
        correoInvitado: correoInvitado,
        uuidInvitado: uuidInvitado,
      );

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

  static String get _codigoGuardado {
    final codigo = html.window.localStorage[_codigoStorageKey] ?? '';
    if (!SmxCodeInvitado.isValid(codigo)) return '';
    return SmxCodeInvitado.normalizar(codigo);
  }

  static String _sql(String value) {
    return value.replaceAll("'", "''");
  }

  static void _guardarInvitado({
    required String codigo,
    required String uuidAnfitrion,
    required String correoInvitado,
    required String uuidInvitado,
  }) {
    html.window.localStorage[_codigoStorageKey] = codigo;
    html.window.localStorage[_uuidAnfitrionStorageKey] = uuidAnfitrion;
    html.window.localStorage[_correoInvitadoStorageKey] = correoInvitado;
    html.window.localStorage[_uuidInvitadoStorageKey] = uuidInvitado;
  }

  @override
  void dispose() {
    _disposed = true;
    codigoController.dispose();
    super.dispose();
  }
}
