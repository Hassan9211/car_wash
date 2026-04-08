import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English';

  void _selectLanguage(String value) {
    setState(() {
      _selectedLanguage = value;
    });
  }

  void _continue() {
    context.goToRoleSelection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const Spacer(flex: 5),
              const Text(
                'Choose Language',
                key: Key('language_title'),
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 22),
              _LanguageOptionTile(
                key: const Key('language_option_english'),
                label: 'English',
                isSelected: _selectedLanguage == 'English',
                onTap: () => _selectLanguage('English'),
              ),
              const SizedBox(height: 12),
              _LanguageOptionTile(
                key: const Key('language_option_arabic'),
                label: 'Arabic',
                isSelected: _selectedLanguage == 'Arabic',
                onTap: () => _selectLanguage('Arabic'),
              ),
              const Spacer(flex: 7),
              AppPrimaryButton(
                key: const Key('language_continue_button'),
                label: 'Continue',
                onPressed: _continue,
                height: 52,
                textStyle: const TextStyle(
                  fontSize: 22 / 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 10),
              RichText(
                key: const Key('language_login_text'),
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF332D28),
                  ),
                  children: [
                    const TextSpan(text: 'Already have an account? '),
                    TextSpan(
                      text: 'Login Now',
                      style: const TextStyle(
                        color: AppButtonColors.actionForeground,
                        decoration: TextDecoration.underline,
                        decorationColor: AppButtonColors.actionForeground,
                      ),
                      recognizer: TapGestureRecognizer()..onTap = _continue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = isSelected
        ? AppColors.brandGreen
        : const Color(0xFFE9E6E3);
    final textColor = isSelected
        ? AppColors.brandGreen
        : const Color(0xFFA6A19D);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: isSelected ? 1 : 0.8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                _LanguageRadio(isSelected: isSelected),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w400,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageRadio extends StatelessWidget {
  const _LanguageRadio({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 16,
      height: 16,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.brandGreen : const Color(0xFFDCD8D4),
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.brandGreen : Colors.transparent,
        ),
      ),
    );
  }
}
