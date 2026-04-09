import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/presentation/widgets/auth_shared_widgets.dart';
import 'package:car_wash/features/authentication/utils/auth_validators.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = true;
  bool _obscurePassword = true;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  void _goBack() {
    context.goToRoleSelection();
  }

  void _goToSignup() {
    context.goToSignup();
  }

  void _goToForgotPassword() {
    context.goToForgotPassword();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    AuthSession.setCurrentUser(email: _emailController.text.trim());
    AuthSession.setAuthenticated(true);
    context.goToHome();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: 'Login',
      onBack: _goBack,
      footer: AuthBottomPrompt(
        prefixText: 'Don\'t have an account? ',
        actionText: 'Signup',
        onTap: _goToSignup,
        actionKey: const Key('login_to_signup_link'),
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AuthBrandBadge(),
            const SizedBox(height: 14),
            const Text(
              'Login',
              key: Key('login_screen_title'),
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Login to your account to discover and book the best car wash effortlessly.',
              style: TextStyle(
                fontSize: 14.5,
                height: 1.2,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            AuthInputField(
              key: const Key('login_email_field'),
              controller: _emailController,
              label: 'Email Address',
              hintText: '',
              isFocusedStyle: true,
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidators.validateEmail,
            ),
            const SizedBox(height: 14),
            AuthInputField(
              key: const Key('login_password_field'),
              controller: _passwordController,
              label: 'Password',
              hintText: 'Password',
              obscureText: _obscurePassword,
              validator: AuthValidators.validatePassword,
              suffix: IconButton(
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                InkWell(
                  key: const Key('login_remember_me'),
                  onTap: () {
                    setState(() {
                      _rememberMe = !_rememberMe;
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Row(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: _rememberMe
                              ? AppButtonColors.primaryBackground
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: _rememberMe
                                ? AppButtonColors.primaryBackground
                                : AppButtonColors.selectionBorder,
                          ),
                        ),
                        child: _rememberMe
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Remember me',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                AppActionTextButton(
                  key: const Key('login_forgot_password_button'),
                  label: 'Forgot Password?',
                  onPressed: _goToForgotPassword,
                  foregroundColor: AppButtonColors.destructiveForeground,
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppPrimaryButton(
              key: const Key('login_submit_button'),
              label: 'Login',
              onPressed: _submit,
              textStyle: const TextStyle(
                fontSize: 16.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Divider(
                    color: AppColors.border,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    'or continue with',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                Expanded(
                  child: Divider(
                    color: AppColors.border,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: const [
                Expanded(child: AppSocialButton(child: AppGoogleLogo())),
                SizedBox(width: 10),
                Expanded(child: AppSocialButton(child: AppGmailLogo())),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
