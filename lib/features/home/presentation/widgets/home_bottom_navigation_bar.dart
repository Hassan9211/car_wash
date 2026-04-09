import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum HomeBottomTab {
  home,
  bookings,
  wallet,
  profile,
}

class HomeBottomNavigationBar extends StatelessWidget {
  const HomeBottomNavigationBar({
    super.key,
    required this.selectedTab,
  });

  final HomeBottomTab selectedTab;

  void _handleTap(BuildContext context, HomeBottomTab tab) {
    if (tab == selectedTab) {
      return;
    }

    switch (tab) {
      case HomeBottomTab.home:
        context.goToHome();
        return;
      case HomeBottomTab.bookings:
        context.goToBookings();
        return;
      case HomeBottomTab.wallet:
        context.goToWallet();
        return;
      case HomeBottomTab.profile:
        context.goToProfile();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.navBar,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x50000000),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _BottomNavItem(
              icon: Icons.home_rounded,
              isSelected: selectedTab == HomeBottomTab.home,
              onTap: () => _handleTap(context, HomeBottomTab.home),
            ),
            _BottomNavItem(
              icon: Icons.calendar_month_outlined,
              isSelected: selectedTab == HomeBottomTab.bookings,
              onTap: () => _handleTap(context, HomeBottomTab.bookings),
            ),
            _BottomNavItem(
              icon: Icons.account_balance_wallet_outlined,
              isSelected: selectedTab == HomeBottomTab.wallet,
              onTap: () => _handleTap(context, HomeBottomTab.wallet),
            ),
            _BottomNavItem(
              icon: Icons.person_outline_rounded,
              isSelected: selectedTab == HomeBottomTab.profile,
              onTap: () => _handleTap(context, HomeBottomTab.profile),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  const _BottomNavItem({
    required this.icon,
    required this.onTap,
    this.isSelected = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40,
          height: 40,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [
                        Color(0xFF28D877),
                        AppColors.brandGreen,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.brandGreenLight : AppColors.border,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.brandGreen.withValues(alpha: 0.32),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ]
                  : const [],
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textMuted,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
