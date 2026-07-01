import 'dart:async';

import 'package:geolocator/geolocator.dart';

class SmxGeolocation {
  bool _hasPermission = false;
  LocationPermission? _permission;
  String _lastLocation = '';
  String _lastError = '';

  bool get hasPermission => _hasPermission;
  LocationPermission? get permission => _permission;
  String get lastLocation => _lastLocation;
  String get lastError => _lastError;

  Future<bool> requestPermission() async {
    _lastError = '';

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setDenied('El servicio de ubicacion no esta habilitado.');
        return false;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      _permission = permission;
      _hasPermission =
          permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

      if (!_hasPermission) {
        _setDenied('Permiso de ubicacion denegado.');
      }

      return _hasPermission;
    } catch (error) {
      _setDenied(error.toString());
      return false;
    }
  }

  Future<String?> getGeolocation({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration timeout = const Duration(seconds: 10),
  }) async {
    _lastError = '';

    try {
      if (!_hasPermission) {
        final permission = await Geolocator.checkPermission();
        _permission = permission;
        _hasPermission =
            permission == LocationPermission.always ||
            permission == LocationPermission.whileInUse;

        if (!_hasPermission) {
          _setDenied('Debe solicitar permiso de ubicacion primero.');
          return null;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(accuracy: accuracy),
      ).timeout(timeout);

      _lastLocation = '${position.latitude}, ${position.longitude}';
      return _lastLocation;
    } on TimeoutException {
      _lastError = 'No se pudo obtener la ubicacion a tiempo.';
      return null;
    } catch (error) {
      _lastError = error.toString();
      return null;
    }
  }

  void _setDenied(String message) {
    _hasPermission = false;
    _lastError = message;
  }
}
