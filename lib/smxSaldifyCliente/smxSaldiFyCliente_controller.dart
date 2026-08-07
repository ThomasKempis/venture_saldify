import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';

import '../smxApis/smxConstants.dart';
import '../smxAuth/smxLogonMovil.dart';

enum SmxSaldiFyClienteStatus {
  pendiente,
  aceptado,
  archivado,
  invalido,
  usuarioNoCorresponde,
}

class SmxSaldiFyClienteController extends SmxController {
  final SmxLogonMovil controllerMain = SmxConstants.controllerMain;
  late SmxRowSet rstClienteCredito;
  SmxSaldiFyClienteStatus status = SmxSaldiFyClienteStatus.invalido;
  String? _mensajeInvitacion;

  SmxSaldiFyClienteController({required super.alias, required super.data});

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    final uuidAnfitrion = controllerMain.getUuidAnfitrion();
    if (uuidAnfitrion.isEmpty) {
      status = SmxSaldiFyClienteStatus.invalido;
      return;
    }

    const aliasSql = 'ADD_SYSUSER10_SYSUSER11';

    removeSql(aliasSql);

    addSTrans(
      aliasSql,
      "select * from ADD_SYSUSER10_SYSUSER11("
      "'${_sql(uuidAnfitrion)}', "
      "'${_sql(controllerMain.getCorreo())}')",
    );

    await getCallWS();

    rstClienteCredito = getRowset(aliasSql);

    if (rstClienteCredito.getRowCount() == 0) {
      status = SmxSaldiFyClienteStatus.invalido;
      return;
    }

    rstClienteCredito.first();

    final mensaje = rstClienteCredito.getValue('MENSAJE').trim();
    if (mensaje.isNotEmpty && mensaje.toUpperCase() != 'OK') {
      _mensajeInvitacion = mensaje;
      status = _getStatusInvitacion();
      return;
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
    if (_mensajeInvitacion != null) {
      return _mensajeInvitacion;
    }

    return switch (status) {
      SmxSaldiFyClienteStatus.aceptado => null,
      SmxSaldiFyClienteStatus.pendiente =>
        'Su invitación esta pendiente de aprobacion por el anfitrion.',
      SmxSaldiFyClienteStatus.archivado =>
        'Su relacion fue archivada por el anfitrion.',
      SmxSaldiFyClienteStatus.invalido => 'Su invitacion no es valida.',
      SmxSaldiFyClienteStatus.usuarioNoCorresponde =>
        'Esta invitación pertenece a otro usuario.',
    };
  }

  String get tituloValidacion {
    if (_mensajeInvitacion != null) {
      return status == SmxSaldiFyClienteStatus.archivado
          ? 'Vinculo archivado'
          : 'Estado de la invitación';
    }

    return switch (status) {
      SmxSaldiFyClienteStatus.pendiente => 'Invitacion pendiente',
      SmxSaldiFyClienteStatus.archivado => 'Vinculo archivado',
      SmxSaldiFyClienteStatus.invalido => 'Link de invitacion no valido',
      SmxSaldiFyClienteStatus.usuarioNoCorresponde =>
        'Invitación de otro usuario',
      SmxSaldiFyClienteStatus.aceptado => '',
    };
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

      return fullName;
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

  bool get conCatalogo => _getInvitacionInt('CON_CATALOGO') == 1;

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

  static String _sql(String value) {
    return value.replaceAll("'", "''");
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
