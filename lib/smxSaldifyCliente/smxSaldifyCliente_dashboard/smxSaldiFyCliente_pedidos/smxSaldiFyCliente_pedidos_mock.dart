import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

SmxRowSet getRstSmxSaldiFyClientePedidosMock() {
  return SmxRowSet.newRowSet(_rstSmxSaldiFyClientePedidosMock);
}

final List<Map<String, dynamic>> _rstSmxSaldiFyClientePedidosMock = [
  {
    'PRODUCTO': 'Tenis deportivos',
    'IMPORTE': r'$2,400',
    'ESTADO': 'Provisto',
    'ESTADO_TIPO': 'approved',
    'FECHA': '07 Jun',
    'AFECTA_SALDO': true,
  },
  {
    'PRODUCTO': 'Mochila escolar',
    'IMPORTE': r'$1,250',
    'ESTADO': 'En revision',
    'ESTADO_TIPO': 'review',
    'FECHA': '07 Jun',
    'AFECTA_SALDO': false,
  },
  {
    'PRODUCTO': 'Uniforme completo',
    'IMPORTE': r'$3,100',
    'ESTADO': 'Provisto',
    'ESTADO_TIPO': 'approved',
    'FECHA': '05 Jun',
    'AFECTA_SALDO': true,
  },
  {
    'PRODUCTO': 'Audifonos',
    'IMPORTE': r'$600',
    'ESTADO': 'Solicitado',
    'ESTADO_TIPO': 'pending',
    'FECHA': '04 Jun',
    'AFECTA_SALDO': false,
  },
  {
    'PRODUCTO': 'Pago recibido',
    'IMPORTE': r'-$1,000',
    'ESTADO': 'Pagado',
    'ESTADO_TIPO': 'paid',
    'FECHA': '01 Jun',
    'AFECTA_SALDO': false,
  },
];
