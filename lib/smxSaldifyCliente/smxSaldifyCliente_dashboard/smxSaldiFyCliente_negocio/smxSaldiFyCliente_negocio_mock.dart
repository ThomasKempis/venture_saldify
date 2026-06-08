import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

SmxRowSet getRstSmxSaldiFyClienteNegocioMock() {
  return SmxRowSet.newRowSet(_rstSmxSaldiFyClienteNegocioMock);
}

final List<Map<String, dynamic>> _rstSmxSaldiFyClienteNegocioMock = [
  {
    'NEGOCIO': 'Comercial Rivera',
    'ESTADO': 'Aprobado',
    'CORTE': '15 Jun',
    'CONTACTO': 'WhatsApp del negocio',
    'MENSAJE':
        'Tus compras provistas se cargan a credito y aparecen en saldo pendiente.',
  },
];
