import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'sign_up_icons.dart';

/// Measurements shared by every input box of the sign-up form (Figma px).
abstract final class SignUpFieldMetrics {
  static const double height = 50;
  static const double cornerRadius = 5;
  static const double underlineThickness = 1;

  /// Distance from the top of the box to the text baseline.
  static const double textBaseline = 30;

  /// Distance from the left edge of the box to the start of the text.
  static const double textLeft = 10;

  // Phone number fields.
  static const double flagLeft = 10;
  static const double flagTop = 18;
  static const double chevronLeft = 33.25;
  static const double chevronTop = 21.75;
  static const double countryCodeLeft = 46;
  static const double codeSeparatorLeft = 73.25;
  static const double codeSeparatorTop = 19.9;
  static const double codeSeparatorWidth = 1;
  static const double codeSeparatorHeight = 10.1;
  static const double phoneTextLeft = 86;

  // Password fields.
  static const double eyeIconLeft = 306;
  static const double eyeIconTop = 15.5;
  static const double passwordTextRight = 55;
}

/// Light rounded box with a grey underline, used behind every input.
class SignUpFieldBox extends StatelessWidget {
  const SignUpFieldBox({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: SignUpFieldMetrics.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SignUpFieldMetrics.cornerRadius),
        child: ColoredBox(
          color: AppColors.fieldBackground,
          child: Stack(
            children: [
              ...children,
              const Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: SignUpFieldMetrics.underlineThickness,
                child: ColoredBox(color: AppColors.fieldUnderline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Borderless text input whose baseline sits exactly on
/// [SignUpFieldMetrics.textBaseline].
class _BaselineTextInput extends StatelessWidget {
  const _BaselineTextInput({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.isTextHidden = false,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool isTextHidden;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Baseline(
      baseline: SignUpFieldMetrics.textBaseline,
      baselineType: TextBaseline.alphabetic,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        inputFormatters: inputFormatters,
        obscureText: isTextHidden,
        enableSuggestions: !isTextHidden,
        autocorrect: !isTextHidden,
        autofillHints: autofillHints,
        textCapitalization: textCapitalization,
        maxLines: 1,
        style: AppTextStyles.fieldInput,
        cursorColor: AppColors.brandPurple,
        cursorHeight: 16,
        decoration: InputDecoration.collapsed(
          hintText: hintText,
          hintStyle: AppTextStyles.fieldHint,
        ),
      ),
    );
  }
}

/// Plain text field: name, e-mail, etc.
class SignUpTextField extends StatelessWidget {
  const SignUpTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return SignUpFieldBox(
      children: [
        Positioned(
          left: SignUpFieldMetrics.textLeft,
          right: SignUpFieldMetrics.textLeft,
          top: 0,
          child: _BaselineTextInput(
            controller: controller,
            hintText: hintText,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            textCapitalization: textCapitalization,
          ),
        ),
      ],
    );
  }
}

/// Password field with an eye button that shows or hides the text.
class SignUpPasswordField extends StatelessWidget {
  const SignUpPasswordField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.isPasswordHidden,
    required this.onVisibilityToggle,
    this.textInputAction = TextInputAction.next,
  });

  final TextEditingController controller;
  final String hintText;
  final bool isPasswordHidden;
  final VoidCallback onVisibilityToggle;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return SignUpFieldBox(
      children: [
        Positioned(
          left: SignUpFieldMetrics.textLeft,
          right: SignUpFieldMetrics.passwordTextRight,
          top: 0,
          child: _BaselineTextInput(
            controller: controller,
            hintText: hintText,
            keyboardType: TextInputType.visiblePassword,
            textInputAction: textInputAction,
            isTextHidden: isPasswordHidden,
            autofillHints: const [AutofillHints.newPassword],
          ),
        ),
        Positioned(
          left: SignUpFieldMetrics.eyeIconLeft,
          top: SignUpFieldMetrics.eyeIconTop,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onVisibilityToggle,
            child: EyeIcon(isCrossedOut: !isPasswordHidden),
          ),
        ),
      ],
    );
  }
}

/// Phone number field with the UAE flag and the "971" country code.
class SignUpPhoneField extends StatelessWidget {
  const SignUpPhoneField({
    super.key,
    required this.controller,
    required this.hintText,
    this.countryCode = '971',
    this.showCountryPickerArrow = false,
    this.onCountryCodeTap,
  });

  final TextEditingController controller;
  final String hintText;
  final String countryCode;
  final bool showCountryPickerArrow;
  final VoidCallback? onCountryCodeTap;

  @override
  Widget build(BuildContext context) {
    return SignUpFieldBox(
      children: [
        const Positioned(
          left: SignUpFieldMetrics.flagLeft,
          top: SignUpFieldMetrics.flagTop,
          child: UaeFlagIcon(),
        ),
        if (showCountryPickerArrow)
          const Positioned(
            left: SignUpFieldMetrics.chevronLeft,
            top: SignUpFieldMetrics.chevronTop,
            child: ChevronDownIcon(),
          ),
        Positioned(
          left: SignUpFieldMetrics.countryCodeLeft,
          top: 0,
          child: Baseline(
            baseline: SignUpFieldMetrics.textBaseline,
            baselineType: TextBaseline.alphabetic,
            child: Text(countryCode, style: AppTextStyles.countryCode),
          ),
        ),
        const Positioned(
          left: SignUpFieldMetrics.codeSeparatorLeft,
          top: SignUpFieldMetrics.codeSeparatorTop,
          width: SignUpFieldMetrics.codeSeparatorWidth,
          height: SignUpFieldMetrics.codeSeparatorHeight,
          child: ColoredBox(color: AppColors.hintGrey),
        ),
        Positioned(
          left: 0,
          top: 0,
          width: SignUpFieldMetrics.codeSeparatorLeft,
          height: SignUpFieldMetrics.height,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: onCountryCodeTap,
          ),
        ),
        Positioned(
          left: SignUpFieldMetrics.phoneTextLeft,
          right: SignUpFieldMetrics.textLeft,
          top: 0,
          child: _BaselineTextInput(
            controller: controller,
            hintText: hintText,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            autofillHints: const [AutofillHints.telephoneNumberNational],
          ),
        ),
      ],
    );
  }
}
