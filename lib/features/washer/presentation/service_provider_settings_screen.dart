// ignore_for_file: deprecated_member_use

import 'package:car_wash/core/localization/app_localizations.dart';
import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_button_styles.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/model/app_user_role.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ServiceProviderSettingsScreen extends StatelessWidget {
  const ServiceProviderSettingsScreen({super.key});
  static const _pushNotificationsPrefsKey =
      'service_provider_settings.push_notifications';
  static const _mailNotificationsPrefsKey =
      'service_provider_settings.mail_notifications';
  static const _dangerButtonColor = Color(0xFFD34A4A);

  @override
  Widget build(BuildContext context) {
    final items = <_SettingsActionItem>[
      _SettingsActionItem(
        title: context.translate('privacy_policy'),
        icon: Icons.privacy_tip_outlined,
        onTap: () => context.pushToPrivacyPolicy(),
      ),
      _SettingsActionItem(
        title: context.translate('terms_conditions'),
        icon: Icons.article_outlined,
        onTap: () => context.pushToTermsConditions(),
      ),
      _SettingsActionItem(
        title: context.translate('help_center'),
        icon: Icons.help_outline_rounded,
        onTap: () => context.pushToHelpCenter(),
      ),
      _SettingsActionItem(
        title: context.translate('notifications'),
        icon: Icons.notifications_none_rounded,
        onTap: () => _showNotificationSettings(context),
      ),
      _SettingsActionItem(
        title: context.translate('delete_account'),
        icon: Icons.delete_outline_rounded,
        onTap: () => _showDeleteAccountDialog(context),
      ),
      _SettingsActionItem(
        title: context.translate('logout'),
        icon: Icons.logout_rounded,
        onTap: () => _showLogoutDialog(context),
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _SettingsTopBar(),
            Divider(height: 1, thickness: 0.8, color: AppColors.border),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.translate('account'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingsActionTile(
                      item: _SettingsActionItem(
                        title: context.translate('language'),
                        trailingText: AuthSession.currentLocale == 'en' ? 'English' : 'العربية',
                        icon: Icons.language_rounded,
                        onTap: () => context.goToLanguage(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SettingsActionTile(
                      item: _SettingsActionItem(
                        title: context.translate('switch_to_customer'),
                        icon: Icons.swap_horiz_rounded,
                        onTap: () => _switchRole(context),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      context.translate('support'),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (var index = 0; index < items.length; index++) ...[
                      _SettingsActionTile(item: items[index]),
                      if (index != items.length - 1) const SizedBox(height: 12),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  static Future<void> _switchRole(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: _AccountActionDialog(
            icon: Icons.swap_horiz_rounded,
            title: context.translate('switch_customer_title'),
            description: context.translate('switch_customer_desc'),
            confirmLabel: context.translate('yes_switch'),
            cancelLabel: context.translate('cancel'),
            confirmColor: AppColors.brandGreen,
            confirmTextColor: Colors.white,
            cancelColor: AppColors.surfaceMuted,
            cancelTextColor: AppColors.textSecondary,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onConfirm: () {
              Navigator.of(dialogContext).pop();
              AuthSession.setCurrentRole(AppUserRole.customer);
              if (context.mounted) {
                context.goToHome();
              }
            },
          ),
        );
      },
    );
  }

  static Future<void> _showDeleteAccountDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: _AccountActionDialog(
            icon: Icons.delete_rounded,
            title: context.translate('delete_account_title'),
            description: context.translate('delete_account_desc'),
            confirmLabel: context.translate('yes'),
            cancelLabel: context.translate('no'),
            confirmColor: _dangerButtonColor,
            confirmTextColor: Colors.white,
            cancelColor: AppColors.brandGreen,
            cancelTextColor: Colors.white,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onConfirm: () {
              Navigator.of(dialogContext).pop();
              AuthSession.clear();
              if (context.mounted) {
                context.goToLogin();
              }
            },
          ),
        );
      },
    );
  }

  static Future<void> _showNotificationSettings(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _NotificationSettingsSheet(),
    );
  }

  static Future<void> _showLogoutDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: _AccountActionDialog(
            icon: Icons.logout_rounded,
            title: context.translate('logout_title'),
            description: context.translate('logout_desc'),
            confirmLabel: context.translate('yes'),
            cancelLabel: context.translate('no'),
            confirmColor: _dangerButtonColor,
            confirmTextColor: Colors.white,
            cancelColor: AppColors.brandGreen,
            cancelTextColor: Colors.white,
            onCancel: () => Navigator.of(dialogContext).pop(),
            onConfirm: () {
              Navigator.of(dialogContext).pop();
              AuthSession.clear();
              if (context.mounted) {
                context.goToLogin();
              }
            },
          ),
        );
      },
    );
  }
}

