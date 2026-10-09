import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/input_validators.dart';
import '../widgets/consent_checkbox_row.dart';
import '../widgets/pill_submit_button.dart';
import '../widgets/profile_photo_picker.dart';
import '../widgets/sign_up_header.dart';
import '../widgets/sign_up_text_fields.dart';

/// Sign-up screen ("Create an account").
///
/// Every size below is in Figma px on a 375 px wide frame; the whole app is
/// rendered on a 375 px wide canvas by `DesignWidthScaler`, so these values
/// stay proportionally identical on every device.
class CreateAccountPage extends StatefulWidget {
  const CreateAccountPage({super.key});

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();
}

abstract final class _CreateAccountLayout {
  /// Height of the status bar in the Figma frame.
  static const double statusBarHeight = 44;
  static const double pageSidePadding = 20;

  static const double nameFieldWidth = 157;
  static const double gapBetweenNameFields = 21;

  /// Helper text blocks sit between two fields; the first line's baseline is
  /// this far below the field above.
  static const double helperTextBlockHeight = 52;
  static const double helperTextFirstBaseline = 28;

  static const double gapAfterProfilePhoto = 15;
  static const double gapBetweenFields = 15;
  static const double gapBetweenPasswordFields = 5;
  static const double gapAfterConfirmPassword = 19;

  /// Space between the button and the system navigation bar.
  static const double gapBelowSubmitButton = 20;

  /// Android's 3-button navigation bar is 48 dp tall, gesture navigation only
  /// ~16-24 dp. A bottom inset at least this tall (Figma px) means buttons.
  static const double minButtonNavigationBarHeight = 32;
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _alternativeMobileNumberController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _hasAcceptedTerms = false;

  final ImagePicker _imagePicker = ImagePicker();
  File? _profilePhoto;

  late final List<TextEditingController> _requiredFieldControllers = [
    _firstNameController,
    _lastNameController,
    _mobileNumberController,
    _emailController,
    _passwordController,
    _confirmPasswordController,
  ];

  bool get _canCreateAccount =>
      _hasAcceptedTerms &&
      _requiredFieldControllers.every(
        (controller) => controller.text.trim().isNotEmpty,
      ) &&
      InputValidators.isValidUaeMobileNumber(_mobileNumberController.text) &&
      InputValidators.isValidEmail(_emailController.text);

  @override
  void initState() {
    super.initState();
    for (final TextEditingController controller in _requiredFieldControllers) {
      controller.addListener(_onRequiredFieldChanged);
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileNumberController.dispose();
    _alternativeMobileNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onRequiredFieldChanged() => setState(() {});

  Future<void> _onProfilePhotoTap() async {
    FocusScope.of(context).unfocus();
    final ImageSource? photoSource = await showPhotoSourcePicker(context);
    if (photoSource == null) return;

    try {
      final XFile? pickedPhoto = await _imagePicker.pickImage(
        source: photoSource,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      if (pickedPhoto == null || !mounted) return;
      setState(() => _profilePhoto = File(pickedPhoto.path));
    } on PlatformException {
      if (!mounted) return;
      final String sourceName = photoSource == ImageSource.camera
          ? 'camera'
          : 'photo library';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not open the $sourceName. '
            'Please allow access in your device settings.',
          ),
        ),
      );
    }
  }

