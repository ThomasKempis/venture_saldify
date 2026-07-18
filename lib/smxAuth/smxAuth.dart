import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'google/AuthRepository.dart';
import 'models/smxAuthUser.dart';
import 'storage/smxAuthStorage.dart';

export 'models/smxAuthUser.dart';

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

class SmxAuth with ChangeNotifier {
  final SmxAuthStorage _storage;
  final AuthRepository _googleRepository;

  SmxAuth({AuthRepository? googleRepository})
    : _googleRepository = googleRepository ?? AuthRepository(),
      _storage = const SmxAuthStorage();

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
