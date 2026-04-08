import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class LeaderboardSkeleton extends StatelessWidget {
  const LeaderboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Fake header
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              _skeletonBox(height: 32, width: 32, borderRadius: 8),
              const SizedBox(width: 12),
              _skeletonBox(height: 28, width: 160),
            ],
          ),
        ),
        // Fake filter pills
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              _skeletonBox(height: 44, width: 100, borderRadius: 25),
              const SizedBox(width: 12),
              _skeletonBox(height: 44, width: 110, borderRadius: 25),
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
            itemBuilder: (_, __) => _buildTileSkeleton(),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildTileSkeleton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _skeletonBox(height: 24, width: 24, borderRadius: 12),
          const SizedBox(width: 16),
          _skeletonBox(height: 40, width: 40, borderRadius: 20),
          const SizedBox(width: 16),
          Expanded(
            child: _skeletonBox(height: 18, width: double.infinity),
          ),
          const SizedBox(width: 16),
          _skeletonBox(height: 16, width: 60),
        ],
      ),
    );
  }

  Widget _skeletonBox({
    double height = 16,
    double? width,
    double borderRadius = 8,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}