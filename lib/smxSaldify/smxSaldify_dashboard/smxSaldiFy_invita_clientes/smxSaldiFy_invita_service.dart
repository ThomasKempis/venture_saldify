import 'package:venture_saldify/smxApis/smxConfig.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';

import '../../../smxApis/smxCodeSegu.dart';
import 'smxSaldiFy_invita_clientes_models.dart';

class SmxSaldifyInvitaService {
  static const String aliasAddCodigo = 'ADD_CODIGO_INVITACION';
  static const int maxIntentosCodigo = 5;

  const SmxSaldifyInvitaService._();

  static Future<SmxSaldiFyInvitacionGenerada?> crearInvitacion({
    required SmxSaldiFyInvitaStatus prefijo
  }) async {
    final controller = SmxConstants.controllerMain;
    final uuidAnfitrion = controller.getUuid().trim();
    if (uuidAnfitrion.isEmpty) return null;

    for (var intento = 0; intento < maxIntentosCodigo; intento++) {
      final codigo = SmxGenCodeSeguridad.generar(prefijo: prefijo);
      final status = await _reservarCodigoInvitacion(
        prefijo: prefijo,
        codigo: codigo,
        uuidAnfitrion: uuidAnfitrion,
      );

      if (controller.jsonSend.getError() != null) return null;

      if (status == 'OK') {
        return SmxSaldiFyInvitacionGenerada(
          codigo: codigo,
          codigoFormato: SmxGenCodeSeguridad.format(codigo),
          link: _buildLink(codigo),
        );
      }

      if (status == 'DUPLICADO') continue;

      return null;
    }

    return null;
  }

  static Future<String> _reservarCodigoInvitacion({
    required SmxSaldiFyInvitaStatus prefijo,
    required String codigo,
    required String uuidAnfitrion,
  }) async {
    final controller = SmxConstants.controllerMain;
    String sqlSTans = '';

    if (prefijo == SmxSaldiFyInvitaStatus.SF) {
      sqlSTans = "select * from ADD_SYSUSER90_SALDIFY("
                 "'${_sql(codigo)}', "
                 "'${_sql(uuidAnfitrion)}')";

    } else if (prefijo == SmxSaldiFyInvitaStatus.SY) {
      sqlSTans = "select * from ADD_SYSUSER91_SALDIFY("
                 "'${_sql(codigo)}', "
                 "'${_sql(uuidAnfitrion)}')";

    } else {
      return '';

    }

    controller.addSTrans(
      aliasAddCodigo,
      sqlSTans,
    );

    await controller.getCallWS();

    if (controller.jsonSend.getError() != null) return '';

    final rst = controller.getRowset(aliasAddCodigo);
    if (rst.getRowCount() == 0) return '';

    rst.first();
    return rst.getValue('TMPUSER99_STATUS');
  }

  static String _buildLink(String codigo) {
    return Uri.parse(SmxConfig.invitationBaseUrl)
        .replace(queryParameters: {SmxConstants.urlValidator.codigoKey: codigo})
        .toString();
  }

  static String _sql(String value) {
    return value.trim().replaceAll("'", "''");
  }
}
