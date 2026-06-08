import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

SmxRowSet getRstSmxSaldiFyClienteResumenMock() {
  return SmxRowSet.newRowSet(_rstSmxSaldiFyClienteResumenMock);
}

final List<Map<String, dynamic>> _rstSmxSaldiFyClienteResumenMock = [
  {'LABEL': 'Credito asignado', 'VALUE': r'$18,000', 'NOTE': 'Limite aprobado'},
  {
    'LABEL': 'Credito disponible',
    'VALUE': r'$10,900',
    'NOTE': 'Despues de compras',
  },
  {'LABEL': 'Saldo pendiente', 'VALUE': r'$7,100', 'NOTE': 'Solo provistos'},
  {'LABEL': 'Pedidos en revision', 'VALUE': r'$1,850', 'NOTE': '2 pendientes'},
];
