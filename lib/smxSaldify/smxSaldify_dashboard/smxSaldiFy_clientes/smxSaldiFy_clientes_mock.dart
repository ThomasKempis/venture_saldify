import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

SmxRowSet getRstSmxSaldiFyClientesMock() {
  return SmxRowSet.newRowSet(_rstSmxSaldiFyClientesMock);
}

final List<Map<String, dynamic>> _rstSmxSaldiFyClientesMock = [
  {
    'UUID_INVITADO': 'f0819499-f101-4e6f-a5fd-190c401d21a1',
    'NAME': 'Maria Lopez',
    'CORREO': 'maria.lopez@gmail.com',
    'TELEFONO': '4437300242',
    'STATUS': 'Al dia',
    'STATUS_TYPE': 'ok',
    'CUT_DATE': '15 Jun',
    'CREDIT': r'$18,000',
    'BALANCE': r'$4,800',
  },
  {
    'UUID_INVITADO': '66d2f242-17b6-41fb-8a7c-a6fa13ce9c2b',
    'NAME': 'Carlos Rivera',
    'CORREO': 'carlos.rivera@gmail.com',
    'TELEFONO': '2213948527',
    'STATUS': 'Por vencer',
    'STATUS_TYPE': 'warning',
    'CUT_DATE': '06 Jun',
    'CREDIT': r'$12,500',
    'BALANCE': r'$7,100',
  },
  {
    'UUID_INVITADO': '240ec3bf-5204-479f-b7f3-893c35c15d48',
    'NAME': 'Ana Torres',
    'CORREO': 'ana.torres@gmail.com',
    'TELEFONO': '4436721905',
    'STATUS': 'Vencido',
    'STATUS_TYPE': 'danger',
    'CUT_DATE': '31 May',
    'CREDIT': r'$20,000',
    'BALANCE': r'$11,200',
  },
  {
    'UUID_INVITADO': '8574f780-1cb9-4a0c-91db-e9783c65b529',
    'NAME': 'Luis Mendoza',
    'CORREO': 'luis.mendoza@gmail.com',
    'TELEFONO': '2227394816',
    'STATUS': 'Al dia',
    'STATUS_TYPE': 'ok',
    'CUT_DATE': '20 Jun',
    'CREDIT': r'$15,000',
    'BALANCE': r'$2,900',
  },
  {
    'UUID_INVITADO': '88f8ccb3-72de-4fae-805a-d83fcbd34cf6',
    'NAME': 'Sofia Ramirez',
    'CORREO': 'sofia.ramirez@gmail.com',
    'TELEFONO': '2215837049',
    'STATUS': 'Por vencer',
    'STATUS_TYPE': 'warning',
    'CUT_DATE': '08 Jun',
    'CREDIT': r'$9,500',
    'BALANCE': r'$5,600',
  },
  {
    'UUID_INVITADO': 'c0ea6d77-c36e-44f7-a443-ff30ca1c68ec',
    'NAME': 'Miguel Herrera',
    'CORREO': 'miguel.herrera@gmail.com',
    'TELEFONO': '4439152680',
    'STATUS': 'Vencido',
    'STATUS_TYPE': 'danger',
    'CUT_DATE': '29 May',
    'CREDIT': r'$16,000',
    'BALANCE': r'$8,750',
  },
];
