import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_core_connect/smxJson/SmxJsonUtil.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxShowDialog/smxShowDialogs.dart';
import 'package:venture_widgets/smxTextField/smxTextField.dart';

class SmxSaldiFyClienteController extends SmxController {
  late SmxRowSet rstSysuser10;
  late SmxRowSet rstSysuser11;

  final int relaSysuser10Cliente;

  bool lastSaveOk = false;
  bool isCorreoResolved = false;
  bool datosEditable = true;
  bool existingSysuser10 = false;
  int resolveVersion = 0;
  int editaFind = -1;

  String correoBusqueda = '';
  String correoResolved = '';

  SmxSaldiFyClienteController({
    required super.alias,
    required super.data,
    this.relaSysuser10Cliente = -1,
  });

  bool get isUpdate => relaSysuser10Cliente > 0;
  bool get isDatosReadOnly => !datosEditable;

  String get saveButtonLabel {
    if (isUpdate && !datosEditable) {
      return 'Cerrar';
    }
    return 'Guardar cliente';
  }

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    addSql(
      'SYSUSER10',
      isUpdate
          ? 'select * from SYSUSER10_CAB_MOVIL where ID_SYSUSER10 = $relaSysuser10Cliente'
          : 'select * from SYSUSER10_CAB_MOVIL where 1 = 0',
    );

    if (!isUpdate) {
      addSql('SYSUSER11', 'select * from SYSUSER11_DET_CONTACTOS where 1 = 0');
    }

    await getRowSetFuture('SYSUSER10');

    rstSysuser10 = getRowset('SYSUSER10');
    rstSysuser10.tabla = 'SYSUSER10_CAB_MOVIL';

    if (isUpdate) {
      data.accion = AccionNN.W;
      rstSysuser10.first();
      rstSysuser10.setAccion(AccionNN.W);
      final correo =
          rstSysuser10.getValue('SYSUSER10_CORREO')?.toString() ?? '';
      correoBusqueda = _getGmailUser(correo);
      correoResolved = _buildGmailAddress(correo);
      _setCorreoLocalPart();
    } else {
      rstSysuser11 = getRowset('SYSUSER11');
      rstSysuser11.tabla = 'SYSUSER11_DET_CONTACTOS';

      data.accion = AccionNN.I;
      rstSysuser10.insert();
      _setDefaults();
    }

