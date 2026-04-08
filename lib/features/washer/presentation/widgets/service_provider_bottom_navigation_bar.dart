import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

enum ServiceProviderBottomTab { home, bookings, earnings, profile }

class ServiceProviderBottomNavigationBar extends StatelessWidget {
  const ServiceProviderBottomNavigationBar({
    super.key,
    required this.selectedTab,
  });

  final ServiceProviderBottomTab selectedTab;

  void _handleTap(BuildContext context, ServiceProviderBottomTab tab) {
    if (tab == selectedTab) {
      return;
    }

    switch (tab) {
      case ServiceProviderBottomTab.home:
        context.goToServiceProviderHome();
        return;
      case ServiceProviderBottomTab.bookings:
        context.goToServiceProviderBookings();
        return;
      case ServiceProviderBottomTab.earnings:
        context.goToServiceProviderPaymentHistory();
        return;
      case ServiceProviderBottomTab.profile:
        context.goToServiceProviderProfile();
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, -2),
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
              isSelected: selectedTab == ServiceProviderBottomTab.home,
              onTap: () => _handleTap(context, ServiceProviderBottomTab.home),
            ),
            _BottomNavItem(
              icon: Icons.calendar_month_outlined,
              isSelected: selectedTab == ServiceProviderBottomTab.bookings,
              onTap: () =>
                  _handleTap(context, ServiceProviderBottomTab.bookings),
            ),
            _BottomNavItem(
              icon: Icons.account_balance_wallet_outlined,
              isSelected: selectedTab == ServiceProviderBottomTab.earnings,
              onTap: () =>
                  _handleTap(context, ServiceProviderBottomTab.earnings),
            ),
            _BottomNavItem(
              icon: Icons.person_outline_rounded,
              isSelected: selectedTab == ServiceProviderBottomTab.profile,
              onTap: () =>
                  _handleTap(context, ServiceProviderBottomTab.profile),
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
          width: 44,
          height: 44,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brandGreen : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.white : const Color(0xFF8D8D8D),
              size: 22,
            ),
          ),
        ),
      ),
    );
  }
}
