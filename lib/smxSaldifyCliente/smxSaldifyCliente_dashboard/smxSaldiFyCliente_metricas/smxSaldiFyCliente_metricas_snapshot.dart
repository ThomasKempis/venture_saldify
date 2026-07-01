import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

class SmxSaldiFyClienteMetricasSnapshot {
  final double credito;
  final double disponible;
  final double compras;
  final double pagos;
  final double saldo;
  final double deudor;

  const SmxSaldiFyClienteMetricasSnapshot({
    required this.credito,
    required this.disponible,
    required this.compras,
    required this.pagos,
    required this.saldo,
    required this.deudor,
  });

  const SmxSaldiFyClienteMetricasSnapshot.empty()
    : credito = 0,
      disponible = 0,
      compras = 0,
      pagos = 0,
      saldo = 0,
      deudor = 0;

  factory SmxSaldiFyClienteMetricasSnapshot.fromRowSet(SmxRowSet? rstMetricas) {
    if (rstMetricas == null || rstMetricas.getRowCount() == 0) {
      return const SmxSaldiFyClienteMetricasSnapshot.empty();
    }

    rstMetricas.first();

    return SmxSaldiFyClienteMetricasSnapshot(
      credito: rstMetricas.getValue('SYSUSER12_CREDITO'),
      disponible: rstMetricas.getValue('SYSUSER12_DISPONIBLE'),
      compras: rstMetricas.getValue('SYSUSER12_COMPRAS'),
      pagos: rstMetricas.getValue('SYSUSER12_PAGOS'),
      saldo: rstMetricas.getValue('SYSUSER12_BALANCE'),
      deudor: rstMetricas.getValue('SYSUSER12_DEUDOR'),
    );
  }
}
