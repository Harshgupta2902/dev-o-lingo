import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class PracticeQuizSkeleton extends StatelessWidget {
  const PracticeQuizSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kSurface,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Expanded(child: _skeletonBox(height: 10, borderRadius: 20)),
            const SizedBox(width: 14),
            _skeletonBox(height: 15, width: 40),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Row(
                  children: [
                    _skeletonBox(height: 30, width: 80, borderRadius: 12),
                    const SizedBox(width: 12),
                    _skeletonBox(height: 30, width: 70, borderRadius: 12),
                  ],
                ),
                const SizedBox(height: 32),
                _skeletonBox(height: 15, width: 100),
                const SizedBox(height: 12),
                _skeletonBox(height: 25, width: double.infinity),
                const SizedBox(height: 8),
                _skeletonBox(height: 25, width: 200),
                const SizedBox(height: 40),
                ...List.generate(4, (index) => _OptionSkeleton()),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            color: Colors.white,
            child: Row(
              children: [
                _skeletonBox(height: 40, width: 80, borderRadius: 12),
                const SizedBox(width: 16),
                Expanded(child: _skeletonBox(height: 50, borderRadius: 16)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _skeletonBox({double height = 16, double? width, double borderRadius = 8}) {
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

class _OptionSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: kBorder.withOpacity(0.3), width: 2),
        ),
        child: Row(
          children: [
            Shimmer.fromColors(
              baseColor: kBorder.withOpacity(0.4),
              highlightColor: kSurface,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Shimmer.fromColors(
                baseColor: kBorder.withOpacity(0.4),
                highlightColor: kSurface,
                child: Container(
                  height: 15,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
