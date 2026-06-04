import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleAuthProvider googleProvider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');

      return await _auth.signInWithPopup(googleProvider);
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();

    if (kIsWeb) {
      try {
        Uri.parse('https://accounts.google.com/Logout');
      } catch (e) {}
    }
  }
}