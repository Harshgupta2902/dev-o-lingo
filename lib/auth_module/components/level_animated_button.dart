import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:lingolearn/utilities/enums.dart';

class LevelAnimatedButton extends StatefulWidget {
  final Widget child;
  final bool isPressed;
  final double? width;
  final double height;
  final Size? minimumSize;
  final Size? maximumSize;
  final double buttonHeight;
  final double borderRadius;
  final Color? buttonColor;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? disabledForegroundColor;
  final Color? disabledBackgroundColor;
  final ButtonTypes buttonType;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final InteractiveInkFeatureFactory? splashFactory;
  const LevelAnimatedButton({
    super.key,
    this.onPressed,
    this.padding,
    this.width,
    this.height = 50,
    this.minimumSize,
    this.maximumSize,
    this.isPressed = false,
    this.buttonHeight = 4,
    this.borderRadius = 16,
    this.buttonColor,
    this.foregroundColor = Colors.white,
    this.backgroundColor,
    this.disabledForegroundColor,
    this.disabledBackgroundColor,
    this.splashFactory = NoSplash.splashFactory,
    this.buttonType = ButtonTypes.roundedRectangle,
    required this.child,
  });
  @override
  State<LevelAnimatedButton> createState() => _LevelAnimatedButtonState();
}

class _LevelAnimatedButtonState extends State<LevelAnimatedButton>
    with SingleTickerProviderStateMixin {
  late bool _isPressed = widget.isPressed;
  static const Duration duration = Duration(milliseconds: 80);
  @override
  Widget build(BuildContext context) {
    bool isDisabled = widget.onPressed == null;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: LevelButton(
        onPressed: !isDisabled ? _handleButtonPress : null,
        padding: widget.padding,
        width: widget.width,
        height: widget.height,
        minimumSize: widget.minimumSize,
        maximumSize: widget.maximumSize,
        isPressed: isDisabled ? true : _isPressed,
        buttonHeight: widget.buttonHeight,
        borderRadius: widget.borderRadius,
        buttonColor: widget.buttonColor,
        foregroundColor: widget.foregroundColor,
        backgroundColor: widget.backgroundColor,
        disabledForegroundColor: widget.disabledForegroundColor,
        disabledBackgroundColor: widget.disabledBackgroundColor,
        splashFactory: widget.splashFactory,
        buttonType: widget.buttonType,
        child: widget.child,
      ),
    );
  }

  Future<void> _handleButtonPress() async {
    setState(() {
      _isPressed = true;
    });
    await Future.delayed(duration, () {
      setState(() {
        _isPressed = false;
        if (widget.onPressed != null) {
          widget.onPressed!();
        }
      });
    });
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }
}

class LevelButton extends StatelessWidget {
  final Widget child;
  final bool isPressed;
  final double? width;
  final double height;
  final Size? minimumSize;
  final Size? maximumSize;
  final double buttonHeight;
  final double borderRadius;
  final Color? buttonColor;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? disabledForegroundColor;
  final Color? disabledBackgroundColor;
  final ButtonTypes buttonType;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry? padding;
  final InteractiveInkFeatureFactory? splashFactory;
  const LevelButton({
    super.key,
    ButtonPositions? buttonPosition,
    this.onPressed,
    this.padding,
    this.width,
    this.height = 50,
    this.minimumSize,
    this.maximumSize,
    this.isPressed = false,
    this.buttonHeight = 4,
    this.borderRadius = 16,
    this.buttonColor,
    this.foregroundColor = Colors.white,
    this.backgroundColor,
    this.disabledForegroundColor,
    this.disabledBackgroundColor,
    this.splashFactory = NoSplash.splashFactory,
    this.buttonType = ButtonTypes.roundedRectangle,
    required this.child,
  });

  Color _shadeColor(Color color, double factor) => Color.fromRGBO(
      math.max(0, color.red - (color.red * factor).round()),
      math.max(0, color.green - (color.green * factor).round()),
      math.max(0, color.blue - (color.blue * factor).round()),
      1);

  Color _tintColor(Color color, double factor) => Color.fromRGBO(
      math.min(255, color.red + (color.red * factor).round()),
      math.min(255, color.green + (color.green * factor).round()),
      math.min(255, color.blue + (color.blue * factor).round()),
      1);

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null;
    final baseColor = backgroundColor ?? Theme.of(context).colorScheme.primary;
    final bottomColor = _shadeColor(baseColor, 0.2);
    final topGradientStart = _tintColor(baseColor, 0.2);
    final topGradientEnd = baseColor;

    final double actualHeight = height;
    final double actualWidth = width ?? height;

    final double currentHeight =
        (isPressed || isDisabled) ? actualHeight : actualHeight + buttonHeight;
    final double currentTopMargin =
        (isPressed || isDisabled) ? buttonHeight : 0;

    final BorderRadiusGeometry buttonBorderRadius =
        buttonType == ButtonTypes.circle
            ? BorderRadius.circular(actualHeight / 2) // Perfect circle
            : BorderRadius.circular(borderRadius);

    return Container(
      width: actualWidth,
      height: currentHeight,
      margin: EdgeInsets.only(top: currentTopMargin),
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: actualHeight,
            child: Container(
              decoration: BoxDecoration(
                color: bottomColor,
                borderRadius: buttonBorderRadius,
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: actualHeight,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [topGradientStart, topGradientEnd],
                ),
                borderRadius: buttonBorderRadius,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: baseColor.withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: onPressed,
                  child: Center(
                    child: DefaultTextStyle(
                      style: TextStyle(color: foregroundColor),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LevelButtonTypes {
  static ButtonTypes get roundedRectangle => ButtonTypes.roundedRectangle;

  static ButtonTypes get circle => ButtonTypes.circle;

  static ButtonTypes get oval => ButtonTypes.oval;
}

class LevelSegmentedButtonPositions {
  static ButtonPositions get start => ButtonPositions.start;

  static ButtonPositions get between => ButtonPositions.between;

  static ButtonPositions get end => ButtonPositions.end;
}

// Custom painter for zigzag path segments
class ZigzagSegmentPainter extends CustomPainter {
  final double startX;
  final double endX;
  final double nodeSize;
  final double verticalSpacing;

  ZigzagSegmentPainter({
    required this.startX,
    required this.endX,
    required this.nodeSize,
    required this.verticalSpacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.3)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Start point of the line segment (center of previous node)
    final p1 = Offset(startX, nodeSize / 2);
    // End point of the line segment (center of next node, relative to this segment's height)
    final p2 = Offset(endX, verticalSpacing - (nodeSize / 2));

    path.moveTo(p1.dx, p1.dy);

    // Create smooth S-curve for zigzag
    final controlY = p1.dy + (p2.dy - p1.dy) / 2;
    path.cubicTo(
      p1.dx,
      controlY,
      p2.dx,
      controlY,
      p2.dx,
      p2.dy,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
