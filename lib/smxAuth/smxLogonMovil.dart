import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as html;
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_core_connect/smxConstants_core.dart';
import 'package:venture_core_connect/smxJson/SmxJsonUtil.dart';
import 'package:venture_core_connect/smxJson/smxJsonFiles.dart';
import 'package:venture_widgets/smxTmpScreen.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxViewMap/smxLocationReporter.dart';

import '../smxSaldify/smxSaldify.dart';
import '../smxSaldifyCliente/smxSaldifyCliente.dart';
import '../smxSaldifyLogon/smxSaldifyAccessSession.dart';
import 'smxAuth.dart';

class SmxLogonMovil extends SmxTmpCtl {
  static const edad_maxima = 14;
  final SmxAuthUser authUser;
  final SmxSaldifyAccessMode accessMode;
  late SmxRowSet rstSysUser10;
  String _uuidAnfitrionInvitacion = '';

  SmxLogonMovil({required this.authUser, required this.accessMode}) {
    SmxConstants.controllerMain = this;
  }

  Future<void> checkPermissionCamara() async {
    final Map<String, dynamic> mediaConstraints = {
      'video': {
        'facingMode': 'environment', // ¡Aquí está la clave!
        'width': {'ideal': 0, 'max': 1920},
        'height': {'ideal': 0, 'max': 1080},
      },
      'audio': true,
    };

    try {
      final stream = await html.window.navigator.mediaDevices!.getUserMedia(
        mediaConstraints,
      );
      stream.getTracks().forEach((track) => track.stop());
    } catch (e) {
      print('Permiso de cámara denegado o fallido: $e');
    }
  }

  Future<void> prepareUser(BuildContext context) async {
    final nombresSql = _sql(authUser.displayName.toUpperCase());
    final correoSql = _sql(getCorreo());
    final geolocalizacionSql = SmxConstants_core.geoLocalizacion;

    removeSql('SYSUSER10');
    addSTrans(
      'SYSUSER10',
      "select * from ADD_SYSUSER10("
          "'$nombresSql', "
          "'$correoSql', "
          "'$geolocalizacionSql')",
    );

    await getCallWS();

    if (jsonSend.getError() != null) {
      throw StateError(jsonSend.error!);
    }

    rstSysUser10 = getRowset('SYSUSER10');

    if (rstSysUser10.getRowCount() == 0) {
      throw StateError('ADD_SYSUSER10 no regresó datos del usuario.');
    }

    rstSysUser10.first();

    SmxConstants_core.instancia = "SALDIFY";
    SmxConstants_core.usuario = rstSysUser10.getValue('SYSUSER99_USUARIO');
    SmxConstants_core.clave = rstSysUser10.getValue('SYSUSER99_PASSWORD');

    resetJsonSend();

    rstSysUser10.first();
    rstSysUser10.tabla = 'SYSUSER10_CAB_MOVIL';

    if (rstSysUser10.getValue('RELA_SYSJSON02') <= 0) {
      data.tablaTroncalRst = rstSysUser10;

      final idImage = await _callWSImageLoad();

      if (idImage > 0) {
        rstSysUser10.update('RELA_SYSJSON02', idImage);
        await callTroncalSave(rstSysUser10);
      }
    }
  }

  Future<void> navigateToAppMovil(BuildContext context) async {
    await prepareUser(context);
    await navigatePreparedUser(context);
  }

  Future<void> navigatePreparedUser(BuildContext context) async {
    await SmxLocationReporter.report(
      controller: this,
      idSysuser10: rstSysUser10.getId(),
      accion: 'LOGIN',
    );

    SmxSaldifyAccessSession.markActive(accessMode, getCorreo());

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => accessMode == SmxSaldifyAccessMode.invitado
            ? SmxSaldiFyCliente()
            : SmxSaldiFy(),
      ),
    );
  }

  String getCorreo() {
    return authUser.email.toLowerCase();
  }

  String getUuid() {
    return rstSysUser10.getValue('SYSUSER10_UUID')?.toString() ?? '';
  }

  String getUuidAnfitrion() {
    if (_uuidAnfitrionInvitacion.isNotEmpty) {
      return _uuidAnfitrionInvitacion;
    }

    return rstSysUser10
            .getValue('SYSUSER99_UUID_ANFITRION')
            ?.toString()
            .trim() ??
        '';
  }

  void setUuidAnfitrion(String uuidAnfitrion) {
    _uuidAnfitrionInvitacion = uuidAnfitrion.trim();
  }

  String getNombres() {
    String nombres = rstSysUser10.getValue('SYSUSER10_NOMBRES') ?? '';
    String apellidos = rstSysUser10.getValue('SYSUSER10_APELLIDOS') ?? '';

    if (nombres.isEmpty || apellidos.isEmpty) {
      return authUser.displayName.toUpperCase();
    }

    return "$nombres $apellidos";
  }

  Future<Uint8List> getImagen() async {
    if (authUser.imageBytes != null) return authUser.imageBytes!;

    // Cargar la imagen por defecto desde assets
    final byteData = await rootBundle.load('assets/images/ventureWeb.png');
    return byteData.buffer.asUint8List();
  }

  bool isMayorEdad(DateTime fechaNacimiento) {
    final ahora = DateTime.now();
    final edad = ahora.year - fechaNacimiento.year;

    // Verificar si ya pasó el cumpleaños este año
    if (ahora.month < fechaNacimiento.month ||
        (ahora.month == fechaNacimiento.month &&
            ahora.day < fechaNacimiento.day)) {
      return edad - 1 >= edad_maxima;
    }

    return edad >= edad_maxima;
  }

  Future<int> _callWSImageLoad() async {
    // 1. Preparar el objeto de archivo
    final smxJsonFiles = SmxJsonFiles()
      ..alias = 'SYSUSER10'
      ..accion = TipoFileAccion.UPLOAD.stringValue
      ..nameFile = 'PHOTO_PERFIL.PNG'
      ..fileBytes = await getImagen(); // Obtener los bytes de la imagen

    // 2. Configurar la solicitud
    jsonSend
      ..microServicio = SmxServicios.FILES.toStringValue()
      ..files = {'SYSUSER10': smxJsonFiles};

    await getCallWS();

    if (jsonSend.files == null || jsonSend.files!.isEmpty) {
      return 0;
    }

    //jsonSend.files!.values.first.uuidFile!;
    return jsonSend.files!.values.first.idSysJson02;
  }

  static String _sql(String value) {
    return value.trim().replaceAll("'", "''");
  }
}
