import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/smxAuthUser.dart';
import '../storage/smxAuthStorage.dart';
import 'AuthRepository.dart';
import 'AuthService.dart';

enum GoogleLoginStatus {
  idle,
  signingIn,
  popupBlocked,
  popupClosed,
  cancelled,
  error,
}

class AuthViewModel with ChangeNotifier {
  final AuthService _authService;
  final SmxAuthStorage _storage;

  GoogleLoginStatus _status = GoogleLoginStatus.idle;
  String? _errorMessage;
  String? _errorCode;

  AuthViewModel(this._authService, this._storage);

  factory AuthViewModel.google() {
    return AuthViewModel(
      GoogleAuthService(AuthRepository()),
      const SmxAuthStorage(),
    );
  }

  GoogleLoginStatus get status => _status;
  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;
  bool get isLoading => _status == GoogleLoginStatus.signingIn;

  Future<SmxAuthUser?> signIn() async {
    _setStatus(GoogleLoginStatus.signingIn);

    try {
      final googleUser = await _authService.signIn();

      _storage.saveIdentity(googleUser);

      final cachedImage = _storage.readImage();
      final imageBytes = cachedImage ?? await _storage.savePhoto(googleUser);

      final user = googleUser.copyWith(imageBytes: imageBytes);

      _setStatus(GoogleLoginStatus.idle);
      return user;
    } on FirebaseAuthException catch (error) {
      _setFirebaseError(error);
      return null;
    } catch (_) {
      _setStatus(
        GoogleLoginStatus.error,
        message: 'No se pudo iniciar sesión con Google. Intenta nuevamente.',
      );
      return null;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _storage.clear();
    _setStatus(GoogleLoginStatus.idle);
  }

  void resetStatus() => _setStatus(GoogleLoginStatus.idle);

  void _setFirebaseError(FirebaseAuthException error) {
    final code = error.code;

    if (code == 'popup-blocked' || code == 'auth/popup-blocked') {
      _setStatus(
        GoogleLoginStatus.popupBlocked,
        code: code,
        message:
            'Tu navegador bloqueó la ventana de Google. Habilita ventanas emergentes para este sitio y vuelve a intentar.',
      );
      return;
    }
    if (code == 'popup-closed-by-user' || code == 'auth/popup-closed-by-user') {
      _setStatus(
        GoogleLoginStatus.popupClosed,
        code: code,
        message: 'Se cerró la ventana de Google antes de completar el ingreso.',
      );
      return;
    }
    if (code == 'cancelled-popup-request' ||
        code == 'auth/cancelled-popup-request') {
      _setStatus(
        GoogleLoginStatus.cancelled,
        code: code,
        message: 'Ya había un inicio de sesión con Google en proceso.',
      );
      return;
    }

    _setStatus(
      GoogleLoginStatus.error,
      code: code,
      message:
          error.message ??
          'No se pudo iniciar sesión con Google. Intenta nuevamente.',
    );
  }

  void _setStatus(GoogleLoginStatus value, {String? code, String? message}) {
    _status = value;
    _errorCode = code;
    _errorMessage = message;
    notifyListeners();
  }
}
