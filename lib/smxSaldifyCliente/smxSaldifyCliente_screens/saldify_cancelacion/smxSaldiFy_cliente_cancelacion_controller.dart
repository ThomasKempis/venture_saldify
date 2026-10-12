import 'package:flutter/material.dart';
import 'package:venture_widgets/smxClassDrivers.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import '../../../smxApis/smxConstants.dart';
import '../../../smxLayout/smx_decision_dialog.dart';
import '../../../smxLayout/smx_message_dialog.dart';

class SmxSaldiFyClienteCancelacionController extends SmxController {
  final TextEditingController explicacionController = TextEditingController();

  // Identidad SMX
  int idSysuser13 = 0;
  DateTime? sysuser13Fapl;

  // Estados del checklist
  bool saldoCero = false;
  bool sinComprasPendientes = false;
  bool sinPagosPendientes = false;

  final String anfitrionNombre;

  SmxSaldiFyClienteCancelacionController({
    required super.alias,
    required super.data,
    required this.anfitrionNombre,
  });

  @override
  Future<void> init() async {
    if (isBeginDB()) return;
    beginDB();

    final idUsuario = SmxConstants.controllerMain.rstSysUser10.getId();

    removeSql('QRY_CANCELACION');
    addSql(
      'QRY_CANCELACION',
      'select * from QRY_SYSUSER11_CANCELACION($idUsuario)',
    );

    await getRowSetFuture('QRY_CANCELACION');

    final rst = getRowset('QRY_CANCELACION');
    if (rst.getRowCount() > 0) {
      rst.first();
      
      // Asignación de identidad obligatoria
      idSysuser13 = rst.getValue('ID_SYSUSER13');
      sysuser13Fapl = rst.getValue('SYSUSER13_FAPL');

      // Asignación de lógica funcional
      saldoCero = rst.getValue('SYSUSER13_SALDO_CERO') == 1;
      sinComprasPendientes = rst.getValue('SYSUSER13_COMPRAS_PENDIENTE') == 1;
      sinPagosPendientes = rst.getValue('SYSUSER13_PAGOS_PENDIENTES') == 1;
    }
  }

  bool get puedeCancelar =>
      saldoCero && sinComprasPendientes && sinPagosPendientes;

  @override
  void dispose() {
    explicacionController.dispose();
    super.dispose();
  }

  Future<void> cancelarVinculo(BuildContext context) async {
    if (!puedeCancelar) return;

    final motivo = explicacionController.text.trim();
    if (motivo.isEmpty) {
      await showSmxMessageDialog(
        context,
        title: 'Falta información',
        message: 'Por favor, indica el motivo de la desvinculación',
        variant: SmxMessageVariant.validation,
      );
      return;
    }

    final confirmed = await showSmxDecisionDialog(
      context,
      title: 'Cancela relación',
      message:
          'Quieres cancelar la relación con el anfitrion $anfitrionNombre?',
      acceptText: 'Eliminar',
      variant: SmxDecisionVariant.danger,
    );

    if (!confirmed) return;

    if (context.mounted) {
      Navigator.of(context).pop();
    }
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