  void _onCreateAccountPressed() {
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final EdgeInsets systemPadding = MediaQuery.paddingOf(context);
    final double topSpace = math.max(
      _CreateAccountLayout.statusBarHeight,
      systemPadding.top,
    );

    // Only Android's 3-button navigation bar gets the grey Figma background.
    // iPhones (home indicator) and Android gesture navigation stay white.
    final bool hasButtonNavigationBar =
        defaultTargetPlatform == TargetPlatform.android &&
        systemPadding.bottom >=
            _CreateAccountLayout.minButtonNavigationBarHeight;

    // Figma keeps 20 px between the button and the navigation bar. A button
    // bar needs that gap above it; the iPhone home indicator and Android
    // gesture bar are thin lines at the very bottom, so 20 px from the screen
    // edge already clears them.
    final double bottomSpace =
        _CreateAccountLayout.gapBelowSubmitButton +
        (hasButtonNavigationBar ? systemPadding.bottom : 0);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fixed part: never scrolls.
                SizedBox(height: topSpace),
                SignUpHeader(
                  title: 'Create an account',
                  onBackTap: () => Navigator.of(context).maybePop(),
                ),
                ProfilePhotoPicker(
                  photoFile: _profilePhoto,
                  onTap: _onProfilePhotoTap,
                ),
                const SizedBox(
                  height: _CreateAccountLayout.gapAfterProfilePhoto,
                ),
                // Form: scrolls only when it is taller than the space left.
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    // Keep the keyboard open while scrolling to the next
                    // field.
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.manual,
                    padding: EdgeInsets.only(bottom: bottomSpace),
                    child: _buildForm(),
                  ),
                ),
              ],
            ),
            if (hasButtonNavigationBar)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: systemPadding.bottom,
                child: const ColoredBox(color: AppColors.navigationBar),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _CreateAccountLayout.pageSidePadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(
                width: _CreateAccountLayout.nameFieldWidth,
                child: SignUpTextField(
                  controller: _firstNameController,
                  hintText: '* First name',
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.givenName],
                ),
              ),
              const SizedBox(width: _CreateAccountLayout.gapBetweenNameFields),
              SizedBox(
                width: _CreateAccountLayout.nameFieldWidth,
                child: SignUpTextField(
                  controller: _lastNameController,
                  hintText: '* Last name',
                  keyboardType: TextInputType.name,
                  textCapitalization: TextCapitalization.words,
                  autofillHints: const [AutofillHints.familyName],
                ),
              ),
            ],
          ),
          const _HelperTextBlock(
            text:
                'This mobile number will be used for you to Sign In\n'
                'and will allow us to call you upon your request',
          ),
          SignUpPhoneField(
            controller: _mobileNumberController,
            hintText: '* Mobile number (ex: 50*******)',
            floatingLabelText: '* Mobile number',
          ),
          const _HelperTextBlock(
            text:
                'Do you have an alternative mobile number for messaging?\n'
                '(WhatsApp or Telegram)',
          ),
          SignUpPhoneField(
            controller: _alternativeMobileNumberController,
            hintText: 'Mobile number (optional)',
            showCountryPickerArrow: true,
            verifiedTickTop:
                SignUpFieldMetrics.alternativeMobileVerifiedTickTop,
          ),
          const SizedBox(height: _CreateAccountLayout.gapBetweenFields),
          SignUpTextField(
            controller: _emailController,
            hintText: '* Email address',
            showVerifiedTickWhen: InputValidators.isValidEmail,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: _CreateAccountLayout.gapBetweenFields),
          SignUpPasswordField(
            controller: _passwordController,
            hintText: '* Password',
            isPasswordHidden: _isPasswordHidden,
            onVisibilityToggle: () =>
                setState(() => _isPasswordHidden = !_isPasswordHidden),
          ),
          const SizedBox(height: _CreateAccountLayout.gapBetweenPasswordFields),
          SignUpPasswordField(
            controller: _confirmPasswordController,
            hintText: '* Confirm password',
            isPasswordHidden: _isConfirmPasswordHidden,
            textInputAction: TextInputAction.done,
            onVisibilityToggle: () => setState(
              () => _isConfirmPasswordHidden = !_isConfirmPasswordHidden,
            ),
          ),
          const SizedBox(height: _CreateAccountLayout.gapAfterConfirmPassword),
          ConsentCheckboxRow(
            isChecked: _hasAcceptedTerms,
            onChanged: (isChecked) =>
                setState(() => _hasAcceptedTerms = isChecked),
          ),
          PillSubmitButton(
            label: 'Create my account',
            isEnabled: _canCreateAccount,
            onPressed: _onCreateAccountPressed,
          ),
        ],
      ),
    );
  }
}

/// Centred grey 12 px text placed between two fields.
class _HelperTextBlock extends StatelessWidget {
  const _HelperTextBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _CreateAccountLayout.helperTextBlockHeight,
      child: Align(
        alignment: Alignment.topCenter,
        child: Baseline(
          baseline: _CreateAccountLayout.helperTextFirstBaseline,
          baselineType: TextBaseline.alphabetic,
          child: Text(
            text,
            style: AppTextStyles.helperText,
            textAlign: TextAlign.center,
            softWrap: false,
          ),
        ),
      ),
    );
  }
}
