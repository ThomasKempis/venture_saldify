import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';

class SmxSaldiFyMiRedController extends SmxController {
  static const String aliasMiRed = 'QRY_SYSUSER11_MI_RED';

  final int idRaiz;
  final int idActivo;
  SmxRowSet rstMiRed = SmxRowSet.newRowSet([]);
  final List<SmxMiRedNode> nodes = [];

  SmxSaldiFyMiRedController({
    required super.alias,
    required super.data,
    required this.idRaiz,
    this.idActivo = 0,
  });

  @override
  Future<void> init() async {
    if (isBeginDB()) return;
    beginDB();

    removeSql(aliasMiRed);
    addSql(
      aliasMiRed,
      'select * from QRY_SYSUSER11_MI_RED($idRaiz, $idActivo)',
    );

    await getRowSetFuture(aliasMiRed);

    if (jsonSend.getError() != null) {
      return;
    }

    rstMiRed = getRowset(aliasMiRed);
    _loadNodes();
  }

  void _loadNodes() {
    nodes.clear();

    for (var index = 0; index < rstMiRed.getRowCount(); index++) {
      rstMiRed.index(index);
      nodes.add(
        SmxMiRedNode(
          nivel: _getInt('NIVEL'),
          path: _getString('PATH'),
          idSysuser11: _getInt('ID_SYSUSER11'),
          relaSysuser10Padre: _getInt('RELA_SYSUSER10_PADRE'),
          relaSysuser10Hijo: _getInt('RELA_SYSUSER10_HIJO'),
          status: _getInt('SYSUSER11_STATUS'),
          nombres: _getString('SYSUSER10_NOMBRES'),
          apellidos: _getString('SYSUSER10_APELLIDOS'),
          correo: _getString('SYSUSER10_CORREO'),
          telefono: _getString('SYSUSER10_TELEFONO'),
        ),
      );
    }
  }

  int _getInt(String field) {
    final value = rstMiRed.getValue(field);
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  String _getString(String field) {
    return rstMiRed.getValue(field)?.toString().trim() ?? '';
  }

  bool get hasNodes => nodes.isNotEmpty;

  @override
  Future<void> save() async {}

  @override
  Future<void> cancel() async {}

  @override
  Future<void> delete() async {}

  @override
  void filtro(Function(String, Cancela) refresh) {}
}

class SmxMiRedNode {
  final int nivel;
  final String path;
  final int idSysuser11;
  final int relaSysuser10Padre;
  final int relaSysuser10Hijo;
  final int status;
  final String nombres;
  final String apellidos;
  final String correo;
  final String telefono;

  const SmxMiRedNode({
    required this.nivel,
    required this.path,
    required this.idSysuser11,
    required this.relaSysuser10Padre,
    required this.relaSysuser10Hijo,
    required this.status,
    required this.nombres,
    required this.apellidos,
    required this.correo,
    required this.telefono,
  });

  String get nombreCompleto {
    final value = '$nombres $apellidos'.trim();
    return value.isEmpty ? 'Sin nombre' : value;
  }

  String get statusLabel {
    return switch (status) {
      1 => 'Activo',
      2 => 'Archivado',
      _ => 'Pendiente',
    };
  }
}
