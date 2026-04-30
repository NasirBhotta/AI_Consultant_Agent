import 'package:agent_app/src/app/theme/app_theme_extension.dart';
import 'package:agent_app/src/core/constants/app_strings.dart';
import 'package:agent_app/src/core/utils/app_logger.dart';
import 'package:agent_app/src/features/auth/constants/auth_strings.dart';
import 'package:agent_app/src/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:agent_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:agent_app/src/features/auth/presentation/pages/sign_in_page.dart';
import 'package:agent_app/src/features/auth/presentation/widgets/auth_brand_badge.dart';
import 'package:agent_app/src/features/auth/presentation/widgets/auth_shell.dart';
import 'package:agent_app/src/features/home/presentation/pages/home_page.dart';
import 'package:agent_app/src/shared/widgets/app_primary_button.dart';
import 'package:agent_app/src/shared/widgets/app_secondary_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({
    super.key,
    required this.isStartupReady,
    required this.email,
  });

  final bool isStartupReady;
  final String email;

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isSubmitting = false;

  AuthRepository get authRepository => FirebaseAuthRepository();

  Future<void> _resendVerificationEmail() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      await authRepository.sendEmailVerification();
      _showMessage(AuthStrings.verificationEmailSent);
    } on FirebaseAuthException catch (error, stackTrace) {
      AppLogger.error('Resend verification failed.', error, stackTrace);
      _showMessage(error.message ?? AuthStrings.createAccountUnavailable);
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected resend verification failed.', error, stackTrace);
      _showMessage(AuthStrings.createAccountUnavailable);
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> _checkVerificationStatus() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      final isVerified = await authRepository.reloadAndCheckEmailVerification();

      if (!mounted) {
        return;
      }

      if (!isVerified) {
        _showMessage(AuthStrings.verificationStillPending);
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      AppLogger.error('Verification refresh failed.', error, stackTrace);
      _showMessage(error.message ?? AuthStrings.createAccountUnavailable);
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected verification refresh failed.', error, stackTrace);
      _showMessage(AuthStrings.createAccountUnavailable);
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> _backToSignIn() async {
    setState(() {
      isSubmitting = true;
    });

    try {
      await authRepository.signOut();
      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => SignInPage(isStartupReady: widget.isStartupReady),
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error('Sign-out before returning to sign-in failed.', error, stackTrace);
      _showMessage('Please try again.');
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

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;

    return AuthShell(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        decoration: BoxDecoration(
          color: appTheme.surfacePrimary.withValues(alpha: 0.96),
          border: Border.all(color: appTheme.borderSubtle),
          boxShadow: appTheme.panelShadow,
        ),
        child: Column(
          children: [
            const AuthBrandBadge(),
            const SizedBox(height: 24),
            Text(AppStrings.appName, style: textTheme.headlineMedium),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
              decoration: BoxDecoration(
                color: appTheme.surfaceSecondary,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: appTheme.borderStrong),
                boxShadow:
                    appTheme.panelShadow
                        .map(
                          (shadow) => shadow.copyWith(
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                            color: shadow.color.withValues(alpha: 0.2),
                          ),
                        )
                        .toList(),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.mark_email_unread_outlined,
                    size: 44,
                    color: appTheme.successSoft,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    AuthStrings.verifyEmailTitle,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AuthStrings.verifyEmailBody,
                    textAlign: TextAlign.center,
                    style: textTheme.bodyMedium?.copyWith(
                      color: appTheme.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: appTheme.surfaceTertiary,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: appTheme.borderSubtle),
                    ),
                    child: Text(
                      widget.email,
                      textAlign: TextAlign.center,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AppPrimaryButton(
                    label: AuthStrings.iVerifiedMyEmail,
                    onPressed: isSubmitting ? null : _checkVerificationStatus,
                    isLoading: isSubmitting,
                  ),
                  const SizedBox(height: 14),
                  AppSecondaryButton(
                    label: AuthStrings.resendVerificationEmail,
                    onPressed: isSubmitting ? null : _resendVerificationEmail,
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: isSubmitting ? null : _backToSignIn,
                    child: const Text(AuthStrings.backToSignIn),
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
