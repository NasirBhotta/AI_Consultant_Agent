import 'package:flutter/material.dart';
import '../widgets/auth_brand_badge.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../features/auth/constants/auth_strings.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_secondary_button.dart';
import 'sign_in_page.dart';
import 'sign_up_page.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key, required this.isStartupReady});

  final bool isStartupReady;

  void _openSignIn(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignInPage(isStartupReady: isStartupReady),
      ),
    );
  }

  void _openSignUp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SignUpPage(isStartupReady: isStartupReady),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AuthBrandBadge(size: 80, iconSize: 40),

              const SizedBox(height: 24),

              Text(AppStrings.appName, style: textTheme.headlineMedium),

              const SizedBox(height: 12),

              Text(AuthStrings.startupTagline, textAlign: TextAlign.center),

              const SizedBox(height: 40),

              AppPrimaryButton(
                label: "Sign Up",
                onPressed: () => _openSignUp(context),
              ),

              const SizedBox(height: 12),

              AppSecondaryButton(
                label: "Sign In",
                onPressed: () => _openSignIn(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
