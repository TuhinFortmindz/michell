import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Thin left chevron used as the header back button (7.5 x 13.5 px).
class BackChevronIcon extends StatelessWidget {
  const BackChevronIcon({super.key});

  static const Size iconSize = Size(7.5, 13.5);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: iconSize,
      painter: _PolylinePainter(
        points: const [Offset(6.75, 0.75), Offset(0.75, 6.75), Offset(6.75, 12.75)],
        color: AppColors.brandPurple,
        strokeWidth: 1.5,
      ),
    );
  }
}

/// Small down chevron shown before the country code (11.25 x 6.5 px).
class ChevronDownIcon extends StatelessWidget {
  const ChevronDownIcon({super.key});

  static const Size iconSize = Size(11.25, 6.5);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: iconSize,
      painter: _PolylinePainter(
        points: const [Offset(0.75, 0.75), Offset(5.625, 5.75), Offset(10.5, 0.75)],
        color: AppColors.brandPurple,
        strokeWidth: 1.5,
      ),
    );
  }
}

/// Outlined eye drawn in a 20 x 20 px box. When [isCrossedOut] is true a
/// slash is added to show that the password is visible.
class EyeIcon extends StatelessWidget {
  const EyeIcon({super.key, this.isCrossedOut = false});

  static const double boxSize = 20;

  final bool isCrossedOut;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(boxSize),
      painter: _EyePainter(isCrossedOut: isCrossedOut),
    );
  }
}

/// White "camera with plus" outline drawn in a 48 x 48 px box.
class CameraPlusIcon extends StatelessWidget {
  const CameraPlusIcon({super.key});

  static const double boxSize = 48;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size.square(boxSize),
      painter: _CameraPlusPainter(),
    );
  }
}

/// UAE flag with rounded corners (20 x 14 px).
class UaeFlagIcon extends StatelessWidget {
  const UaeFlagIcon({super.key});

  static const Size flagSize = Size(20, 14);
  static const double cornerRadius = 2.5;
  static const double redBarWidth = 4.375;
  static const double greenStripeBottom = 5;
  static const double whiteStripeBottom = 9;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(cornerRadius),
      child: CustomPaint(size: flagSize, painter: _UaeFlagPainter()),
    );
  }
}

class _PolylinePainter extends CustomPainter {
  const _PolylinePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final Path path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final Offset point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, _roundStroke(color, strokeWidth));
  }

  @override
  bool shouldRepaint(_PolylinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
}

class _EyePainter extends CustomPainter {
  const _EyePainter({required this.isCrossedOut});

  final bool isCrossedOut;

  /// The eye is drawn on a 24-unit grid and scaled into the 20 px box.
  static const double gridSize = 24;
  static const double strokeWidth = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / gridSize;
    final Paint stroke = _roundStroke(AppColors.hintGrey, strokeWidth / scale);

    canvas.save();
    canvas.scale(scale);

    canvas.drawCircle(const Offset(12, 12), 2, stroke);

    final Path eyeOutline = Path()
      ..moveTo(21, 12)
      ..relativeCubicTo(-2.4, 4, -5.4, 6, -9, 6)
      ..relativeCubicTo(-3.6, 0, -6.6, -2, -9, -6)
      ..relativeCubicTo(2.4, -4, 5.4, -6, 9, -6)
      ..relativeCubicTo(3.6, 0, 6.6, 2, 9, 6);
    canvas.drawPath(eyeOutline, stroke);

    if (isCrossedOut) {
      canvas.drawLine(const Offset(4, 4), const Offset(20, 20), stroke);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_EyePainter oldDelegate) =>
      oldDelegate.isCrossedOut != isCrossedOut;
}

class _CameraPlusPainter extends CustomPainter {
  /// The camera is drawn on a 24-unit grid and scaled into the 48 px box.
  static const double gridSize = 24;
  static const double strokeWidth = 3.5;

  @override
  void paint(Canvas canvas, Size size) {
    final double scale = size.width / gridSize;
    final Paint stroke = _roundStroke(AppColors.buttonText, strokeWidth / scale);
    const Radius cornerRadius = Radius.circular(2);
    const Radius lensBumpRadius = Radius.circular(1);

    canvas.save();
    canvas.scale(scale);

    final Path cameraBody = Path()
      ..moveTo(12, 20)
      ..relativeLineTo(-7, 0)
      ..relativeArcToPoint(const Offset(-2, -2), radius: cornerRadius)
      ..relativeLineTo(0, -9)
      ..relativeArcToPoint(const Offset(2, -2), radius: cornerRadius)
      ..relativeLineTo(1, 0)
      ..relativeArcToPoint(const Offset(2, -2), radius: cornerRadius, clockwise: false)
      ..relativeArcToPoint(const Offset(1, -1), radius: lensBumpRadius)
      ..relativeLineTo(6, 0)
      ..relativeArcToPoint(const Offset(1, 1), radius: lensBumpRadius)
      ..relativeArcToPoint(const Offset(2, 2), radius: cornerRadius, clockwise: false)
      ..relativeLineTo(1, 0)
      ..relativeArcToPoint(const Offset(2, 2), radius: cornerRadius)
      ..relativeLineTo(0, 3.5);
    canvas.drawPath(cameraBody, stroke);

    canvas.drawCircle(const Offset(12, 13), 3, stroke);

    canvas.drawLine(const Offset(16, 19), const Offset(22, 19), stroke);
    canvas.drawLine(const Offset(19, 16), const Offset(19, 22), stroke);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CameraPlusPainter oldDelegate) => false;
}

class _UaeFlagPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double stripesLeft = UaeFlagIcon.redBarWidth;

    canvas.drawRect(
      Rect.fromLTRB(stripesLeft, 0, size.width, UaeFlagIcon.greenStripeBottom),
      Paint()..color = AppColors.uaeFlagGreen,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        stripesLeft,
        UaeFlagIcon.greenStripeBottom,
        size.width,
        UaeFlagIcon.whiteStripeBottom,
      ),
      Paint()..color = AppColors.uaeFlagWhite,
    );
    canvas.drawRect(
      Rect.fromLTRB(
        stripesLeft,
        UaeFlagIcon.whiteStripeBottom,
        size.width,
        size.height,
      ),
      Paint()..color = AppColors.uaeFlagBlack,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, stripesLeft, size.height),
      Paint()..color = AppColors.uaeFlagRed,
    );
  }

  @override
  bool shouldRepaint(_UaeFlagPainter oldDelegate) => false;
}

Paint _roundStroke(Color color, double strokeWidth) {
  return Paint()
    ..color = color
    ..style = PaintingStyle.stroke
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;
}
