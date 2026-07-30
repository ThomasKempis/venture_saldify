import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum SmxBrand { saldify, redventas, redcontrol }

abstract class SmxConfig {
  static const String _invitationWelcomeFile = 'saldify_invitation_welcome.png';
  static const String _invitationWelcomeHdFile =
      'saldify_invitation_welcome_hd.png';
  static final Map<String, Future<bool>> _assetExistsCache = {};

  /// Detecta el modo de la aplicación inyectado durante la compilación.
  /// Ejemplo: flutter build web --dart-define=APP_MODE=redventas
  static const String appModeConst = String.fromEnvironment(
    'APP_MODE',
    defaultValue: 'saldify',
  );

  /// Devuelve el modo actual ('saldify' o 'redventas')
  static String get appMode => appModeConst;

  /// Marca activa segun el modo de compilacion.
  static const SmxBrand brand = appModeConst == 'redventas'
      ? SmxBrand.redventas
      : appModeConst == 'redcontrol'
      ? SmxBrand.redcontrol
      : SmxBrand.saldify;

  /// Rutas dinámicas (String) para casos donde se necesite el path directamente
  static String get logoPath => 'assets/images/$appModeConst/logo.png';
  static String get logoCabPath => 'assets/images/$appModeConst/logo_cab.png';

  static Future<Image?> invitationWelcomeImage({
    required bool hd,
    BoxFit fit = BoxFit.contain,
    double? width,
    double? height,
  }) async {
    final file = hd ? _invitationWelcomeHdFile : _invitationWelcomeFile;
    final path = 'assets/images/$appModeConst/$file';

    if (!await _assetExists(path)) return null;

    return Image.asset(path, fit: fit, width: width, height: height);
  }

  static Future<bool> _assetExists(String path) {
    return _assetExistsCache.putIfAbsent(path, () async {
      try {
        await rootBundle.load(path);
        return true;
      } catch (_) {
        return false;
      }
    });
  }

  /// Widget de Logo principal ya configurado
  static Widget logo({
    BoxFit fit = BoxFit.contain,
    double? width,
    double? height,
  }) {
    return Image.asset(logoPath, fit: fit, width: width, height: height);
  }

  /// Widget de Logo para cabecera ya configurado
  static Widget logoCab({
    BoxFit fit = BoxFit.contain,
    double? width,
    double? height,
  }) {
    return Image.asset(logoCabPath, fit: fit, width: width, height: height);
  }

  /// Título dinámico de la aplicación
  static String get titulo {
    return switch (brand) {
      SmxBrand.redventas => 'RedVentas',
      SmxBrand.redcontrol => 'RedControl',
      SmxBrand.saldify => 'Saldify',
    };
  }

  /// Eslogan o descripción dinámica de la aplicación
  static String get descripcion {
    return switch (brand) {
      SmxBrand.redventas => 'CONECTA + GESTIONA + CRECE',
      SmxBrand.redcontrol => 'CONTROL TOTAL DE TU RED',
      SmxBrand.saldify => 'RE DE VENTAS Y CRÉDITOS EN LÍNEA',
    };
  }

  /// URL publica utilizada para abrir los enlaces de invitacion.
  static String get invitationBaseUrl {
    return switch (brand) {
      SmxBrand.redventas => 'https://venture.jars.mx/redVentas',
      SmxBrand.redcontrol => 'https://venture.jars.mx/redcontrol',
      SmxBrand.saldify => 'https://venture.jars.mx/venture_saldify',
    };
  }
}
