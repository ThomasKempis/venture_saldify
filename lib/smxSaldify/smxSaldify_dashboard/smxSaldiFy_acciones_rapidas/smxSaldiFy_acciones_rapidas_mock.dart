import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

const smxSaldiFyAccionesRapidasCorteMock = 'Corte: 15 Jun';

SmxRowSet getRstSmxSaldiFyAccionesRapidasMock() {
  return SmxRowSet.newRowSet(_rstSmxSaldiFyAccionesRapidasMock);
}

final List<Map<String, dynamic>> _rstSmxSaldiFyAccionesRapidasMock = [
  {'ICON_KEY': 'CLIENTE', 'LABEL': 'Cliente'},
  {'ICON_KEY': 'PAGO', 'LABEL': 'Pago'},
  {'ICON_KEY': 'CREDITO', 'LABEL': 'Credito'},
  {'ICON_KEY': 'REPORTE', 'LABEL': 'Reporte'},
];
