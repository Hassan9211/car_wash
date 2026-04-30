// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:car_wash/core/localization/app_localizations.dart';
import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/services/id_card_service.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_button_styles.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/model/app_user_role.dart';
import 'package:car_wash/features/home/data/provider_catalog.dart';
import 'package:car_wash/features/home/model/service_provider_profile.dart';
import 'package:car_wash/features/services/data/service_catalog.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
        title: 'Update ID Card',
        icon: Icons.badge_outlined,
        onTap: () => _showIdCardSheet(context),
      ),
      _SettingsActionItem(
        title: 'Choose Services',
        icon: Icons.miscellaneous_services_outlined,
        onTap: () => _showServicesSheet(context),
      ),
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
                        onTap: () => context.pushToLanguage(),
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
                context.goToRoleSelection();
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

  static Future<void> _showIdCardSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _IdCardSheet(),
    );
  }

  static Future<void> _showServicesSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const _ServicesSheet(),
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
                context.goToRoleSelection();
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

// ─── ID Card Sheet ────────────────────────────────────────────────────────────

class _IdCardSheet extends StatefulWidget {
  const _IdCardSheet();

  @override
  State<_IdCardSheet> createState() => _IdCardSheetState();
}

class _IdCardSheetState extends State<_IdCardSheet> {
  String? _imagePath;
  DateTime? _expiryDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _imagePath = IdCardService.imagePath;
    _expiryDate = IdCardService.expiryDate;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? now.add(const Duration(days: 365)),
      firstDate: now,
      lastDate: DateTime(now.year + 20),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _save() async {
    if (_imagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an ID card image.')),
      );
      return;
    }
    if (_expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select expiry date.')),
      );
      return;
    }
    setState(() => _isSaving = true);
    await IdCardService.save(imagePath: _imagePath!, expiryDate: _expiryDate!);
    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('ID card updated successfully.'),
        backgroundColor: AppColors.brandGreen,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isExpired = _expiryDate != null &&
        DateTime.now().isAfter(_expiryDate!);

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Update ID Card',
                style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              // Image picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: _imagePath != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.file(
                            File(_imagePath!),
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.upload_rounded,
                                size: 36, color: AppColors.textMuted),
                            SizedBox(height: 8),
                            Text(
                              'Tap to upload ID card image',
                              style: TextStyle(
                                fontSize: 13, color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 14),

              // Expiry date picker
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isExpired
                          ? const Color(0xFFD34A4A)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: isExpired
                            ? const Color(0xFFD34A4A)
                            : AppColors.brandGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _expiryDate != null
                              ? 'Expiry: ${_formatDate(_expiryDate!)}'
                              : 'Select expiry date',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: isExpired
                                ? const Color(0xFFD34A4A)
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      if (isExpired)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEEEE),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'EXPIRED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD34A4A),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              if (isExpired) ...[
                const SizedBox(height: 8),
                const Text(
                  'Your ID card is expired. You cannot accept new bookings until you update it.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFFD34A4A),
                    height: 1.4,
                  ),
                ),
              ],

              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    _isSaving ? 'Saving...' : 'Save ID Card',
                    style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Services Sheet ───────────────────────────────────────────────────────────

class _ServicesSheet extends StatefulWidget {
  const _ServicesSheet();

  @override
  State<_ServicesSheet> createState() => _ServicesSheetState();
}

class _ServicesSheetState extends State<_ServicesSheet> {
  late Set<String> _selected;

  @override
  void initState() {
    super.initState();
    final current = ProviderCatalog.currentProviderProfile().supportedServices;
    _selected = Set<String>.from(current);
  }

  Future<void> _save() async {
    await _restoreSavedProvidersIfNeeded();

    // Find the actual stored provider — never use fallback
    final providerId = ProviderCatalog.currentSessionProviderId;
    final stored = ProviderCatalog.providers;

    ServiceProviderProfile? existing;

    // Match by ID first
    try {
      existing = stored.firstWhere((p) => p.id == providerId);
    } catch (_) {}

    // Match by name if ID not found
    if (existing == null) {
      final name = AuthSession.displayName.trim().toLowerCase();
      try {
        existing = stored.firstWhere(
          (p) => p.name.trim().toLowerCase() == name,
        );
      } catch (_) {}
    }

    if (existing == null || existing.id == 'fallback_provider') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your profile setup first.'),
          backgroundColor: AppColors.dangerSurface,
        ),
      );
      return;
    }

    await ProviderCatalog.saveOrUpdateProvider(
      existing.copyWith(supportedServices: _selected.toList()),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Services updated.'),
        backgroundColor: AppColors.brandGreen,
      ),
    );
  }

  Future<void> _restoreSavedProvidersIfNeeded() async {
    await ProviderCatalog.fetchProviders();
  }

  @override
  Widget build(BuildContext context) {
    final allServices = ServiceCatalog.allServices;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42, height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Choose Services',
                style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allServices.map((service) {
                  final isSelected = _selected.contains(service.label);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selected.remove(service.label);
                        } else {
                          _selected.add(service.label);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.brandGreen
                            : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.brandGreen
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            service.icon,
                            size: 14,
                            color: isSelected
                                ? Colors.white
                                : service.iconColor,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            service.label,
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: FilledButton(
                  onPressed: _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.brandGreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Save Services',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
