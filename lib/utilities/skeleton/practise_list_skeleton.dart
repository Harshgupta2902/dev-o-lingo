import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PracticeListShimmer extends StatelessWidget {
  const PracticeListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemBuilder: (_, __) => const PracticeTileShimmer(),
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemCount: 6, // 6 skeletons
    );
  }
}

class PracticeTileShimmer extends StatelessWidget {
  const PracticeTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final baseColor = Colors.grey.shade300;
    final highlight = Colors.grey.shade100;

    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Shimmer.fromColors(
            baseColor: baseColor,
            highlightColor: highlight,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // avatar
                    _ShimmerCircle(diameter: 44),
                    SizedBox(width: 12),
                    // title + chips + progress + stats
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // date + chips (matches Wrap structure)
                          Row(
                            children: [
                              _ShimmerLine(width: 100, height: 16, radius: 6),
                              SizedBox(width: 8),
                              _ShimmerPill(width: 60, height: 18),
                            ],
                          ),
                          SizedBox(height: 10),
                          // progress
                          _ShimmerBar(height: 8, radius: 8),
                          SizedBox(height: 8),
                          // stats row
                          Row(
                            children: [
                              _ShimmerLine(width: 70, height: 12, radius: 4),
                              SizedBox(width: 10),
                              _ShimmerLine(width: 40, height: 12, radius: 4),
                              SizedBox(width: 10),
                              _ShimmerLine(width: 40, height: 12, radius: 4),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// --- small shimmer atoms ---

class _ShimmerLine extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerLine({
    required this.width,
    required this.height,
    this.radius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return _ShimmerRect(width: width, height: height, radius: radius);
  }
}

class _ShimmerBar extends StatelessWidget {
  final double height;
  final double radius;
  const _ShimmerBar({required this.height, this.radius = 8});

  @override
  Widget build(BuildContext context) {
    return _ShimmerRect(width: double.infinity, height: height, radius: radius);
  }
}

class _ShimmerPill extends StatelessWidget {
  final double width;
  final double height;
  const _ShimmerPill({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return _ShimmerRect(width: width, height: height, radius: 999);
  }
}

class _ShimmerCircle extends StatelessWidget {
  final double diameter;
  const _ShimmerCircle({required this.diameter});

  @override
  Widget build(BuildContext context) {
    return _ShimmerBase(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _ShimmerDot extends StatelessWidget {
  const _ShimmerDot();

  @override
  Widget build(BuildContext context) {
    return const _ShimmerCircle(diameter: 6);
  }
}

class _ShimmerRect extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  const _ShimmerRect({
    required this.width,
    required this.height,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return _ShimmerBase(
      child: Container(
        width: width == double.infinity ? null : width,
        height: height,
        constraints: width == double.infinity
            ? const BoxConstraints(minWidth: double.infinity)
            : null,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class _ShimmerBase extends StatelessWidget {
  final Widget child;
  const _ShimmerBase({required this.child});

  @override
  Widget build(BuildContext context) {
    // The gradient is provided by the parent Shimmer.fromColors,
    // here we just paint a base box to animate over.
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: child,
    );
  }
}