class _NotificationSettingsSheet extends StatefulWidget {
  const _NotificationSettingsSheet();

  @override
  State<_NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState extends State<_NotificationSettingsSheet> {
  bool _pushNotificationsEnabled = true;
  bool _mailNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _restorePreferences();
  }

  Future<void> _restorePreferences() async {
    final preferences = await SharedPreferences.getInstance();
    if (!mounted) {
      return;
    }

    setState(() {
      _pushNotificationsEnabled = preferences.getBool(
            ServiceProviderSettingsScreen._pushNotificationsPrefsKey,
          ) ??
          true;
      _mailNotificationsEnabled = preferences.getBool(
            ServiceProviderSettingsScreen._mailNotificationsPrefsKey,
          ) ??
          true;
    });
  }

  Future<void> _updatePushNotifications(bool value) async {
    setState(() {
      _pushNotificationsEnabled = value;
    });

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
      ServiceProviderSettingsScreen._pushNotificationsPrefsKey,
      value,
    );
  }

  Future<void> _updateMailNotifications(bool value) async {
    setState(() {
      _mailNotificationsEnabled = value;
    });

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
      ServiceProviderSettingsScreen._mailNotificationsPrefsKey,
      value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 16 + MediaQuery.of(context).viewPadding.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Notifications',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              _NotificationToggleTile(
                title: 'Push notifications',
                subtitle: 'Receive booking updates and app alerts.',
                icon: Icons.notifications_active_outlined,
                value: _pushNotificationsEnabled,
                onChanged: _updatePushNotifications,
              ),
              const SizedBox(height: 10),
              const Divider(height: 1, thickness: 0.8, color: AppColors.border),
              const SizedBox(height: 10),
              _NotificationToggleTile(
                title: 'Mail notifications',
                subtitle: 'Receive important updates by email.',
                icon: Icons.mail_outline_rounded,
                value: _mailNotificationsEnabled,
                onChanged: _updateMailNotifications,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsTopBar extends StatelessWidget {
  const _SettingsTopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: Stack(
        children: [
          Positioned(
            left: 8,
            top: 0,
            bottom: 0,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppButtonColors.actionForeground,
                size: 18,
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 56),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  context.translate('settings'),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationToggleTile extends StatelessWidget {
  const _NotificationToggleTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.brandGreen, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11.5,
                  height: 1.4,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Colors.white,
          activeTrackColor: AppColors.brandGreen,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: AppColors.textMuted.withValues(alpha: 0.4),
        ),
      ],
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  const _SettingsActionTile({required this.item});

  final _SettingsActionItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.brandGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 12, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 12.8,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              if (item.trailingText != null) ...[
                Text(
                  item.trailingText!,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.brandGreenLight.withValues(alpha: 0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(width: 10),
              ],
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 17,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsActionItem {
  const _SettingsActionItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.trailingText,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final String? trailingText;
}

class _AccountActionDialog extends StatelessWidget {
  const _AccountActionDialog({
    required this.icon,
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.confirmColor,
    required this.confirmTextColor,
    required this.cancelColor,
    required this.cancelTextColor,
    required this.onCancel,
    required this.onConfirm,
  });

  final IconData icon;
  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final Color confirmColor;
  final Color confirmTextColor;
  final Color cancelColor;
  final Color cancelTextColor;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 26,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, size: 54, color: confirmColor),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              height: 1.3,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              height: 1.4,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton(
                    onPressed: onCancel,
                    style: AppButtonStyles.filled(
                      backgroundColor: cancelColor,
                      foregroundColor: cancelTextColor,
                      height: 44,
                    ),
                    child: Text(
                      cancelLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 44,
                  child: FilledButton(
                    onPressed: onConfirm,
                    style: AppButtonStyles.filled(
                      backgroundColor: confirmColor,
                      foregroundColor: confirmTextColor,
                      height: 44,
                    ),
                    child: Text(
                      confirmLabel,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
