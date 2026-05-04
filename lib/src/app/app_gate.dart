import 'package:agent_app/src/features/auth/presentation/pages/landing_page.dart';
import 'package:agent_app/src/features/auth/presentation/pages/verify_email_page.dart';
import 'package:agent_app/src/features/home/presentation/pages/home_page.dart';
import 'package:agent_app/src/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppGate {
  static Future<dynamic> resolve() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const LandingPage(isStartupReady: true);
    }

    if (!user.emailVerified) {
      return VerifyEmailPage(isStartupReady: true, email: '${user.email}');
    }

    final prefs = await SharedPreferences.getInstance();

    final onboardingDone =
        prefs.getBool('onboardingCompleted_${user.uid}') ?? false;

    if (!onboardingDone) {
      return const OnboardingPage();
    }

    return const HomePage();
  }
}
