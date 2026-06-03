import 'package:agent_app/src/app/theme/app_theme_extension.dart';
import 'package:agent_app/src/features/onboarding/domain/models/onboarding_profile.dart';
import 'package:agent_app/src/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:agent_app/src/shared/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingTwo extends ConsumerStatefulWidget {
  const OnboardingTwo({super.key});

  @override
  ConsumerState<OnboardingTwo> createState() => _OnboardingTwoState();
}

class _OnboardingTwoState extends ConsumerState<OnboardingTwo> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _nationalityController;
  late final TextEditingController _countryController;

  static const List<String> _intakeOptions = [
    'Winter 2025/26',
    'Summer 2026',
    'Winter 2026/27',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingDraftProvider);
    _fullNameController = TextEditingController(text: state.fullName);
    _nationalityController = TextEditingController(text: state.nationality);
    _countryController = TextEditingController(text: state.countryOfResidence);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  void _syncController(TextEditingController controller, String value) {
    if (controller.text == value) {
      return;
    }

    controller.value = controller.value.copyWith(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
      composing: TextRange.empty,
    );
  }

  int _currentQuestionIndex(OnboardingProfile state) {
    if (state.fullName.trim().isEmpty) {
      return 0;
    }
    if (state.nationality.trim().isEmpty) {
      return 1;
    }
    if (state.targetDegree == null) {
      return 2;
    }
    if (state.intakeSemester.trim().isEmpty) {
      return 3;
    }
    if (state.countryOfResidence.trim().isEmpty) {
      return 4;
    }
    return 5;
  }

  String _questionText(int index) {
    switch (index) {
      case 0:
        return "What is your full name?";
      case 1:
        return "What is your nationality?";
      case 2:
        return "What degree are you targeting?";
      case 3:
        return "Which intake semester fits your plan?";
      case 4:
        return "What country do you currently live in?";
      default:
        return '';
    }
  }

  String _answerText(int index, OnboardingProfile state) {
    switch (index) {
      case 0:
        return state.fullName.trim();
      case 1:
        return state.nationality.trim();
      case 2:
        return _degreeLabel(state.targetDegree);
      case 3:
        return state.intakeSemester.trim();
      case 4:
        return state.countryOfResidence.trim();
      default:
        return '';
    }
  }

  void _submitTextAnswer(int index, OnboardingDraftController controller) {
    switch (index) {
      case 0:
        controller.updateFullName(_fullNameController.text.trim());
        break;
      case 1:
        controller.updateNationality(_nationalityController.text.trim());
        break;
      case 4:
        controller.updateCountryOfResidence(_countryController.text.trim());
        break;
    }

    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingDraftProvider);
    final controller = ref.read(onboardingDraftProvider.notifier);
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;
    final currentQuestionIndex = _currentQuestionIndex(state);

    _syncController(_fullNameController, state.fullName);
    _syncController(_nationalityController, state.nationality);
    _syncController(_countryController, state.countryOfResidence);

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
          decoration: BoxDecoration(
            gradient: appTheme.heroGradient,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: appTheme.borderStrong),
            boxShadow: appTheme.panelShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: appTheme.surfacePrimary.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: appTheme.borderSubtle),
                ),
                child: Text(
                  'AI-GUIDED PROFILE SETUP',
                  style: textTheme.labelMedium?.copyWith(
                    color: appTheme.successSoft,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your onboarding agent will ask one question at a time.',
                style: textTheme.headlineSmall?.copyWith(height: 1.18),
              ),
              const SizedBox(height: 10),
              Text(
                'This step now behaves like a guided conversation: answered items stay visible as a transcript, and only the current question is active.',
                style: textTheme.bodyLarge?.copyWith(
                  color: appTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        for (
          var index = 0;
          index < currentQuestionIndex && index < 5;
          index++
        ) ...[
          _AgentPrompt(title: 'EduAgent', question: _questionText(index)),
          const SizedBox(height: 10),
          _UserAnswer(answer: _answerText(index, state)),
          const SizedBox(height: 18),
        ],
        if (currentQuestionIndex < 5) ...[
          _AgentPrompt(
            title: 'EduAgent',
            question: _questionText(currentQuestionIndex),
            isActive: true,
          ),
          const SizedBox(height: 12),
          _CurrentAnswerComposer(
            child: _buildCurrentInput(
              context,
              currentQuestionIndex,
              state,
              controller,
            ),
          ),
        ] else ...[
          _AgentPrompt(
            title: 'EduAgent',
            question:
                'Perfect. I have everything I need for your personal background.',
            isActive: true,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: appTheme.surfaceSecondary,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: appTheme.borderSubtle),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0x2232C17C),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Color(0xFF32C17C),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All questions are answered. You can use Continue below to complete onboarding and save this setup to Firebase.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: appTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCurrentInput(
    BuildContext context,
    int currentQuestionIndex,
    OnboardingProfile state,
    OnboardingDraftController controller,
  ) {
    switch (currentQuestionIndex) {
      case 0:
        return _TextAnswerInput(
          controller: _fullNameController,
          hintText: 'Type your full name',
          actionLabel: 'Send answer',
          onChanged: (_) => setState(() {}),
          onSubmit: () => _submitTextAnswer(currentQuestionIndex, controller),
        );
      case 1:
        return _TextAnswerInput(
          controller: _nationalityController,
          hintText: 'Type your nationality',
          actionLabel: 'Send answer',
          onChanged: (_) => setState(() {}),
          onSubmit: () => _submitTextAnswer(currentQuestionIndex, controller),
        );
      case 2:
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              TargetDegree.values.map((degree) {
                return _OptionChip(
                  label: _degreeLabel(degree),
                  isSelected: state.targetDegree == degree,
                  onTap: () => controller.selectTargetDegree(degree),
                );
              }).toList(),
        );
      case 3:
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children:
              _intakeOptions.map((intake) {
                return _OptionChip(
                  label: intake,
                  isSelected: state.intakeSemester == intake,
                  onTap: () => controller.updateIntakeSemester(intake),
                );
              }).toList(),
        );
      case 4:
        return _TextAnswerInput(
          controller: _countryController,
          hintText: 'Type your current country',
          actionLabel: 'Send answer',
          onChanged: (_) => setState(() {}),
          onSubmit: () => _submitTextAnswer(currentQuestionIndex, controller),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _degreeLabel(TargetDegree? degree) {
    switch (degree) {
      case TargetDegree.bsc:
        return 'B.Sc.';
      case TargetDegree.msc:
        return 'M.Sc.';
      case TargetDegree.mba:
        return 'MBA';
      case null:
        return '';
    }
  }
}

class _AgentPrompt extends StatelessWidget {
  const _AgentPrompt({
    required this.title,
    required this.question,
    this.isActive = false,
  });

  final String title;
  final String question;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color:
                isActive
                    ? Theme.of(context).colorScheme.primary
                    : appTheme.surfaceTertiary,
            shape: BoxShape.circle,
            border: Border.all(color: appTheme.borderStrong),
          ),
          child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: textTheme.bodyMedium?.copyWith(
                  color: appTheme.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: appTheme.surfaceSecondary,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color:
                        isActive
                            ? appTheme.borderStrong
                            : appTheme.borderSubtle,
                  ),
                ),
                child: Text(
                  question,
                  style: textTheme.bodyLarge?.copyWith(
                    color: appTheme.textPrimary,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _UserAnswer extends StatelessWidget {
  const _UserAnswer({required this.answer});

  final String answer;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 280),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.22),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Text(
          answer,
          style: textTheme.bodyLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _CurrentAnswerComposer extends StatelessWidget {
  const _CurrentAnswerComposer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: appTheme.borderSubtle),
      ),
      child: child,
    );
  }
}

class _TextAnswerInput extends StatelessWidget {
  const _TextAnswerInput({
    required this.controller,
    required this.hintText,
    required this.actionLabel,
    required this.onChanged,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String hintText;
  final String actionLabel;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppTextField(
          prefixIcon: Icons.edit_rounded,
          hintText: hintText,
          controller: controller,
          textInputAction: TextInputAction.done,
          onChanged: onChanged,
          onSubmitted: (_) => onSubmit(),
        ),
        const SizedBox(height: 14),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: controller.text.trim().isEmpty ? null : onSubmit,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: Text(actionLabel),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Answer this question to unlock the next one.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: appTheme.textMuted),
        ),
      ],
    );
  }
}

class _OptionChip extends StatelessWidget {
  const _OptionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.primary
                      : appTheme.borderStrong,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.28),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ]
                    : null,
          ),
          child: Text(
            label,
            style: textTheme.bodyLarge?.copyWith(
              color: isSelected ? Colors.white : appTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
