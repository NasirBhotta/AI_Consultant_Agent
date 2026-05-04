import 'package:agent_app/src/app/theme/app_theme_extension.dart';
import 'package:agent_app/src/core/constants/app_strings.dart';
import 'package:agent_app/src/core/utils/app_logger.dart';
import 'package:agent_app/src/features/home/presentation/pages/home_page.dart';
import 'package:agent_app/src/features/onboarding/presentation/pages/onboarding_steps/onboarding_one.dart';
import 'package:agent_app/src/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:agent_app/src/shared/widgets/app_primary_button.dart';
import 'package:agent_app/src/shared/widgets/app_secondary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  late final PageController _pageController;
  int _currentStep = 0;

  int get _totalSteps => 1;

  bool get _isLastStep => _currentStep == _totalSteps - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool isSubmitting = false;

  Future<void> _handleContinue() async {
    if (!_isLastStep) {
      await _pageController.nextPage(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOut,
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await ref.read(onboardingControllerProvider).completeOnboarding();

      if (!mounted) {
        return;
      }

      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
    } on FirebaseAuthException catch (error, stackTrace) {
      AppLogger.error('Failed to complete onboarding.', error, stackTrace);
      _showMessage(error.message ?? 'Please sign in again and try once more.');
    } catch (error, stackTrace) {
      AppLogger.error(
        'Unexpected onboarding completion failure.',
        error,
        stackTrace,
      );
      _showMessage('We could not finish onboarding. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _handleBack() async {
    if (_currentStep == 0) {
      Navigator.of(context).maybePop();
      return;
    }

    await _pageController.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: appTheme.appBackground,
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
              child: Row(
                children: List.generate(_totalSteps, (index) {
                  final isActive = index == _currentStep;
                  return Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 6,
                      margin: EdgeInsets.only(
                        right: index == _totalSteps - 1 ? 0 : 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isActive
                                ? appTheme.successSoft
                                : appTheme.surfaceTertiary,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Step ${_currentStep + 1} of $_totalSteps',
                  style: textTheme.labelMedium?.copyWith(
                    color: appTheme.textMuted,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: const [OnboardingOne()],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Row(
                children: [
                  Expanded(
                    child: AppSecondaryButton(
                      label: 'Back',
                      onPressed: isSubmitting ? null : _handleBack,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppPrimaryButton(
                      label: _isLastStep ? 'Continue' : 'Next',
                      onPressed: isSubmitting ? null : _handleContinue,
                      isLoading: isSubmitting,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
