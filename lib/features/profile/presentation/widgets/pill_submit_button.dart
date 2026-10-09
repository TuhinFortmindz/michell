import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Full-width rounded button. Grey while disabled, purple once enabled.
class PillSubmitButton extends StatelessWidget {
  const PillSubmitButton({
    super.key,
    required this.label,
    required this.isEnabled,
    required this.onPressed,
  });

  static const double height = 52;
  static const double labelBaseline = 32;

  final String label;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final BorderRadius pillShape = BorderRadius.circular(height / 2);

    return SizedBox(
      height: height,
      child: Material(
        color: isEnabled ? AppColors.brandPurple : AppColors.buttonDisabled,
        borderRadius: pillShape,
        child: InkWell(
          borderRadius: pillShape,
          onTap: isEnabled ? onPressed : null,
          child: Align(
            alignment: Alignment.topCenter,
            child: Baseline(
              baseline: labelBaseline,
              baselineType: TextBaseline.alphabetic,
              child: Text(label, style: AppTextStyles.primaryButton),
            ),
          ),
        ),
      ),
    );
  }
}
