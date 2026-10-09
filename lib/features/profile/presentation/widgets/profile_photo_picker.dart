import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import 'sign_up_icons.dart';

/// Round grey placeholder with a purple ring and a "camera +" icon.
class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({super.key, this.onTap});

  static const double diameter = 100;
  static const double ringWidth = 2;

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: diameter,
          height: diameter,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.avatarFill,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.brandPurple, width: ringWidth),
          ),
          child: const CameraPlusIcon(),
        ),
      ),
    );
  }
}
