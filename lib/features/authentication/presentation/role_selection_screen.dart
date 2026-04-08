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
    AuthSession.setCurrentRole(_selectedRole);
    context.goToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F6),
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
                  const Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 56),
                      child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Select Role',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
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
              color: const Color(0xFFE9E6E3).withValues(alpha: 0.9),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF8FCF9), Color(0xFFEEF8F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: const Color(0xFFDCEBDF)),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How would you like to continue?',
                            key: Key('role_selection_title'),
                            style: TextStyle(
                              fontSize: 25,
                              height: 1.15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF16241A),
                              letterSpacing: -0.8,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Choose your app experience. You can continue as a customer to book services or as a service provider to manage jobs and earnings.',
                            style: TextStyle(
                              fontSize: 14.5,
                              height: 1.45,
                              color: Color(0xFF5E6E65),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _RoleOptionCard(
                      key: const Key('role_selection_customer_option'),
                      role: AppUserRole.customer,
                      title: 'Customer',
                      subtitle:
                          'Book washes, track arrivals, and manage orders.',
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
                      title: 'Service Provider',
                      subtitle:
                          'Accept requests, manage active jobs, and monitor earnings.',
                      icon: Icons.local_shipping_rounded,
                      iconTint: const Color(0xFF176B87),
                      iconBackground: const Color(0xFFE8F5FA),
                      highlights: const [
                        'New requests',
                        'Live jobs',
                        'Earnings view',
                      ],
                      isSelected: _selectedRole == AppUserRole.serviceProvider,
                      onTap: () => _selectRole(AppUserRole.serviceProvider),
                    ),
                    const Spacer(),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE7EBE8)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF6DE),
                              borderRadius: BorderRadius.circular(11),
                            ),
                            child: const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF8A5D0A),
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Selected role: ${_selectedRole.label}. We will use this later to show the right dashboard and features.',
                              style: const TextStyle(
                                fontSize: 12.8,
                                height: 1.45,
                                color: Color(0xFF617168),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    AppPrimaryButton(
                      key: const Key('role_selection_continue_button'),
                      label: 'Continue',
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppColors.brandGreen
                  : const Color(0xFFE6EBE7),
              width: isSelected ? 1.3 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0x140F7D32)
                    : const Color(0x0D000000),
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
                            color: Color(0xFF1C251F),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          role.description,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF7A8981),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _RoleRadio(isSelected: isSelected),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Color(0xFF5F6E66),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final item in highlights)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: iconBackground,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: iconTint,
                        ),
                      ),
                    ),
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
          color: isSelected ? AppColors.brandGreen : const Color(0xFFD2DAD4),
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
