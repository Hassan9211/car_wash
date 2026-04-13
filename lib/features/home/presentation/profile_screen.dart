// ignore_for_file: deprecated_member_use

import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_button_styles.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/model/app_user_role.dart';
import 'package:car_wash/features/home/presentation/widgets/home_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const _dangerButtonColor = Color(0xFFD34A4A);
  static const _pushNotificationsPrefsKey = 'user_profile.push_notifications';
  static const _mailNotificationsPrefsKey = 'user_profile.mail_notifications';

  @override
  Widget build(BuildContext context) {
    final items = <_ProfileActionSection>[
      _ProfileActionSection(
        title: 'Account',
        items: [
          _ProfileActionItem(
            title: 'Switch to Service Provider',
            icon: Icons.swap_horiz_rounded,
            onTap: () => _switchRole(context),
          ),
        ],
      ),
      _ProfileActionSection(
        title: 'Support',
        items: [
          _ProfileActionItem(
            title: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onTap: () => context.pushToPrivacyPolicy(),
          ),
          _ProfileActionItem(
            title: 'Terms & Conditions',
            icon: Icons.article_outlined,
            onTap: () => context.pushToTermsConditions(),
          ),
          _ProfileActionItem(
            title: 'Help Center',
            icon: Icons.help_outline_rounded,
            onTap: () => context.pushToHelpCenter(),
          ),
          _ProfileActionItem(
            title: 'Notification',
            icon: Icons.notifications_none_rounded,
            onTap: () => _showNotificationSettings(context),
          ),
          _ProfileActionItem(
            title: 'Delete Account',
            icon: Icons.delete_outline_rounded,
            onTap: () => _showDeleteAccountDialog(context),
          ),
          _ProfileActionItem(
            title: 'Logout',
            icon: Icons.logout_rounded,
            onTap: () => _showLogoutDialog(context),
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 56,
              child: Stack(
                children: [
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      key: const Key('profile_back_button'),
                      onPressed: context.goToHome,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppButtonColors.actionForeground,
                        size: 18,
                      ),
                    ),
                  ),
                  const Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 56),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'User Profile',
                          key: Key('profile_screen_title'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
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
            ),
            Divider(height: 1, thickness: 0.8, color: AppColors.border),
            Expanded(
              child: ValueListenableBuilder<int>(
                valueListenable: AuthSession.listenable,
                builder: (context, _, unusedChild) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 20, 22, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ProfileSummaryCard(
                        name: AuthSession.displayName,
                        email: AuthSession.displayEmail,
                        initials: AuthSession.initials,
                        onEditTap: () => _openEditProfile(context),
                      ),
                      const SizedBox(height: 16),
                      for (final section in items) ...[
                        Text(
                          section.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        for (final item in section.items) ...[
                          _ProfileActionTile(item: item),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNavigationBar(
        selectedTab: HomeBottomTab.profile,
      ),
    );
  }


  static Future<void> _switchRole(BuildContext context) async {
    final shouldSwitch = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.58),
      builder: (dialogContext) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              surface: AppColors.surfaceElevated,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: AlertDialog(
            backgroundColor: AppColors.surfaceElevated,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: const Text(
              'Switch Account?',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
            ),
            content: const Text(
              'Are you sure you want to switch to your action Service Provider account?',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13.5, height: 1.4),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: const Text('No', style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ),
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(true),
                style: FilledButton.styleFrom(backgroundColor: AppColors.brandGreen, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: const Text('Yes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        );
      },
    );

    if (shouldSwitch == true && context.mounted) {
      if (AuthSession.isProviderSetupCompleted) {
        AuthSession.setCurrentRole(AppUserRole.serviceProvider);
        context.goToHome();
      } else {
        context.goToServiceProviderSetup();
      }
    }
  }

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<void> _openEditProfile(BuildContext context) async {
    final didUpdate = await context.pushToProfileEdit();
    if (didUpdate == true && context.mounted) {
      _showMessage(context, 'Profile updated successfully');
    }
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
            title: 'Are you sure you want to delete this account?',
            description:
                'This will clear your saved profile data from the app and sign you out of the current session.',
            confirmLabel: 'Yes',
            cancelLabel: 'No',
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
            title: 'Are you sure you want to log out?',
            description:
                'You will be signed out of the current session and returned to the login screen.',
            confirmLabel: 'Yes',
            cancelLabel: 'No',
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

class _ProfileSummaryCard extends StatelessWidget {
  const _ProfileSummaryCard({
    required this.name,
    required this.email,
    required this.initials,
    required this.onEditTap,
  });

  final String name;
  final String email;
  final String initials;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _ProfileAvatar(initials: initials),
          const SizedBox(height: 10),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.brandGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const Key('profile_edit_button'),
              onPressed: onEditTap,
              style: AppButtonStyles.filled(height: 44),
              icon: const Icon(Icons.edit_rounded, size: 16),
              label: const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.initials});

  final String initials;

  @override
  Widget build(BuildContext context) {
    const dotOffsets = <Offset>[
      Offset(-34, -26),
      Offset(-22, -38),
      Offset(-2, -42),
      Offset(16, -40),
      Offset(34, -24),
      Offset(-40, -4),
      Offset(40, 2),
      Offset(-30, 26),
      Offset(0, 36),
      Offset(28, 28),
    ];

    return SizedBox(
      width: 110,
      height: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          for (final offset in dotOffsets)
            Transform.translate(
              offset: offset,
              child: Container(
                width: offset.dx.abs() > 30 ? 4 : 3,
                height: offset.dx.abs() > 30 ? 4 : 3,
                decoration: const BoxDecoration(
                  color: AppColors.brandGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brandGreen, width: 1.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.18),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(shape: BoxShape.circle),
              child: ClipOval(
                child: Image(
                  image: AuthSession.avatarImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return DecoratedBox(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.surfaceHighlight,
                            AppColors.surfaceMuted,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({required this.item});

  final _ProfileActionItem item;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surfaceElevated,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: AppColors.brandGreen,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
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

class _ProfileActionSection {
  const _ProfileActionSection({required this.title, required this.items});

  final String title;
  final List<_ProfileActionItem> items;
}

class _ProfileActionItem {
  const _ProfileActionItem({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
}

class _NotificationSettingsSheet extends StatefulWidget {
  const _NotificationSettingsSheet();

  @override
  State<_NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState
    extends State<_NotificationSettingsSheet> {
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
      _pushNotificationsEnabled =
          preferences.getBool(ProfileScreen._pushNotificationsPrefsKey) ?? true;
      _mailNotificationsEnabled =
          preferences.getBool(ProfileScreen._mailNotificationsPrefsKey) ?? true;
    });
  }

  Future<void> _updatePushNotifications(bool value) async {
    setState(() {
      _pushNotificationsEnabled = value;
    });

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(ProfileScreen._pushNotificationsPrefsKey, value);
  }

  Future<void> _updateMailNotifications(bool value) async {
    setState(() {
      _mailNotificationsEnabled = value;
    });

    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(ProfileScreen._mailNotificationsPrefsKey, value);
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
            offset: const Offset(0, 18),
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
