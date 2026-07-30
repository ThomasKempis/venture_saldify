import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _auth;

  AuthRepository({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  User? getCurrentUser() {
    final currentUser = _auth.currentUser;
    if (currentUser != null) return currentUser;
    return _auth.currentUser;
  }

  /*
  Future<User?> getCurrentUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) return currentUser;

    return _auth.authStateChanges().first.timeout(
      const Duration(milliseconds: 800),
      onTimeout: () => null,
    );
  }
  */

  Future<UserCredential> signInWithGoogle({
    bool forceAccountSelection = false,
  }) {
    final provider = GoogleAuthProvider()
      ..addScope('email')
      ..addScope('profile');

    if (forceAccountSelection) {
      provider.setCustomParameters({'prompt': 'select_account'});
    }

    return _auth.signInWithPopup(provider);
  }

  Future<void> signOut() => _auth.signOut();
}
