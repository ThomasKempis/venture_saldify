import '../models/smxAuthUser.dart';
import 'AuthRepository.dart';

abstract class AuthService {
  Future<SmxAuthUser> signIn();
  Future<void> signOut();
}

class GoogleAuthService implements AuthService {
  final AuthRepository _repository;

  GoogleAuthService(this._repository);

  @override
  Future<SmxAuthUser> signIn() async {
    final credential = await _repository.signInWithGoogle();
    final user = credential.user;

    if (user == null || (user.email?.trim().isEmpty ?? true)) {
      throw StateError('Google no devolvió una cuenta válida.');
    }

    return SmxAuthUser(
      provider: 'google',
      providerId: user.uid,
      email: user.email!.trim().toLowerCase(),
      displayName: user.displayName?.trim() ?? '',
      photoUrl: user.photoURL,
    );
  }

  @override
  Future<void> signOut() => _repository.signOut();
}
