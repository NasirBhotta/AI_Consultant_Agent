import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/models/auth_session.dart';
import '../../domain/models/sign_in_credentials.dart';
import '../../domain/models/sign_up_credentials.dart';
import '../../domain/repositories/auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({FirebaseAuth? firebaseAuth})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  AuthSession _toSession(User user, {String? fallbackEmail}) {
    return AuthSession(
      userId: user.uid,
      email: user.email ?? fallbackEmail ?? '',
      displayName: user.displayName,
      emailVerified: user.emailVerified,
    );
  }

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

    return _toSession(user, fallbackEmail: credentials.email.trim());
  }

  @override
  Future<AuthSession> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      final userCredential = await _firebaseAuth.signInWithPopup(provider);
      final user = userCredential.user;

      if (user == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No user was returned from Google sign-in.',
        );
      }

      return _toSession(user);
    }

    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      throw FirebaseAuthException(
        code: 'sign_in_canceled',
        message: 'Google sign-in was canceled.',
      );
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    final user = userCredential.user;

    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user was returned from Google sign-in.',
      );
    }

    return _toSession(user);
  }

  @override
  Future<AuthSession> signUp(SignUpCredentials credentials) async {
    final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
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

    final trimmedName = credentials.displayName?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      await user.updateDisplayName(trimmedName);
    }

    await user.reload();
    final refreshedUser = _firebaseAuth.currentUser;

    if (refreshedUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'The signed up user could not be reloaded.',
      );
    }

    return _toSession(refreshedUser, fallbackEmail: credentials.email.trim());
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'There is no signed in user to verify.',
      );
    }

    await user.sendEmailVerification();
  }

  @override
  Future<bool> reloadAndCheckEmailVerification() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'There is no signed in user to refresh.',
      );
    }

    await user.reload();
    return _firebaseAuth.currentUser?.emailVerified ?? false;
  }

  @override
  Future<void> sendPasswordReset({required String email}) {
    return _firebaseAuth.sendPasswordResetEmail(email: email.trim());
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
  }
}
