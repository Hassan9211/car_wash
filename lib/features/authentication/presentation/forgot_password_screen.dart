import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/services/otp_email_service.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/presentation/widgets/auth_shared_widgets.dart';
import 'package:car_wash/features/authentication/utils/auth_validators.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  bool _isLoading = false;

  void _goBack() {
    context.goToLogin();
  }

  Future<void> _sendResetLink() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final email = _emailController.text.trim();
      AuthSession.setCurrentEmail(email);
      await OtpEmailService.sendPasswordResetLink(email);
      if (!mounted) return;
      context.goToCheckEmail();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to send reset link. Please try again.'),
          backgroundColor: AppColors.dangerSurface,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: 'Forgot Password',
      onBack: _goBack,
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Center(
              child: AuthBrandBadge(iconSize: 46, fontSize: 15),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Reset Your Password',
                key: Key('forgot_password_screen_title'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.4,
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Forgot your password? No worries! Enter your email below to receive a reset link.',
              style: TextStyle(
                fontSize: 14.5,
                height: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 18),
            AuthInputField(
              key: const Key('forgot_password_email_field'),
              controller: _emailController,
              label: 'Email Address',
              hintText: '',
              isFocusedStyle: true,
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidators.validateEmail,
            ),
            const SizedBox(height: 18),
            AppPrimaryButton(
              key: const Key('forgot_password_submit_button'),
              label: _isLoading ? 'Sending...' : 'Send Password Reset Link',
              onPressed: _isLoading ? null : _sendResetLink,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
