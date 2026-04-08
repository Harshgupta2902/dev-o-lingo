import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LessonPathSkeleton extends StatelessWidget {
  final bool isUnitList;
  const LessonPathSkeleton({super.key, this.isUnitList = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeaderSkeleton(),
        _buildModernTabsSkeleton(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            itemCount: 4,
            itemBuilder: (context, index) {
              if (isUnitList) {
                return _unitCardSkeleton();
              }
              return _lessonBubbleRow(index);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSkeleton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _skeletonBox(height: 48, width: 48, borderRadius: 24),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _skeletonBox(height: 14, width: 60),
                      const SizedBox(height: 4),
                      _skeletonBox(height: 18, width: 100),
                    ],
                  ),
                ],
              ),
              _skeletonBox(height: 48, width: 48, borderRadius: 24),
            ],
          ),
          const SizedBox(height: 32),
          _skeletonBox(height: 40, width: 200),
          const SizedBox(height: 8),
          _skeletonBox(height: 40, width: 160),
        ],
      ),
    );
  }

  Widget _buildModernTabsSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: _skeletonBox(height: 52, width: double.infinity, borderRadius: 16),
    );
  }

  Widget _unitCardSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
          bottomRight: Radius.circular(32),
          bottomLeft: Radius.circular(8),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(height: 28, width: 180),
          const SizedBox(height: 16),
          Row(
            children: List.generate(
              5,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _skeletonBox(height: 20, width: 20, borderRadius: 4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _lessonBubbleRow(int i) {
    final offset = (i % 2 == 0) ? 40.0 : -40.0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Transform.translate(
        offset: Offset(offset, 0),
        child: Center(
          child: _skeletonBox(height: 72, width: 72, borderRadius: 36),
        ),
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
