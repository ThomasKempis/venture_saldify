import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class SmxAppLocalizations {
  final Locale locale;

  SmxAppLocalizations(this.locale);

  static SmxAppLocalizations? of(BuildContext context) {
    return Localizations.of<SmxAppLocalizations>(context, SmxAppLocalizations);
  }

  Map<String, String> _localizedStrings = {}; // Inicia vacía


  // Cargar el archivo JSON correspondiente al idioma
  Future<bool> load() async {
    String jsonString =
    await rootBundle.loadString('translations/${locale.languageCode}.json');

    Map<String, dynamic> jsonMap = json.decode(jsonString);

    _localizedStrings = jsonMap.map((key, value) {
      return MapEntry(key, value.toString());
    });

    return true;
  }

  // Obtener la traducción por clave
  String translate(String key) {
    return _localizedStrings[key] ?? key;
  }

  // Delegado para la internacionalización
  static const LocalizationsDelegate<SmxAppLocalizations> delegate =
  _AppLocalizationsDelegate();
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<SmxAppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<SmxAppLocalizations> load(Locale locale) async {
    SmxAppLocalizations localizations = SmxAppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}