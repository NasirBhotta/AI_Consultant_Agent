import 'package:agent_app/src/app/app_gate.dart';
import 'package:agent_app/src/app/startup/app_startup.dart';
import 'package:agent_app/src/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:agent_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:agent_app/src/features/onboarding/data/repositories/firebase_onboarding_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firebaseStorageProvider = Provider<FirebaseStorage>((ref) {
  return FirebaseStorage.instance;
});

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((
  ref,
) async {
  return SharedPreferences.getInstance();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(firebaseAuth: ref.watch(firebaseAuthProvider));
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
});

final onboardingRepositoryProvider =
    FutureProvider<FirebaseOnboardingRepository>((ref) async {
      final sharedPreferences = await ref.watch(
        sharedPreferencesProvider.future,
      );
      return FirebaseOnboardingRepository(
        firestore: ref.watch(firebaseFirestoreProvider),
        storage: ref.watch(firebaseStorageProvider),
        sharedPreferences: sharedPreferences,
      );
    });

final appStartupProvider = FutureProvider<void>((ref) async {
  await AppStartup().initialize();
});

final appGateProvider = FutureProvider<Widget>((ref) async {
  final sharedPreferences = await ref.watch(sharedPreferencesProvider.future);
  final onboardingRepository = await ref.watch(
    onboardingRepositoryProvider.future,
  );
  final gate = AppGate(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    sharedPreferences: sharedPreferences,
    onboardingRepository: onboardingRepository,
  );
  return gate.resolve();
});
