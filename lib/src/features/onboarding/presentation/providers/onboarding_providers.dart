import 'package:agent_app/src/app/providers/app_providers.dart';
import 'package:agent_app/src/features/onboarding/domain/models/onboarding_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingDraftProvider =
    StateNotifierProvider<OnboardingDraftController, OnboardingProfile>((ref) {
      return OnboardingDraftController(ref);
    });

final onboardingControllerProvider = Provider<OnboardingController>((ref) {
  return OnboardingController(ref);
});

class OnboardingDraftController extends StateNotifier<OnboardingProfile> {
  OnboardingDraftController(this._ref) : super(const OnboardingProfile());

  final Ref _ref;

  Future<void> loadDraft() async {
    if (state.isHydrating || state.hasLoadedDraft) {
      return;
    }

    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) {
      state = state.copyWith(hasLoadedDraft: true);
      return;
    }

    state = state.copyWith(isHydrating: true);

    try {
      final repository = await _ref.read(onboardingRepositoryProvider.future);
      final draft = await repository.fetchDraft(
        userId: user.uid,
        fallbackFullName: user.displayName,
      );
      state = draft.copyWith(isHydrating: false, hasLoadedDraft: true);
    } catch (_) {
      state = state.copyWith(
        isHydrating: false,
        hasLoadedDraft: true,
        fullName:
            state.fullName.isNotEmpty
                ? state.fullName
                : (user.displayName ?? ''),
      );
      rethrow;
    }
  }

  void selectApsStatus(ApsCertificateStatus value) {
    state = state.copyWith(apsStatus: value);
  }

  void updateFullName(String value) {
    state = state.copyWith(fullName: value);
  }

  void updateNationality(String value) {
    state = state.copyWith(nationality: value);
  }

  void selectTargetDegree(TargetDegree value) {
    state = state.copyWith(targetDegree: value);
  }

  void updateIntakeSemester(String value) {
    state = state.copyWith(intakeSemester: value);
  }

  void updateCountryOfResidence(String value) {
    state = state.copyWith(countryOfResidence: value);
  }

  void selectAcademicTrack(AcademicTrack value) {
    final currentDocuments = Map<OnboardingDocumentType, OnboardingDocumentRecord>.from(
      state.documents,
    );

    if (value == AcademicTrack.matricInter) {
      currentDocuments.remove(OnboardingDocumentType.oLevelCertificate);
      currentDocuments.remove(OnboardingDocumentType.oLevelMarksheet);
      currentDocuments.remove(OnboardingDocumentType.aLevelCertificate);
      currentDocuments.remove(OnboardingDocumentType.aLevelMarksheet);
    } else {
      currentDocuments.remove(OnboardingDocumentType.matricCertificate);
      currentDocuments.remove(OnboardingDocumentType.matricMarksheet);
      currentDocuments.remove(OnboardingDocumentType.interCertificate);
      currentDocuments.remove(OnboardingDocumentType.interMarksheet);
    }

    state = state.copyWith(academicTrack: value, documents: currentDocuments);
  }

  void startDocumentUpload(OnboardingDocumentType type) {
    state = state.copyWith(uploadingDocument: type);
  }

  void finishDocumentUpload(OnboardingDocumentType type, OnboardingDocumentRecord record) {
    final updatedDocuments = Map<OnboardingDocumentType, OnboardingDocumentRecord>.from(
      state.documents,
    );
    updatedDocuments[type] = record;

    state = state.copyWith(
      documents: updatedDocuments,
      clearUploadingDocument: true,
    );
  }

  void removeDocument(OnboardingDocumentType type) {
    final updatedDocuments = Map<OnboardingDocumentType, OnboardingDocumentRecord>.from(
      state.documents,
    );
    updatedDocuments.remove(type);
    state = state.copyWith(documents: updatedDocuments);
  }

  void clearUploadingDocument() {
    state = state.copyWith(clearUploadingDocument: true);
  }
}

class OnboardingController {
  const OnboardingController(this._ref);

  final Ref _ref;

  Future<void> saveDraft() async {
    final user = _requireUser();
    final repository = await _ref.read(onboardingRepositoryProvider.future);
    final profile = _ref.read(onboardingDraftProvider);

    await repository.saveDraft(
      userId: user.uid,
      email: user.email ?? '',
      profile: profile,
    );
  }

  Future<void> uploadDocument({
    required OnboardingDocumentType type,
    required List<String> allowedExtensions,
  }) async {
    final user = _requireUser();
    final draftController = _ref.read(onboardingDraftProvider.notifier);
    final repository = await _ref.read(onboardingRepositoryProvider.future);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowMultiple: false,
      withData: true,
      allowedExtensions: allowedExtensions,
    );

    if (result == null || result.files.isEmpty) {
      return;
    }

    final selectedFile = result.files.single;
    final bytes = selectedFile.bytes;
    if (bytes == null) {
      throw FirebaseAuthException(
        code: 'file-bytes-missing',
        message: 'The selected file could not be read.',
      );
    }

    draftController.startDocumentUpload(type);

    try {
      final record = await repository.uploadDocument(
        userId: user.uid,
        type: type,
        fileName: selectedFile.name,
        bytes: bytes,
      );
      draftController.finishDocumentUpload(type, record);
      await saveDraft();
    } catch (_) {
      draftController.clearUploadingDocument();
      rethrow;
    }
  }

  Future<void> removeDocument(OnboardingDocumentType type) async {
    final repository = await _ref.read(onboardingRepositoryProvider.future);
    final draftController = _ref.read(onboardingDraftProvider.notifier);
    final existingRecord = _ref.read(onboardingDraftProvider).documents[type];

    if (existingRecord != null) {
      await repository.removeDocument(existingRecord);
    }

    draftController.removeDocument(type);
    await saveDraft();
  }

  Future<void> completeOnboarding() async {
    final user = _requireUser();
    final repository = await _ref.read(onboardingRepositoryProvider.future);
    final profile = _ref.read(onboardingDraftProvider);

    if (profile.fullName.trim().isNotEmpty &&
        profile.fullName.trim() != (user.displayName ?? '').trim()) {
      await user.updateDisplayName(profile.fullName.trim());
      await user.reload();
    }

    await repository.completeOnboarding(
      userId: user.uid,
      email: user.email ?? '',
      profile: profile,
    );
  }

  User _requireUser() {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'There is no signed in user to finish onboarding.',
      );
    }

    return user;
  }
}
