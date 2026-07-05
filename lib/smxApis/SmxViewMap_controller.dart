import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_core_connect/smxJson/smxJsonGeo.dart';
import 'package:venture_core_connect/smxWebSocket/smxChannels/smxWebSocketGeoManager.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxTmpScreen.dart';
import 'package:latlong2/latlong.dart';

class SmxViewMap_controller extends SmxTmpCtl {
  static final int REFRESH = 11;

  final SmxWebSocketGeoManager _socket = SmxWebSocketGeoManager();

  final ValueNotifier<List<Marker>> markersNotifier = ValueNotifier([]);
  final SmxController controller;
  final SmxRowSet? rstDataUsuarioMovil;
  final bool onLine;

  late LatLng currentPosition;
  late final MapController mapController;

  //int _updateZoomCounter = 0;
  Size mapSize = Size.zero;
  bool _isCallingGeolocacion = false;

  int idSysUser10 = -1;
  String correoUser = '';
  String nombreUser = '';

  SmxViewMap_controller({
    required this.controller,
    required this.onLine,
    this.rstDataUsuarioMovil,
  }) {
    mapController = MapController();

    if (rstDataUsuarioMovil != null &&
        rstDataUsuarioMovil!.getRowCount() == 1) {
      rstDataUsuarioMovil!.first();
      idSysUser10 = rstDataUsuarioMovil!.getId();
      correoUser = rstDataUsuarioMovil!.getValue('SYSUSER10_CORREO') ?? '';
      nombreUser = rstDataUsuarioMovil!.getValue('SYSUSER10_NOMBRES') ?? '';
    }

    if (onLine) {
      _initSocket();
    }
  }

  void _initSocket() async {
    _socket.getConnection();
    _socket.setCallback((smxJsonGeo) {
      markersNotifier.value = _loadMarkersFromInvitados(smxJsonGeo);
      _centerMapToAllMarkers();
    });
  }

  void disposeCannel() {
    _socket.dispose();
  }

  String formatCurrentLocation() {
    return "${currentPosition.latitude},${currentPosition.longitude}";
  }

  LatLng formatLocation(String location) {
    List<String> values = location.split(',');
    LatLng reto = LatLng(0, 0);

    if (values.length == 2 &&
        values[0].trim().isNotEmpty &&
        values[1].trim().isNotEmpty) {
      final latitud = double.tryParse(values[0].trim());
      final longitud = double.tryParse(values[1].trim());

      if (latitud != null && longitud != null) {
        reto = LatLng(latitud, longitud);
      }
    }

    return reto;
  }

  void callGeolocacion({
    required BuildContext context,
    String? correoInvitado,
    bool superaDistancia = false,
    Function(String)? onGeoDistancia,
    Function(String)? onGeolocacion,
  }) async {
    if (_isCallingGeolocacion) {
      return;
    }

    _isCallingGeolocacion = true;

    if (correoInvitado == null || correoInvitado.isEmpty) {
      await _sendCurrentLocation();

      if (superaDistancia && onGeoDistancia != null) {
        onGeoDistancia(formatCurrentLocation());
      }

      if (onGeolocacion != null) {
        onGeolocacion(formatCurrentLocation());
      }

      _isCallingGeolocacion = false;

      return;
    }

    try {
      if (idSysUser10 <= 0) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario no disponible')),
          );
        }
        return;
      }

      removeSql('SYSUSER10I');
      addSql(
        'SYSUSER10I',
        "Select * from PRD_SYSUSER11('C', '$correoInvitado', $idSysUser10)",
      );
      await getRowSetFuture('SYSUSER10I');
      SmxRowSet rst = getRowset('SYSUSER10I');
      rst.first();

      // Mostrar mensaje según resultado
      int result = rst.getValue('SYSUSER11_OK');
      String message;
      switch (result) {
        case 0:
          message = 'Invitado no encontrado';
          break;
        case 1:
          message = 'Invitado encontrado';
          break;
        case 2:
          message = 'Invitado agregado';
          break;
        default:
          message = 'Operación completada';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      // manejar error
    } finally {
      await _sendCurrentLocation();
      _isCallingGeolocacion = false;
    }
  }

  Future<void> _sendCurrentLocation() async {
    if (idSysUser10 <= 0) return;
    await _socket.send(_smxJsonGeo(), true);
  }

  List<Marker> _loadMarkersFromInvitados(SmxJsonGeo jsonGeoRecibido) {
    if (jsonGeoRecibido.invitadosAceptados.isEmpty) {
      return [];
    }

    return jsonGeoRecibido.invitadosAceptados.entries
        .map((entry) {
          final geoUsuario = entry.value;

          // Verificar si tiene locación válida
          if (geoUsuario.locacion.isEmpty ||
              !geoUsuario.locacion.contains(',')) {
            return null; // Retornar null para luego filtrar
          }

          try {
            final coords = geoUsuario.locacion.split(',');
            final lat = double.parse(coords[0].trim());
            final lng = double.parse(coords[1].trim());

            return Marker(
              point: LatLng(lat, lng),
              width: 50.0,
              height: 50.0,
              child: Tooltip(
                message:
                    '${geoUsuario.nombre}\n${geoUsuario.correo}\n${geoUsuario.fechaFormat}',
                child: const Icon(
                  Icons.person_pin,
                  color: Colors.green,
                  size: 36.0,
                ),
              ),
            );
          } catch (e) {
            debugPrint('Error parsing location for ${geoUsuario.nombre}: $e');
            return null;
          }
        })
        .where((marker) => marker != null) // Filtra los nulls
        .toList()
        .cast<Marker>(); // Convierte List<Marker?> a List<Marker>
  }

  SmxJsonGeo _smxJsonGeo() {
    final geo = SmxJsonGeo()
      ..jsonSend = jsonSend
      ..idSysUser10 = idSysUser10
      ..correo = correoUser
      ..nombre = nombreUser
      ..locacion = formatCurrentLocation()
      ..fecha = DateTime.now();

    return geo;
  }

  void _centerMapToAllMarkers() {
    final allPoints = [
      currentPosition,
      ...markersNotifier.value.map((m) => m.point),
    ];

    if (allPoints.isEmpty) {
      centerMap();
      return;
    }

    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (final p in allPoints) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    final centerLat = (minLat + maxLat) / 2;
    final centerLng = (minLng + maxLng) / 2;
    final center = LatLng(centerLat, centerLng);

    const double WORLD_DIM = 256;
    const double MAX_ZOOM = 18;

    double latFraction = (latRad(maxLat) - latRad(minLat)).abs() / pi;
    double lngDiff = maxLng - minLng;
    if (lngDiff < 0) lngDiff += 360;
    double lngFraction = lngDiff / 360;

    double latZoom = zoom(mapSize.height, WORLD_DIM, latFraction);
    double lngZoom = zoom(mapSize.width, WORLD_DIM, lngFraction);

    double zoomCalc = min(min(latZoom, lngZoom), MAX_ZOOM);

    mapController.move(center, zoomCalc);
  }

  double latRad(double lat) {
    final sinLat = sin(lat * pi / 180);
    return log((1 + sinLat) / (1 - sinLat)) / 2;
  }

  double zoom(double mapPx, double worldPx, double fraction) {
    return (log(mapPx / worldPx / fraction) / ln2);
  }

  void centerMap() {
    mapController.move(currentPosition, mapController.camera.zoom);
  }
}

/*
    _updateZoomCounter++;
    if (_updateZoomCounter < REFRESH) {
      centerMap();
      return;
    }
    _updateZoomCounter = 0;
    */
