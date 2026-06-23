import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

SmxRowSet getRstSmxSaldiFyAccionesRapidasMock() {
  return SmxRowSet.newRowSet(_rstSmxSaldiFyAccionesRapidasMock);
}

final List<Map<String, dynamic>> _rstSmxSaldiFyAccionesRapidasMock = [
  {'ICON_KEY': 'CLIENTE', 'LABEL': 'Cliente'},
  {'ICON_KEY': 'ARCHIVADOS', 'LABEL': 'Archivados'},
  {'ICON_KEY': 'VENCIDOS', 'LABEL': 'Vencimientos'},
];
