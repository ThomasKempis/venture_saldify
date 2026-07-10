import 'package:flutter/material.dart';

abstract class SmxConfig {
  /// Detecta el modo de la aplicación inyectado durante la compilación.
  /// Ejemplo: flutter build web --dart-define=APP_MODE=redcontrol
  static const String _appMode = String.fromEnvironment('APP_MODE', defaultValue: 'saldify');

  /// Devuelve el modo actual ('saldify' o 'redcontrol')
  static String get appMode => _appMode;

  /// Rutas dinámicas (String) para casos donde se necesite el path directamente
  static String get logoPath => 'assets/images/$_appMode/logo.png';
  static String get logoCabPath => 'assets/images/$_appMode/logo_cab.png';

  /// Widget de Logo principal ya configurado
  static Widget logo({
    BoxFit fit = BoxFit.contain,
    double? width,
    double? height,
  }) {
    return Image.asset(
      logoPath,
      fit: fit,
      width: width,
      height: height,
    );
  }

  /// Widget de Logo para cabecera ya configurado
  static Widget logoCab({
    BoxFit fit = BoxFit.contain,
    double? width,
    double? height,
  }) {
    return Image.asset(
      logoCabPath,
      fit: fit,
      width: width,
      height: height,
    );
  }

  /// Título dinámico de la aplicación
  static String get titulo {
    return _appMode == 'redcontrol' ? 'RedControl' : 'Saldify';
  }

  /// Eslogan o descripción dinámica de la aplicación
  static String get descripcion {
    return _appMode == 'redcontrol'
        ? 'CONTROL TOTAL DE TU RED'
        : 'SMART BALANCE & CREDITS CONTROL';
  }
}
