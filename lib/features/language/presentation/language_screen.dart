import 'package:car_wash/core/localization/app_localizations.dart';
import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:flutter/material.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  late String _selectedLanguageCode;

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode = AuthSession.currentLocale;
  }

  void _selectLanguage(String languageCode) {
    setState(() {
      _selectedLanguageCode = languageCode;
    });
  }

  void _continue() {
    AuthSession.setCurrentLocale(_selectedLanguageCode);
    context.goToRoleSelection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              const Spacer(flex: 5),
              Text(
                context.translate('choose_language'),
                key: const Key('language_title'),
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 22),
              _LanguageOptionTile(
                key: const Key('language_option_english'),
                label: 'English',
                isSelected: _selectedLanguageCode == 'en',
                onTap: () => _selectLanguage('en'),
              ),
              const SizedBox(height: 12),
              _LanguageOptionTile(
                key: const Key('language_option_arabic'),
                label: 'العربية',
                isSelected: _selectedLanguageCode == 'ar',
                onTap: () => _selectLanguage('ar'),
              ),
              const Spacer(flex: 7),
              AppPrimaryButton(
                key: const Key('language_continue_button'),
                label: context.translate('continue'),
                onPressed: _continue,
                height: 52,
                textStyle: const TextStyle(
                  fontSize: 22 / 1.45,
                  fontWeight: FontWeight.w500,
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
        : AppColors.border;
    final textColor = isSelected
        ? AppColors.brandGreenLight
        : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          height: 50,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.surfaceHighlight
                : AppColors.surfaceElevated,
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
          color: isSelected ? AppColors.brandGreen : AppColors.border,
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
