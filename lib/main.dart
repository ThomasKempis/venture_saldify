import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxLogonMovil.dart';
import 'package:venture_saldify/smxThemeData.dart';

final bool useDevInvitacionCliente = true;
const String devUuidAnfitrion = 'ce9db2f5-dfb5-4b0e-9d35-941c0387f6de';
const String devUuidInvitado = 'bdfed92f-4e29-4565-9851-1a11068901c4';

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

  _applyDevInvitacionCliente();

  final queryParameters = Uri.base.queryParameters;

  await SmxConstants.smxAppStartUp(
    produccion: true,
    queryParameters: queryParameters,
  );

  runApp(MyAppSmx());
}

void _applyDevInvitacionCliente() {
  if (!kDebugMode || !useDevInvitacionCliente) return;

  if (Uri.base.queryParameters.containsKey(SmxConstants.uuidInvitadoParam) ||
      Uri.base.queryParameters.containsKey(SmxConstants.uuidAnfitrionParam)) {
    return;
  }

  final newUri = Uri.base.replace(
    queryParameters: {
      ...Uri.base.queryParameters,
      SmxConstants.uuidInvitadoParam: devUuidInvitado,
      SmxConstants.uuidAnfitrionParam: devUuidAnfitrion,
    },
  );

  html.window.history.replaceState(null, 'Saldify Dev', newUri.toString());
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
