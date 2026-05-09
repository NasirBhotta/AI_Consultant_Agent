import 'package:agent_app/src/app/providers/app_providers.dart';
import 'package:agent_app/src/features/onboarding/domain/models/onboarding_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
