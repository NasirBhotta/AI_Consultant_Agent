import '../models/auth_session.dart';
import '../models/sign_in_credentials.dart';
import '../models/sign_up_credentials.dart';

abstract class AuthRepository {
  Future<AuthSession> signIn(SignInCredentials credentials);

  Future<AuthSession> signInWithGoogle();

  Future<AuthSession> signUp(SignUpCredentials credentials);

  Future<void> sendEmailVerification();

  Future<bool> reloadAndCheckEmailVerification();

  Future<void> sendPasswordReset({required String email});

  Future<void> signOut();
}
