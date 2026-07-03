import 'dart:async';

import 'package:venture_core_connect/smxConstants_core.dart';

import 'smxConstants.dart';
import 'smxGeolocation.dart';

class SmxLocationReporter {
  static const String procedureName = 'UPDATE_SYSUSER10_GEOLOCAL';
  static final SmxGeolocation _geolocation = SmxGeolocation();

  const SmxLocationReporter._();

  static void reportUnawaited(String accion) {
    unawaited(report(accion: accion));
  }

  static Future<void> report({required String accion}) async {
    try {
      final controller = SmxConstants.controllerMain;
      final idSysuser10 = controller.rstSysUser10.getId();
      if (idSysuser10 <= 0) return;

      final hasPermission = await _geolocation.requestPermission();
      if (!hasPermission) return;

      final geoloc = (await _geolocation.getGeolocation())?.trim() ?? '';
      if (geoloc.isEmpty) return;

      SmxConstants_core.geoLocalizacion = geoloc;

      final cleanAccion = accion.trim().toUpperCase();
      if (cleanAccion.isEmpty) return;

      controller.addSTrans(
        procedureName,
        "select * from $procedureName("
        '$idSysuser10, '
        "'${_sqlString(geoloc)}', "
        "'${_sqlString(cleanAccion)}')",
      );

      await controller.getCallWS();

      if (controller.jsonSend.getError() == null) {
        controller.rstSysUser10.update('SYSUSER10_GEOLOC_ULT', geoloc);
      }
    } catch (_) {
      return;
    }
  }

  static String _sqlString(String value) {
    return value.replaceAll("'", "''");
  }
}
