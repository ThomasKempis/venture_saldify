import 'dart:async';
import 'package:universal_html/html.dart' as html;
import 'package:venture_core_connect/smxConstants_core.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxConstants_widgets.dart';
import '../firebase_options.dart';
import '../smxLogonMovil/logon/smxLogonMovil_controller.dart';

enum SmxServiciosSaldify {
  CHATBOT_IA_SALDIFY
}

abstract class SmxConstants {
  static late SmxLogonMovil_controller controllerMain;
  static SmxRowSet? rstCompraVacia;
  static SmxRowSet? rstPagoVacio;

  static const String codigoInvitacionKey = 'codigo';

  static Map<String, String> startParametersUrl = {};
  static String _uuidAnfitrionInvitacion = '';
  static String _uuidInvitadoInvitacion = '';
  static String _correoInvitadoInvitacion = '';

  static String get correoInvitadoParam {
    return _correoInvitadoInvitacion;
  }

  static String get uuidInvitadoParam {
    return _uuidInvitadoInvitacion;
  }

  static String get uuidAnfitrionParam {
    return _uuidAnfitrionInvitacion;
  }

  static String get codigoInvitacionParam {
    return startParametersUrl[codigoInvitacionKey]?.trim() ?? '';
  }

  static bool get hasCodigoInvitacion {
    return codigoInvitacionParam.isNotEmpty;
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

  static void setClienteInvitado({
    required String uuidAnfitrion,
    String uuidInvitado = '',
    String correoInvitado = '',
  }) {
    _uuidAnfitrionInvitacion = uuidAnfitrion.trim();
    _uuidInvitadoInvitacion = uuidInvitado.trim();
    _correoInvitadoInvitacion = correoInvitado.trim();
  }

  static void clearClienteInvitado() {
    _uuidAnfitrionInvitacion = '';
    _uuidInvitadoInvitacion = '';
    _correoInvitadoInvitacion = '';
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
