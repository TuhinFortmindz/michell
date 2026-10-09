import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'sign_up_text_fields.dart';

/// Square checkbox followed by the terms / privacy / payment consent text.
class ConsentCheckboxRow extends StatefulWidget {
  const ConsentCheckboxRow({
    super.key,
    required this.isChecked,
    required this.onChanged,
    this.onTermsOfServiceTap,
    this.onPrivacyPolicyTap,
    this.onPaymentPolicyTap,
  });

  static const double height = 58;
  static const double checkboxSize = 25;
  static const double textLeft = 37;
  static const double firstLineBaseline = 9;

  final bool isChecked;
  final ValueChanged<bool> onChanged;
  final VoidCallback? onTermsOfServiceTap;
  final VoidCallback? onPrivacyPolicyTap;
  final VoidCallback? onPaymentPolicyTap;

  @override
  State<ConsentCheckboxRow> createState() => _ConsentCheckboxRowState();
}

class _ConsentCheckboxRowState extends State<ConsentCheckboxRow> {
  late final TapGestureRecognizer _termsOfServiceTap = TapGestureRecognizer();
  late final TapGestureRecognizer _privacyPolicyTap = TapGestureRecognizer();
  late final TapGestureRecognizer _paymentPolicyTap = TapGestureRecognizer();

  @override
  void dispose() {
    _termsOfServiceTap.dispose();
    _privacyPolicyTap.dispose();
    _paymentPolicyTap.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _termsOfServiceTap.onTap = widget.onTermsOfServiceTap;
    _privacyPolicyTap.onTap = widget.onPrivacyPolicyTap;
    _paymentPolicyTap.onTap = widget.onPaymentPolicyTap;

    return SizedBox(
      height: ConsentCheckboxRow.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => widget.onChanged(!widget.isChecked),
              child: _ConsentCheckbox(isChecked: widget.isChecked),
            ),
          ),
          Positioned(
            left: ConsentCheckboxRow.textLeft,
            top: 0,
            child: Baseline(
              baseline: ConsentCheckboxRow.firstLineBaseline,
              baselineType: TextBaseline.alphabetic,
              child: Text.rich(
                TextSpan(
                  style: AppTextStyles.consentText,
                  children: [
                    const TextSpan(text: 'I consent to the '),
                    TextSpan(
                      text: 'Terms of Service',
                      style: AppTextStyles.consentLink,
                      recognizer: _termsOfServiceTap,
                    ),
                    const TextSpan(text: ', '),
                    TextSpan(
                      text: 'Privacy Policy',
                      style: AppTextStyles.consentLink,
                      recognizer: _privacyPolicyTap,
                    ),
                    const TextSpan(text: ',\nand '),
                    TextSpan(
                      text: 'Payment & Cancellation Policy',
                      style: AppTextStyles.consentLink,
                      recognizer: _paymentPolicyTap,
                    ),
                    const TextSpan(text: ' of ABAPRO'),
                  ],
                ),
                softWrap: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConsentCheckbox extends StatelessWidget {
  const _ConsentCheckbox({required this.isChecked});

  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: ConsentCheckboxRow.checkboxSize,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(SignUpFieldMetrics.cornerRadius),
        child: ColoredBox(
          color: isChecked ? AppColors.brandPurple : AppColors.fieldBackground,
          child: Stack(
            children: [
              if (isChecked)
                const Center(
                  child: Icon(
                    Icons.check,
                    size: 18,
                    color: AppColors.buttonText,
                  ),
                ),
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
