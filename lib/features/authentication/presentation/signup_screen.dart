import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/services/google_auth_service.dart';
import 'package:car_wash/core/services/otp_email_service.dart';
import 'package:car_wash/core/services/user_profile_service.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/presentation/widgets/auth_shared_widgets.dart';
import 'package:car_wash/features/authentication/utils/auth_validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatPasswordController =
      TextEditingController();

  bool _obscurePassword = true;
  bool _obscureRepeatPassword = true;
  bool _agreedToTerms = false;
  bool _showTermsError = false;
  bool _isLoading = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  void _goBack() => context.goToLogin();
  void _goToLogin() => context.goToLogin();

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final user = await GoogleAuthService.signIn();
      if (!mounted) return;
      if (user != null) context.goToHome();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google sign in failed. Please try again.'),
          backgroundColor: AppColors.dangerSurface,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final isFormValid = _formKey.currentState?.validate() ?? false;
    if (!isFormValid || !_agreedToTerms) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
        _showTermsError = !_agreedToTerms;
      });
      return;
    }

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      await credential.user?.updateDisplayName(name);

      AuthSession.setCurrentUser(
        email: email,
        userId: credential.user?.uid,
        name: name,
        phoneNumber: phone,
      );

      // Save profile to Firestore
      await UserProfileService.saveProfile();

      if (!mounted) return;

      try {
        await OtpEmailService.sendOtp(email);
      } catch (_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to send OTP. Please try again.'),
            backgroundColor: AppColors.dangerSurface,
          ),
        );
        setState(() => _isLoading = false);
        return;
      }

      if (!mounted) return;
      context.goToOtpVerification();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'email-already-in-use' => 'This email is already registered.',
        'weak-password' => 'Password is too weak.',
        'invalid-email' => 'Invalid email address.',
        _ => 'Signup failed. Please try again.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.dangerSurface,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _repeatPasswordController.dispose();
    super.dispose();
  }

  String? _validatePhoneNumber(String? value) {
    final trimmedValue = value?.trim() ?? '';
    if (trimmedValue.isEmpty) return 'Phone number is required';
    final digitsOnly = trimmedValue.replaceAll(RegExp(r'[^0-9]'), '');
    if (digitsOnly.length < 10) return 'Enter a valid phone number';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: 'Sign Up',
      onBack: _goBack,
      backgroundColor: AppColors.authSoftBackground,
      titleTextStyle: const TextStyle(
        fontSize: 24 / 1.4,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      footerReservedHeight: 244,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppPrimaryButton(
            key: const Key('signup_submit_button'),
            label: _isLoading ? 'Creating account...' : 'Signup',
            onPressed: _isLoading ? null : _submit,
            textStyle: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: Divider(color: AppColors.border)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or continue with',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                ),
              ),
              Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 16),
          AppSocialButton(
            onTap: _signInWithGoogle,
            height: 38,
            borderRadius: 5,
            child: const AppGoogleLogo(),
          ),
          const SizedBox(height: 18),
          AuthBottomPrompt(
            prefixText: 'Already have an account? ',
            actionText: 'Login',
            onTap: _goToLogin,
            actionKey: const Key('signup_to_login_link'),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Center(child: AuthBrandBadge()),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Signup',
                key: Key('signup_screen_title'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Create your account to discover the app effortlessly',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.5, height: 1.35, color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 18),
            AuthInputField(
              key: const Key('signup_name_field'),
              controller: _nameController,
              label: 'Full Name',
              hintText: 'Full Name',
              validator: AuthValidators.validateName,
            ),
            const SizedBox(height: 18),
            AuthInputField(
              key: const Key('signup_email_field'),
              controller: _emailController,
              label: 'Email Address',
              hintText: 'Email Address',
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidators.validateEmail,
            ),
            const SizedBox(height: 18),
            AuthInputField(
              key: const Key('signup_phone_field'),
              controller: _phoneController,
              label: 'Phone Number',
              hintText: 'Phone Number',
              keyboardType: TextInputType.phone,
              validator: _validatePhoneNumber,
            ),
            const SizedBox(height: 18),
            AuthInputField(
              key: const Key('signup_password_field'),
              controller: _passwordController,
              label: 'Create Password',
              hintText: 'Create Password',
              obscureText: _obscurePassword,
              validator: AuthValidators.validatePassword,
              suffix: IconButton(
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20, color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 18),
            AuthInputField(
              key: const Key('signup_repeat_password_field'),
              controller: _repeatPasswordController,
              label: 'Repeat Password',
              hintText: 'Repeat Password',
              obscureText: _obscureRepeatPassword,
              validator: (value) => AuthValidators.validateConfirmPassword(value, _passwordController.text),
              suffix: IconButton(
                onPressed: () => setState(() => _obscureRepeatPassword = !_obscureRepeatPassword),
                icon: Icon(
                  _obscureRepeatPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20, color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 18),
            InkWell(
              key: const Key('signup_terms_checkbox'),
              onTap: () {
                setState(() {
                  _agreedToTerms = !_agreedToTerms;
                  if (_agreedToTerms) _showTermsError = false;
                });
              },
              borderRadius: BorderRadius.circular(4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 14, height: 14,
                        decoration: BoxDecoration(
                          color: _agreedToTerms ? AppButtonColors.primaryBackground : AppColors.inputFill,
                          borderRadius: BorderRadius.circular(2),
                          border: Border.all(
                            color: _agreedToTerms
                                ? AppButtonColors.primaryBackground
                                : _showTermsError
                                    ? AppButtonColors.destructiveForeground
                                    : AppColors.border,
                          ),
                        ),
                        child: _agreedToTerms
                            ? const Icon(Icons.check, size: 10, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'I agree to the Terms and Conditions.',
                          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                  if (_showTermsError) ...[
                    const SizedBox(height: 6),
                    const Text(
                      'Please agree to the Terms and Conditions',
                      style: TextStyle(fontSize: 11.5, color: AppButtonColors.destructiveForeground),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
