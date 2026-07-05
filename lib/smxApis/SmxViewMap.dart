import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:venture_core_connect/smxConstants_core.dart';
import 'package:venture_core_connect/smxDataBase/smxRowSet.dart';
import 'package:venture_widgets/smxController/smxController.dart';
import 'package:venture_widgets/smxStatefulWidget.dart';
import 'package:venture_widgets/smxViewMap/smxViewMap_invitacion.dart';

import 'SmxViewMap_controller.dart';

/*
https://opencagedata.com/dashboard#geocoding
246ca60770914088904790fa7f26be2d
no lo uso pero por las dudas

Position? pos = await Geolocator.getLastKnownPosition();
 */

class SmxViewMap extends SmxStatefulWidget {
  final String geolocacion;
  final bool onLine;
  final bool isInvitar;
  final Function(String)? onGeolocacion;
  final Function(String)? onGeoDistancia;
  final int distanciaInicial;
  final SmxController controller;
  final SmxRowSet? rstDataUsuarioMovil;

  SmxViewMap({
    super.key,
    required this.geolocacion,
    required this.controller,
    this.onGeolocacion,
    this.onGeoDistancia,
    this.distanciaInicial = 5000,
    this.onLine = false,
    this.isInvitar = false,
    this.rstDataUsuarioMovil,
  });

  @override
  _SmxViewMap createState() => _SmxViewMap();
}

class _SmxViewMap extends State<SmxViewMap> {
  LatLng? _initialPosition;
  late SmxViewMap_controller _controllerSmxViewMap;
  StreamSubscription<Position>? _positionStream;
  DateTime _lastSent = DateTime.now().subtract(const Duration(minutes: 1));
  bool _initGeo = true;
  bool _isPositionReady = false;
  String _message = 'Cargando ubicacion';

  @override
  void initState() {
    super.initState();
    _controllerSmxViewMap = SmxViewMap_controller(
      controller: widget.controller,
      onLine: widget.onLine,
      rstDataUsuarioMovil: widget.rstDataUsuarioMovil,
    );

    _initPosition();
  }

  @override
  void didUpdateWidget(covariant SmxViewMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.geolocacion == widget.geolocacion &&
        oldWidget.onLine == widget.onLine) {
      return;
    }

    _positionStream?.cancel();
    _positionStream = null;
    _initialPosition = null;
    _isPositionReady = false;
    _message = 'Cargando ubicacion';
    _initGeo = true;

    _initPosition();
  }

  void _initPosition() {
    if (widget.onLine) {
      _loadCurrentDevicePosition();
      return;
    }

    _loadStaticPosition();
  }

  void _loadStaticPosition() {
    final location = _parseLocation(widget.geolocacion);
    if (location != null) {
      _setCurrentPosition(location, refresh: false);
      return;
    }

    _showMessage('Ubicacion no disponible');
  }

  Future<void> _loadCurrentDevicePosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final location = LatLng(position.latitude, position.longitude);
      SmxConstants_core.geoLocalizacion =
          '${location.latitude}, ${location.longitude}';

      if (!mounted) return;
      _setCurrentPosition(location);
      _startLiveLocationIfNeeded();
    } catch (_) {
      if (!mounted) return;
      _showMessage('No se pudo obtener la ubicacion');
    }
  }

  void _setCurrentPosition(
    LatLng location, {
    bool refresh = true,
    bool moveMap = false,
  }) {
    _controllerSmxViewMap.currentPosition = location;
    _initialPosition ??= location;
    _isPositionReady = true;

    if (moveMap) {
      try {
        _controllerSmxViewMap.mapController.move(
          location,
          _controllerSmxViewMap.mapController.camera.zoom,
        );
      } catch (_) {}
    }

    if (refresh && mounted) {
      setState(() {});
    }
  }

  void _showMessage(String value) {
    _message = value;
    _isPositionReady = false;

    if (mounted) {
      setState(() {});
    }
  }

  void _startLiveLocationIfNeeded() {
    if (!widget.onLine || _positionStream != null) return;
    _startLiveLocation();
  }

  void _startLiveLocation() async {
    try {
      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 5,
            ),
          ).listen((Position pos) {
            final currentPosition = LatLng(pos.latitude, pos.longitude);
            SmxConstants_core.geoLocalizacion =
                '${currentPosition.latitude}, ${currentPosition.longitude}';

            final initialPosition = _initialPosition ?? currentPosition;

            final double distanceInMeters = Geolocator.distanceBetween(
              initialPosition.latitude,
              initialPosition.longitude,
              currentPosition.latitude,
              currentPosition.longitude,
            );

            _setCurrentPosition(currentPosition, moveMap: true);

            final bool superaDistancia =
                distanceInMeters > widget.distanciaInicial;
            final bool superaTiempo =
                DateTime.now().difference(_lastSent) >
                const Duration(minutes: 1);

            if (superaDistancia || superaTiempo || _initGeo) {
              _initGeo = false;
              _initialPosition = currentPosition;
              _lastSent = DateTime.now();

              if (!mounted) return;
              _controllerSmxViewMap.callGeolocacion(
                context: context,
                superaDistancia: superaDistancia,
                onGeoDistancia: widget.onGeoDistancia,
                onGeolocacion: widget.onGeolocacion,
              );
            }
          });
    } catch (_) {}
  }

  LatLng? _parseLocation(String value) {
    final parts = value.split(',');
    if (parts.length != 2) return null;

    final latitude = double.tryParse(parts[0].trim());
    final longitude = double.tryParse(parts[1].trim());
    if (latitude == null || longitude == null) return null;
    if (latitude == 0.0 && longitude == 0.0) return null;

    return LatLng(latitude, longitude);
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _controllerSmxViewMap.disposeCannel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            _controllerSmxViewMap.mapSize = Size(
              constraints.maxWidth,
              constraints.maxHeight,
            );

            if (!_isPositionReady) {
              return _SmxMapMessage(message: _message);
            }

            return builderMap();
          },
        ),

        if (widget.isInvitar)
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: SmxViewMap_invitacion(
              onChangedMail: (correoInvitado) {
                _controllerSmxViewMap.callGeolocacion(
                  context: context,
                  correoInvitado: correoInvitado,
                );
              },
            ),
          ),
      ],
    );
  }

  Widget builderMap() {
    return FlutterMap(
      mapController: _controllerSmxViewMap.mapController,
      options: MapOptions(
        initialCenter: _controllerSmxViewMap.currentPosition,
        initialZoom: 18,
      ),
      children: [
        TileLayer(
          tileProvider: CancellableNetworkTileProvider(),
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          //urlTemplate: 'http://mt{s}.google.com/vt/lyrs=m&x={x}&y={y}&z={z}',
          //subdomains: ['0', '1', '2', '3'],
          //userAgentPackageName: 'venture_app'
        ),
        ValueListenableBuilder<List<Marker>>(
          valueListenable: _controllerSmxViewMap.markersNotifier,
          builder: (context, invitados, child) {
            return MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: _controllerSmxViewMap.currentPosition,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
                ...invitados,
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SmxMapMessage extends StatelessWidget {
  final String message;

  const _SmxMapMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFEAF6F3),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_searching_rounded,
              color: Color(0xFF167C5A),
              size: 34,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(
                color: Color(0xFF183246),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
