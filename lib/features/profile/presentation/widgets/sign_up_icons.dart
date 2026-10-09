import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/theme/app_colors.dart';

/// Paths of the icons: PNGs exported from Figma (`assets/images/`) and an SVG
/// (`assets/icons/`) for the one icon that has no Figma export yet.
abstract final class SignUpIconAssets {
  static const String countryCodeArrow = 'assets/images/Country-codeArrow.png';
  static const String eye = 'assets/images/Eye.png';
  static const String eyeOff = 'assets/icons/eye_off.svg';
  static const String cameraPlus = 'assets/images/camera.png';
  static const String uaeFlag = 'assets/images/uaeFlag.png';
}

/// iOS thin left chevron used as the header back button.
///
/// At [size] the glyph's ink is about 7.75 x 13.5 px, like the Figma arrow.
class BackChevronIcon extends StatelessWidget {
  const BackChevronIcon({super.key});

  static const double size = 17.9;

  @override
  Widget build(BuildContext context) {
    return const Icon(
      CupertinoIcons.left_chevron,
      size: size,
      color: AppColors.brandPurple,
    );
  }
}

/// Small down arrow shown before the country code (11.5 x 6.5 px, Figma
/// export).
class ChevronDownIcon extends StatelessWidget {
  const ChevronDownIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      SignUpIconAssets.countryCodeArrow,
      width: 11.5,
      height: 6.5,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// Outlined eye (24 x 24 px, Figma export). When [isCrossedOut] is true the
/// slashed eye is shown, meaning the password is visible.
class EyeIcon extends StatelessWidget {
  const EyeIcon({super.key, this.isCrossedOut = false});

  static const double size = 24;

  final bool isCrossedOut;

  @override
  Widget build(BuildContext context) {
    if (isCrossedOut) {
      return SvgPicture.asset(
        SignUpIconAssets.eyeOff,
        width: size,
        height: size,
      );
    }
    return Image.asset(
      SignUpIconAssets.eye,
      width: size,
      height: size,
      filterQuality: FilterQuality.medium,
    );
  }
}

/// White "camera with plus" outline (50 x 50 px, Figma export).
class CameraPlusIcon extends StatelessWidget {
  const CameraPlusIcon({super.key});

  static const double size = 50;

  @override
  Widget build(BuildContext context) {
    return Image.asset(SignUpIconAssets.cameraPlus, width: size, height: size);
  }
}

/// UAE flag (Figma export). The image is 20 x 20 px with the 20 x 14 px flag
/// centred vertically.
class UaeFlagIcon extends StatelessWidget {
  const UaeFlagIcon({super.key});

  static const double size = 20;

  @override
  Widget build(BuildContext context) {
    return Image.asset(SignUpIconAssets.uaeFlag, width: size, height: size);
  }
}
