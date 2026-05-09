import 'package:flutter/material.dart';
import 'package:agent_app/src/features/auth/presentation/pages/landing_page.dart';
import 'package:agent_app/src/features/auth/presentation/pages/verify_email_page.dart';
import 'package:agent_app/src/features/home/presentation/pages/home_page.dart';
import 'package:agent_app/src/features/onboarding/data/repositories/firebase_onboarding_repository.dart';
import 'package:agent_app/src/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppGate {
  const AppGate({
    required FirebaseAuth firebaseAuth,
    required SharedPreferences sharedPreferences,
    required FirebaseOnboardingRepository onboardingRepository,
  }) : _firebaseAuth = firebaseAuth,
       _sharedPreferences = sharedPreferences,
       _onboardingRepository = onboardingRepository;

  final FirebaseAuth _firebaseAuth;
  final SharedPreferences _sharedPreferences;
  final FirebaseOnboardingRepository _onboardingRepository;

  Future<Widget> resolve() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return const LandingPage(isStartupReady: true);
    }

    if (!user.emailVerified) {
      return VerifyEmailPage(isStartupReady: true, email: '${user.email}');
    }

    final cachedOnboardingDone =
        _sharedPreferences.getBool(
          FirebaseOnboardingRepository.completionKey(user.uid),
        ) ??
        false;
    final onboardingDone =
        cachedOnboardingDone ||
        await _onboardingRepository.isOnboardingComplete(user.uid);

    if (!onboardingDone) {
      return const OnboardingPage();
    }

    return const HomePage();
  }
}
