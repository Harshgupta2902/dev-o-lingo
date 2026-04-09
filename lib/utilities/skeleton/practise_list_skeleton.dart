import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class PracticeListShimmer extends StatelessWidget {
  const PracticeListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      itemBuilder: (_, __) => const PracticeTileShimmer(),
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemCount: 6,
    );
  }
}

class PracticeTileShimmer extends StatelessWidget {
  const PracticeTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kSandyBorder, width: 2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Circle
          _skeletonBox(height: 54, width: 54, borderRadius: 14),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date and Chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _skeletonBox(height: 20, width: 120, borderRadius: 6),
                    _skeletonBox(height: 24, width: 60, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Stats Row
                Row(
                  children: [
                    _skeletonBox(height: 45, width: 60, borderRadius: 12),
                    const SizedBox(width: 8),
                    _skeletonBox(height: 45, width: 60, borderRadius: 12),
                    const SizedBox(width: 8),
                    _skeletonBox(height: 45, width: 60, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Progress Bar
                _skeletonBox(height: 8, width: double.infinity, borderRadius: 99),
              ],
            ),
          ),
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
      baseColor: kBorder.withOpacity(0.4),
      highlightColor: kSurface,
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
