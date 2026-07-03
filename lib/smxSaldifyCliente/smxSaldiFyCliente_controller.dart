import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';

import '../smxApis/smxConstants.dart';
import '../smxLogonMovil/logon/smxLogonMovil_controller.dart';

enum SmxSaldiFyClienteStatus {
  pendiente,
  aceptado,
  archivado,
  invalido,
  usuarioNoCorresponde,
}

class SmxSaldiFyClienteController extends SmxController {
  final SmxLogonMovil_controller controllerMain = SmxConstants.controllerMain;
  late SmxRowSet rstClienteCredito;
  SmxSaldiFyClienteStatus status = SmxSaldiFyClienteStatus.invalido;

  SmxSaldiFyClienteController({required super.alias, required super.data});

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

    removeSql('QRY_SYSUSER10_SYSUSER11');

    addSql(
      'QRY_SYSUSER10_SYSUSER11',
      "select * from QRY_SYSUSER10_SYSUSER11 "
          "where UUID_ANFITRION = '${SmxConstants.uuidAnfitrionParam}' "
          "and ${_getInvitadoSqlCondition()}",
    );

    await getRowSetFuture('QRY_SYSUSER10_SYSUSER11');

    rstClienteCredito = getRowset('QRY_SYSUSER10_SYSUSER11');

    if (rstClienteCredito.getRowCount() == 0 &&
        SmxConstants.hasCorreoInvitado &&
        controllerMain.getCorreo() == SmxConstants.correoInvitadoParam) {
      addSTrans(
        'ADD_SYSUSER10_SYSUSER11',
        "select * from ADD_SYSUSER10_SYSUSER11("
            "'${SmxConstants.uuidAnfitrionParam}', "
            "'${SmxConstants.correoInvitadoParam}')",
      );

      await getCallWS();

      rstClienteCredito = getRowset('ADD_SYSUSER10_SYSUSER11');
    }

    status = _getStatusInvitacion();
  }

  SmxSaldiFyClienteStatus _getStatusInvitacion() {
    if (rstClienteCredito.getRowCount() == 0) {
      return SmxSaldiFyClienteStatus.invalido;
    }

    rstClienteCredito.first();

    final statusValue = rstClienteCredito.getValue('SYSUSER11_STATUS');
    final statusNumber = statusValue is int
        ? statusValue
        : int.tryParse(statusValue?.toString() ?? '');

    return switch (statusNumber) {
      0 => SmxSaldiFyClienteStatus.pendiente,
      1 => SmxSaldiFyClienteStatus.aceptado,
      2 => SmxSaldiFyClienteStatus.archivado,
      _ => SmxSaldiFyClienteStatus.invalido,
    };
  }

  String? get mensajeValidacion {
    return switch (status) {
      SmxSaldiFyClienteStatus.aceptado => null,
      SmxSaldiFyClienteStatus.pendiente =>
        'Su invitacion esta pendiente de aprobacion por el anfitrion.',
      SmxSaldiFyClienteStatus.archivado =>
        'Su relacion fue archivada por el anfitrion.',
      SmxSaldiFyClienteStatus.invalido => 'Su invitacion no es valida.',
      SmxSaldiFyClienteStatus.usuarioNoCorresponde =>
        'Esta invitacion pertenece a otro usuario.',
    };
  }

  String get tituloValidacion {
    return switch (status) {
      SmxSaldiFyClienteStatus.pendiente => 'Invitacion pendiente',
      SmxSaldiFyClienteStatus.archivado => 'Vinculo archivado',
      SmxSaldiFyClienteStatus.invalido => 'Link de invitacion no valido',
      SmxSaldiFyClienteStatus.usuarioNoCorresponde =>
        'Invitacion de otro usuario',
      SmxSaldiFyClienteStatus.aceptado => '',
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

  String get clientName {
    try {
      final fullName = controllerMain.getNombres().trim();
      if (fullName.isEmpty) return 'Cliente';

      return fullName.split(RegExp(r'\s+')).first;
    } catch (_) {
      return 'Cliente';
    }
  }

  String get anfitrionNombreCompleto {
    final nombreCompleto =
        '${_getInvitacionValue('SYSUSER10_NOMBRES')} '
                '${_getInvitacionValue('SYSUSER10_APELLIDOS')}'
            .trim();

    return nombreCompleto.isEmpty ? 'Anfitrion' : nombreCompleto;
  }

  String get anfitrionTelefono {
    return _getInvitacionValue('SYSUSER10_TELEFONO').trim();
  }

  String get anfitrionCorreo {
    return _getInvitacionValue('SYSUSER10_CORREO').trim();
  }

  String get anfitrionRelacionEstado {
    return switch (status) {
      SmxSaldiFyClienteStatus.pendiente => 'Pendiente',
      SmxSaldiFyClienteStatus.aceptado => 'Aprobado',
      SmxSaldiFyClienteStatus.archivado => 'Archivado',
      SmxSaldiFyClienteStatus.invalido => '',
      SmxSaldiFyClienteStatus.usuarioNoCorresponde => '',
    };
  }

  int get relaSysuser10Anfitrion {
    return _getInvitacionInt('RELA_SYSUSER10');
  }

  int get idSysuser11 {
    if (rstClienteCredito.getRowCount() == 0) return -1;

    return rstClienteCredito.getId();
  }

  String _getInvitacionValue(String field) {
    if (rstClienteCredito.getRowCount() == 0) return '';

    return rstClienteCredito.getValue(field)?.toString() ?? '';
  }

  int _getInvitacionInt(String field) {
    if (rstClienteCredito.getRowCount() == 0) return -1;

    final value = rstClienteCredito.getValue(field);
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? -1;
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
