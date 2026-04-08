import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/presentation/widgets/auth_shared_widgets.dart';
import 'package:flutter/material.dart';

class VerificationCompleteScreen extends StatelessWidget {
  const VerificationCompleteScreen({super.key});

  void _goBack(BuildContext context) {
    context.goToOtpVerification();
  }

  void _continue(BuildContext context) {
    context.goToLocationAccess();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: 'Verification Complete',
      onBack: () => _goBack(context),
      child: Padding(
        padding: const EdgeInsets.only(top: 150),
        child: Column(
          children: [
            const _VerificationSuccessBadge(),
            const SizedBox(height: 22),
            const Text(
              'Verification Complete!',
              key: Key('verification_complete_title'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Text(
                'Your account has been successfully verified.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.2,
                  color: Color(0xFFAAA5A1),
                ),
              ),
            ),
            const SizedBox(height: 22),
            AppPrimaryButton(
              key: const Key('verification_continue_button'),
              label: 'Continue',
              onPressed: () => _continue(context),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerificationSuccessBadge extends StatelessWidget {
  const _VerificationSuccessBadge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 92,
      height: 92,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 12,
            right: 12,
            bottom: 8,
            child: Container(
              height: 34,
              decoration: const BoxDecoration(
                color: AppColors.brandGreen,
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(40),
                ),
              ),
            ),
          ),
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.brandGreen,
                width: 1,
              ),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 42,
              color: AppColors.brandGreen,
            ),
          ),
        ],
      ),
    );
  }
}
