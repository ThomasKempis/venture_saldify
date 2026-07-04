import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxSaldifyLogon/smxSaldifyLogon.dart';
import 'package:venture_saldify/smxThemeData.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //_applyDevCodigoInvitacion();

  final queryParameters = Uri.base.queryParameters;
  final saldifyLogonAssets = SmxSaldifyLogon.warmUpAssets();

  await Future.wait([
    SmxConstants.smxAppStartUp(
      produccion: true,
      queryParameters: queryParameters,
    ),
    saldifyLogonAssets,
  ]);

  runApp(MyAppSmx());
}

void _applyDevCodigoInvitacion() {
  if (!kDebugMode) return;

  const String codigo = 'SF479689914378';

  if (Uri.base.queryParameters.containsKey(SmxConstants.codigoInvitacionKey)) {
    return;
  }

  final newUri = Uri.base.replace(
    queryParameters: {
      ...Uri.base.queryParameters,
      SmxConstants.codigoInvitacionKey: codigo,
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
      home: SmxSaldifyLogon(codigoInicial: SmxConstants.codigoInvitacionParam),
    );
  }
}
