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

/// Reasons "Create my account" is still disabled, in the order of the form.
enum _SignUpProblem {
  firstNameMissing('Enter your first name'),
  lastNameMissing('Enter your last name'),
  mobileNumberInvalid('Enter a 9-digit mobile number'),
  alternativeMobileNumberInvalid(
    'The alternative mobile number must have 9 digits',
  ),
  emailInvalid('Enter a valid email address'),
  passwordMissing('Enter a password'),
  confirmPasswordMissing('Confirm your password'),
  passwordsDoNotMatch('Passwords do not match'),
  termsNotAccepted('Tick the box to accept the policies');

  const _SignUpProblem(this.message);

  final String message;
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

  /// Becomes true the first time the disabled button is pressed; from then on
  /// fields that block the button are underlined in red until fixed.
  bool _showsFieldErrors = false;

  // Used to scroll to the first field that needs fixing.
  final GlobalKey _nameFieldsKey = GlobalKey();
  final GlobalKey _mobileNumberFieldKey = GlobalKey();
  final GlobalKey _alternativeMobileNumberFieldKey = GlobalKey();
  final GlobalKey _emailFieldKey = GlobalKey();
  final GlobalKey _passwordFieldKey = GlobalKey();
  final GlobalKey _confirmPasswordFieldKey = GlobalKey();
  final GlobalKey _consentRowKey = GlobalKey();

  late final List<TextEditingController> _allFieldControllers = [
    _firstNameController,
    _lastNameController,
    _mobileNumberController,
    _alternativeMobileNumberController,
    _emailController,
    _passwordController,
    _confirmPasswordController,
  ];

  List<_SignUpProblem> get _problems {
    final String alternativeMobileNumber =
        _alternativeMobileNumberController.text;
    final String password = _passwordController.text;
    final String confirmPassword = _confirmPasswordController.text;

    return [
      if (_firstNameController.text.trim().isEmpty)
        _SignUpProblem.firstNameMissing,
      if (_lastNameController.text.trim().isEmpty)
        _SignUpProblem.lastNameMissing,
      if (!InputValidators.isValidUaeMobileNumber(_mobileNumberController.text))
        _SignUpProblem.mobileNumberInvalid,
      if (alternativeMobileNumber.isNotEmpty &&
          !InputValidators.isValidUaeMobileNumber(alternativeMobileNumber))
        _SignUpProblem.alternativeMobileNumberInvalid,
      if (!InputValidators.isValidEmail(_emailController.text))
        _SignUpProblem.emailInvalid,
      if (password.isEmpty) _SignUpProblem.passwordMissing,
      if (confirmPassword.isEmpty) _SignUpProblem.confirmPasswordMissing,
      if (password.isNotEmpty &&
          confirmPassword.isNotEmpty &&
          password != confirmPassword)
        _SignUpProblem.passwordsDoNotMatch,
      if (!_hasAcceptedTerms) _SignUpProblem.termsNotAccepted,
    ];
  }

  /// True when [problem] should currently be shown as a red underline.
  bool _showsError(List<_SignUpProblem> problems, _SignUpProblem problem) =>
      _showsFieldErrors && problems.contains(problem);

  GlobalKey _fieldKeyFor(_SignUpProblem problem) => switch (problem) {
    _SignUpProblem.firstNameMissing ||
    _SignUpProblem.lastNameMissing => _nameFieldsKey,
    _SignUpProblem.mobileNumberInvalid => _mobileNumberFieldKey,
    _SignUpProblem.alternativeMobileNumberInvalid =>
      _alternativeMobileNumberFieldKey,
    _SignUpProblem.emailInvalid => _emailFieldKey,
    _SignUpProblem.passwordMissing => _passwordFieldKey,
    _SignUpProblem.confirmPasswordMissing ||
    _SignUpProblem.passwordsDoNotMatch => _confirmPasswordFieldKey,
    _SignUpProblem.termsNotAccepted => _consentRowKey,
  };

  @override
  void initState() {
    super.initState();
    for (final TextEditingController controller in _allFieldControllers) {
      controller.addListener(_onFieldChanged);
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

  void _onFieldChanged() => setState(() {});

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

  /// The grey button was pressed: underline the blocking fields in red, list
  /// what is missing and scroll to the first field that needs fixing.
  void _onDisabledCreateAccountPressed() {
    final List<_SignUpProblem> problems = _problems;
    if (problems.isEmpty) return;

    FocusScope.of(context).unfocus();
    setState(() => _showsFieldErrors = true);

    final BuildContext? firstProblemField = _fieldKeyFor(
      problems.first,
    ).currentContext;
    if (firstProblemField != null) {
      Scrollable.ensureVisible(
        firstProblemField,
        alignment: 0.2,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.bodyText,
        content: Text(
          [
            'Please complete the following:',
            for (final _SignUpProblem problem in problems)
              '•  ${problem.message}',
          ].join('\n'),
          style: AppTextStyles.snackBarMessage,
        ),
      ),
    );
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
    final List<_SignUpProblem> problems = _problems;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _CreateAccountLayout.pageSidePadding,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            key: _nameFieldsKey,
            children: [
              SizedBox(
                width: _CreateAccountLayout.nameFieldWidth,
                child: SignUpTextField(
                  hasError: _showsError(
                    problems,
                    _SignUpProblem.firstNameMissing,
                  ),
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
                  hasError: _showsError(
                    problems,
                    _SignUpProblem.lastNameMissing,
                  ),
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
            key: _mobileNumberFieldKey,
            hasError: _showsError(problems, _SignUpProblem.mobileNumberInvalid),
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
            key: _alternativeMobileNumberFieldKey,
            hasError: _showsError(
              problems,
              _SignUpProblem.alternativeMobileNumberInvalid,
            ),
            controller: _alternativeMobileNumberController,
            hintText: 'Mobile number (optional)',
            showCountryPickerArrow: true,
            verifiedTickTop:
                SignUpFieldMetrics.alternativeMobileVerifiedTickTop,
          ),
          const SizedBox(height: _CreateAccountLayout.gapBetweenFields),
          SignUpTextField(
            key: _emailFieldKey,
            hasError: _showsError(problems, _SignUpProblem.emailInvalid),
            controller: _emailController,
            hintText: '* Email address',
            showVerifiedTickWhen: InputValidators.isValidEmail,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: _CreateAccountLayout.gapBetweenFields),
          SignUpPasswordField(
            key: _passwordFieldKey,
            hasError: _showsError(problems, _SignUpProblem.passwordMissing),
            controller: _passwordController,
            hintText: '* Password',
            isPasswordHidden: _isPasswordHidden,
            onVisibilityToggle: () =>
                setState(() => _isPasswordHidden = !_isPasswordHidden),
          ),
          const SizedBox(height: _CreateAccountLayout.gapBetweenPasswordFields),
          SignUpPasswordField(
            key: _confirmPasswordFieldKey,
            hasError:
                _showsError(problems, _SignUpProblem.confirmPasswordMissing) ||
                _showsError(problems, _SignUpProblem.passwordsDoNotMatch),
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
            key: _consentRowKey,
            hasError: _showsError(problems, _SignUpProblem.termsNotAccepted),
            isChecked: _hasAcceptedTerms,
            onChanged: (isChecked) =>
                setState(() => _hasAcceptedTerms = isChecked),
          ),
          PillSubmitButton(
            label: 'Create my account',
            isEnabled: problems.isEmpty,
            onPressed: _onCreateAccountPressed,
            onDisabledPressed: _onDisabledCreateAccountPressed,
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
