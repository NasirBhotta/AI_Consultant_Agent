import 'package:agent_app/src/app/providers/app_providers.dart';
import 'package:agent_app/src/app/theme/app_theme_extension.dart';
import 'package:agent_app/src/core/constants/app_strings.dart';
import 'package:agent_app/src/core/utils/app_logger.dart';
import 'package:agent_app/src/core/utils/validators.dart';
import 'package:agent_app/src/features/auth/constants/auth_strings.dart';
import 'package:agent_app/src/features/auth/domain/models/sign_in_credentials.dart';
import 'package:agent_app/src/features/auth/presentation/pages/sign_up_page.dart';
import 'package:agent_app/src/features/auth/presentation/pages/verify_email_page.dart';
import 'package:agent_app/src/features/auth/presentation/widgets/auth_brand_badge.dart';
import 'package:agent_app/src/features/auth/presentation/widgets/auth_shell.dart';
import 'package:agent_app/src/features/home/presentation/pages/home_page.dart';
import 'package:agent_app/src/shared/widgets/app_primary_button.dart';
import 'package:agent_app/src/shared/widgets/app_secondary_button.dart';
import 'package:agent_app/src/shared/widgets/app_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

class SignInPage extends ConsumerStatefulWidget {
  const SignInPage({super.key, required this.isStartupReady});

  final bool isStartupReady;

  @override
  ConsumerState<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends ConsumerState<SignInPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isSubmitting = false;
  bool obscurePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!widget.isStartupReady) {
      _showMessage(
        'App services are still initializing. Please wait a moment and try again.',
      );
      return;
    }

    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) {
      _showMessage('Please fix the errors in the form and try again.');
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      isSubmitting = true;
    });

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final session = await authRepository.signIn(
        SignInCredentials(
          email: emailController.text,
          password: passwordController.text,
        ),
      );

      if (!mounted) {
        return;
      }

      if (!session.emailVerified) {
        _showMessage(AuthStrings.verificationStillPending);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (_) => VerifyEmailPage(
                  isStartupReady: widget.isStartupReady,
                  email: session.email,
                ),
          ),
        );
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AuthStrings.signInSuccess)));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      AppLogger.error('Sign-in failed.', error, stackTrace);
      _showMessage(
        error.message ?? 'An unknown error occurred. Please try again.',
      );
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected sign-in failed.', error, stackTrace);
      _showMessage(AuthStrings.signInFailure);
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (!widget.isStartupReady) {
      _showMessage(
        'App services are still initializing. Please wait a moment and try again.',
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      isSubmitting = true;
    });

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.signInWithGoogle();

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      AppLogger.error('Google sign-in failed.', error, stackTrace);
      if (error.code == 'sign_in_canceled') {
        _showMessage('Google sign-in was canceled.');
      } else {
        _showMessage(error.message ?? AuthStrings.googleUnavailable);
      }
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected Google sign-in failed.', error, stackTrace);
      _showMessage(AuthStrings.googleUnavailable);
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handlePasswordReset() async {
    if (!widget.isStartupReady) {
      _showMessage(
        'App services are still initializing. Please wait a moment and try again.',
      );
      return;
    }

    final emailError = Validators.email(emailController.text);
    if (emailError != null) {
      _showMessage(emailError);
      return;
    }

    try {
      final authRepository = ref.read(authRepositoryProvider);
      await authRepository.sendPasswordReset(email: emailController.text);
      _showMessage('Password reset email sent. Please check your inbox.');
    } on FirebaseAuthException catch (error, stackTrace) {
      AppLogger.error('Password reset failed.', error, stackTrace);
      _showMessage(error.message ?? AuthStrings.forgotPasswordUnavailable);
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected password reset failed.', error, stackTrace);
      _showMessage(AuthStrings.forgotPasswordUnavailable);
    }
  }

  void _openSignUp() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SignUpPage(isStartupReady: widget.isStartupReady),
      ),
    );
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
        padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
        decoration: BoxDecoration(
          color: appTheme.surfacePrimary.withValues(alpha: 0.96),
          border: Border.all(color: appTheme.borderSubtle),
          boxShadow: appTheme.panelShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 25, bottom: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AuthBrandBadge(),
              const SizedBox(height: 24),
              Text(AppStrings.appName, style: textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text(
                AuthStrings.signInTagline,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium,
              ),
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
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Text(
                        AuthStrings.signInTitle,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: emailController,
                        hintText: AuthStrings.emailHint,
                        label: AuthStrings.emailLabel,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        validator: Validators.email,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              AuthStrings.passwordLabel,
                              style: textTheme.bodyLarge,
                            ),
                          ),
                          TextButton(
                            onPressed:
                                isSubmitting ? null : _handlePasswordReset,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 0),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text(AuthStrings.forgotPassword),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      AppTextField(
                        controller: passwordController,
                        hintText: '********',
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: Validators.password,
                        obscureText: obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        enabled: !isSubmitting,
                        suffixIcon: IconButton(
                          onPressed:
                              isSubmitting
                                  ? null
                                  : () {
                                    setState(() {
                                      obscurePassword = !obscurePassword;
                                    });
                                  },
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppPrimaryButton(
                        label: AuthStrings.continueLabel,
                        onPressed: isSubmitting ? null : _handleSignIn,
                        isLoading: isSubmitting,
                        trailing: const Icon(Icons.arrow_forward_rounded),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: appTheme.borderStrong),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: appTheme.surfaceTertiary,
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Text(
                              AuthStrings.dividerLabel,
                              style: textTheme.labelMedium?.copyWith(
                                color: appTheme.successSoft,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Divider(color: appTheme.borderStrong),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AppSecondaryButton(
                        label: AuthStrings.continueWithGoogle,
                        onPressed: isSubmitting ? null : _handleGoogleSignIn,
                        leading: SvgPicture.asset(
                          'assets/icons/google.svg',
                          width: 25,
                          height: 25,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AuthStrings.noAccountPrompt,
                            style: textTheme.bodyMedium?.copyWith(
                              color: appTheme.textMuted,
                            ),
                          ),
                          TextButton(
                            onPressed: isSubmitting ? null : _openSignUp,
                            style: TextButton.styleFrom(
                              foregroundColor: appTheme.successSoft,
                            ),
                            child: const Text(AuthStrings.createAccount),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: appTheme.surfaceSecondary,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: appTheme.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 17,
                      color: appTheme.successSoft,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AuthStrings.securityChip,
                      style: textTheme.labelLarge?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: appTheme.successSoft,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: const Text(AuthStrings.privacyPolicy),
                  ),
                  Text(
                    '/',
                    style: textTheme.bodyMedium?.copyWith(
                      color: appTheme.textMuted,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(AuthStrings.termsOfService),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
