import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/data/mock_user_store.dart';
import 'package:car_wash/features/authentication/presentation/widgets/auth_shared_widgets.dart';
import 'package:car_wash/features/authentication/utils/auth_validators.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _rememberedEmailKey = 'login_screen.remembered_email';
  static const _rememberedPasswordKey = 'login_screen.remembered_password';

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _rememberMe = true;
  bool _obscurePassword = true;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void initState() {
    super.initState();
    MockUserStore.instance.init();
    _restoreRememberedCredentials();
  }

  void _goBack() {
    context.goToRoleSelection();
  }

  void _goToSignup() {
    context.goToSignup();
  }

  void _goToForgotPassword() {
    context.goToForgotPassword();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() {
        _autovalidateMode = AutovalidateMode.onUserInteraction;
      });
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Find user in mock database
    final user = MockUserStore.instance.findUser(email);

    if (user == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No account found with this email'),
          backgroundColor: AppColors.dangerSurface,
        ),
      );
      return;
    }

    if (user.password != password) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect password'),
          backgroundColor: AppColors.dangerSurface,
        ),
      );
      return;
    }

    AuthSession.setCurrentUser(
      email: user.email,
      name: user.name,
      phoneNumber: user.phoneNumber,
    );
    AuthSession.setAuthenticated(true);
    await _persistRememberedCredentials();
    if (!mounted) {
      return;
    }
    context.goToHome();
  }

  Future<void> _restoreRememberedCredentials() async {
    final preferences = await SharedPreferences.getInstance();
    final rememberedEmail = preferences.getString(_rememberedEmailKey)?.trim();
    final rememberedPassword = preferences
        .getString(_rememberedPasswordKey)
        ?.trim();

    if (!mounted) {
      return;
    }

    if ((rememberedEmail == null || rememberedEmail.isEmpty) &&
        (rememberedPassword == null || rememberedPassword.isEmpty)) {
      return;
    }

    setState(() {
      _rememberMe = true;
      _emailController.text = rememberedEmail ?? '';
      _passwordController.text = rememberedPassword ?? '';
    });
  }

  Future<void> _persistRememberedCredentials() async {
    final preferences = await SharedPreferences.getInstance();

    if (!_rememberMe) {
      await preferences.remove(_rememberedEmailKey);
      await preferences.remove(_rememberedPasswordKey);
      return;
    }

    await preferences.setString(
      _rememberedEmailKey,
      _emailController.text.trim(),
    );
    await preferences.setString(
      _rememberedPasswordKey,
      _passwordController.text,
    );
  }

  Future<void> _toggleRememberMe() async {
    final nextValue = !_rememberMe;
    setState(() {
      _rememberMe = nextValue;
    });

    if (nextValue) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_rememberedEmailKey);
    await preferences.remove(_rememberedPasswordKey);
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
      titleTextStyle: const TextStyle(
        fontSize: 24 / 1.4,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      footerReservedHeight: 220,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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
          Row(
            children: const [
              Expanded(child: AppSocialButton(child: AppGoogleLogo())),
              SizedBox(width: 10),
              Expanded(child: AppSocialButton(child: AppGmailLogo())),
            ],
          ),
          const SizedBox(height: 18),
          AuthBottomPrompt(
            prefixText: 'Don\'t have an account? ',
            actionText: 'Signup',
            onTap: _goToSignup,
            actionKey: const Key('login_to_signup_link'),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 42),
            const Center(child: AuthBrandBadge()),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                'Login',
                key: Key('login_screen_title'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                'Login to your account to discover and book the best car wash effortlessly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.35,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 52),
            AuthInputField(
              key: const Key('login_email_field'),
              controller: _emailController,
              label: 'Email Address',
              hintText: '',
              isFocusedStyle: true,
              keyboardType: TextInputType.emailAddress,
              validator: AuthValidators.validateEmail,
            ),
            const SizedBox(height: 18),
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
            const SizedBox(height: 14),
            Row(
              children: [
                InkWell(
                  key: const Key('login_remember_me'),
                  onTap: _toggleRememberMe,
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
                          fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }
}
