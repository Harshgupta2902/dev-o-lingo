import 'package:flutter/material.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class LeaderboardSkeleton extends StatefulWidget {
  const LeaderboardSkeleton({super.key});

  @override
  State<LeaderboardSkeleton> createState() => _LeaderboardSkeletonState();
}

class _LeaderboardSkeletonState extends State<LeaderboardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fake header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _ShimmerBox(controller: _c, width: 32, height: 32, borderRadius: 8),
              const SizedBox(width: 12),
              _ShimmerBox(controller: _c, width: 160, height: 20, borderRadius: 6),
              const Spacer(),
              _ShimmerBox(controller: _c, width: 40, height: 40, borderRadius: 12),
            ],
          ),
        ),
        // Fake filter pills
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _ShimmerBox(controller: _c, width: 90, height: 40, borderRadius: 20),
              const SizedBox(width: 12),
              _ShimmerBox(controller: _c, width: 100, height: 40, borderRadius: 20),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Fake list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: 6,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => _LeaderboardTileSkeleton(controller: _c),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _LeaderboardTileSkeleton extends StatelessWidget {
  final AnimationController controller;
  const _LeaderboardTileSkeleton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _ShimmerBox(controller: controller, width: 24, height: 24, borderRadius: 12),
          const SizedBox(width: 16),
          _ShimmerBox(controller: controller, width: 40, height: 40, borderRadius: 20),
          const SizedBox(width: 16),
          Expanded(
            child: _ShimmerBox(controller: controller, height: 16, borderRadius: 6),
          ),
          const SizedBox(width: 16),
          _ShimmerBox(controller: controller, width: 60, height: 16, borderRadius: 6),
        ],
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final AnimationController controller;
  final double? width;
  final double height;
  final double borderRadius;

  const _ShimmerBox({
    required this.controller,
    this.width,
    required this.height,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        // simple shimmer-ish gradient slide
        final shimmerVal = (controller.value * 2) - 1; // -1..1
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            gradient: LinearGradient(
              begin: const Alignment(-1, 0),
              end: const Alignment(1, 0),
              colors: [
                Colors.grey.shade200,
                Colors.grey.shade300,
                Colors.grey.shade200,
              ],
              stops: [
                (0.2 + shimmerVal * 0.2).clamp(0.0, 1.0),
                (0.5 + shimmerVal * 0.2).clamp(0.0, 1.0),
                (0.8 + shimmerVal * 0.2).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}