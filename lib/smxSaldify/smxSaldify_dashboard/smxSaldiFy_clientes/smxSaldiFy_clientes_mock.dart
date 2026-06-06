import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

SmxRowSet getRstSmxSaldiFyClientesMock() {
  return SmxRowSet.newRowSet(_rstSmxSaldiFyClientesMock);
}

final List<Map<String, dynamic>> _rstSmxSaldiFyClientesMock = [
  {
    'NAME': 'Maria Lopez',
    'STATUS': 'Al dia',
    'STATUS_TYPE': 'ok',
    'CUT_DATE': '15 Jun',
    'CREDIT': r'$18,000',
    'BALANCE': r'$4,800',
  },
  {
    'NAME': 'Carlos Rivera',
    'STATUS': 'Por vencer',
    'STATUS_TYPE': 'warning',
    'CUT_DATE': '06 Jun',
    'CREDIT': r'$12,500',
    'BALANCE': r'$7,100',
  },
  {
    'NAME': 'Ana Torres',
    'STATUS': 'Vencido',
    'STATUS_TYPE': 'danger',
    'CUT_DATE': '31 May',
    'CREDIT': r'$20,000',
    'BALANCE': r'$11,200',
  },
  {
    'NAME': 'Luis Mendoza',
    'STATUS': 'Al dia',
    'STATUS_TYPE': 'ok',
    'CUT_DATE': '20 Jun',
    'CREDIT': r'$15,000',
    'BALANCE': r'$2,900',
  },
  {
    'NAME': 'Sofia Ramirez',
    'STATUS': 'Por vencer',
    'STATUS_TYPE': 'warning',
    'CUT_DATE': '08 Jun',
    'CREDIT': r'$9,500',
    'BALANCE': r'$5,600',
  },
  {
    'NAME': 'Miguel Herrera',
    'STATUS': 'Vencido',
    'STATUS_TYPE': 'danger',
    'CUT_DATE': '29 May',
    'CREDIT': r'$16,000',
    'BALANCE': r'$8,750',
  },
];
