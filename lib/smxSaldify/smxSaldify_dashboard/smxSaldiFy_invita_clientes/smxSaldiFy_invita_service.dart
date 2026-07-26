import 'dart:math';

import 'package:venture_saldify/smxApis/smxConfig.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_widgets/smxController/smxController.dart';

import 'smxSaldiFy_invita_clientes_models.dart';

enum SmxSaldifyInvitacionTipo {
  anfitrionAnonimo,
  invitadoRegistrado,
  invitadoCorreo,
}

class SmxSaldifyInvitacionParametros {
  final SmxSaldifyInvitacionTipo tipo;
  final String uuidAnfitrion;
  final String correoInvitado;
  final String uuidInvitado;
  final String telefono;

  const SmxSaldifyInvitacionParametros({
    required this.tipo,
    required this.uuidAnfitrion,
    this.correoInvitado = '',
    this.uuidInvitado = '',
    this.telefono = '',
  });

  const SmxSaldifyInvitacionParametros.anfitrionAnonimo({
    required String uuidAnfitrion,
    String telefono = '',
  }) : this(
         tipo: SmxSaldifyInvitacionTipo.anfitrionAnonimo,
         uuidAnfitrion: uuidAnfitrion,
         telefono: telefono,
       );

  const SmxSaldifyInvitacionParametros.invitadoRegistrado({
    required String uuidAnfitrion,
    required String uuidInvitado,
    String telefono = '',
  }) : this(
         tipo: SmxSaldifyInvitacionTipo.invitadoRegistrado,
         uuidAnfitrion: uuidAnfitrion,
         uuidInvitado: uuidInvitado,
         telefono: telefono,
       );

  const SmxSaldifyInvitacionParametros.invitadoCorreo({
    required String uuidAnfitrion,
    required String correoInvitado,
    String telefono = '',
  }) : this(
         tipo: SmxSaldifyInvitacionTipo.invitadoCorreo,
         uuidAnfitrion: uuidAnfitrion,
         correoInvitado: correoInvitado,
         telefono: telefono,
       );

  String get uuidAnfitrionClean => uuidAnfitrion.trim();
  String get correoInvitadoClean => correoInvitado.trim().toLowerCase();
  String get uuidInvitadoClean => uuidInvitado.trim();
  String get telefonoClean => telefono.trim();

  bool get isValid {
    if (uuidAnfitrionClean.isEmpty) return false;

    return switch (tipo) {
      SmxSaldifyInvitacionTipo.anfitrionAnonimo =>
        correoInvitadoClean.isEmpty && uuidInvitadoClean.isEmpty,
      SmxSaldifyInvitacionTipo.invitadoRegistrado =>
        correoInvitadoClean.isEmpty && uuidInvitadoClean.isNotEmpty,
      SmxSaldifyInvitacionTipo.invitadoCorreo =>
        correoInvitadoClean.isNotEmpty && uuidInvitadoClean.isEmpty,
    };
  }
}

class SmxSaldifyInvitacionLink {
  const SmxSaldifyInvitacionLink._();

  static String build({
    required String codigo,
    required SmxSaldifyInvitacionParametros parametros,
  }) {
    final codigoNormalizado = SmxCodeInvitado.normalizar(codigo);
    final queryParameters = <String, String>{
      SmxConstants.codigoInvitacionKey: codigoNormalizado,
    };

    switch (parametros.tipo) {
      case SmxSaldifyInvitacionTipo.anfitrionAnonimo:
        break;
      case SmxSaldifyInvitacionTipo.invitadoRegistrado:
        queryParameters[SmxConstants.uuidAnfitrionInvitacionKey] =
            parametros.uuidAnfitrionClean;
        queryParameters[SmxConstants.uuidInvitadoInvitacionKey] =
            parametros.uuidInvitadoClean;
        break;
      case SmxSaldifyInvitacionTipo.invitadoCorreo:
        queryParameters[SmxConstants.uuidAnfitrionInvitacionKey] =
            parametros.uuidAnfitrionClean;
        queryParameters[SmxConstants.correoInvitadoInvitacionKey] =
            parametros.correoInvitadoClean;
        break;
    }

    return Uri.parse(
      SmxConfig.invitationBaseUrl,
    ).replace(queryParameters: queryParameters).toString();
  }
}

class SmxSaldifyInvitaService {
  static const String aliasAddCodigo = 'ADD_SYSUSER90_SALDIFY';
  static const int maxIntentosCodigo = 5;

