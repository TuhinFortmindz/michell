import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Text styles taken from the Figma sign-up design (font: Manrope).
///
/// Vertical placement of text is done with [Baseline] widgets, so these
/// styles only set the line height where a text block has several lines.
abstract final class AppTextStyles {
  static const String fontFamily = 'Manrope';

  /// Line height shared by every 12px multi-line text block (16px in Figma).
  static const double smallTextLineHeight = 16 / 12;

  static const TextStyle pageTitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.brandPurple,
  );

  static const TextStyle fieldHint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.hintGrey,
  );

  static const TextStyle fieldInput = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.inputText,
  );

  static const TextStyle countryCode = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.brandPurple,
  );

  static const TextStyle helperText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: smallTextLineHeight,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.hintGrey,
  );

  static const TextStyle consentText = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: smallTextLineHeight,
    leadingDistribution: TextLeadingDistribution.even,
    color: AppColors.bodyText,
  );

  static const TextStyle consentLink = TextStyle(
    color: AppColors.brandPurple,
  );

  static const TextStyle primaryButton = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonText,
  );
}
