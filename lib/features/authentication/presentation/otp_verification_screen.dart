import 'dart:async';

import 'package:car_wash/core/localization/app_localizations.dart';
import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/services/otp_email_service.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
import 'package:car_wash/features/authentication/data/auth_session.dart';
import 'package:car_wash/features/authentication/model/app_user_role.dart';
import 'package:car_wash/features/authentication/presentation/widgets/auth_shared_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  late final List<FocusNode> _focusNodes = List.generate(
    6,
    (_) => FocusNode(),
  );

  Timer? _resendTimer;
  int _secondsRemaining = 58;
  bool _showInvalidCode = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining == 0) {
        timer.cancel();
        return;
      }

      setState(() {
        _secondsRemaining--;
      });
    });
  }

  void _goBack() {
    context.goToSignup();
  }

  void _confirm() {
    final enteredOtp = _controllers.map((controller) => controller.text).join();

    if (enteredOtp.length != _controllers.length) {
      setState(() {
        _showInvalidCode = true;
      });
      return;
    }

    final email = AuthSession.currentEmail ?? '';
    final isValid = OtpEmailService.verifyOtp(email, enteredOtp);

    if (!isValid) {
      setState(() {
        _showInvalidCode = true;
      });
      return;
    }

    OtpEmailService.clearOtp();
    setState(() {
      _showInvalidCode = false;
    });

    // Mark user as authenticated after successful OTP verification
    AuthSession.setAuthenticated(true);
    if (AuthSession.currentRole == null ||
        AuthSession.currentRole == AppUserRole.guest) {
      AuthSession.setCurrentRole(AppUserRole.customer);
    }

    context.goToVerificationComplete();
  }

  void _resendCode() {
    if (_secondsRemaining > 0) {
      return;
    }

    final email = AuthSession.currentEmail ?? '';
    if (email.isNotEmpty) {
      OtpEmailService.sendOtp(email);
    }

    setState(() {
      _secondsRemaining = 58;
      _showInvalidCode = false;
      for (final controller in _controllers) {
        controller.clear();
      }
    });
    _focusNodes.first.requestFocus();
    _startTimer();
  }

  void _handleOtpChange(String value, int index) {
    setState(() {
      _showInvalidCode = false;
    });

    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  Widget _buildOtpField(int index, double boxWidth) {
    final hasValue = _controllers[index].text.trim().isNotEmpty;
    final borderColor = _showInvalidCode
        ? AppButtonColors.destructiveForeground
        : hasValue
        ? AppColors.brandGreen
        : AppColors.border;
    final fillColor = _showInvalidCode
        ? const Color(0xFFFFF4F4)
        : hasValue
        ? AppColors.brandGreen
        : Colors.white;
    final textColor = _showInvalidCode
        ? AppButtonColors.destructiveForeground
        : hasValue
        ? Colors.white
        : AppColors.deepInk;

    return SizedBox(
      width: boxWidth,
      height: 52,
      child: TextField(
        key: Key('otp_digit_$index'),
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        cursorColor: textColor,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          height: 1,
          color: textColor,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: fillColor,
          counterText: '',
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.5,
            ),
          ),
        ),
        onChanged: (value) => _handleOtpChange(value, index),
      ),
    );
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (final controller in _controllers) {
      controller.dispose();
    }
    for (final focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScreenShell(
      title: context.translate('account_verification'),
      onBack: _goBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthBrandBadge(),
          const SizedBox(height: 18),
          Text(
            context.translate('otp_verification'),
            key: const Key('otp_screen_title'),
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            context.translate('otp_instruction'),
            style: const TextStyle(
              fontSize: 14.5,
              height: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              final boxWidth = ((constraints.maxWidth -
                          (spacing * (_controllers.length - 1))) /
                      _controllers.length)
                  .clamp(44.0, 50.0)
                  .toDouble();

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_controllers.length, (index) {
                  return _buildOtpField(index, boxWidth);
                }),
              );
            },
          ),
          if (_showInvalidCode) ...[
            const SizedBox(height: 10),
            Center(
              child: Row(
                key: const Key('otp_invalid_code_message'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 14,
                    color: AppButtonColors.destructiveForeground,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    context.translate('invalid_code'),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppButtonColors.destructiveForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 84),
          Center(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '00:${_secondsRemaining.toString().padLeft(2, '0')} ',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                GestureDetector(
                  key: const Key('otp_resend_button'),
                  onTap: _resendCode,
                  child: Text(
                    context.translate('resend'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppButtonColors.actionForeground,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppPrimaryButton(
            key: const Key('otp_confirm_button'),
            label: context.translate('confirm'),
            onPressed: _confirm,
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
