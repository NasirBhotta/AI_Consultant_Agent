import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme_extension.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../core/utils/validators.dart';
import '../../../../shared/widgets/app_primary_button.dart';
import '../../../../shared/widgets/app_secondary_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../constants/auth_strings.dart';
import '../../data/repositories/firebase_auth_repository.dart';
import '../../domain/models/sign_in_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../widgets/auth_brand_badge.dart';
import '../widgets/auth_shell.dart';
import '../widgets/google_mark.dart';
import '../../../home/presentation/pages/home_page.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key, required this.isStartupReady});

  final bool isStartupReady;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isSubmitting = false;
  bool _obscurePassword = true;

  AuthRepository get _authRepository => FirebaseAuthRepository();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!widget.isStartupReady) {
      _showMessage('App services are still starting. Please try again.');
      return;
    }

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate() || _isSubmitting) {
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() {
      _isSubmitting = true;
    });

    try {
      await _authRepository.signIn(
        SignInCredentials(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text(AuthStrings.signInSuccess)));
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
      );
    } on FirebaseAuthException catch (error, stackTrace) {
      AppLogger.error('Email sign-in failed.', error, stackTrace);
      _showMessage(error.message ?? AuthStrings.signInFailure);
    } catch (error, stackTrace) {
      AppLogger.error('Unexpected sign-in failure.', error, stackTrace);
      _showMessage(AuthStrings.signInFailure);
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  Future<void> _handlePasswordReset() async {
    if (!widget.isStartupReady) {
      _showMessage('Password reset is unavailable until startup completes.');
      return;
    }

    final emailError = Validators.email(_emailController.text);
    if (emailError != null) {
      _showMessage(emailError);
      return;
    }

    try {
      await _authRepository.sendPasswordReset(email: _emailController.text);
      _showMessage('Password reset email sent.');
    } on FirebaseAuthException catch (error, stackTrace) {
      AppLogger.error('Password reset failed.', error, stackTrace);
      _showMessage(error.message ?? AuthStrings.forgotPasswordUnavailable);
    } catch (error, stackTrace) {
      AppLogger.error('Password reset unavailable.', error, stackTrace);
      _showMessage(AuthStrings.forgotPasswordUnavailable);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (!widget.isStartupReady) {
      _showMessage('App services are still starting. Please try again.');
      return;
    }

    try {
      await _authRepository.signInWithGoogle();
    } on UnimplementedError {
      _showMessage(AuthStrings.googleUnavailable);
    } catch (error, stackTrace) {
      AppLogger.error('Google sign-in failed.', error, stackTrace);
      _showMessage(AuthStrings.googleUnavailable);
    }
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = context.appTheme;
    final textTheme = Theme.of(context).textTheme;
    final busy = _isSubmitting;

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
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AuthStrings.signInTitle,
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppTextField(
                        controller: _emailController,
                        label: AuthStrings.emailLabel,
                        hintText: AuthStrings.emailHint,
                        prefixIcon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        autofillHints: const [AutofillHints.email],
                        enabled: !busy,
                        validator: Validators.email,
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
                            onPressed: busy ? null : _handlePasswordReset,
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
                        controller: _passwordController,
                        hintText: '********',
                        prefixIcon: Icons.lock_outline_rounded,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        enabled: !busy,
                        validator: Validators.password,
                        suffixIcon: IconButton(
                          onPressed:
                              busy
                                  ? null
                                  : () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      AppPrimaryButton(
                        label: AuthStrings.continueLabel,
                        onPressed: busy ? null : _handleSignIn,
                        isLoading: busy,
                        trailing: const Icon(Icons.arrow_forward_rounded),
                      ),
                      const SizedBox(height: 22),
                      Row(
                        children: [
                          Expanded(
                            child: Divider(color: appTheme.borderStrong),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: appTheme.surfaceTertiary,
                              borderRadius: BorderRadius.circular(999),
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
                      const SizedBox(height: 22),
                      AppSecondaryButton(
                        label: AuthStrings.continueWithGoogle,
                        onPressed: busy ? null : _handleGoogleSignIn,
                        leading: const GoogleMark(),
                      ),
                      const SizedBox(height: 20),
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
                            onPressed:
                                busy
                                    ? null
                                    : () => _showMessage(
                                      AuthStrings.createAccountUnavailable,
                                    ),
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
                      size: 16,
                      color: appTheme.successSoft,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AuthStrings.securityChip,
                      style: textTheme.labelLarge?.copyWith(
                        color: appTheme.successSoft,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                AuthStrings.securityBody,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
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
                    '*',
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
