import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

List<LocalizationsDelegate> LocalDelegates = [
  //SmxAppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate, // Importante para soporte Cupertino
  GlobalWidgetsLocalizations.delegate,
];

List<Locale> Locales = [
  Locale('es', 'ES'),
  Locale('en', 'US'),
  Locale('es', 'ES'),
];

ThemeData SmxThemeData() {
  return ThemeData(
    primaryColor: const Color(0xFFD47B13),
    appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFD47B13)
    ),
  );
}

