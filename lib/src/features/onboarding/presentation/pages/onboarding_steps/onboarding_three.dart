import 'package:agent_app/src/app/theme/app_theme_extension.dart';
import 'package:agent_app/src/features/onboarding/domain/models/onboarding_profile.dart';
import 'package:agent_app/src/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingThree extends ConsumerWidget {
  const OnboardingThree({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingDraftProvider);
    final controller = ref.read(onboardingDraftProvider.notifier);
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    final requiredDocuments = _requiredDocumentsForTrack(state.academicTrack);
    final optionalDocuments = const [
      _DocumentDefinition(
        type: OnboardingDocumentType.profilePhoto,
        title: 'Profile photo',
        subtitle: 'Used for profile identity and future applications',
        badgeLabel: 'OPTIONAL',
        icon: Icons.account_circle_outlined,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      ),
      _DocumentDefinition(
        type: OnboardingDocumentType.previousCv,
        title: 'Previous CV',
        subtitle: 'Any existing CV, including non-Europass format',
        badgeLabel: 'OPTIONAL',
        icon: Icons.description_outlined,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      ),
      _DocumentDefinition(
        type: OnboardingDocumentType.recommendationLetterOne,
        title: 'Recommendation letter 1',
        subtitle: 'From school, college, or university faculty',
        badgeLabel: 'OPTIONAL',
        icon: Icons.mail_outline_rounded,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      ),
      _DocumentDefinition(
        type: OnboardingDocumentType.recommendationLetterTwo,
        title: 'Recommendation letter 2',
        subtitle: 'Second letter for stronger later applications',
        badgeLabel: 'OPTIONAL',
        icon: Icons.mail_lock_outlined,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
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
                  color: appTheme.surfacePrimary.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: appTheme.borderSubtle),
                ),
                child: Text(
                  'DOCUMENT READINESS',
                  style: textTheme.labelMedium?.copyWith(
                    color: appTheme.successSoft,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Upload the documents we need to match universities.',
                style: textTheme.headlineSmall?.copyWith(height: 1.12),
              ),
              const SizedBox(height: 12),
              Text(
                'We are intentionally skipping motivational letter here because it depends on the specific university. Right now we only collect profile and academic documents, with strict requirements separated from later optional items.',
                style: textTheme.bodyLarge?.copyWith(
                  color: appTheme.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeader(
          title: 'Choose your academic system',
          subtitle:
              'This decides which certificates and marksheets are strictly required.',
        ),
        const SizedBox(height: 12),
        _TrackChoiceCard(
          title: 'Matric + Inter',
          subtitle: 'Upload both certificates and both marksheets',
          icon: Icons.school_outlined,
          isSelected: state.academicTrack == AcademicTrack.matricInter,
          onTap: () => controller.selectAcademicTrack(AcademicTrack.matricInter),
        ),
        const SizedBox(height: 12),
        _TrackChoiceCard(
          title: 'O Level + A Level',
          subtitle: 'Upload certificates and available result statements',
          icon: Icons.translate_rounded,
          isSelected: state.academicTrack == AcademicTrack.oLevelALevel,
          onTap: () => controller.selectAcademicTrack(AcademicTrack.oLevelALevel),
        ),
        const SizedBox(height: 22),
        _SectionHeader(
          title: 'Strictly required for matching',
          subtitle:
              'These are the core academic records the agent needs to start evaluating university fit.',
        ),
        const SizedBox(height: 12),
        if (state.academicTrack == null)
          _EmptyStateCard(
            icon: Icons.rule_folder_outlined,
            message:
                'Select your academic system first so we can show the required documents.',
          )
        else
          ...requiredDocuments.map(
            (document) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _DocumentUploadCard(
                document: document,
                state: state,
              ),
            ),
          ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: appTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: appTheme.borderStrong),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0x2232C17C),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.fact_check_outlined,
                  size: 18,
                  color: Color(0xFF32C17C),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Required right now: academic certificates and marksheets only. Everything below is still valuable, but optional at this stage.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: appTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeader(
          title: 'Helpful for later applications',
          subtitle:
              'Optional now, but useful when we move into shortlisting and application preparation.',
        ),
        const SizedBox(height: 12),
        ...optionalDocuments.map(
          (document) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _DocumentUploadCard(
              document: document,
              state: state,
            ),
          ),
        ),
      ],
    );
  }

  List<_DocumentDefinition> _requiredDocumentsForTrack(AcademicTrack? track) {
    if (track == AcademicTrack.oLevelALevel) {
      return const [
        _DocumentDefinition(
          type: OnboardingDocumentType.oLevelCertificate,
          title: 'O Level certificate',
          subtitle: 'Certificate or official completion document',
          badgeLabel: 'REQUIRED',
          icon: Icons.workspace_premium_outlined,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        ),
        _DocumentDefinition(
          type: OnboardingDocumentType.oLevelMarksheet,
          title: 'O Level marksheet / results',
          subtitle: 'Statement of results or equivalent official marks record',
          badgeLabel: 'REQUIRED',
          icon: Icons.assessment_outlined,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        ),
        _DocumentDefinition(
          type: OnboardingDocumentType.aLevelCertificate,
          title: 'A Level certificate',
          subtitle: 'Certificate or official completion document',
          badgeLabel: 'REQUIRED',
          icon: Icons.workspace_premium_outlined,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        ),
        _DocumentDefinition(
          type: OnboardingDocumentType.aLevelMarksheet,
          title: 'A Level marksheet / results',
          subtitle: 'Statement of results or equivalent official marks record',
          badgeLabel: 'REQUIRED',
          icon: Icons.assessment_outlined,
          allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
        ),
      ];
    }

    return const [
      _DocumentDefinition(
        type: OnboardingDocumentType.matricCertificate,
        title: 'Matric certificate',
        subtitle: 'Secondary school completion certificate',
        badgeLabel: 'REQUIRED',
        icon: Icons.workspace_premium_outlined,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      ),
      _DocumentDefinition(
        type: OnboardingDocumentType.matricMarksheet,
        title: 'Matric marksheet',
        subtitle: 'Official transcript or marks record',
        badgeLabel: 'REQUIRED',
        icon: Icons.assessment_outlined,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      ),
      _DocumentDefinition(
        type: OnboardingDocumentType.interCertificate,
        title: 'Inter certificate',
        subtitle: 'Higher secondary completion certificate',
        badgeLabel: 'REQUIRED',
        icon: Icons.workspace_premium_outlined,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      ),
      _DocumentDefinition(
        type: OnboardingDocumentType.interMarksheet,
        title: 'Inter marksheet',
        subtitle: 'Official transcript or marks record',
        badgeLabel: 'REQUIRED',
        icon: Icons.assessment_outlined,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      ),
    ];
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
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
          style: textTheme.bodyMedium?.copyWith(color: appTheme.textSecondary),
        ),
      ],
    );
  }
}

