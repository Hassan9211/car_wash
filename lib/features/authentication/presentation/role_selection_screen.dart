import 'package:car_wash/core/localization/app_localizations.dart';
import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/model/app_user_role.dart';
import 'package:flutter/material.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  AppUserRole _selectedRole = AuthSession.currentRole ?? AppUserRole.customer;

  void _selectRole(AppUserRole role) {
    setState(() {
      _selectedRole = role;
    });
  }

  void _continue() {
    if (_selectedRole == AppUserRole.guest) {
      AuthSession.setGuestMode();
      context.goToHome();
      return;
    }
    AuthSession.setCurrentRole(_selectedRole);
    context.goToLogin();
  }

  @override
  Widget build(BuildContext context) {
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
                      key: const Key('role_selection_back_button'),
                      onPressed: context.goToLanguage,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppButtonColors.actionForeground,
                        size: 18,
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 56),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          context.translate('select_role'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
              height: 1,
              thickness: 0.8,
              color: AppColors.border,
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: constraints.maxHeight),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.surfaceHighlight,
                                    AppColors.surface,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.translate('how_to_continue'),
                                    key: const Key('role_selection_title'),
                                    style: const TextStyle(
                                      fontSize: 25,
                                      height: 1.15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      letterSpacing: -0.8,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    context.translate('role_description'),
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      height: 1.45,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            _RoleOptionCard(
                              key: const Key('role_selection_customer_option'),
                              role: AppUserRole.customer,
                              title: context.translate('customer'),
                              subtitle: context.translate('customer_subtitle'),
                              icon: Icons.directions_car_filled_rounded,
                              iconTint: AppColors.brandGreen,
                              iconBackground: const Color(0xFFEAF7EE),
                              highlights: const [
                                'Book services',
                                'Track washer',
                                'Pay securely',
                              ],
                              isSelected: _selectedRole == AppUserRole.customer,
                              onTap: () => _selectRole(AppUserRole.customer),
                            ),
                            const SizedBox(height: 14),
                            _RoleOptionCard(
                              key: const Key('role_selection_service_provider_option'),
                              role: AppUserRole.serviceProvider,
                              title: context.translate('service_provider'),
                              subtitle: context.translate('service_provider_subtitle'),
                              icon: Icons.local_shipping_rounded,
                              iconTint: const Color(0xFF176B87),
                              iconBackground: const Color(0xFFE8F5FA),
                              highlights: const [
                                'New requests',
                                'Live jobs',
                                'Earnings view',
                              ],
                              isSelected:
                                  _selectedRole == AppUserRole.serviceProvider,
                              onTap: () => _selectRole(AppUserRole.serviceProvider),
                            ),
                            const SizedBox(height: 14),
                            _RoleOptionCard(
                              key: const Key('role_selection_guest_option'),
                              role: AppUserRole.guest,
                              title: context.translate('guest'),
                              subtitle: context.translate('guest_subtitle'),
                              icon: Icons.person_search_rounded,
                              iconTint: const Color(0xFF8B4A96),
                              iconBackground: const Color(0xFFF6E8FA),
                              highlights: const [
                                'View services',
                                'Check prices',
                                'Explore app',
                              ],
                              isSelected: _selectedRole == AppUserRole.guest,
                              onTap: () => _selectRole(AppUserRole.guest),
                            ),
                            const Spacer(),
                            const SizedBox(height: 16),
                            AppPrimaryButton(
                              key: const Key('role_selection_continue_button'),
                              label: context.translate('continue'),
                              onPressed: _continue,
                              height: 52,
                              textStyle: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleOptionCard extends StatelessWidget {
  const _RoleOptionCard({
    super.key,
    required this.role,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconTint,
    required this.iconBackground,
    required this.highlights,
    required this.isSelected,
    required this.onTap,
  });

  final AppUserRole role;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconTint;
  final Color iconBackground;
  final List<String> highlights;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.brandGreen
                  : AppColors.border,
              width: isSelected ? 1.3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppColors.brandGreen.withValues(alpha: 0.16)
                    : Colors.black.withValues(alpha: 0.16),
                blurRadius: isSelected ? 18 : 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBackground,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: iconTint, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          role.description,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 14),
                  _RoleRadio(isSelected: isSelected),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  for (var index = 0; index < highlights.length; index++) ...[
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: iconBackground,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          highlights[index],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: iconTint,
                          ),
                        ),
                      ),
                    ),
                    if (index != highlights.length - 1)
                      const SizedBox(width: 10),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleRadio extends StatelessWidget {
  const _RoleRadio({required this.isSelected});

  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? AppColors.brandGreen : AppColors.border,
        ),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? AppColors.brandGreen : Colors.transparent,
        ),
      ),
    );
  }
}
