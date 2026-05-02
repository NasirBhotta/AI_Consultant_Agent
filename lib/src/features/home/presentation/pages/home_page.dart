import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../shared/widgets/section_card.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.primaryContainer],
              ),
              borderRadius: BorderRadius.circular(28),
            ),

            ///
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.homeTitle,
                  style: textTheme.headlineSmall?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.homeSubtitle,
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onPrimary.withValues(alpha: 0.92),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.sectionSpacing),
          const SectionCard(
            title: 'Startup flow',
            lines: [
              'Native splash stays visible during initialization',
              'Firebase is initialized before the app opens',
              'Extra boot tasks can be added in src/app/startup/app_startup.dart',
            ],
          ),
          const SizedBox(height: AppConstants.sectionSpacing),
          const SectionCard(
            title: 'Suggested lib structure',
            lines: [
              'lib/',
              '  main.dart',
              '  src/app/              app shell, theme, router',
              '  src/core/             constants, utils, base helpers',
              '  src/features/         feature-first modules',
              '  src/services/         Firebase and external integrations',
              '  src/shared/           reusable widgets and models',
            ],
          ),
          const SizedBox(height: AppConstants.sectionSpacing),
          const SectionCard(
            title: 'Firebase layer',
            lines: [
              'Firebase bootstrap now lives in src/services/firebase/',
              'Add Auth, Firestore, Storage, Messaging wrappers here',
            ],
          ),
          const SizedBox(height: AppConstants.sectionSpacing),
          const SectionCard(
            title: 'How to scale features',
            lines: [
              'Group each feature by domain: data, domain, presentation',
              'Keep shared code out of features unless reused broadly',
              'Place environment-specific setup at the app/services level',
            ],
          ),
        ],
      ),
    );
  }
}
