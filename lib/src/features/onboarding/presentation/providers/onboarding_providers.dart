import 'package:agent_app/src/app/providers/app_providers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final onboardingControllerProvider = Provider<OnboardingController>((ref) {
  return OnboardingController(ref);
});

class OnboardingController {
  const OnboardingController(this._ref);

  final Ref _ref;

  Future<void> completeOnboarding() async {
    final user = _ref.read(firebaseAuthProvider).currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'There is no signed in user to finish onboarding.',
      );
    }

    final prefs = await _ref.read(sharedPreferencesProvider.future);
    await prefs.setBool('onboardingCompleted_${user.uid}', true);
  }
}
