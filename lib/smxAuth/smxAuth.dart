import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;

import 'google/AuthRepository.dart';

enum SmxAuthProvider { google, facebook, apple, microsoft }

extension SmxAuthProviderX on SmxAuthProvider {
  String get code {
    return switch (this) {
      SmxAuthProvider.google => 'google',
      SmxAuthProvider.facebook => 'facebook',
      SmxAuthProvider.apple => 'apple',
      SmxAuthProvider.microsoft => 'microsoft',
    };
  }

  String get label {
    return switch (this) {
      SmxAuthProvider.google => 'Google',
      SmxAuthProvider.facebook => 'Facebook',
      SmxAuthProvider.apple => 'Apple',
      SmxAuthProvider.microsoft => 'Microsoft',
    };
  }
}

enum SmxAuthStatus {
  idle,
  authenticating,
  popupBlocked,
  popupClosed,
  cancelled,
  unsupportedProvider,
  error,
}

class SmxAuthUser {
  final String provider;
  final String providerId;
  final String email;
  final String displayName;
  final String? photoUrl;
  final Uint8List? imageBytes;

  const SmxAuthUser({
    required this.provider,
    required this.providerId,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.imageBytes,
  });

  SmxAuthUser copyWith({Uint8List? imageBytes}) {
    return SmxAuthUser(
      provider: provider,
      providerId: providerId,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }
}

class SmxAuth with ChangeNotifier {
  final _SmxAuthStorage _storage;
  final AuthRepository _googleRepository;

  SmxAuth({AuthRepository? googleRepository})
    : _googleRepository = googleRepository ?? AuthRepository(),
      _storage = const _SmxAuthStorage();

  SmxAuthStatus _status = SmxAuthStatus.idle;
  SmxAuthProvider? _provider;
  String? _errorMessage;
  String? _errorCode;

  SmxAuthStatus get status => _status;
  SmxAuthProvider? get provider => _provider;
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;
  bool get isLoading => _status == SmxAuthStatus.authenticating;

  Future<SmxAuthUser?> signIn(
    SmxAuthProvider provider, {
    bool forceAccountSelection = false,
  }) async {
    if (isLoading) return null;

    _setStatus(SmxAuthStatus.authenticating, provider: provider);

    try {
      final authUser = await _signInProvider(
        provider,
        forceAccountSelection: forceAccountSelection,
      );

      _storage.saveIdentity(authUser);

      final cachedImage = _storage.readImage();
      final imageBytes = cachedImage ?? await _storage.savePhoto(authUser);
      final user = authUser.copyWith(imageBytes: imageBytes);

      _setStatus(SmxAuthStatus.idle, provider: provider);
      return user;
    } on FirebaseAuthException catch (error) {
      _setFirebaseError(error, provider);
      _setStatus(SmxAuthStatus.idle, provider: provider);
      return null;
    } on UnsupportedError catch (error) {
      _setStatus(
        SmxAuthStatus.unsupportedProvider,
        provider: provider,
        message: error.message,
      );
      _setStatus(SmxAuthStatus.idle, provider: provider);
      return null;
    } catch (_) {
      _setStatus(
        SmxAuthStatus.error,
        provider: provider,
        message:
            'No se pudo iniciar sesión con ${provider.label}. Intenta nuevamente.',
      );
      _setStatus(SmxAuthStatus.idle, provider: provider);
      return null;
    }
  }

  Future<void> signOut(SmxAuthProvider provider) async {
    await switch (provider) {
      SmxAuthProvider.google => _googleRepository.signOut(),
      SmxAuthProvider.facebook ||
      SmxAuthProvider.apple ||
      SmxAuthProvider.microsoft => Future<void>.value(),
    };

    _storage.clear();
    _setStatus(SmxAuthStatus.idle, provider: provider);
  }

  void resetStatus() => _setStatus(SmxAuthStatus.idle, provider: _provider);

  Future<SmxAuthUser> _signInProvider(
    SmxAuthProvider provider, {
    required bool forceAccountSelection,
  }) {
    return switch (provider) {
      SmxAuthProvider.google => _signInGoogle(
        forceAccountSelection: forceAccountSelection,
      ),
      SmxAuthProvider.facebook ||
      SmxAuthProvider.apple ||
      SmxAuthProvider.microsoft => throw UnsupportedError(
        'El ingreso con ${provider.label} todavía no está disponible.',
      ),
    };
  }

  Future<SmxAuthUser> _signInGoogle({
    required bool forceAccountSelection,
  }) async {
    if (!forceAccountSelection) {
      final currentUser = await _googleRepository.getCurrentUser();
      if (currentUser != null) {
        return _createGoogleAuthUser(currentUser);
      }
    }

    final credential = await _googleRepository.signInWithGoogle(
      forceAccountSelection: forceAccountSelection,
    );
    final user = credential.user;

    if (user == null || (user.email?.trim().isEmpty ?? true)) {
      throw StateError('Google no devolvió una cuenta válida.');
    }

    return _createGoogleAuthUser(user);
  }

  SmxAuthUser _createGoogleAuthUser(User user) {
    return SmxAuthUser(
      provider: SmxAuthProvider.google.code,
      providerId: user.uid,
      email: user.email!.trim().toLowerCase(),
      displayName: user.displayName?.trim() ?? '',
      photoUrl: user.photoURL,
    );
  }

  void _setFirebaseError(
    FirebaseAuthException error,
    SmxAuthProvider provider,
  ) {
    final code = error.code;

    if (code == 'popup-blocked' || code == 'auth/popup-blocked') {
      _setStatus(
        SmxAuthStatus.popupBlocked,
        provider: provider,
        code: code,
        message:
            'Tu navegador bloqueó la ventana de ${provider.label}. Habilita ventanas emergentes para este sitio y vuelve a intentar.',
      );
      return;
    }

    if (code == 'popup-closed-by-user' || code == 'auth/popup-closed-by-user') {
      _setStatus(
        SmxAuthStatus.popupClosed,
        provider: provider,
        code: code,
        message:
            'Se cerró la ventana de ${provider.label} antes de completar el ingreso.',
      );
      return;
    }

    if (code == 'cancelled-popup-request' ||
        code == 'auth/cancelled-popup-request') {
      _setStatus(
        SmxAuthStatus.cancelled,
        provider: provider,
        code: code,
        message:
            'Ya había un inicio de sesión con ${provider.label} en proceso.',
      );
      return;
    }

    _setStatus(
      SmxAuthStatus.error,
      provider: provider,
      code: code,
      message:
          error.message ??
          'No se pudo iniciar sesión con ${provider.label}. Intenta nuevamente.',
    );
  }

  void _setStatus(
    SmxAuthStatus value, {
    SmxAuthProvider? provider,
    String? code,
    String? message,
  }) {
    _status = value;
    _provider = provider;
    _errorCode = code;
    _errorMessage = message;
    notifyListeners();
  }
}

class _SmxAuthStorage {
  static const _providerKey = 'smx_auth_provider';
  static const _providerIdKey = 'smx_auth_provider_id';
  static const _correoKey = 'correo';
  static const _nombresKey = 'nombres';
  static const _imagenKey = 'imagen';

  const _SmxAuthStorage();

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