    data.tablaTroncalRst = rstSysuser10;
    data.tablaTroncal = 'SYSUSER10_CAB_MOVIL';
  }

  Future<bool> resolveCorreo(String value) async {
    final context = data.context;
    if (context == null) return false;

    isCorreoResolved = false;
    existingSysuser10 = false;
    datosEditable = true;
    editaFind = -1;

    if (!_isValidGmailUser(value)) {
      showValidDialog(
        context,
        mensaje: 'Debe ingresar un usuario Gmail valido.',
      );
      return false;
    }

    final correo = _buildGmailAddress(value);
    correoBusqueda = _getGmailUser(correo);
    correoResolved = correo;

    removeSql('QRY_SYSUSER10_FIND');
    addSql(
      'QRY_SYSUSER10_FIND',
      'select * from QRY_SYSUSER10_FIND('
          '${SmxConstants.controllerMain.rstSysUser10.getId()}, '
          "'${_sql(correo)}', "
          '${isUpdate ? 0 : 1})',
    );

    await showDialogWait(context, () async {
      await getRowSetFuture('QRY_SYSUSER10_FIND');
    });

    if (jsonSend.getError() != null) {
      final currentContext = data.context;
      if (currentContext != null && currentContext.mounted) {
        showSystemErrorDialog(currentContext, message: jsonSend.error!);
      }
      return false;
    }

    final rstFind = getRowset('QRY_SYSUSER10_FIND');
    existingSysuser10 = rstFind.getRowCount() > 0;

    if (!existingSysuser10) {
      editaFind = 1;
      await _prepareNotFoundEmail(correo);
      _markResolved();
      return true;
    }

    rstFind.first();

    final idSysuser10 = rstFind.getId();
    final edita = rstFind.getValue('EDITA');
    editaFind = edita;

    if (isUpdate && idSysuser10 > 0 && idSysuser10 != relaSysuser10Cliente) {
      showValidDialog(
        context,
        mensaje: 'Este correo pertenece a otro cliente.',
      );
      return false;
    }

    if (!isUpdate && edita == 2) {
      isCorreoResolved = false;
      showValidDialog(context, mensaje: 'Ya esta registrado en mi sistema.');
      return false;
    }

    datosEditable = edita == 1;
    _setSysuser10FromFind(rstFind, correo);
    _configureSysuser10Action();
    _markResolved();

    return true;
  }

  @override
  Future<void> save() async {
    lastSaveOk = false;

    final context = data.context;
    if (context == null) return;

    if (!isCorreoResolved) {
      showValidDialog(context, mensaje: 'Debe buscar el correo del cliente.');
      return;
    }

    if (editaFind == 2 && !isUpdate) {
      showValidDialog(context, mensaje: 'Ya esta registrado en mi sistema.');
      return;
    }

    if (isUpdate && !datosEditable) {
      lastSaveOk = true;
      return;
    }

    if (datosEditable) {
      if (!validateWidgets(context)) {
        return;
      }

      if (!_validateSpecialFields(context)) {
        return;
      }

      final correo = _buildGmailAddress(getText('SYSUSER10_CORREO'));
      rstSysuser10.update('SYSUSER10_CORREO', correo);
      rstSysuser10.update('SYSUSER10_CORREO_01', correo);
    }

    if (!isUpdate) {
      if (existingSysuser10 && !datosEditable) {
        await _saveRelacionOnly(context);
      } else {
        _setRelacionPendiente();
        await _saveSysuser10(context);
      }
      return;
    }

    await _saveSysuser10(context);
  }

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}

  Future<void> _prepareNotFoundEmail(String correo) async {
    if (!isUpdate) {
      removeSql('SYSUSER10');
      addSql('SYSUSER10', 'select * from SYSUSER10_CAB_MOVIL where 1 = 0');
      await getRowSetFuture('SYSUSER10');

      rstSysuser10 = getRowset('SYSUSER10');
      rstSysuser10.tabla = 'SYSUSER10_CAB_MOVIL';
      rstSysuser10.insert();
      _setDefaults();
      data.accion = AccionNN.I;
    }

    rstSysuser10.first();
    rstSysuser10.update('SYSUSER10_CORREO', _getGmailUser(correo));
    rstSysuser10.update('SYSUSER10_CORREO_01', correo);
    setText('SYSUSER10_CORREO', _getGmailUser(correo));

    data.tablaTroncalRst = rstSysuser10;
    data.tablaTroncal = 'SYSUSER10_CAB_MOVIL';
  }

  void _setDefaults() {
    rstSysuser10.update('RELA_SYSJSON02', null);
    rstSysuser10.update('SYSUSER10_UUID', const Uuid().v4());
    rstSysuser10.update('SYSUSER10_NOMBRES', '');
    rstSysuser10.update('SYSUSER10_APELLIDOS', '');
    rstSysuser10.update('SYSUSER10_TELEFONO', '');
    rstSysuser10.update('SYSUSER10_CORREO', '');
    rstSysuser10.update('SYSUSER10_CORREO_01', '');
    rstSysuser10.update('SYSUSER10_FECHA', DateTime.now());
    rstSysuser10.update('SYSUSER10_GEOLOC_ULT', '');
  }

  void _setSysuser10FromFind(SmxRowSet rstFind, String correo) {
    rstSysuser10.first();
    rstSysuser10.update('RELA_SYSJSON02', rstFind.getValue('RELA_SYSJSON02'));
    rstSysuser10.update('ID_SYSUSER10', rstFind.getId());
    rstSysuser10.update(
      'SYSUSER10_NOMBRES',
      rstFind.getValue('SYSUSER10_NOMBRES') ?? '',
    );
    rstSysuser10.update(
      'SYSUSER10_APELLIDOS',
      rstFind.getValue('SYSUSER10_APELLIDOS') ?? '',
    );
    rstSysuser10.update(
      'SYSUSER10_TELEFONO',
      rstFind.getValue('SYSUSER10_TELEFONO') ?? '',
    );
    rstSysuser10.update('SYSUSER10_CORREO', _getGmailUser(correo));
    rstSysuser10.update('SYSUSER10_CORREO_01', correo);
    setText('SYSUSER10_CORREO', _getGmailUser(correo));
    rstSysuser10.update(
      'SYSUSER10_FECHA',
      rstFind.getValue('SYSUSER10_FECHA') ?? DateTime.now(),
    );

    final geoloc = rstFind.getValue('SYSUSER10_GEOLOC_ULT');
    if (geoloc != null) {
      rstSysuser10.update('SYSUSER10_GEOLOC_ULT', geoloc);
    }
  }

  void _configureSysuser10Action() {
    if (datosEditable) {
      data.accion = AccionNN.W;
      rstSysuser10.setAccion(AccionNN.W);
    } else {
      rstSysuser10.setAccion(AccionNN.N);
    }

    data.tablaTroncalRst = rstSysuser10;
    data.tablaTroncal = 'SYSUSER10_CAB_MOVIL';
  }

  void _markResolved() {
    isCorreoResolved = true;
    resolveVersion++;
  }

  bool _validateSpecialFields(BuildContext context) {
    if (!(getValueFactory('SYSUSER10_TELEFONO').getWidGet() as SmxTextField)
        .isValidaStringSpecial) {
      showValidDialog(context, mensaje: 'Debe ingresar un telefono valido.');
      return false;
    }

    if (!_isValidGmailUser(getText('SYSUSER10_CORREO'))) {
      showValidDialog(
        context,
        mensaje: 'Debe ingresar un usuario Gmail valido.',
      );
      return false;
    }

    return true;
  }

  void _setRelacionPendiente() {
    _prepareRelacionPendiente();
    rstSysuser10.setDetTransaction(rstSysuser11);
  }

  void _prepareRelacionPendiente() {
    rstSysuser10.first();

    if (rstSysuser11.getRowCount() == 0) {
      rstSysuser11.insert();
    } else {
      rstSysuser11.first();
    }

    rstSysuser11.tabla = 'SYSUSER11_DET_CONTACTOS';
    rstSysuser11.setAccion(AccionNN.I);
    rstSysuser11.update(
      'RELA_SYSUSER10_ANFITRION',
      SmxConstants.controllerMain.rstSysUser10.getId(),
    );
    rstSysuser11.update('RELA_SYSUSER10', rstSysuser10.getId());
    rstSysuser11.update('SYSUSER11_STATUS', 0);
  }

  Future<void> _saveSysuser10(BuildContext context) async {
    await showDialogWait(context, () async {
      await callTroncalSave(rstSysuser10);
    });

    if (jsonSend.getError() != null) {
      final currentContext = data.context;
      if (currentContext != null && currentContext.mounted) {
        showSystemErrorDialog(currentContext, message: jsonSend.error!);
      }
      return;
    }

    lastSaveOk = true;
  }

  Future<void> _saveRelacionOnly(BuildContext context) async {
    _prepareRelacionPendiente();

    data.accion = AccionNN.I;
    data.tablaTroncalRst = rstSysuser11;
    data.tablaTroncal = 'SYSUSER11_DET_CONTACTOS';

    await showDialogWait(context, () async {
      await callTroncalSave(rstSysuser11);
    });

    if (jsonSend.getError() != null) {
      final currentContext = data.context;
      if (currentContext != null && currentContext.mounted) {
        showSystemErrorDialog(currentContext, message: jsonSend.error!);
      }
      return;
    }

    lastSaveOk = true;
  }

  String _sql(String value) {
    return value.replaceAll("'", "''");
  }

  void _setCorreoLocalPart() {
    final correo = rstSysuser10.getValue('SYSUSER10_CORREO')?.toString() ?? '';
    rstSysuser10.update('SYSUSER10_CORREO', _getGmailUser(correo));
  }

  String _buildGmailAddress(String value) {
    return '${_getGmailUser(value)}@gmail.com';
  }

  String _getGmailUser(String value) {
    final correo = value.trim().toLowerCase();
    if (correo.endsWith('@gmail.com')) {
      return correo.substring(0, correo.length - '@gmail.com'.length).trim();
    }
    return correo;
  }

  bool _isValidGmailUser(String value) {
    final correo = value.trim().toLowerCase();
    if (correo.isEmpty) return false;
    if (correo.contains('@') && !correo.endsWith('@gmail.com')) return false;

    final user = _getGmailUser(correo);
    if (user.isEmpty || user.contains('@')) return false;

    return RegExp(r'^[a-z0-9._%+-]+$').hasMatch(user);
  }
}
