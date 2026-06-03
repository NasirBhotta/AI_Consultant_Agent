import 'package:agent_app/src/app/theme/app_theme_extension.dart';
import 'package:agent_app/src/core/utils/app_logger.dart';
import 'package:agent_app/src/features/onboarding/presentation/pages/onboarding_steps/onboarding_one.dart';
import 'package:agent_app/src/features/onboarding/presentation/pages/onboarding_steps/onboarding_three.dart';
import 'package:agent_app/src/features/onboarding/presentation/pages/onboarding_steps/onboarding_two.dart';
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

  int get _implementedSteps => 3;

  int get _displayTotalSteps => 5;

  bool get _isLastStep => _currentStep == _implementedSteps - 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(onboardingDraftProvider.notifier).loadDraft();
      } catch (error, stackTrace) {
        AppLogger.error('Failed to load onboarding draft.', error, stackTrace);
        if (mounted) {
          _showMessage('We could not load your saved onboarding details.');
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool isSubmitting = false;

  Future<void> _handleContinue() async {
    final profile = ref.read(onboardingDraftProvider);

    if (_currentStep == 0 && !profile.isStepOneComplete) {
      _showMessage('Select your APS certificate status before continuing.');
      return;
    }

    if (_currentStep == 1 && !profile.isStepTwoComplete) {
      _showMessage('Complete the personal background details to continue.');
      return;
    }

    if (_currentStep == 2 && !profile.isStepThreeComplete) {
      _showMessage('Upload the required academic documents to continue.');
      return;
    }

    try {
      if (mounted) {
        setState(() {
          isSubmitting = true;
        });
      }

      if (!_isLastStep) {
        await ref.read(onboardingControllerProvider).saveDraft();
        await _pageController.nextPage(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOut,
        );
        return;
      }

      await ref.read(onboardingControllerProvider).saveDraft();
      _showMessage('Step 3 is saved. We can build step 4 next.');
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
    final profile = ref.watch(onboardingDraftProvider);
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;
    final progress = (_currentStep + 1) / _displayTotalSteps;
    final percentLabel = '${(progress * 100).round()}% complete';

    return Scaffold(
      backgroundColor: appTheme.appBackground,
      appBar: AppBar(
        title: const Text('Application Journey'),
        actions: [
          IconButton(
            tooltip: 'Progress help',
            onPressed:
                () => _showMessage(
                  'We save each onboarding step so you can safely resume later.',
                ),
            icon: const Icon(Icons.help_outline_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 10),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Step ${_currentStep + 1} of $_displayTotalSteps',
                        style: textTheme.titleMedium?.copyWith(
                          color: appTheme.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        percentLabel,
                        style: textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,
                      backgroundColor: appTheme.surfaceTertiary,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
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
                children: const [
                  OnboardingOne(),
                  OnboardingTwo(),
                  OnboardingThree(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: appTheme.surfaceSecondary,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: appTheme.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          profile.isStepOneComplete &&
                                  profile.isStepTwoComplete &&
                                  profile.isStepThreeComplete
                              ? Icons.verified_rounded
                              : Icons.auto_awesome_rounded,
                          size: 20,
                          color:
                              profile.isStepOneComplete &&
                                      profile.isStepTwoComplete &&
                                      profile.isStepThreeComplete
                                  ? const Color(0xFF32C17C)
                                  : appTheme.successSoft,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            profile.isStepOneComplete &&
                                    profile.isStepTwoComplete &&
                                    profile.isStepThreeComplete
                                ? 'Step 3 is complete. The next onboarding steps can build on this saved data.'
                                : 'Your responses are saved as you move through the journey.',
                            style: textTheme.bodyMedium?.copyWith(
                              color: appTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child:
                            _currentStep == 0
                                ? const SizedBox()
                                : AppSecondaryButton(
                                  label: 'Back',
                                  onPressed: isSubmitting ? null : _handleBack,
                                ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppPrimaryButton(
                          label: _isLastStep ? 'Save Progress' : 'Next',
                          onPressed: isSubmitting ? null : _handleContinue,
                          isLoading: isSubmitting,
                        ),
                      ),
                    ],
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
