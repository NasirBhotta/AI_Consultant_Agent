import 'package:agent_app/src/app/theme/app_theme_extension.dart';
import 'package:agent_app/src/core/constants/app_strings.dart';
import 'package:agent_app/src/core/utils/app_logger.dart';
import 'package:agent_app/src/core/utils/validators.dart';
import 'package:agent_app/src/features/auth/constants/auth_strings.dart';
import 'package:agent_app/src/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:agent_app/src/features/auth/domain/models/sign_up_credentials.dart';
import 'package:agent_app/src/features/auth/domain/repositories/auth_repository.dart';
import 'package:agent_app/src/features/auth/presentation/pages/sign_in_page.dart';
import 'package:agent_app/src/features/auth/presentation/pages/verify_email_page.dart';
import 'package:agent_app/src/features/auth/presentation/widgets/auth_brand_badge.dart';
import 'package:agent_app/src/features/auth/presentation/widgets/auth_shell.dart';
import 'package:agent_app/src/features/home/presentation/pages/home_page.dart';
import 'package:agent_app/src/shared/widgets/app_primary_button.dart';
import 'package:agent_app/src/shared/widgets/app_secondary_button.dart';
import 'package:agent_app/src/shared/widgets/app_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key, required this.isStartupReady});

  final bool isStartupReady;

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool isSubmitting = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  AuthRepository get authRepository => FirebaseAuthRepository();

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String? _confirmPasswordValidator(String? value) {
    final requiredError = Validators.password(value);
    if (requiredError != null) {
      return requiredError;
    }

    if (value != passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  Future<void> _handleSignUp() async {
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
      final session = await authRepository.signUp(
        SignUpCredentials(
          email: emailController.text,
          password: passwordController.text,
          displayName: fullNameController.text,
        ),
      );
      await authRepository.sendEmailVerification();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AuthStrings.signUpSuccess)));

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
    } on FirebaseAuthException catch (error, stackTrace) {
      AppLogger.error('Sign-up failed.', error, stackTrace);
      _showMessage(error.message ?? AuthStrings.createAccountUnavailable);
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected sign-up failed.', error, stackTrace);
      _showMessage(AuthStrings.createAccountUnavailable);
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
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
      await authRepository.signInWithGoogle();

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      AppLogger.error('Google sign-up failed.', error, stackTrace);
      if (error.code == 'sign_in_canceled') {
        _showMessage('Google sign-up was canceled.');
      } else {
        _showMessage(error.message ?? AuthStrings.googleUnavailable);
      }
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected Google sign-up failed.', error, stackTrace);
      _showMessage(AuthStrings.googleUnavailable);
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void _openSignIn() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => SignInPage(isStartupReady: widget.isStartupReady),
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
                AuthStrings.signUpTagline,
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
                        AuthStrings.signUpTitle,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        AuthStrings.signUpSubtitle,
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium?.copyWith(
                          color: appTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: fullNameController,
                        hintText: AuthStrings.fullNameHint,
                        label: AuthStrings.fullNameLabel,
                        prefixIcon: Icons.person_outline_rounded,
                        autofillHints: const [AutofillHints.name],
                        validator:
                            (value) => Validators.requiredField(
                              value,
                              fieldName: AuthStrings.fullNameLabel,
                            ),
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 18),
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
                      const SizedBox(height: 18),
                      AppTextField(
                        controller: passwordController,
                        hintText: 'Minimum 8 characters',
                        label: AuthStrings.passwordLabel,
                        prefixIcon: Icons.lock_outline_rounded,
                        validator: Validators.password,
                        obscureText: obscurePassword,
                        autofillHints: const [AutofillHints.newPassword],
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
                      const SizedBox(height: 18),
                      AppTextField(
                        controller: confirmPasswordController,
                        hintText: 'Repeat your password',
                        label: AuthStrings.confirmPasswordLabel,
                        prefixIcon: Icons.lock_reset_rounded,
                        validator: _confirmPasswordValidator,
                        obscureText: obscureConfirmPassword,
                        autofillHints: const [AutofillHints.newPassword],
                        enabled: !isSubmitting,
                        suffixIcon: IconButton(
                          onPressed:
                              isSubmitting
                                  ? null
                                  : () {
                                    setState(() {
                                      obscureConfirmPassword =
                                          !obscureConfirmPassword;
                                    });
                                  },
                          icon: Icon(
                            obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppPrimaryButton(
                        label: AuthStrings.createAccountLabel,
                        onPressed: isSubmitting ? null : _handleSignUp,
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
                        onPressed: isSubmitting ? null : _handleGoogleSignUp,
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
                            AuthStrings.alreadyHaveAccountPrompt,
                            style: textTheme.bodyMedium?.copyWith(
                              color: appTheme.textMuted,
                            ),
                          ),
                          TextButton(
                            onPressed: isSubmitting ? null : _openSignIn,
                            style: TextButton.styleFrom(
                              foregroundColor: appTheme.successSoft,
                            ),
                            child: const Text(AuthStrings.signInLabel),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