class _TrackChoiceCard extends StatelessWidget {
  const _TrackChoiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? appTheme.surfaceTertiary.withValues(alpha: 0.7)
                    : appTheme.surfaceSecondary,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? appTheme.successSoft : appTheme.borderSubtle,
              width: isSelected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: appTheme.surfacePrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: appTheme.successSoft, size: 22),
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
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                isSelected
                    ? Icons.radio_button_checked_rounded
                    : Icons.radio_button_off_rounded,
                color: isSelected ? appTheme.successSoft : appTheme.borderStrong,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocumentUploadCard extends ConsumerWidget {
  const _DocumentUploadCard({required this.document, required this.state});

  final _DocumentDefinition document;
  final OnboardingProfile state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;
    final record = state.documents[document.type];
    final isUploading = state.uploadingDocument == document.type;
    final controller = ref.read(onboardingControllerProvider);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: appTheme.surfaceSecondary,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color:
              record != null
                  ? appTheme.successSoft
                  : appTheme.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: appTheme.surfacePrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(document.icon, color: appTheme.successSoft, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: textTheme.bodyLarge?.copyWith(
                        color: appTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document.subtitle,
                      style: textTheme.bodyMedium?.copyWith(
                        color: appTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _StatusBadge(
                label:
                    record != null
                        ? 'UPLOADED'
                        : document.badgeLabel,
                color:
                    record != null
                        ? const Color(0xFF32C17C)
                        : document.badgeLabel == 'REQUIRED'
                        ? const Color(0xFFFFB86B)
                        : appTheme.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (record == null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: appTheme.surfacePrimary,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: appTheme.borderSubtle),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 34,
                    color: appTheme.textMuted,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Supported: ${document.allowedExtensions.join(', ').toUpperCase()}',
                    style: textTheme.bodyMedium?.copyWith(
                      color: appTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FilledButton.icon(
                      onPressed:
                          isUploading
                              ? null
                              : () async {
                                try {
                                  await controller.uploadDocument(
                                    type: document.type,
                                    allowedExtensions: document.allowedExtensions,
                                  );
                                } catch (error) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('$error')),
                                    );
                                  }
                                }
                              },
                      icon:
                          isUploading
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                              : const Icon(Icons.upload_file_rounded, size: 18),
                      label: Text(isUploading ? 'Uploading...' : 'Upload file'),
                    ),
                  ),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: appTheme.surfacePrimary,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: appTheme.borderStrong),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.insert_drive_file_outlined,
                        color: appTheme.successSoft,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          record.fileName,
                          style: textTheme.bodyMedium?.copyWith(
                            color: appTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          try {
                            await controller.removeDocument(document.type);
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$error')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.delete_outline_rounded, size: 18),
                        label: const Text('Remove'),
                      ),
                      const SizedBox(width: 10),
                      FilledButton.icon(
                        onPressed: () async {
                          try {
                            await controller.uploadDocument(
                              type: document.type,
                              allowedExtensions: document.allowedExtensions,
                            );
                          } catch (error) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('$error')),
                              );
                            }
                          }
                        },
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text('Replace'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.icon, required this.message});

  final IconData icon;
  final String message;

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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: appTheme.surfacePrimary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: appTheme.textMuted),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: appTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: appTheme.borderSubtle),
      ),
      child: Text(
        label,
        style: textTheme.labelMedium?.copyWith(
          color: color,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _DocumentDefinition {
  const _DocumentDefinition({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.badgeLabel,
    required this.icon,
    required this.allowedExtensions,
  });

  final OnboardingDocumentType type;
  final String title;
  final String subtitle;
  final String badgeLabel;
  final IconData icon;
  final List<String> allowedExtensions;
}
