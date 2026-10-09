import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/input_validators.dart';
import 'sign_up_icons.dart';

/// Measurements shared by every input box of the sign-up form (Figma px).
abstract final class SignUpFieldMetrics {
  static const double height = 50;
  static const double cornerRadius = 5;
  static const double underlineThickness = 1;

  /// Baseline of the hint while the field is empty, and of the country code.
  static const double textBaseline = 30;

  /// Once a field has a value, the hint becomes a small label on top and the
  /// value sits below it. Baselines measured on the filled Figma frame.
  static const double floatingLabelBaseline = 21;
  static const double valueBaseline = 40;
  static const double phoneFloatingLabelBaseline = 18;
  static const double phoneValueBaseline = 37;
  static const double passwordFloatingLabelBaseline = 22;

  /// Hidden-password dots: baseline of the bullet glyphs, and how far the
  /// text starts left of [textLeft] so the first dot's edge lines up with it.
  static const double passwordDotsBaseline = 40.87;
  static const double passwordDotsLeftShift = 4.07;

  /// Distance from the left edge of the box to the start of the text.
  static const double textLeft = 10;

  // Phone number fields.
  static const double flagLeft = 10;
  static const double flagTop = 15;
  static const double chevronLeft = 33.125;
  static const double chevronTop = 21.75;
  static const double countryCodeLeft = 46;
  static const double codeSeparatorLeft = 73.25;
  static const double codeSeparatorTop = 19.9;
  static const double codeSeparatorWidth = 1;
  static const double codeSeparatorHeight = 10.1;
  static const double phoneTextLeft = 86;

  // Password fields.
  static const double eyeIconLeft = 304;
  static const double eyeIconTop = 13;
  static const double passwordTextRight = 55;

  // Verified tick (phone and e-mail fields), same column as the eye icon.
  static const double verifiedTickLeft = 304;

  /// Figma has the tick 0.5 px lower in the alternative mobile and e-mail
  /// fields than in the main mobile field.
  static const double mobileVerifiedTickTop = 13;
  static const double alternativeMobileVerifiedTickTop = 13.5;
  static const double emailVerifiedTickTop = 13.5;

  /// Right edge of the text while the verified tick is visible. When the
  /// tick is hidden the text uses the full width up to [textLeft].
  static const double textRightBeforeIcon = 55;
}

/// Returns true when [value] is valid and the verified tick should show.
typedef FieldValueCheck = bool Function(String value);

/// Purple verified tick shown while [controller] holds a valid value.
class _VerifiedTickWhenValid extends StatelessWidget {
  const _VerifiedTickWhenValid({
    required this.controller,
    required this.isValueValid,
  });

  final TextEditingController controller;
  final FieldValueCheck isValueValid;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) => isValueValid(value.text)
          ? const VerifiedTickIcon()
          : const SizedBox.shrink(),
    );
  }
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

/// Where the label and value of one kind of field sit (Figma px).
class _FieldTextLayout {
  const _FieldTextLayout({
    required this.left,
    required this.right,
    required this.floatingLabelBaseline,
    required this.valueBaseline,
  });

  final double left;
  final double right;
  final double floatingLabelBaseline;
  final double valueBaseline;
}

const _FieldTextLayout _plainFieldLayout = _FieldTextLayout(
  left: SignUpFieldMetrics.textLeft,
  right: SignUpFieldMetrics.textLeft,
  floatingLabelBaseline: SignUpFieldMetrics.floatingLabelBaseline,
  valueBaseline: SignUpFieldMetrics.valueBaseline,
);

const _FieldTextLayout _passwordFieldLayout = _FieldTextLayout(
  left: SignUpFieldMetrics.textLeft,
  right: SignUpFieldMetrics.passwordTextRight,
  floatingLabelBaseline: SignUpFieldMetrics.passwordFloatingLabelBaseline,
  valueBaseline: SignUpFieldMetrics.valueBaseline,
);

const _FieldTextLayout _phoneFieldLayout = _FieldTextLayout(
  left: SignUpFieldMetrics.phoneTextLeft,
  right: SignUpFieldMetrics.textLeft,
  floatingLabelBaseline: SignUpFieldMetrics.phoneFloatingLabelBaseline,
  valueBaseline: SignUpFieldMetrics.phoneValueBaseline,
);

/// Borderless text input with a floating label.
///
/// Empty: the grey hint sits on [SignUpFieldMetrics.textBaseline].
/// Filled: the hint turns into a small grey label on top and the purple value
/// is shown below it, as in the filled Figma frame.
class _FloatingLabelInput extends StatelessWidget {
  const _FloatingLabelInput({
    required this.controller,
    required this.hintText,
    required this.floatingLabelText,
    required this.layout,
    this.keyboardType,
    this.textInputAction = TextInputAction.next,
    this.inputFormatters,
    this.isTextHidden = false,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.showsVerifiedTickWhen,
  });

  final TextEditingController controller;
  final String hintText;
  final String floatingLabelText;
  final _FieldTextLayout layout;

  /// Same check that shows the verified tick: while it passes, the text stops
  /// before the tick; otherwise it uses the full width.
  final FieldValueCheck? showsVerifiedTickWhen;
  final TextInputType? keyboardType;
  final TextInputAction textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool isTextHidden;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final bool hasValue = value.text.isNotEmpty;
        final bool showsPasswordDots = hasValue && isTextHidden;

