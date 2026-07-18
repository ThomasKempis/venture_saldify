import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

import '../models/smxAuthUser.dart';

class SmxAuthStorage {
  static const _providerKey = 'smx_auth_provider';
  static const _providerIdKey = 'smx_auth_provider_id';
  static const _correoKey = 'correo';
  static const _nombresKey = 'nombres';
  static const _imagenKey = 'imagen';

  const SmxAuthStorage();

  SmxAuthUser? read() {
    final email = html.window.localStorage[_correoKey]?.trim() ?? '';
    if (email.isEmpty) return null;

    return SmxAuthUser(
      provider: html.window.localStorage[_providerKey] ?? '',
      providerId: html.window.localStorage[_providerIdKey] ?? '',
      email: email,
      displayName: html.window.localStorage[_nombresKey] ?? '',
    );
  }

  void saveIdentity(SmxAuthUser user) {
    final previousProviderId =
        html.window.localStorage[_providerIdKey]?.trim() ?? '';

    if (previousProviderId.isNotEmpty &&
        previousProviderId != user.providerId) {
      html.window.localStorage.remove(_imagenKey);
    }

    html.window.localStorage[_providerKey] = user.provider;
    html.window.localStorage[_providerIdKey] = user.providerId;
    html.window.localStorage[_correoKey] = user.email.trim().toLowerCase();
    html.window.localStorage[_nombresKey] = user.displayName.trim();
  }

  Future<Uint8List?> savePhoto(SmxAuthUser user) async {
    final photoUrl = user.photoUrl?.trim() ?? '';
    if (photoUrl.isEmpty) {
      html.window.localStorage.remove(_imagenKey);
      return null;
    }

    try {
      final response = await http
          .get(Uri.parse(photoUrl))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        html.window.localStorage[_imagenKey] = base64Encode(response.bodyBytes);
        return response.bodyBytes;
      }
    } catch (error, stackTrace) {
      if (kDebugMode) {
        print(stackTrace);
      }
      html.window.localStorage.remove(_imagenKey);
    }

    return null;
  }

  Uint8List? readImage() {
    final value = html.window.localStorage[_imagenKey];
    if (value == null || value.isEmpty) return null;

    try {
      return base64Decode(value);
    } catch (_) {
      return null;
    }
  }

  void clear() {
    html.window.localStorage.remove(_providerKey);
    html.window.localStorage.remove(_providerIdKey);
    html.window.localStorage.remove(_correoKey);
    html.window.localStorage.remove(_nombresKey);
    html.window.localStorage.remove(_imagenKey);
  }
}
