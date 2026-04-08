import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class ExerciseViewSkeleton extends StatelessWidget {
  const ExerciseViewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeaderSkeleton(),
        Expanded(
          child: SingleChildScrollView(
            physics: const NeverScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonBox(height: 15, width: double.infinity),
                  const SizedBox(height: 8),
                  _skeletonBox(height: 15, width: 250),
                  const SizedBox(height: 8),
                  _skeletonBox(height: 15, width: 150),
                  const SizedBox(height: 32),
                  // Divider skeleton
                  Row(
                    children: [
                      const Expanded(child: Divider(color: kBorder, thickness: 1.5)),
                      const SizedBox(width: 16),
                      _skeletonBox(height: 35, width: 150, borderRadius: 100),
                      const SizedBox(width: 16),
                      const Expanded(child: Divider(color: kBorder, thickness: 1.5)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // List items skeleton
                  ...List.generate(3, (index) => _resourceItemSkeleton()),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSkeleton() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: kBorder, width: 1.5)),
      ),
      padding: const EdgeInsets.only(top: 45, left: 16, right: 24, bottom: 16),
      child: Row(
        children: [
          _skeletonBox(height: 40, width: 40, borderRadius: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _skeletonBox(height: 10, width: 100),
                const SizedBox(height: 6),
                _skeletonBox(height: 20, width: 180),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resourceItemSkeleton() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _skeletonBox(height: 24, width: 70, borderRadius: 6),
          const SizedBox(width: 12),
          Expanded(child: _skeletonBox(height: 15, width: double.infinity)),
          const SizedBox(width: 12),
          _skeletonBox(height: 16, width: 16, borderRadius: 4),
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
