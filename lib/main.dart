import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxLogonMovil/logon/smxLogonMovil.dart';
import 'package:venture_saldify/smxThemeData.dart';

const String devUuidAnfitrion = 'ce9db2f5-dfb5-4b0e-9d35-941c0387f6de';
const String devCorreoInvitado = 'santiago.azael.mohr@gmail.com';
const String devUuidInvitado = 'bdfed92f-4e29-4565-9851-1a11068901c4';
const SmxInvitacionMode devModalidad = SmxInvitacionMode.uuid_invitado;

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
  if (!kDebugMode || devModalidad == SmxInvitacionMode.admin) return;

  if (Uri.base.queryParameters.containsKey(SmxConstants.uuidInvitadoParam) ||
      Uri.base.queryParameters.containsKey(SmxConstants.correoInvitadoParam) ||
      Uri.base.queryParameters.containsKey(SmxConstants.uuidAnfitrionParam)) {
    return;
  }

  final invitacionParameters = _getDevInvitacionParameters();
  if (invitacionParameters.isEmpty) return;

  final newUri = Uri.base.replace(
    queryParameters: {...Uri.base.queryParameters, ...invitacionParameters},
  );

  html.window.history.replaceState(null, 'Saldify Dev', newUri.toString());
}

Map<String, String> _getDevInvitacionParameters() {
  final uuidAnfitrion = devUuidAnfitrion.trim();
  final uuidInvitado = devUuidInvitado.trim();
  final correoInvitado = devCorreoInvitado.trim();

  if (uuidAnfitrion.isEmpty) return {};

  if (devModalidad == SmxInvitacionMode.uuid_invitado &&
      uuidInvitado.isNotEmpty) {
    return {
      SmxConstants.uuidAnfitrionParam: uuidAnfitrion,
      SmxConstants.uuidInvitadoParam: uuidInvitado,
    };
  }

  if (devModalidad == SmxInvitacionMode.correo_invitado &&
      correoInvitado.isNotEmpty) {
    return {
      SmxConstants.uuidAnfitrionParam: uuidAnfitrion,
      SmxConstants.correoInvitadoParam: correoInvitado,
    };
  }

  return {};
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
