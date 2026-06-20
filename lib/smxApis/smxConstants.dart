import 'dart:async';
import 'package:universal_html/html.dart' as html;
import 'package:venture_core_connect/smxConstants_core.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxConstants_widgets.dart';
import '../firebase_options.dart';
import '../smxLogonMovil/logon/smxLogonMovil_controller.dart';

enum SmxInvitacionMode { admin, uuid_invitado, correo_invitado }

abstract class SmxConstants {
  static late SmxLogonMovil_controller controllerMain;
  static SmxRowSet? rstCompraVacia;
  static SmxRowSet? rstPagoVacio;

  static const String uuidInvitadoKey = 'uuid_invitado';
  static const String correoInvitadoKey = 'correo_invitado';
  static const String uuidAnfitrionKey = 'uuid_anfitrion';

  static Map<String, String> startParametersUrl = {};

  static String get correoInvitadoParam {
    return startParametersUrl[correoInvitadoKey]?.trim() ?? '';
  }

  static String get uuidInvitadoParam {
    return startParametersUrl[uuidInvitadoKey]?.trim() ?? '';
  }

  static String get uuidAnfitrionParam {
    return startParametersUrl[uuidAnfitrionKey]?.trim() ?? '';
  }

  static bool get hasUuidInvitado {
    return uuidAnfitrionParam.isNotEmpty &&
        uuidInvitadoParam.isNotEmpty &&
        correoInvitadoParam.isEmpty;
  }

  static bool get hasCorreoInvitado {
    return uuidAnfitrionParam.isNotEmpty &&
        correoInvitadoParam.isNotEmpty &&
        uuidInvitadoParam.isEmpty;
  }

  static bool get isClienteInvitado {
    return hasUuidInvitado || hasCorreoInvitado;
  }

  static SmxInvitacionMode get invitacionMode {
    if (hasUuidInvitado) return SmxInvitacionMode.uuid_invitado;
    if (hasCorreoInvitado) return SmxInvitacionMode.correo_invitado;

    return SmxInvitacionMode.admin;
  }

  static bool get hasParametrosInvitacionInvalidos {
    final hasAnyParam =
        uuidAnfitrionParam.isNotEmpty ||
        uuidInvitadoParam.isNotEmpty ||
        correoInvitadoParam.isNotEmpty;

    return hasAnyParam && !isClienteInvitado;
  }

  static Future<void> smxAppStartUp({
    required bool produccion,
    required Map<String, String> queryParameters,
  }) async {
    SmxConstants_core.initSetupConnection(produccion);

    startParametersUrl = queryParameters;

    // Deshabilita que se pueda hacer drag and drop sobre la pagina de la aplicaccion
    // Excepto que crees tu propia área para recibir el archivo enviado
    html.window.addEventListener("dragover", (event) => event.preventDefault());
    html.window.addEventListener("drop", (event) => event.preventDefault());

    Completer<void> completer = Completer<void>();

    try {
      await SmxConstants_widgets.startUpFireAuth(
        DefaultFirebaseOptions.currentPlatform,
      );

      // ================================================================================================ //

      completer.complete();
    } catch (error) {
      completer.completeError(error);
    }
  }
}
