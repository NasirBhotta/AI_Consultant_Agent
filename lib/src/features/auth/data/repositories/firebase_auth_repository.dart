import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/models/auth_session.dart';
import '../../domain/models/sign_in_credentials.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  @override
  Future<AuthSession> signIn(SignInCredentials credentials) async {
    final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
      email: credentials.email.trim(),
      password: credentials.password,
    );

    final user = userCredential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user was returned from Firebase Auth.',
      );
    }

    return AuthSession(
      userId: user.uid,
      email: user.email ?? credentials.email.trim(),
      displayName: user.displayName,
    );
  }

  @override
  Future<void> signInWithGoogle() {
    throw UnimplementedError('Google sign-in is not configured yet.');
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }
}
