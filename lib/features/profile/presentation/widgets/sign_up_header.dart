import 'package:flutter/material.dart';

import '../../../../core/theme/app_text_styles.dart';
import 'sign_up_icons.dart';

/// Back button and centred page title, from the bottom of the status bar
/// down to the top of the profile photo.
class SignUpHeader extends StatelessWidget {
  const SignUpHeader({super.key, required this.title, this.onBackTap});

  static const double height = 53;
  static const double titleBaseline = 25;
  static const double backIconLeft = 15;
  static const double backIconTop = 9.5;
  static const double backTapAreaWidth = 48;

  final String title;
  final VoidCallback? onBackTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Baseline(
              baseline: titleBaseline,
              baselineType: TextBaseline.alphabetic,
              child: Text(title, style: AppTextStyles.pageTitle),
            ),
          ),
          const Positioned(
            left: backIconLeft,
            top: backIconTop,
            child: BackChevronIcon(),
          ),
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: backTapAreaWidth,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBackTap,
            ),
          ),
        ],
      ),
    );
  }
}
