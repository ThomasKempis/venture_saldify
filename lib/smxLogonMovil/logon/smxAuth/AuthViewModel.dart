import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  bool _isLoading = false;
  GoogleLoginStatus _googleLoginStatus = GoogleLoginStatus.idle;
  String? _googleLoginErrorMessage;
  String? _googleLoginErrorCode;

  AuthViewModel(this._authService);

  bool get isLoading => _isLoading;
  GoogleLoginStatus get googleLoginStatus => _googleLoginStatus;
  String? get googleLoginErrorMessage => _googleLoginErrorMessage;
  String? get googleLoginErrorCode => _googleLoginErrorCode;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    _setGoogleLoginStatus(GoogleLoginStatus.signingIn);
    try {
      await _authService.signInWithGoogle();
      _setGoogleLoginStatus(GoogleLoginStatus.idle);
    } on FirebaseAuthException catch (e) {
      _setGoogleLoginError(e);
    } catch (e) {
      _setGoogleLoginStatus(
        GoogleLoginStatus.error,
        message: 'No se pudo iniciar sesión con Google. Intenta nuevamente.',
      );
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _authService.signOut();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setGoogleLoginError(FirebaseAuthException error) {
    final code = error.code;

    if (code == 'popup-blocked' || code == 'auth/popup-blocked') {
      _setGoogleLoginStatus(
        GoogleLoginStatus.popupBlocked,
        code: code,
        message:
            'Tu navegador bloqueó la ventana de Google. Habilita ventanas emergentes para este sitio y vuelve a intentar.',
      );
      return;
    }

    if (code == 'popup-closed-by-user' || code == 'auth/popup-closed-by-user') {
      _setGoogleLoginStatus(
        GoogleLoginStatus.popupClosed,
        code: code,
        message: 'Se cerró la ventana de Google antes de completar el ingreso.',
      );
      return;
    }

    if (code == 'cancelled-popup-request' ||
        code == 'auth/cancelled-popup-request') {
      _setGoogleLoginStatus(
        GoogleLoginStatus.cancelled,
        code: code,
        message: 'Ya había un inicio de sesión con Google en proceso.',
      );
      return;
    }

    _setGoogleLoginStatus(
      GoogleLoginStatus.error,
      code: code,
      message:
          error.message ??
          'No se pudo iniciar sesión con Google. Intenta nuevamente.',
    );
  }

  void _setGoogleLoginStatus(
    GoogleLoginStatus status, {
    String? code,
    String? message,
  }) {
    _googleLoginStatus = status;
    _googleLoginErrorCode = code;
    _googleLoginErrorMessage = message;
    notifyListeners();
  }
}
