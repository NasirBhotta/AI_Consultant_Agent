import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../features/auth/constants/auth_strings.dart';
import '../../../../features/auth/presentation/pages/sign_in_page.dart';
import '../../../../features/auth/presentation/widgets/auth_brand_badge.dart';
import '../../../../features/auth/presentation/widgets/auth_shell.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_secondary_button.dart';
import '../../app_startup.dart';

class StartupPage extends StatefulWidget {
  const StartupPage({super.key});

  @override
  State<StartupPage> createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  final AppStartup _startup = AppStartup();

  bool _isInitializing = true;
  bool _isStartupReady = false;
  Object? _startupError;

  @override
  void initState() {
    super.initState();
    _loadApp();
  }

  Future<void> _loadApp() async {
    setState(() {
      _isInitializing = true;
      _startupError = null;
    });

    try {
      await _startup.initialize();
      _isStartupReady = true;
    } catch (error, stackTrace) {
      _isStartupReady = false;
      _startupError = error;
      AppLogger.error('Startup failed.', error, stackTrace);
    } finally {
      FlutterNativeSplash.remove();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isInitializing = false;
    });
  }

  void _openSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => SignInPage(isStartupReady: _isStartupReady),
      ),
    );
  }

  void _showPendingFlow(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label flow is the next screen to build.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;
    final hasError = _startupError != null;

    return AuthShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 52),
                    const AuthBrandBadge(size: 62, iconSize: 30),
                    const SizedBox(height: 26),
                    Text(
                      AppStrings.appName,
                      textAlign: TextAlign.center,
                      style: textTheme.displayMedium,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AuthStrings.startupTagline,
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        color: appTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 48),
                    if (_isInitializing)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 18),
                        child: Text(
                          AuthStrings.startupLoading,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    if (hasError)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 18),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.error.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withValues(alpha: 0.36),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              AuthStrings.startupFailed,
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: appTheme.errorSoft,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            AppSecondaryButton(
                              label: AuthStrings.retry,
                              onPressed: _loadApp,
                            ),
                          ],
                        ),
                      ),
                    AppPrimaryButton(
                      label: AuthStrings.signUpTitle,
                      onPressed:
                          _isInitializing
                              ? null
                              : () => _showPendingFlow(AuthStrings.signUpTitle),
                      isLoading: _isInitializing,
                    ),
                    const SizedBox(height: 16),
                    AppSecondaryButton(
                      label: AuthStrings.logInTitle,
                      onPressed: _isInitializing ? null : _openSignIn,
                    ),
                    const SizedBox(height: 40),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: appTheme.borderSubtle.withValues(alpha: 0.6),
                            thickness: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            AppStrings.appFooter,
                            style: textTheme.labelLarge?.copyWith(
                              color: appTheme.textMuted,
                              letterSpacing: 3.2,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: appTheme.borderSubtle.withValues(alpha: 0.6),
                            thickness: 1,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
