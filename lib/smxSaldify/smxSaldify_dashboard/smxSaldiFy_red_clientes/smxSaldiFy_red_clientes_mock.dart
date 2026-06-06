import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

SmxRowSet getRstSmxSaldiFyMetricasMock() {
  return SmxRowSet.newRowSet(_rstSmxSaldiFyMetricasMock);
}

final List<Map<String, dynamic>> _rstSmxSaldiFyMetricasMock = [
  {'LABEL': 'Total vendido', 'VALUE': r'$184,250', 'NOTE': '+12% este corte'},
  {'LABEL': 'Credito entregado', 'VALUE': r'$96,000', 'NOTE': '8 clientes'},
  {'LABEL': 'Pagos recibidos', 'VALUE': r'$42,780', 'NOTE': '18 movimientos'},
  {'LABEL': 'Saldo pendiente', 'VALUE': r'$53,220', 'NOTE': '3 por vencer'},
];
