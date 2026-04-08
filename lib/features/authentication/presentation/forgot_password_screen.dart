import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
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

  void _goBack() {
    context.goToLogin();
  }

  void _goToLogin() {
    context.goToLogin();
  }

  void _sendResetLink() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    context.goToCheckEmail();
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
            const AuthBrandBadge(),
            const SizedBox(height: 16),
            const Text(
              'Reset Your Password',
              key: Key('forgot_password_screen_title'),
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w600,
                color: Colors.black,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Forgot your password? No worries! Enter your email below to receive a reset link.',
              style: TextStyle(
                fontSize: 14.5,
                height: 1.2,
                color: Color(0xFFAAA5A1),
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
              label: 'Send Password Reset Link',
              onPressed: _sendResetLink,
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 18),
            Center(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const Text(
                    'Remember your password? ',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Color(0xFFC0BBB7),
                    ),
                  ),
                  GestureDetector(
                    key: const Key('forgot_password_to_login_link'),
                    onTap: _goToLogin,
                    child: const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: AppButtonColors.actionForeground,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
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
