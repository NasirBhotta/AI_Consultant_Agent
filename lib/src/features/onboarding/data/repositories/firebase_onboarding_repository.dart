import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/onboarding_profile.dart';

class FirebaseOnboardingRepository {
  FirebaseOnboardingRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required SharedPreferences sharedPreferences,
  }) : _firestore = firestore,
       _storage = storage,
       _sharedPreferences = sharedPreferences;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
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
    final rawProfile = snapshot.data()?['onboardingProfile'];
    final profile = OnboardingProfile.fromFirestore(
      rawProfile is Map ? Map<String, dynamic>.from(rawProfile) : null,
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

  Future<OnboardingDocumentRecord> uploadDocument({
    required String userId,
    required OnboardingDocumentType type,
    required String fileName,
    required Uint8List bytes,
  }) async {
    final sanitizedFileName = fileName.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final storagePath =
        'users/$userId/onboarding/${type.name}/${DateTime.now().millisecondsSinceEpoch}_$sanitizedFileName';
    final storageRef = _storage.ref().child(storagePath);

    final metadata = SettableMetadata(
      customMetadata: {'onboardingDocumentType': type.name},
    );

    await storageRef.putData(bytes, metadata);
    final downloadUrl = await storageRef.getDownloadURL();

    return OnboardingDocumentRecord(
      fileName: fileName,
      downloadUrl: downloadUrl,
      storagePath: storagePath,
      uploadedAtIso: DateTime.now().toUtc().toIso8601String(),
    );
  }

  Future<void> removeDocument(OnboardingDocumentRecord record) async {
    if (record.storagePath.isEmpty) {
      return;
    }

    await _storage.ref().child(record.storagePath).delete();
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
