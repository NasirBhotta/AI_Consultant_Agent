import '../models/auth_session.dart';
import '../models/sign_in_credentials.dart';

abstract class AuthRepository {
  Future<AuthSession> signIn(SignInCredentials credentials);

  Future<void> signInWithGoogle();

  Future<void> sendPasswordReset({required String email});
}
