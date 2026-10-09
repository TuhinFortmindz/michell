import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:michell/features/profile/presentation/widgets/profile_photo_picker.dart';
import 'package:michell/main.dart';

Future<void> _loadManropeFonts() async {
  final FontLoader manrope = FontLoader('Manrope');
  for (final String weight in ['Regular', 'Medium', 'SemiBold', 'Bold']) {
    final Uint8List bytes = File(
      'assets/fonts/Manrope-$weight.ttf',
    ).readAsBytesSync();
    manrope.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await manrope.load();

  // The back arrow is a CupertinoIcons glyph.
  final String cupertinoFontPath =
      '${Platform.environment['HOME']}/.pub-cache/hosted/pub.dev/'
      'cupertino_icons-1.0.9/assets/CupertinoIcons.ttf';
  if (File(cupertinoFontPath).existsSync()) {
    final FontLoader cupertinoIcons =
        FontLoader('packages/cupertino_icons/CupertinoIcons')..addFont(
          Future.value(
            ByteData.sublistView(File(cupertinoFontPath).readAsBytesSync()),
          ),
        );
    await cupertinoIcons.load();
  }
}

void main() {
  testWidgets('Create account page renders on the Figma frame size', (
    WidgetTester tester,
  ) async {
    await _loadManropeFonts();

    // Figma frame: 375 x 844, exported at 4x.
    tester.view.devicePixelRatio = 4;
    tester.view.physicalSize = const Size(375 * 4, 844 * 4);
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const MichellApp());
    // PNG assets decode asynchronously; load them before checking the frame.
    await tester.runAsync(() async {
      for (final Element image in find.byType(Image).evaluate()) {
        await precacheImage((image.widget as Image).image, image);
      }
    });
    await tester.pumpAndSettle();

    expect(find.text('Create an account'), findsOneWidget);
    expect(find.text('Create my account'), findsOneWidget);

    final String? screenshotPath =
        Platform.environment['CREATE_ACCOUNT_SCREENSHOT'];
    if (screenshotPath != null) {
      await tester.runAsync(() async {
        RenderObject renderObject = tester.renderObject(find.byType(Scaffold));
        while (!renderObject.isRepaintBoundary) {
          renderObject = renderObject.parent!;
        }
        final OffsetLayer layer = renderObject.debugLayer! as OffsetLayer;
        final ui.Image image = await layer.toImage(
          renderObject.paintBounds,
          pixelRatio: 4,
        );
        final ByteData? png = await image.toByteData(
          format: ui.ImageByteFormat.png,
        );
        File(screenshotPath).writeAsBytesSync(png!.buffer.asUint8List());
      });
    }
  });

  testWidgets('Tapping the profile photo offers camera and gallery', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MichellApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byType(ProfilePhotoPicker));
    await tester.pumpAndSettle();

    expect(find.text('Take photo'), findsOneWidget);
    expect(find.text('Choose from gallery'), findsOneWidget);
  });

  testWidgets('Keyboard stays open while typing into every field', (
    WidgetTester tester,
  ) async {
    tester.view.devicePixelRatio = 3;
    tester.view.physicalSize = const Size(393 * 3, 852 * 3);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const MichellApp());
    await tester.pumpAndSettle();

    final Finder textFields = find.byType(TextField);
    for (int index = 0; index < textFields.evaluate().length; index++) {
      await tester.ensureVisible(textFields.at(index));
      await tester.pumpAndSettle();
      await tester.tap(textFields.at(index));
      await tester.pump();

      String typedText = '';
      for (final String character in ['5', '0', '1']) {
        typedText += character;
        tester.testTextInput.updateEditingValue(
          TextEditingValue(
            text: typedText,
            selection: TextSelection.collapsed(offset: typedText.length),
          ),
        );
        await tester.pump();

        final EditableTextState editableText = tester.state(
          find.descendant(
            of: textFields.at(index),
            matching: find.byType(EditableText),
          ),
        );
        expect(editableText.widget.focusNode.hasFocus, isTrue);
        expect(tester.testTextInput.isVisible, isTrue);
        expect(editableText.textEditingValue.text, typedText);
      }
    }
  });
}
