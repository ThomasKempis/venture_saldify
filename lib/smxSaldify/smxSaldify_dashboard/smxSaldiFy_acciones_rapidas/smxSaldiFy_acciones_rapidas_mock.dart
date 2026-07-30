import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';

SmxRowSet getRstSmxSaldiFyAccionesRapidasMock() {
  return SmxRowSet.newRowSet(_rstSmxSaldiFyAccionesRapidasMock);
}

final List<Map<String, dynamic>> _rstSmxSaldiFyAccionesRapidasMock = [
  {'ICON_KEY': 'CLIENTE', 'LABEL': 'Cliente'},
  {'ICON_KEY': 'PRODUCTOS', 'LABEL': 'Productos'},
  {'ICON_KEY': 'REPORTES', 'LABEL': 'Reportes'},
  {'ICON_KEY': 'COBRANZA', 'LABEL': 'Cobranza'},
  {'ICON_KEY': 'ARCHIVADOS', 'LABEL': 'Archivados'},
];
