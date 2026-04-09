import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class AppPrimaryButton extends StatefulWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.height = 46,
    this.borderRadius = 6,
    this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;
  final double borderRadius;
  final TextStyle? textStyle;

  @override
  State<AppPrimaryButton> createState() => _AppPrimaryButtonState();
}

class _AppPrimaryButtonState extends State<AppPrimaryButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onPressed != null;
    final resolvedTextStyle =
        (widget.textStyle ??
                const TextStyle(
                  fontSize: 15.5,
                  fontWeight: FontWeight.w600,
                ))
            .copyWith(color: AppButtonColors.primaryForeground);

    return SizedBox(
      width: double.infinity,
      child: Opacity(
        opacity: isEnabled ? 1 : 0.58,
        child: AnimatedScale(
          scale: _isPressed ? 0.985 : 1,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          child: AnimatedSlide(
            offset: _isPressed ? const Offset(0, 0.02) : Offset.zero,
            duration: const Duration(milliseconds: 110),
            curve: Curves.easeOutCubic,
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              child: Ink(
                height: widget.height,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF2ADB77),
                      AppColors.brandGreen,
                      Color(0xFF0F6D35),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: AppColors.brandGreenLight.withValues(alpha: 0.35),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandGreen.withValues(
                        alpha: _isPressed ? 0.18 : 0.34,
                      ),
                      blurRadius: _isPressed ? 10 : 22,
                      offset: Offset(0, _isPressed ? 5 : 12),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: isEnabled
                      ? () {
                          HapticFeedback.lightImpact();
                          widget.onPressed?.call();
                        }
                      : null,
                  onHighlightChanged: (isHighlighted) {
                    if (_isPressed == isHighlighted) {
                      return;
                    }

                    setState(() {
                      _isPressed = isHighlighted;
                    });
                  },
                  splashColor: Colors.white.withValues(alpha: 0.16),
                  highlightColor: Colors.black.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  child: Center(
                    child: Text(widget.label, style: resolvedTextStyle),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppCircularIconButton extends StatefulWidget {
  const AppCircularIconButton({
    super.key,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    required this.onTap,
    this.size = 52,
    this.iconSize = 26,
    this.showShadow = true,
  });

  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;
  final bool showShadow;

  @override
  State<AppCircularIconButton> createState() => _AppCircularIconButtonState();
}

class _AppCircularIconButtonState extends State<AppCircularIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.94 : 1,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        shadowColor: widget.backgroundColor.withValues(alpha: 0.4),
        child: InkWell(
          onTap: () {
            HapticFeedback.selectionClick();
            widget.onTap();
          },
          onHighlightChanged: (isHighlighted) {
            if (_isPressed == isHighlighted) {
              return;
            }

            setState(() {
              _isPressed = isHighlighted;
            });
          },
          splashColor: Colors.white.withValues(alpha: 0.14),
          highlightColor: Colors.black.withValues(alpha: 0.08),
          customBorder: const CircleBorder(),
          child: Ink(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
              boxShadow: widget.showShadow
                  ? [
                      BoxShadow(
                        color: widget.backgroundColor.withValues(
                          alpha: _isPressed ? 0.14 : 0.24,
                        ),
                        blurRadius: _isPressed ? 7 : 12,
                        offset: Offset(0, _isPressed ? 3 : 6),
                      ),
                    ]
                  : const [],
            ),
            child: Icon(
              widget.icon,
              color: widget.iconColor,
              size: widget.iconSize,
            ),
          ),
        ),
      ),
    );
  }
}

class AppActionTextButton extends StatelessWidget {
  const AppActionTextButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.foregroundColor = AppButtonColors.actionForeground,
    this.fontSize = 12.5,
  });

  final String label;
  final VoidCallback onPressed;
  final Color foregroundColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foregroundColor,
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        animationDuration: const Duration(milliseconds: 110),
        overlayColor: foregroundColor.withValues(alpha: 0.12),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: fontSize),
      ),
    );
  }
}

class AppSocialButton extends StatelessWidget {
  const AppSocialButton({
    super.key,
    required this.child,
    this.height = 44,
    this.backgroundColor = AppColors.surfaceElevated,
    this.borderColor = AppButtonColors.socialBorder,
    this.borderRadius = 6,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double height;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: child,
    );
  }
}

class AppGoogleLogo extends StatelessWidget {
  const AppGoogleLogo({
    super.key,
    this.size = 24,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/google_logo.webp',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

class AppGmailLogo extends StatelessWidget {
  const AppGmailLogo({
    super.key,
    this.width = 24,
    this.height = 24,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/icons/gmail_logo.webp',
      width: width,
      height: height,
      fit: BoxFit.contain,
    );
  }
}

class AppAppleLogo extends StatelessWidget {
  const AppAppleLogo({
    super.key,
    this.size = 22,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.apple_rounded,
      size: size,
      color: AppColors.textPrimary,
    );
  }
}

class AppFacebookLogo extends StatelessWidget {
  const AppFacebookLogo({
    super.key,
    this.size = 20,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.facebook_rounded,
      size: size,
      color: const Color(0xFF1877F2),
    );
  }
}
