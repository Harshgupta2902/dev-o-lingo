import 'package:flutter/material.dart';
import 'package:lingolearn/utilities/constants/assets_path.dart';
import 'package:lingolearn/utilities/theme/app_box_decoration.dart';

enum TriangleDirection { top, bottom, left, right }

class PolygonTextBox extends StatelessWidget {
  const PolygonTextBox({
    super.key,
    required this.title,
    this.direction = TriangleDirection.right,
    this.offset = 30,
    required this.borderRadius,
  });

  final String title;
  final TriangleDirection direction;
  final double offset;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final triangle = Positioned(
      top: direction == TriangleDirection.top
          ? -10
          : (direction == TriangleDirection.left ||
                  direction == TriangleDirection.right)
              ? offset
              : null,
      bottom: direction == TriangleDirection.bottom ? -10 : null,
      left: direction == TriangleDirection.left
          ? -20
          : (direction == TriangleDirection.top ||
                  direction == TriangleDirection.bottom)
              ? offset
              : null,
      right: direction == TriangleDirection.right ? -20 : null,
      child: Transform.rotate(
        angle: _getRotationAngle(),
        child: Image.asset(
          AssetPath.polygonImg,
          width: 30,
          height: 20,
        ),
      ),
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        triangle,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: AppBoxDecoration.getBoxDecoration(
            color: Colors.grey.shade200,
            border: Border.all(
              color: Colors.grey[300]!,
              width: 2,
            ),
            borderRadius: borderRadius,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  double _getRotationAngle() {
    switch (direction) {
      case TriangleDirection.top:
        return 3.1416;
      case TriangleDirection.right:
        return -1.5708;
      case TriangleDirection.bottom:
        return 0;
      case TriangleDirection.left:
        return 1.5708;
    }
  }
}