        final double inputBaseline = !hasValue
            ? SignUpFieldMetrics.textBaseline
            : showsPasswordDots
            ? SignUpFieldMetrics.passwordDotsBaseline
            : layout.valueBaseline;
        final double inputLeft = showsPasswordDots
            ? layout.left - SignUpFieldMetrics.passwordDotsLeftShift
            : layout.left;
        final bool showsVerifiedTick =
            showsVerifiedTickWhen?.call(value.text) ?? false;
        final double textRight = showsVerifiedTick
            ? SignUpFieldMetrics.textRightBeforeIcon
            : layout.right;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            // Keep the input first, with a key: inserting the label before it
            // would recreate the TextField, drop its focus and close the
            // keyboard on the first typed character.
            Positioned(
              key: const ValueKey('input'),
              left: inputLeft,
              right: textRight,
              top: 0,
              child: Baseline(
                baseline: inputBaseline,
                baselineType: TextBaseline.alphabetic,
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  textInputAction: textInputAction,
                  inputFormatters: inputFormatters,
                  obscureText: isTextHidden,
                  obscuringCharacter: '•',
                  enableSuggestions: !isTextHidden,
                  autocorrect: !isTextHidden,
                  autofillHints: autofillHints,
                  textCapitalization: textCapitalization,
                  maxLines: 1,
                  style: showsPasswordDots
                      ? AppTextStyles.passwordDots
                      : AppTextStyles.fieldValue,
                  cursorColor: AppColors.brandPurple,
                  cursorHeight: 16,
                  decoration: InputDecoration.collapsed(
                    hintText: hintText,
                    hintStyle: AppTextStyles.fieldHint,
                  ),
                ),
              ),
            ),
            if (hasValue)
              Positioned(
                left: layout.left,
                right: textRight,
                top: 0,
                child: Baseline(
                  baseline: layout.floatingLabelBaseline,
                  baselineType: TextBaseline.alphabetic,
                  child: Text(
                    floatingLabelText,
                    style: AppTextStyles.fieldFloatingLabel,
                    maxLines: 1,
                    softWrap: false,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Plain text field: name, e-mail, etc.
class SignUpTextField extends StatelessWidget {
  const SignUpTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.floatingLabelText,
    this.keyboardType,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
    this.showVerifiedTickWhen,
  });

  final TextEditingController controller;
  final String hintText;

  /// Label shown above the value; defaults to [hintText].
  final String? floatingLabelText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  /// When set, a verified tick is shown while this check passes.
  final FieldValueCheck? showVerifiedTickWhen;

  @override
  Widget build(BuildContext context) {
    final FieldValueCheck? isValueValid = showVerifiedTickWhen;

    return SignUpFieldBox(
      children: [
        Positioned.fill(
          child: _FloatingLabelInput(
            controller: controller,
            hintText: hintText,
            floatingLabelText: floatingLabelText ?? hintText,
            layout: _plainFieldLayout,
            showsVerifiedTickWhen: isValueValid,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            textCapitalization: textCapitalization,
          ),
        ),
        if (isValueValid != null)
          Positioned(
            left: SignUpFieldMetrics.verifiedTickLeft,
            top: SignUpFieldMetrics.emailVerifiedTickTop,
            child: _VerifiedTickWhenValid(
              controller: controller,
              isValueValid: isValueValid,
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
        Positioned.fill(
          child: _FloatingLabelInput(
            controller: controller,
            hintText: hintText,
            floatingLabelText: hintText,
            layout: _passwordFieldLayout,
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
///
/// Accepts up to 9 digits and shows the verified tick once all 9 are entered.
class SignUpPhoneField extends StatelessWidget {
  const SignUpPhoneField({
    super.key,
    required this.controller,
    required this.hintText,
    this.floatingLabelText,
    this.countryCode = '971',
    this.showCountryPickerArrow = false,
    this.onCountryCodeTap,
    this.verifiedTickTop = SignUpFieldMetrics.mobileVerifiedTickTop,
  });

  final TextEditingController controller;
  final String hintText;

  /// Label shown above the number; defaults to [hintText].
  final String? floatingLabelText;
  final String countryCode;
  final bool showCountryPickerArrow;
  final VoidCallback? onCountryCodeTap;
  final double verifiedTickTop;

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
        Positioned.fill(
          child: _FloatingLabelInput(
            controller: controller,
            hintText: hintText,
            floatingLabelText: floatingLabelText ?? hintText,
            layout: _phoneFieldLayout,
            showsVerifiedTickWhen: InputValidators.isValidUaeMobileNumber,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(
                InputValidators.uaeMobileNumberLength,
              ),
            ],
            autofillHints: const [AutofillHints.telephoneNumberNational],
          ),
        ),
        Positioned(
          left: SignUpFieldMetrics.verifiedTickLeft,
          top: verifiedTickTop,
          child: _VerifiedTickWhenValid(
            controller: controller,
            isValueValid: InputValidators.isValidUaeMobileNumber,
          ),
        ),
      ],
    );
  }
}
