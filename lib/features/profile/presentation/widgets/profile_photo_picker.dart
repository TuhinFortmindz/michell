import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'sign_up_icons.dart';

/// Round profile photo with a purple ring.
///
/// Shows a grey placeholder with a "camera +" icon until [photoFile] is set,
/// then shows the photo cropped to the circle.
class ProfilePhotoPicker extends StatelessWidget {
  const ProfilePhotoPicker({super.key, this.photoFile, this.onTap});

  static const double diameter = 100;

  /// Figma places the circle at x = 137, half a pixel left of true centre.
  static const double leftOffset = 137;
  static const double ringWidth = 2;

  // "Edit" badge shown once a photo is chosen (measured on the filled Figma
  // frame, relative to the top-left of the photo circle).
  static const double editBadgeLeft = 76.5;
  static const double editBadgeTop = 76.1;

  final File? photoFile;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final File? selectedPhoto = photoFile;

    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: leftOffset),
        child: GestureDetector(
          onTap: onTap,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: diameter,
                height: diameter,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.avatarFill,
                  shape: BoxShape.circle,
                ),
                // The ring is painted on top so the photo never covers it.
                foregroundDecoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.brandPurple,
                    width: ringWidth,
                  ),
                ),
                child: selectedPhoto == null
                    ? const CameraPlusIcon()
                    : ClipOval(
                        child: Image.file(
                          selectedPhoto,
                          width: diameter,
                          height: diameter,
                          fit: BoxFit.cover,
                        ),
                      ),
              ),
              if (selectedPhoto != null)
                const Positioned(
                  left: editBadgeLeft,
                  top: editBadgeTop,
                  child: EditPhotoBadgeIcon(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Asks the user where the profile photo should come from.
///
/// Shows an iOS action sheet on iPhone and a bottom sheet on Android.
/// Returns `null` when the user cancels.
Future<ImageSource?> showPhotoSourcePicker(BuildContext context) {
  const String takePhotoLabel = 'Take photo';
  const String chooseFromGalleryLabel = 'Choose from gallery';

  if (Theme.of(context).platform == TargetPlatform.iOS) {
    return showCupertinoModalPopup<ImageSource>(
      context: context,
      builder: (sheetContext) => CupertinoActionSheet(
        title: const Text('Profile photo'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheetContext, ImageSource.camera),
            child: const Text(takePhotoLabel),
          ),
          CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(sheetContext, ImageSource.gallery),
            child: const Text(chooseFromGalleryLabel),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(sheetContext),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  const TextStyle optionTextStyle = TextStyle(
    fontFamily: AppTextStyles.fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.bodyText,
  );

  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: AppColors.pageBackground,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.photo_camera_outlined,
                color: AppColors.brandPurple,
              ),
              title: const Text(takePhotoLabel, style: optionTextStyle),
              onTap: () => Navigator.pop(sheetContext, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_outlined,
                color: AppColors.brandPurple,
              ),
              title: const Text(chooseFromGalleryLabel, style: optionTextStyle),
              onTap: () => Navigator.pop(sheetContext, ImageSource.gallery),
            ),
          ],
        ),
      ),
    ),
  );
}
