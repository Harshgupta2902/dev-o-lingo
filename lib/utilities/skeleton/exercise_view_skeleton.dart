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
                  _shimmerLine(width: double.infinity),
                  const SizedBox(height: 8),
                  _shimmerLine(width: 250),
                  const SizedBox(height: 8),
                  _shimmerLine(width: 150),
                  const SizedBox(height: 32),
                  // Divider skeleton
                  Row(
                    children: [
                      const Expanded(child: Divider(color: kBorder, thickness: 1.5)),
                      const SizedBox(width: 16),
                      _shimmerBox(width: 150, height: 35, borderRadius: 100),
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
          _shimmerCircle(size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _shimmerLine(width: 100, height: 10),
                const SizedBox(height: 6),
                _shimmerLine(width: 180, height: 20),
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
          _shimmerBox(width: 70, height: 24, borderRadius: 6),
          const SizedBox(width: 12),
          Expanded(child: _shimmerLine(height: 15)),
          const SizedBox(width: 12),
          _shimmerBox(width: 16, height: 16, borderRadius: 4),
        ],
      ),
    );
  }

  Widget _shimmerLine({double width = 100, double height = 15}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }

  Widget _shimmerBox({required double width, required double height, double borderRadius = 8}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }

  Widget _shimmerCircle({double size = 40}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade200,
      highlightColor: Colors.grey.shade50,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
