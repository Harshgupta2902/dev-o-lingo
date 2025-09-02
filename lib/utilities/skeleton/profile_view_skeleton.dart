import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AccountSkeleton extends StatelessWidget {
  const AccountSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          const SizedBox(height: 8),
          // Avatar skeleton
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: const CircleAvatar(
              radius: 44,
              backgroundColor: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          _skeletonBox(height: 20, width: 140),
          const SizedBox(height: 6),
          _skeletonBox(height: 16, width: 100),
          const SizedBox(height: 20),

          // Top counts row skeleton
          Row(
            children: List.generate(
              3,
              (i) => Expanded(
                child: Column(
                  children: [
                    _skeletonBox(height: 18, width: 60),
                    const SizedBox(height: 6),
                    _skeletonBox(height: 14, width: 50),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Action buttons skeleton
          Row(
            children: [
              Expanded(child: _skeletonBox(height: 44)),
              const SizedBox(width: 12),
              Expanded(child: _skeletonBox(height: 44)),
            ],
          ),
          const SizedBox(height: 24),

          // Stats grid skeleton
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 96,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, i) => _skeletonCard(),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox({double height = 16, double? width}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }

  Widget _skeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        padding: const EdgeInsets.all(14),
      ),
    );
  }
}
