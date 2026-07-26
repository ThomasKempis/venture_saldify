import 'package:flutter/material.dart';

enum SmxBrand { saldify, redventas, redcontrol }

abstract class SmxConfig {
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
}
