import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';

import '../smxApis/smxConstants.dart';
import '../smxLogonMovil/logon/smxLogonMovil_controller.dart';

enum SmxSaldiFyClienteStatus {
  pendiente,
  aceptado,
  rechazado,
  invalido,
  usuarioNoCorresponde,
}

class SmxSaldiFyClienteController extends SmxController {
  final SmxLogonMovil_controller controllerMain = SmxConstants.controllerMain;
  late SmxRowSet rstInvitacion;
  SmxSaldiFyClienteStatus status = SmxSaldiFyClienteStatus.invalido;

  SmxSaldiFyClienteController({
    required super.alias,
    required super.data,
  });

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    if (!SmxConstants.isClienteInvitado) {
      status = SmxSaldiFyClienteStatus.invalido;
      return;
    }

    if (!_isUsuarioInvitado()) {
      status = SmxSaldiFyClienteStatus.usuarioNoCorresponde;
      return;
    }

    addSql(
      'QRY_SYSUSER10_SYSUSER11',
      "select * from QRY_SYSUSER10_SYSUSER11 "
          "where UUID_ANFITRION = '${SmxConstants.uuidAnfitrionParam}' "
          "and ${_getInvitadoSqlCondition()}",
    );

    await getRowSetFuture('QRY_SYSUSER10_SYSUSER11');

    rstInvitacion = getRowset('QRY_SYSUSER10_SYSUSER11');

    if(rstInvitacion.getRowCount() == 0 &&
        SmxConstants.hasCorreoInvitado &&
        controllerMain.getCorreo() == SmxConstants.correoInvitadoParam) {

      removeSql('QRY_SYSUSER10_SYSUSER11');

      addSql(
        'QRY_SYSUSER10_SYSUSER11',
        "select * from ADD_SYSUSER10_SYSUSER11("
              "'${SmxConstants.uuidAnfitrionParam}', "
              "'${SmxConstants.correoInvitadoParam}')"
      );

      await getRowSetFuture('QRY_SYSUSER10_SYSUSER11');

      rstInvitacion = getRowset('QRY_SYSUSER10_SYSUSER11');
    }


    status = _getStatusInvitacion();
  }

  SmxSaldiFyClienteStatus _getStatusInvitacion() {
    if (rstInvitacion.getRowCount() == 0) {
      return SmxSaldiFyClienteStatus.invalido;
    }

    rstInvitacion.first();

    final statusValue = rstInvitacion.getValue('SYSUSER11_STATUS');
    final statusNumber = statusValue is int
        ? statusValue
        : int.tryParse(statusValue?.toString() ?? '');

    return switch (statusNumber) {
      0 => SmxSaldiFyClienteStatus.pendiente,
      1 => SmxSaldiFyClienteStatus.aceptado,
      2 => SmxSaldiFyClienteStatus.rechazado,
      _ => SmxSaldiFyClienteStatus.invalido,
    };
  }

  String? get mensajeValidacion {
    return switch (status) {
      SmxSaldiFyClienteStatus.aceptado => null,
      SmxSaldiFyClienteStatus.pendiente => 'Su invitacion esta pendiente de aprobacion por el anfitrion.',
      SmxSaldiFyClienteStatus.rechazado => 'Su invitacion fue rechazada por el anfitrion.',
      SmxSaldiFyClienteStatus.invalido => 'Su invitacion no es valida.',
      SmxSaldiFyClienteStatus.usuarioNoCorresponde => 'Esta invitacion pertenece a otro usuario.',
    };
  }

  bool _isUsuarioInvitado() {
    if (SmxConstants.hasUuidInvitado) {
      return uuidUsuarioLogueado == SmxConstants.uuidInvitadoParam;
    }

    if (SmxConstants.hasCorreoInvitado) {
      return controllerMain.getCorreo() == SmxConstants.correoInvitadoParam;
    }

    return false;
  }

  String _getInvitadoSqlCondition() {
    if (SmxConstants.hasUuidInvitado) {
      return "UUID_INVITADO = '${SmxConstants.uuidInvitadoParam}'";
    }

    return "upper(INVITADO_CORREO) = upper('${SmxConstants.correoInvitadoParam}')";
  }

  String get uuidUsuarioLogueado {
    return controllerMain.rstSysUser10
            .getValue('SYSUSER10_UUID')
            ?.toString()
            .trim() ??
        '';
  }

  String get anfitrionNombreCompleto {
    final nombreCompleto =
        '${_getInvitacionValue('SYSUSER10_NOMBRES')} '
                '${_getInvitacionValue('SYSUSER10_APELLIDOS')}'
            .trim();

    return nombreCompleto.isEmpty ? 'Anfitrion' : nombreCompleto;
  }

  String _getInvitacionValue(String field) {
    if (rstInvitacion.getRowCount() == 0) return '';

    return rstInvitacion.getValue(field)?.toString() ?? '';
  }

  @override
  Future<void> save() async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}
}
