import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/presentation/widgets/auth_shared_widgets.dart';
import 'package:car_wash/features/authentication/utils/auth_validators.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(_passwordController.text);
      } else {
        // User not signed in — re-authenticate via email
        final email = AuthSession.currentEmail ?? '';
        if (email.isNotEmpty) {
          await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
        }
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully!'),
          backgroundColor: AppColors.brandGreen,
        ),
      );
      context.goToLogin();
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'requires-recent-login' => 'Please log in again before changing your password.',
        'weak-password' => 'Password is too weak.',
        _ => 'Failed to reset password. Please try again.',
      };
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: AppColors.dangerSurface),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: 'New Password',
      onBack: () => context.goToLogin(),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Center(child: AuthBrandBadge(iconSize: 46, fontSize: 15)),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'Set New Password',
                style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Enter your new password below.',
              style: TextStyle(fontSize: 14.5, height: 1.2, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 18),
            AuthInputField(
              controller: _passwordController,
              label: 'New Password',
              hintText: 'New Password',
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
              controller: _confirmController,
              label: 'Confirm Password',
              hintText: 'Confirm Password',
              obscureText: _obscureConfirm,
              validator: (value) => AuthValidators.validateConfirmPassword(value, _passwordController.text),
              suffix: IconButton(
                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                icon: Icon(
                  _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20, color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 24),
            AppPrimaryButton(
              label: _isLoading ? 'Saving...' : 'Reset Password',
              onPressed: _isLoading ? null : _submit,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
