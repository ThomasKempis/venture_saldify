import 'dart:async';
import 'package:universal_html/html.dart' as html;
import 'package:venture_core_connect/smxConstants_core.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxApis/smxCodeSegu.dart';
import 'package:venture_widgets/smxConstants_widgets.dart';
import '../firebase_options.dart';
import '../smxAuth/smxLogonMovil.dart';

enum SmxServiciosSaldify { CHATBOT_IA_SALDIFY }

abstract class SmxConstants {
  static const String URL_IMAGES_SALDIFY =
      'https://venture.jars.mx/sovimex/Temps/saldify/';
  static const String URL_IMAGES_PRODUCTOS = '${URL_IMAGES_SALDIFY}SYSUSER41';

  static late SmxLogonMovil controllerMain;

  static SmxRowSet? rstCompraVacia;
  static SmxRowSet? rstPagoVacio;
  static SmxRowSet? rstProductoVacio;
  static SmxRowSet? rstCabeceraVacia;
  static SmxRowSet? rstDetallesVacios;

  static late SmxRowSet rstMetricasAnfitrion;
  static late SmxRowSet rstMetricasCliente;

  static late _SmxInvitacionUrlValidator urlValidator;

  static Future<void> smxAppStartUp({
    required bool produccion,
    required Map<String, String> queryParameters,
  }) async {
    SmxConstants_core.initSetupConnection(produccion);
    urlValidator = _SmxInvitacionUrlValidator(queryParameters);

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

class _SmxInvitacionUrlValidator {
  static const String codigoInvitacionKey = 'codigo';

  final Map<String, String> params;

  const _SmxInvitacionUrlValidator(this.params);

  bool isValida() {
    return SmxGenCodeSeguridad.isValid(codigo);
  }

  SmxSaldiFyInvitaStatus? getUrlTipo() {
    return SmxGenCodeSeguridad.getUrlTipo(codigo);
  }

  String get codigoKey => codigoInvitacionKey;

  String get codigo {
    return params[codigoInvitacionKey]?.trim().toUpperCase() ?? '';
  }
}
