import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'AuthService.dart';
class AuthViewModel with ChangeNotifier {
  final AuthService _authService;
  bool _isLoading = false;

  AuthViewModel(this._authService);

  bool get isLoading => _isLoading;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<void> signInWithGoogle() async {
    _setLoading(true);
    try {
      await _authService.signInWithGoogle();
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
}
