import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/presentation/widgets/auth_shared_widgets.dart';
import 'package:flutter/material.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  void _goBack(BuildContext context) {
    context.goToForgotPassword();
  }

  void _goToLogin(BuildContext context) {
    context.goToLogin();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: 'Check Your Email',
      onBack: () => _goBack(context),
      child: Padding(
        padding: const EdgeInsets.only(top: 108),
        child: Column(
          children: [
            const _MailSuccessIllustration(),
            const SizedBox(height: 18),
            const Text(
              'Check Your Email',
              key: Key('check_email_screen_title'),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 22),
              child: Text(
                'Password reset link has been sent on your email address.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.5,
                  height: 1.2,
                  color: Color(0xFFAAA5A1),
                ),
              ),
            ),
            const SizedBox(height: 18),
            AppPrimaryButton(
              key: const Key('check_email_back_to_login_button'),
              label: 'Back to Login',
              onPressed: () => _goToLogin(context),
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

class _MailSuccessIllustration extends StatelessWidget {
  const _MailSuccessIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 118,
      height: 106,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 26,
            left: 5,
            right: 5,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF7F7F7),
                borderRadius: BorderRadius.circular(2),
                border: Border.all(
                  color: const Color(0xFFBEBEBE),
                ),
              ),
            ),
          ),
          Positioned(
            top: 19,
            left: 16,
            right: 16,
            child: CustomPaint(
              size: const Size(86, 46),
              painter: _EnvelopeFlapPainter(),
            ),
          ),
          Positioned(
            top: 0,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
                border: Border.all(
                  color: const Color(0xFFBEBEBE),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: AppColors.brandGreen,
                size: 28,
              ),
            ),
          ),
          const Positioned(
            left: 14,
            bottom: 16,
            child: _TinyMailLines(),
          ),
        ],
      ),
    );
  }
}

class _EnvelopeFlapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0xFFBEBEBE);

    final fill = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    final path = Path()
      ..moveTo(0, size.height * 0.55)
      ..lineTo(size.width / 2, 0)
      ..lineTo(size.width, size.height * 0.55)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, fill);
    canvas.drawPath(path, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _TinyMailLines extends StatelessWidget {
  const _TinyMailLines();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 9,
          height: 2.4,
          decoration: BoxDecoration(
            color: AppColors.brandGreen,
            borderRadius: BorderRadius.circular(99),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 22,
          height: 2.2,
          decoration: BoxDecoration(
            color: const Color(0xFF222222),
            borderRadius: BorderRadius.circular(99),
          ),
        ),
      ],
    );
  }
}