  const SmxSaldifyInvitaService._();

  static Future<SmxSaldiFyInvitacionGenerada?> crearInvitacion({
    required SmxController controller,
    required SmxSaldifyInvitacionParametros parametros,
  }) async {
    if (!parametros.isValid) return null;

    for (var intento = 0; intento < maxIntentosCodigo; intento++) {
      final codigo = SmxCodeInvitado.generar();
      final status = await _reservarCodigoInvitacion(
        controller: controller,
        codigo: codigo,
        uuidAnfitrion: parametros.uuidAnfitrionClean,
        correoInvitado: parametros.correoInvitadoClean,
        uuidInvitado: parametros.uuidInvitadoClean,
      );

      if (controller.jsonSend.getError() != null) return null;

      if (status == 'OK') {
        return _buildInvitacionGenerada(
          codigo: codigo,
          parametros: parametros,
          telefono: parametros.telefonoClean,
        );
      }

      if (status == 'DUPLICADO') continue;

      return null;
    }

    return null;
  }

  static Future<String> _reservarCodigoInvitacion({
    required SmxController controller,
    required String codigo,
    required String uuidAnfitrion,
    required String correoInvitado,
    required String uuidInvitado,
  }) async {
    controller.addSTrans(
      aliasAddCodigo,
      "select * from ADD_SYSUSER90_SALDIFY("
      "'${_sql(codigo)}', "
      "'${_sql(uuidAnfitrion)}', "
      "'${_sql(correoInvitado)}', "
      "'${_sql(uuidInvitado)}')",
    );

    await controller.getCallWS();

    if (controller.jsonSend.getError() != null) return '';

    final rst = controller.getRowset(aliasAddCodigo);
    if (rst.getRowCount() == 0) return '';

    rst.first();
    return rst.getValue('TMPUSER99_STATUS');
  }

  static SmxSaldiFyInvitacionGenerada _buildInvitacionGenerada({
    required String codigo,
    required SmxSaldifyInvitacionParametros parametros,
    required String telefono,
  }) {
    final codigoNormalizado = SmxCodeInvitado.normalizar(codigo);

    return SmxSaldiFyInvitacionGenerada(
      codigo: codigoNormalizado,
      codigoFormato: SmxCodeInvitado.format(codigoNormalizado),
      link: SmxSaldifyInvitacionLink.build(
        codigo: codigoNormalizado,
        parametros: parametros,
      ),
      telefono: telefono,
    );
  }

  static String _sql(String value) {
    return value.trim().replaceAll("'", "''");
  }
}

class SmxCodeInvitado {
  static const String prefix = 'SF';
  static const int digitCount = 12;

  static final Random _random = Random.secure();

  const SmxCodeInvitado._();

  static String generar() {
    final baseDigits = StringBuffer();

    for (var i = 0; i < digitCount - 1; i++) {
      baseDigits.write(_random.nextInt(10));
    }

    final checkDigit = _buildLuhnCheckDigit(baseDigits.toString());

    return '$prefix$baseDigits$checkDigit';
  }

  static String normalizar(String value) {
    return value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
  }

  static String format(String value) {
    final code = normalizar(value);

    if (!code.startsWith(prefix)) return code;

    final digits = code.substring(prefix.length);
    final groups = <String>[];

    for (var index = 0; index < digits.length; index += 4) {
      final end = min(index + 4, digits.length);
      groups.add(digits.substring(index, end));
    }

    return [prefix, ...groups].join(' ').trim();
  }

  static bool isValid(String value) {
    final code = normalizar(value);

    if (!code.startsWith(prefix)) return false;

    final digits = code.substring(prefix.length);
    if (digits.length != digitCount) return false;
    if (!RegExp(r'^\d+$').hasMatch(digits)) return false;

    return _isValidLuhn(digits);
  }

  static int _buildLuhnCheckDigit(String digits) {
    final sum = _luhnSum('${digits}0');
    return (10 - (sum % 10)) % 10;
  }

  static bool _isValidLuhn(String digits) {
    return _luhnSum(digits) % 10 == 0;
  }

  static int _luhnSum(String digits) {
    var sum = 0;
    var doubleDigit = false;

    for (var index = digits.length - 1; index >= 0; index--) {
      var digit = int.parse(digits[index]);

      if (doubleDigit) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }

      sum += digit;
      doubleDigit = !doubleDigit;
    }

    return sum;
  }
}
