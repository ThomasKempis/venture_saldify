import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_core_connect/smxConstants_core.dart';
import 'package:venture_core_connect/smxJson/SmxJsonUtil.dart';
import 'package:venture_core_connect/smxJson/smxJsonFiles.dart';
import 'package:venture_widgets/smxInfoUser/smxInfoUser.dart';
import 'package:venture_widgets/smxTmpScreen.dart';
import 'package:universal_html/html.dart' as html;
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';

import '../../smxSaldify/smxSaldify.dart';
import '../../smxSaldifyCliente/smxSaldifyCliente.dart';

class SmxLogonMovil_controller extends SmxTmpCtl {
  static const edad_maxima = 14;
  late SmxRowSet rstSysUser10;
  late final SmxInfoUser infoUser;

  SmxLogonMovil_controller() {
    infoUser = SmxInfoUser();
    SmxConstants.controllerMain = this;
  }

  Future<void> checkPermissionLocation() async {
    await infoUser.checkLocationPermission();
    SmxConstants_core.geoLocalizacion = infoUser.location;
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

  bool isUserLoggedIn() {
    final correo = html.window.localStorage['correo'];
    return correo != null && correo.isNotEmpty;
  }

  Future<void> saveCredentials(User user) async {
    final correo = user.email ?? '';
    final nombres = user.displayName ?? '';
    final imagenUrl = user.photoURL ?? '';

    html.window.localStorage['correo'] = correo;
    html.window.localStorage['nombres'] = nombres;

    if (imagenUrl.isNotEmpty) {
      try {
        final response = await http.get(Uri.parse(imagenUrl));
        if (response.statusCode == 200) {
          final base64Image = base64Encode(response.bodyBytes);

          html.window.localStorage['imagen'] = base64Image;
        }
      } catch (_) {}
    }
  }

  void navigateToAppMovil(BuildContext context) async {
    SmxConstants_core.instancia = 'SALDIFY';

    resetJsonSend();

    addSql(
      'SYSUSER10',
      "Select * from SYSUSER10_CAB_MOVIL where SYSUSER10_CORREO = '${getCorreo()}'",
    );

    await showDialogWait(context, () async {
      await getRowSetFuture('SYSUSER10');
      rstSysUser10 = getRowset('SYSUSER10');

      if (rstSysUser10.getRowCount() == 0) {
        int idImage = await _callWSImageLoad();

        rstSysUser10.insert();
        rstSysUser10.tabla = 'SYSUSER10_CAB_MOVIL';

        if (idImage > 0) {
          rstSysUser10.update('RELA_SYSJSON02', idImage);
        }

        rstSysUser10.update('SYSUSER10_NOMBRES', getNombres());
        rstSysUser10.update('SYSUSER10_APELLIDOS', '');
        rstSysUser10.update('SYSUSER10_TELEFONO', '');
        rstSysUser10.update('SYSUSER10_CORREO', getCorreo());
        rstSysUser10.update('SYSUSER10_CORREO_01', getCorreo());
        rstSysUser10.update('SYSUSER10_FECHA', DateTime.now());
        rstSysUser10.update(
          'SYSUSER10_GEOLOC_ULT',
          SmxConstants_core.geoLocalizacion,
        );
        rstSysUser10.update('SYSUSER10_UUID', const Uuid().v4());

        await callTroncalSave(rstSysUser10);

        removeSql('SYSUSER10');
        addSql(
          'SYSUSER10',
          "Select * from SYSUSER10_CAB_MOVIL where SYSUSER10_CORREO = '${getCorreo()}'",
        );

        await getRowSetFuture('SYSUSER10');
        rstSysUser10 = getRowset('SYSUSER10');
      }
    });

    rstSysUser10.first();
    data.tablaTroncalRst = rstSysUser10;

    if (rstSysUser10.getValue('RELA_SYSJSON02') <= 0) {
      int idImage = await _callWSImageLoad();
      rstSysUser10.update('RELA_SYSJSON02', idImage);
      await callTroncalSave(rstSysUser10);
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SmxConstants.isClienteInvitado || SmxConstants.hasParametrosInvitacionInvalidos
            ? SmxSaldiFyCliente()
            : SmxSaldiFy(),
      ),
    );
  }

  String getCorreo() {
    return html.window.localStorage['correo']!.toLowerCase();
  }

  String getUuid() {
    return rstSysUser10.getValue('SYSUSER10_UUID')?.toString() ?? '';
  }

  String getNombres() {
    String nombres = rstSysUser10.getValue('SYSUSER10_NOMBRES') ?? '';
    String apellidos = rstSysUser10.getValue('SYSUSER10_APELLIDOS') ?? '';

    if (nombres.isEmpty || apellidos.isEmpty) {
      return html.window.localStorage['nombres']!.toUpperCase();
    }

    return "$nombres $apellidos";
  }

  Future<Uint8List> getImagen() async {
    final base64String = html.window.localStorage['imagen'];
    if (base64String != null && base64String.isNotEmpty) {
      try {
        return base64Decode(base64String);
      } catch (_) {}
    }

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
}
