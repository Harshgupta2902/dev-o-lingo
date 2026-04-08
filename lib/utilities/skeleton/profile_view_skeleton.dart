import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class AccountSkeleton extends StatelessWidget {
  const AccountSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 60, bottom: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopNavigationSkeleton(),
          const SizedBox(height: 24),
          _buildProfileHeaderSkeleton(),
          const SizedBox(height: 40),
          _buildStatisticsSectionSkeleton(),
          const SizedBox(height: 40),
          _buildHorizontalListSkeleton("Achievements"),
          const SizedBox(height: 40),
          _buildSuggestionsSectionSkeleton(),
        ],
      ),
    );
  }

  Widget _buildTopNavigationSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _skeletonBox(height: 32, width: 120),
          _skeletonBox(height: 40, width: 40, borderRadius: 12),
        ],
      ),
    );
  }

  Widget _buildProfileHeaderSkeleton() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          _skeletonBox(height: 112, width: 112, borderRadius: 60),
          const SizedBox(height: 20),
          _skeletonBox(height: 28, width: 180),
          const SizedBox(height: 8),
          _skeletonBox(height: 16, width: 140),
          const SizedBox(height: 32),
          Container(
            height: 1,
            color: kBeigeBg,
            margin: const EdgeInsets.symmetric(horizontal: 32),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    _skeletonBox(height: 24, width: 60),
                    const SizedBox(height: 4),
                    _skeletonBox(height: 14, width: 80),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: kBeigeBg),
              Expanded(
                child: Column(
                  children: [
                    _skeletonBox(height: 24, width: 60),
                    const SizedBox(height: 4),
                    _skeletonBox(height: 14, width: 80),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatisticsSectionSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(height: 28, width: 150),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 4,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 90,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, i) => _skeletonBox(
              height: 90,
              width: double.infinity,
              borderRadius: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalListSkeleton(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _skeletonBox(height: 28, width: 160),
              _skeletonBox(height: 20, width: 60),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _skeletonBox(height: 110, width: 280, borderRadius: 24),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestionsSectionSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _skeletonBox(height: 28, width: 180),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 170,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              return _skeletonBox(height: 170, width: 140, borderRadius: 24);
            },
          ),
        ),
      ],
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
