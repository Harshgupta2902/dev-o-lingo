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
      itemCount: 6,
    );
  }
}

class PracticeTileShimmer extends StatelessWidget {
  const PracticeTileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(height: 44, width: 44, borderRadius: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _skeletonBox(height: 18, width: 100, borderRadius: 6),
                    const SizedBox(width: 8),
                    _skeletonBox(height: 18, width: 60, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 10),
                _skeletonBox(height: 8, width: double.infinity, borderRadius: 4),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _skeletonBox(height: 14, width: 70, borderRadius: 4),
                    const SizedBox(width: 10),
                    _skeletonBox(height: 14, width: 40, borderRadius: 4),
                    const SizedBox(width: 10),
                    _skeletonBox(height: 14, width: 40, borderRadius: 4),
                  ],
                ),
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
