import 'package:flutter/material.dart';

/// Lays out [child] on a canvas that is always [designWidth] logical pixels
/// wide and scales it to fill the real screen width.
///
/// Every padding and size written in Figma units therefore keeps exactly the
/// same proportion on every device: a screenshot scaled to [designWidth]
/// overlaps the Figma frame 1:1. The system text scale is ignored for the
/// same reason.
class DesignWidthScaler extends StatelessWidget {
  const DesignWidthScaler({
    super.key,
    required this.designWidth,
    required this.child,
  });

  final double designWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final MediaQueryData realMediaQuery = MediaQuery.of(context);
    final Size realScreenSize = realMediaQuery.size;
    if (realScreenSize.width <= 0 || realScreenSize.height <= 0) {
      return child;
    }

    final double scaleFactor = realScreenSize.width / designWidth;
    final Size designScreenSize = realScreenSize / scaleFactor;

    final MediaQueryData designMediaQuery = realMediaQuery.copyWith(
      size: designScreenSize,
      devicePixelRatio: realMediaQuery.devicePixelRatio * scaleFactor,
      padding: realMediaQuery.padding / scaleFactor,
      viewPadding: realMediaQuery.viewPadding / scaleFactor,
      viewInsets: realMediaQuery.viewInsets / scaleFactor,
      systemGestureInsets: realMediaQuery.systemGestureInsets / scaleFactor,
      textScaler: TextScaler.noScaling,
    );

    return MediaQuery(
      data: designMediaQuery,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: designScreenSize.width,
          height: designScreenSize.height,
          child: child,
        ),
      ),
    );
  }
}
