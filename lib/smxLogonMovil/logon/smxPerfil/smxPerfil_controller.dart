import 'package:flutter/cupertino.dart';
import 'package:venture_widgets/smxTmpScreen.dart';
import 'dart:typed_data';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';
import 'package:venture_widgets/smxTextField/smxTextField.dart';
import 'package:venture_widgets/smxViewMap/smxLocationReporter.dart';

import '../../../smxApis/smxConstants.dart';
import '../smxLogonMovil_controller.dart';

class SmxPerfil_controller extends SmxTmpCtl {
  final SmxLogonMovil_controller controllerMain = SmxConstants.controllerMain;

  @override
  final BuildContext context;

  SmxPerfil_controller(this.context) {
    data.context = context;
    data.tablaTroncalRst = controllerMain.rstSysUser10;
  }

  @override
  Future<void> save() async {
    await SmxLocationReporter.report(
      controller: controllerMain,
      idSysuser10: controllerMain.rstSysUser10.getId(),
      accion: 'PERFIL',
    );

    await showDialogWait(context, () async {
      await callTroncalSave(controllerMain.rstSysUser10);
    });
  }

  Future<Uint8List> getImagen() async {
    return await controllerMain.getImagen();
  }

  String getCorreo() {
    return controllerMain.getCorreo();
  }

  String getNombres() {
    String nombres = controllerMain.rstSysUser10.getValue('SYSUSER10_NOMBRES');
    String apellidos = controllerMain.rstSysUser10.getValue(
      'SYSUSER10_APELLIDOS',
    );
    return "$nombres $apellidos";
  }

  bool showValida() {
    if (!validateWidgets(context)) {
      return false;
    }

    if (!(getValueFactory('SYSUSER10_TELEFONO').getWidGet() as SmxTextField)
        .isValidaStringSpecial) {
      showValidDialog(context, mensaje: "Debe ingresar un Teléfono válido");
      return false;
    }

    if (!(getValueFactory('SYSUSER10_CORREO_01').getWidGet() as SmxTextField)
        .isValidaStringSpecial) {
      showValidDialog(context, mensaje: "Debe ingresar un correo válido");
      return false;
    }

    if (!(controllerMain.isMayorEdad(getDate('SYSUSER10_FECHA')))) {
      showValidDialog(
        context,
        mensaje:
            "Debe ingresar una edad mayor a ${SmxLogonMovil_controller.edad_maxima} años",
      );
      return false;
    }

    return true;
  }
}
