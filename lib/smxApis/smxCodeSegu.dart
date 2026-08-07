import 'dart:math';

enum SmxSaldiFyInvitaStatus { SF, SY }

class SmxGenCodeSeguridad {
  static const SmxSaldiFyInvitaStatus prefijoDefault = SmxSaldiFyInvitaStatus.SF;
  static const int digitCount = 12;

  static final Random _random = Random.secure();

  const SmxGenCodeSeguridad._();

  static String generar({required SmxSaldiFyInvitaStatus prefijo}) {
    final baseDigits = StringBuffer();

    for (var i = 0; i < digitCount - 1; i++) {
      baseDigits.write(_random.nextInt(10));
    }

    final checkDigit = _buildLuhnCheckDigit(baseDigits.toString());

    return '${prefijo.name}$baseDigits$checkDigit';
  }

  static String format(String value) {
    final code = _normalizar(value);
    String? prefix = _obtenerPrefijo(code);

    if (prefix == null) return code;

    final digits = code.substring(prefix.length);
    final groups = <String>[];

    for (var index = 0; index < digits.length; index += 4) {
      final end = min(index + 4, digits.length);
      groups.add(digits.substring(index, end));
    }

    return [prefix, ...groups].join(' ').trim();
  }

  static bool isValid(String value) {
    final code = _normalizar(value);
    String? prefix = _obtenerPrefijo(code);

    if (prefix == null) return false;

    final digits = code.substring(prefix.length);
    if (digits.length != digitCount) return false;
    if (!RegExp(r'^\d+$').hasMatch(digits)) return false;

    return _isValidLuhn(digits);
  }

  static SmxSaldiFyInvitaStatus? getUrlTipo(String value) {
    bool valid = isValid(value);
    if (!valid) return null;

    final code = _normalizar(value);
    String? prefix = _obtenerPrefijo(code);

    return SmxSaldiFyInvitaStatus.values.firstWhere(
          (status) => status.name == prefix,
    );
  }

  static String _normalizar(String value) {
    return value.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');
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

  static String? _obtenerPrefijo(String value) {
    if (value.length < 2) return null;

    String prefijo = value.substring(0, 2);

    for (var element in SmxSaldiFyInvitaStatus.values) {
      if (element.name == prefijo) {
        return element.name; // Retorna el prefijo si lo encuentra
      }
    }

    return null; // Si termina el ciclo y no encontró nada, retorna null
  }
}
