import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'core/theme/app_colors.dart';
import 'core/theme/app_text_styles.dart';
import 'core/widgets/design_width_scaler.dart';
import 'features/profile/presentation/pages/create_account_page.dart';

/// Width of the Figma frame the UI was designed on.
const double figmaFrameWidth = 375;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MichellApp());
}

class MichellApp extends StatelessWidget {
  const MichellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Create an account',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: AppTextStyles.fontFamily,
        scaffoldBackgroundColor: AppColors.pageBackground,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.brandPurple),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: AppColors.brandPurple,
          selectionHandleColor: AppColors.brandPurple,
        ),
      ),
      builder: (context, child) => DesignWidthScaler(
        designWidth: figmaFrameWidth,
        child: child ?? const SizedBox.shrink(),
      ),
      home: const CreateAccountPage(),
    );
  }
}
