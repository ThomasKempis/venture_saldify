import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxController/smxRowSetTrack.dart';

import '../../../smxApis/smxConstants.dart';

class SmxSaldiFyCobranzaController extends SmxController {
  SmxRowSet rstClientes = SmxRowSet.newRowSet([]);
  List<SmxSaldiFyCobranzaCliente> clientes = [];

  SmxSaldiFyCobranzaController({required super.alias, required super.data});

  @override
  Future<void> init() async {
    if (isBeginDB()) return;

    beginDB();

    addSql(
      'QRY_SYSUSER11_COBRANZA',
      'select * from QRY_SYSUSER11_COBRANZA(1, ${SmxConstants.controllerMain.rstSysUser10.getId()})',
    );

    await SmxRowSetTrack.run(
      controller: this,
      call: () => getRowSetFuture('QRY_SYSUSER11_COBRANZA'),
    );

    rstClientes = getRowset('QRY_SYSUSER11_COBRANZA');
    rstClientes.first();
    clientes = _buildClientes();
  }

  bool get hasClientes => clientes.isNotEmpty;

  List<SmxSaldiFyCobranzaCliente> _buildClientes() {
    final items = <SmxSaldiFyCobranzaCliente>[];

    rstClientes.beforeFirst();
    while (rstClientes.next()) {
      final status = _stringValue('SYSUSER12_STATUS');
      final balance = _doubleValue('SYSUSER12_BALANCE');

      items.add(
        SmxSaldiFyCobranzaCliente(
          idSysuser11: rstClientes.getId(),
          relaSysuser10Cliente: _intValue('RELA_SYSUSER10_CLIENTE'),
          name: _stringValue('SYSUSER10_INVITADO'),
          phone: _stringValue('SYSUSER10_TELEFONO'),
          email: _stringValue('SYSUSER10_CORREO'),
          location: _stringValue('SYSUSER10_GEOLOC_ULT'),
          cutDate: _stringValue('SYSUSER12_CORTE'),
          balance: balance,
          balanceText: rstClientes.getValueFormatAmount('SYSUSER12_BALANCE'),
          dias: _intValue('SYSUSER12_DIAS'),
          status: status,
          statusType: _stringValue('SYSUSER12_STATUS_TIPO'),
        ),
      );
    }

    rstClientes.first();
    return items;
  }

  String _stringValue(String field) {
    return rstClientes.getValue(field)?.toString().trim() ?? '';
  }

  int _intValue(String field) {
    final value = rstClientes.getValue(field);
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? -1;
  }

  double _doubleValue(String field) {
    return rstClientes.getValue(field);
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

class SmxSaldiFyCobranzaCliente {
  final int idSysuser11;
  final int relaSysuser10Cliente;
  final String name;
  final String phone;
  final String email;
  final String location;
  final String cutDate;
  final double balance;
  final String balanceText;
  final int dias;
  final String status;
  final String statusType;

  const SmxSaldiFyCobranzaCliente({
    required this.idSysuser11,
    required this.relaSysuser10Cliente,
    required this.name,
    required this.phone,
    required this.email,
    required this.location,
    required this.cutDate,
    required this.balance,
    required this.balanceText,
    required this.dias,
    required this.status,
    required this.statusType,
  });

  bool get hasLocation => _parseLocation(location) != null;

  static ({double lat, double lng})? _parseLocation(String value) {
    final parts = value.split(',');
    if (parts.length != 2) return null;

    final lat = double.tryParse(parts[0].trim());
    final lng = double.tryParse(parts[1].trim());
    if (lat == null || lng == null) return null;

    return (lat: lat, lng: lng);
  }
}
