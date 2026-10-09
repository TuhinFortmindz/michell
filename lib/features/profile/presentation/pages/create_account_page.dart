import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileNumberController = TextEditingController();
  final TextEditingController _alternativeMobileNumberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _isPasswordHidden = true;
  bool _isConfirmPasswordHidden = true;
  bool _hasAcceptedTerms = false;

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
      _requiredFieldControllers.every((controller) => controller.text.trim().isNotEmpty,);

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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: AppColors.navigationBar,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
      child: Scaffold(
        backgroundColor: AppColors.pageBackground,
        body: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  top: topSpace,
                  bottom: _CreateAccountLayout.gapBelowSubmitButton +
                      systemPadding.bottom,
                ),
                child: _buildForm(context),
              ),
            ),
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

  Widget _buildForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SignUpHeader(
          title: 'Create an account',
          onBackTap: () => Navigator.of(context).maybePop(),
        ),
        const ProfilePhotoPicker(),
        const SizedBox(height: _CreateAccountLayout.gapAfterProfilePhoto),
        Padding(
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
                  const SizedBox(
                    width: _CreateAccountLayout.gapBetweenNameFields,
                  ),
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
                text: 'This mobile number will be used for you to Sign In\n'
                    'and will allow us to call you upon your request',
              ),
              SignUpPhoneField(
                controller: _mobileNumberController,
                hintText: '* Mobile number (ex: 50*******)',
              ),
              const _HelperTextBlock(
                text: 'Do you have an alternative mobile number for messaging?\n'
                    '(WhatsApp or Telegram)',
              ),
              SignUpPhoneField(
                controller: _alternativeMobileNumberController,
                hintText: 'Mobile number (optional)',
                showCountryPickerArrow: true,
              ),
              const SizedBox(height: _CreateAccountLayout.gapBetweenFields),
              SignUpTextField(
                controller: _emailController,
                hintText: '* Email address',
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
              const SizedBox(
                height: _CreateAccountLayout.gapBetweenPasswordFields,
              ),
              SignUpPasswordField(
                controller: _confirmPasswordController,
                hintText: '* Confirm password',
                isPasswordHidden: _isConfirmPasswordHidden,
                textInputAction: TextInputAction.done,
                onVisibilityToggle: () => setState(
                  () => _isConfirmPasswordHidden = !_isConfirmPasswordHidden,
                ),
              ),
              const SizedBox(
                height: _CreateAccountLayout.gapAfterConfirmPassword,
              ),
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
        ),
      ],
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
