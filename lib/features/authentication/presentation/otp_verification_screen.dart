import 'dart:async';

import 'package:car_wash/core/router/app_navigation.dart';
import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:car_wash/core/widgets/app_buttons.dart';
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

    setState(() {
      _showInvalidCode = false;
    });

    context.goToVerificationComplete();
  }

  void _resendCode() {
    if (_secondsRemaining > 0) {
      return;
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
    if (_showInvalidCode) {
      setState(() {
        _showInvalidCode = false;
      });
    }

    if (value.isNotEmpty && index < _focusNodes.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  Widget _buildOtpField(int index, double boxWidth) {
    final borderColor = _showInvalidCode
        ? AppButtonColors.destructiveForeground
        : AppButtonColors.primaryBackground;

    return SizedBox(
      width: boxWidth,
      height: 40,
      child: TextField(
        key: Key('otp_digit_$index'),
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        cursorColor: AppButtonColors.primaryBackground,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(1),
        ],
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ).copyWith(
          color: _showInvalidCode
              ? AppButtonColors.destructiveForeground
              : AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.inputFill,
          isDense: true,
          counterText: '',
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: borderColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(
              color: borderColor,
              width: 1.2,
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
      title: 'Account Verification',
      onBack: _goBack,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthBrandBadge(),
          const SizedBox(height: 18),
          const Text(
            'OTP Verification',
            key: Key('otp_screen_title'),
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Enter OTP sent to your email to verify your account.',
            style: TextStyle(
              fontSize: 14.5,
              height: 1.2,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 8.0;
              final boxWidth = ((constraints.maxWidth -
                          (spacing * (_controllers.length - 1))) /
                      _controllers.length)
                  .clamp(38.0, 42.0)
                  .toDouble();

              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_controllers.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == _controllers.length - 1 ? 0 : spacing,
                    ),
                    child: _buildOtpField(index, boxWidth),
                  );
                }),
              );
            },
          ),
          if (_showInvalidCode) ...[
            const SizedBox(height: 10),
            const Center(
              child: Row(
                key: Key('otp_invalid_code_message'),
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 14,
                    color: AppButtonColors.destructiveForeground,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Invalid Code',
                    style: TextStyle(
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
                  child: const Text(
                    'Resend',
                    style: TextStyle(
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
            label: 'Confirm',
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
