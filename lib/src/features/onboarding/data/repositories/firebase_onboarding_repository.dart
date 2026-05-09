import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/onboarding_profile.dart';

class FirebaseOnboardingRepository {
  FirebaseOnboardingRepository({
    required FirebaseFirestore firestore,
    required SharedPreferences sharedPreferences,
  }) : _firestore = firestore,
       _sharedPreferences = sharedPreferences;

  final FirebaseFirestore _firestore;
  final SharedPreferences _sharedPreferences;

  static String completionKey(String userId) => 'onboardingCompleted_$userId';

  DocumentReference<Map<String, dynamic>> _userDocument(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  Future<OnboardingProfile> fetchDraft({
    required String userId,
    String? fallbackFullName,
  }) async {
    final snapshot = await _userDocument(userId).get();
    final profile = OnboardingProfile.fromFirestore(
      (snapshot.data()?['onboardingProfile'] as Map<String, dynamic>?),
    );

    if (profile.fullName.trim().isNotEmpty || (fallbackFullName ?? '').isEmpty) {
      return profile;
    }

    return profile.copyWith(fullName: fallbackFullName, hasLoadedDraft: true);
  }

  Future<void> saveDraft({
    required String userId,
    required String email,
    required OnboardingProfile profile,
  }) async {
    await _userDocument(userId).set({
      'email': email,
      'onboardingCompleted': false,
      'onboardingProfile': profile.toFirestore(),
      'onboardingUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> completeOnboarding({
    required String userId,
    required String email,
    required OnboardingProfile profile,
  }) async {
    await _userDocument(userId).set({
      'email': email,
      'onboardingCompleted': true,
      'onboardingCompletedAt': FieldValue.serverTimestamp(),
      'onboardingProfile': profile.toFirestore(),
      'onboardingUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await _sharedPreferences.setBool(completionKey(userId), true);
  }

  Future<bool> isOnboardingComplete(String userId) async {
    final cached = _sharedPreferences.getBool(completionKey(userId));
    if (cached == true) {
      return true;
    }

    final snapshot = await _userDocument(userId).get();
    final isComplete = (snapshot.data()?['onboardingCompleted'] as bool?) ?? false;

    if (isComplete) {
      await _sharedPreferences.setBool(completionKey(userId), true);
    }

    return isComplete;
  }
}
