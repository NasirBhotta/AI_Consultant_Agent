import 'package:agent_app/src/app/theme/app_theme_extension.dart';
import 'package:agent_app/src/core/constants/app_strings.dart';
import 'package:agent_app/src/features/home/presentation/pages/home_page.dart';
import 'package:agent_app/src/shared/widgets/app_primary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  bool isSubmitting = false;

  Future<void> _completeOnboarding() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboardingCompleted_${user.uid}', true);

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: appTheme.appBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                decoration: BoxDecoration(
                  color: appTheme.surfacePrimary.withValues(alpha: 0.96),
                  border: Border.all(color: appTheme.borderSubtle),
                  boxShadow: appTheme.panelShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        gradient: appTheme.heroGradient,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 30,
                        color: appTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Welcome to ${AppStrings.appName}',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Create your onboarding flow here. This feature can hold intro slides, profile setup, permissions, or a quick product tour.',
                      style: textTheme.bodyLarge?.copyWith(
                        color: appTheme.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: appTheme.surfaceSecondary,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: appTheme.borderStrong),
                      ),
                      child: Text(
                        'Recommended location: lib/src/features/onboarding/presentation/pages and lib/src/features/onboarding/presentation/widgets.',
                        style: textTheme.bodyMedium?.copyWith(
                          color: appTheme.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppPrimaryButton(
                      label: 'Finish onboarding',
                      onPressed: isSubmitting ? null : _completeOnboarding,
                      isLoading: isSubmitting,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
