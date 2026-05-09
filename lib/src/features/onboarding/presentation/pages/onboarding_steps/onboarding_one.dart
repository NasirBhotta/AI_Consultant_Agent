import 'package:agent_app/src/app/theme/app_theme_extension.dart';
import 'package:agent_app/src/features/onboarding/domain/models/onboarding_profile.dart';
import 'package:agent_app/src/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingOne extends ConsumerWidget {
  const OnboardingOne({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingDraftProvider);
    final controller = ref.read(onboardingDraftProvider.notifier);
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            gradient: appTheme.heroGradient,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: appTheme.borderStrong),
            boxShadow: appTheme.panelShadow,
          ),

          /// updated
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: appTheme.surfacePrimary.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: appTheme.borderSubtle),
                ),
                child: Text(
                  'APPLICATION GATE CHECK',
                  style: textTheme.labelMedium?.copyWith(
                    color: appTheme.successSoft,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'Do you have an APS Certificate?',
                style: textTheme.headlineMedium?.copyWith(
                  fontSize: 34,
                  height: 1.05,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'The Akademische Prufstelle (APS) is mandatory for applicants from Pakistan and South Asia to verify academic credentials for German universities.',
                style: textTheme.bodyLarge?.copyWith(
                  color: appTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _ChoiceCard(
          isSelected: state.apsStatus == ApsCertificateStatus.hasCertificate,
          accentColor: const Color(0xFF32C17C),
          icon: Icons.check_circle_outline_rounded,
          title: 'Yes, I have it',
          subtitle: 'I have a digital or physical copy of my certificate.',
          onTap:
              () => controller.selectApsStatus(
                ApsCertificateStatus.hasCertificate,
              ),
        ),
        const SizedBox(height: 14),
        _ChoiceCard(
          isSelected: state.apsStatus == ApsCertificateStatus.applying,
          accentColor: const Color(0xFFFFB86B),
          icon: Icons.schedule_rounded,
          title: "I'm applying for it",
          subtitle: 'My application is in progress with the APS office.',
          badgeLabel: 'ALLOW 4-8 WEEKS',
          onTap:
              () => controller.selectApsStatus(ApsCertificateStatus.applying),
        ),
        const SizedBox(height: 14),
        _ChoiceCard(
          isSelected: state.apsStatus == ApsCertificateStatus.needsGuidance,
          accentColor: const Color(0xFF9BBEFF),
          icon: Icons.help_outline_rounded,
          title: "I don't know what this is",
          subtitle: 'I need more information about the APS requirement.',
          onTap:
              () => controller.selectApsStatus(
                ApsCertificateStatus.needsGuidance,
              ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: appTheme.borderStrong),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0x33FFB86B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 18,
                  color: Color(0xFFFFB86B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'You can continue now, but application launch steps should wait until your APS is confirmed.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: appTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _InfoCard(
          title: 'Why is this required?',
          body:
              "Germany's Academic Evaluation Center uses APS to validate transcripts and academic eligibility before university admission proceeds.",
          actionLabel: 'View detailed guide',
          actionIcon: Icons.arrow_forward_rounded,
        ),
        const SizedBox(height: 16),
        _InfoCard(
          title: 'Need help?',
          body:
              'Our advisors can help you understand the APS process, required documents, and expected timelines.',
          actionLabel: 'Talk to an agent',
          leadingIcon: Icons.support_agent_rounded,
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.isSelected,
    required this.accentColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badgeLabel,
  });

  final bool isSelected;
  final Color accentColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badgeLabel;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? appTheme.surfaceTertiary.withValues(alpha: 0.7)
                    : appTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? appTheme.successSoft : appTheme.borderSubtle,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        color: appTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: appTheme.textSecondary,
                      ),
                    ),
                    if (badgeLabel != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: appTheme.surfacePrimary,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: appTheme.borderSubtle),
                        ),
                        child: Text(
                          badgeLabel!,
                          style: textTheme.labelMedium?.copyWith(
                            color: appTheme.accentWarm,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected
                            ? appTheme.successSoft
                            : appTheme.borderStrong,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Center(
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: appTheme.successSoft,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                        : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.actionLabel,
    this.leadingIcon,
    this.actionIcon,
  });

  final String title;
  final String body;
  final String actionLabel;
  final IconData? leadingIcon;
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: appTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: appTheme.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leadingIcon != null) ...[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: appTheme.surfaceTertiary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(leadingIcon, size: 20, color: appTheme.successSoft),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            title,
            style: textTheme.bodyLarge?.copyWith(
              color: appTheme.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: textTheme.bodyMedium?.copyWith(
              color: appTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                actionLabel,
                style: textTheme.bodyMedium?.copyWith(
                  color: appTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (actionIcon != null) ...[
                const SizedBox(width: 8),
                Icon(actionIcon, size: 18, color: appTheme.textPrimary),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
