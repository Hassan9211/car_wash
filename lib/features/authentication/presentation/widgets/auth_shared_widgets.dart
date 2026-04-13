import 'package:car_wash/core/theme/app_button_colors.dart';
import 'package:car_wash/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class AuthScreenShell extends StatelessWidget {
  const AuthScreenShell({
    super.key,
    required this.title,
    required this.onBack,
    required this.child,
    this.footer,
    this.footerReservedHeight = 92,
    this.backgroundColor = AppColors.authSoftBackground,
    this.titleTextStyle,
  });

  final String title;
  final VoidCallback onBack;
  final Widget child;
  final Widget? footer;
  final double footerReservedHeight;
  final Color backgroundColor;
  final TextStyle? titleTextStyle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundColor,
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              backgroundColor,
              AppColors.appBackground,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 54,
                child: Stack(
                  children: [
                    Positioned(
                      left: 8,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        onPressed: onBack,
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
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style:
                                titleTextStyle ??
                                const TextStyle(
                                  fontSize: 24 / 1.4,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textPrimary,
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(
                height: 1,
                thickness: 0.8,
                color: AppColors.border,
              ),
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.fromLTRB(
                          18,
                          18,
                          18,
                          footer != null ? footerReservedHeight : 20,
                        ),
                        child: child,
                      ),
                    ),
                    if (footer != null)
                      Positioned(
                        left: 18,
                        right: 18,
                        bottom: 18,
                        child: footer!,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthBottomPrompt extends StatelessWidget {
  const AuthBottomPrompt({
    super.key,
    required this.prefixText,
    required this.actionText,
    required this.onTap,
    this.actionKey,
  });

  final String prefixText;
  final String actionText;
  final VoidCallback onTap;
  final Key? actionKey;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            prefixText,
            style: const TextStyle(
              fontSize: 14.5,
              color: AppColors.textMuted,
            ),
          ),
          GestureDetector(
            key: actionKey,
            onTap: onTap,
            child: Text(
              actionText,
              style: const TextStyle(
                fontSize: 14.5,
                color: AppButtonColors.actionForeground,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthBrandBadge extends StatelessWidget {
  const AuthBrandBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.local_car_wash_rounded,
          size: 30,
          color: AppColors.brandGreenLight,
        ),
        SizedBox(height: 4),
        Text(
          'Lavego',
          style: TextStyle(
            fontSize: 11,
            height: 1,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class AuthInputField extends StatefulWidget {
  const AuthInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    this.isFocusedStyle = false,
    this.obscureText = false,
    this.keyboardType,
    this.suffix,
    this.validator,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool isFocusedStyle;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  @override
  State<AuthInputField> createState() => _AuthInputFieldState();
}

class _AuthInputFieldState extends State<AuthInputField> {
  late final FocusNode _focusNode = FocusNode()
    ..addListener(() {
      setState(() {});
    });

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHighlighted = widget.isFocusedStyle && _focusNode.hasFocus;

    final borderColor = isHighlighted
        ? AppColors.brandGreen
        : AppColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.isFocusedStyle && isHighlighted)
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 2),
            child: Text(
              widget.label,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.brandGreen,
              ),
            ),
          ),
        TextFormField(
          controller: widget.controller,
          focusNode: _focusNode,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          cursorColor: AppColors.brandGreen,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14.5,
          ),
          autocorrect: false,
          enableSuggestions: false,
          autofillHints: const <String>[],
          decoration: InputDecoration(
            filled: true,
            fillColor: AppColors.inputFill,
            hintText: widget.isFocusedStyle && !isHighlighted
                ? widget.label
                : widget.hintText,
            labelText: widget.isFocusedStyle ? null : widget.label,
            labelStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14.5,
            ),
            hintStyle: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 14.5,
            ),
            errorStyle: const TextStyle(
              fontSize: 11.5,
              height: 1.2,
            ),
            floatingLabelBehavior: widget.isFocusedStyle
                ? FloatingLabelBehavior.never
                : FloatingLabelBehavior.auto,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            suffixIcon: widget.suffix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: borderColor,
                width: isHighlighted ? 1 : 0.9,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(
                color: borderColor,
                width: isHighlighted ? 1 : 0.9,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppColors.brandGreen,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppButtonColors.destructiveForeground,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(
                color: AppButtonColors.destructiveForeground,
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
