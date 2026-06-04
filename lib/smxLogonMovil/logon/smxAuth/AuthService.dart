import 'package:firebase_auth/firebase_auth.dart';

import 'AuthRepository.dart';

abstract class AuthService {
  Stream<User?> get authStateChanges;
  Future<UserCredential?> signInWithGoogle();
  Future<void> signOut();
}

class FirebaseAuthService implements AuthService {
  final AuthRepository _repository;

  FirebaseAuthService(this._repository);

  @override
  Stream<User?> get authStateChanges => _repository.authStateChanges;

  @override
  Future<UserCredential?> signInWithGoogle() => _repository.signInWithGoogle();

  @override
  Future<void> signOut() => _repository.signOut();
}