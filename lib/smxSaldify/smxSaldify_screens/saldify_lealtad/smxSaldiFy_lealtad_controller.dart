import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_saldify/smxApis/smxConstants.dart';
import 'package:venture_saldify/smxSaldify/smxSaldify_dashboard/smxSaldiFy_invita_clientes/smxSaldiFy_invita_clientes_models.dart';
import 'package:venture_saldify/smxSaldify/smxSaldify_dashboard/smxSaldiFy_invita_clientes/smxSaldiFy_invita_service.dart';
import 'package:venture_saldify/smxApis/smxCodeSegu.dart'; 
import 'package:venture_widgets/smxClassDrivers.dart'; 
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxController/smxRowSetTrack.dart';

class SmxSaldiFyLealtadController extends SmxController {
  SmxSaldiFyInvitacionGenerada? _invitacion;
  SmxRowSet? _rstHistorial;
  bool _loadingInvitacion = false;
  bool _loadingHistorial = false;

  SmxSaldiFyInvitacionGenerada? get invitacion => _invitacion;
  SmxRowSet? get rstHistorial => _rstHistorial;
  bool get loadingInvitacion => _loadingInvitacion;
  bool get loadingHistorial => _loadingHistorial;

  SmxSaldiFyLealtadController({required super.alias, required super.data});

  @override
  Future<void> init() async {
    if (isBeginDB()) return;
    beginDB();
    
    await SmxRowSetTrack.run(
      controller: this,
      call: () => cargarTodo(),
    );
  }

  Future<void> cargarTodo() async {
    // Ejecución secuencial para evitar bloqueos
    await generarNuevaInvitacion();
    await cargarHistorial();
  }

  Future<void> generarNuevaInvitacion() async {
    if (_loadingInvitacion) return;
    _loadingInvitacion = true;
    notifyListeners();
    try {
      _invitacion = await SmxSaldifyInvitaService.crearInvitacion(
          prefijo: SmxSaldiFyInvitaStatus.SY);
    } finally {
      _loadingInvitacion = false;
      notifyListeners();
    }
  }


  Future<void> cargarHistorial() async {
    _loadingHistorial = true;
    notifyListeners();
    try {
      final idUsuario = SmxConstants.controllerMain.rstSysUser10.getId();
      
      removeSql('QRY_LEALTAD');
      addSql('QRY_LEALTAD', "select * from QRY_SYSUSER91($idUsuario)");

      await getRowSetFuture('QRY_LEALTAD');
      _rstHistorial = getRowset('QRY_LEALTAD');
    } finally {
      _loadingHistorial = false;
      notifyListeners();
    }
  }

  int get totalCompletados {
    if (_rstHistorial == null) return 0;
    int count = 0;

    for (var i = 0; i < _rstHistorial!.getRowCount(); i++) {
      _rstHistorial!.index(i);
      if (_rstHistorial!.getValue('SYSUSER91_FECHA_REG') != null) count++;
    }
    
    if (_rstHistorial!.getRowCount() > 0) {
      _rstHistorial!.first();
    }
    return count;
  }

  int get monedas => totalCompletados ~/ 5;
  int get estrellas => totalCompletados % 5;

  @override
  Future<void> save() async {}
  @override
  Future<void> delete() async {}
  @override
  Future<void> cancel() async {}
  @override
  void filtro(Function(String, Cancela) refresh) {}
}
