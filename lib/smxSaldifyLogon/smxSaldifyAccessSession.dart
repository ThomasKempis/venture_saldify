import 'package:universal_html/html.dart' as html;

enum SmxSaldifyAccessMode {
  anfitrion('anfitrion'),
  invitado('invitado');

  final String value;

  const SmxSaldifyAccessMode(this.value);
}

class SmxSaldifyAccessSession {
  static const _ultimoModoKey = 'saldify_ultimo_modo';
  static const _anfitrionCorreoKey = 'saldify_anfitrion_correo';
  static const _invitadoCorreoKey = 'saldify_invitado_google_correo';

  const SmxSaldifyAccessSession._();

  static SmxSaldifyAccessMode? get ultimoModo {
    final value = html.window.localStorage[_ultimoModoKey];

    for (final mode in SmxSaldifyAccessMode.values) {
      if (mode.value == value) return mode;
    }

    return null;
  }

  static String get anfitrionCorreo {
    return html.window.localStorage[_anfitrionCorreoKey]?.trim() ?? '';
  }

  static String get invitadoCorreo {
    return html.window.localStorage[_invitadoCorreoKey]?.trim() ?? '';
  }

  static void markActive(SmxSaldifyAccessMode mode, String correo) {
    final cleanCorreo = correo.trim().toLowerCase();

    html.window.localStorage[_ultimoModoKey] = mode.value;

    if (mode == SmxSaldifyAccessMode.anfitrion) {
      html.window.localStorage[_anfitrionCorreoKey] = cleanCorreo;
    } else {
      html.window.localStorage[_invitadoCorreoKey] = cleanCorreo;
    }
  }
}
