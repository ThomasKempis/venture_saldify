import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxLogonMovil.dart';
import 'package:venture_saldify/smxThemeData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await SmxConstants.smxAppStartUp(
    produccion: true,
    queryParameters: Uri.base.queryParameters,
  );

  runApp(MyAppSmx());
}

class MyAppSmx extends StatelessWidget {
  const MyAppSmx({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VentureWeb UserMovil',
      localizationsDelegates: LocalDelegates,
      supportedLocales: Locales,
      locale: const Locale('es', 'MX'),
      debugShowCheckedModeBanner: false,
      theme: SmxThemeData(),
      home: SmxLogonMovil(),
    );
  }
}
