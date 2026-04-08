import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:flutter/material.dart';

class AppPrimaryButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppButtonColors.primaryBackground,
          foregroundColor: AppButtonColors.primaryForeground,
          minimumSize: Size.fromHeight(height),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          textStyle: textStyle,
        ),
        child: Text(label),
      ),
    );
  }
}

class AppCircularIconButton extends StatelessWidget {
  const AppCircularIconButton({
    super.key,
    required this.backgroundColor,
    required this.iconColor,
    required this.icon,
    required this.onTap,
    this.size = 52,
    this.iconSize = 26,
  });

  final Color backgroundColor;
  final Color iconColor;
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Ink(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: iconSize),
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
    this.backgroundColor = Colors.white,
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
      color: Colors.black,
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
