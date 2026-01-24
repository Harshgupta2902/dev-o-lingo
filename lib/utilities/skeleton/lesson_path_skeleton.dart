import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LessonPathSkeleton extends StatelessWidget {
  final bool isUnitList;
  const LessonPathSkeleton({super.key, this.isUnitList = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔹 Header stats skeleton
        Padding(
          padding: const EdgeInsets.only(top: 40, left: 20, right: 20, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(4, (index) => _circleStat()),
          ),
        ),
        const SizedBox(height: 16),

        // 🔹 Fake content (scrollable)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: 8,
            itemBuilder: (context, i) {
              if (isUnitList) {
                return _unitCardSkeleton();
              }
              
              final offset = (i % 2 == 0) ? 40.0 : -40.0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Transform.translate(
                  offset: Offset(offset, 0),
                  child: Center(
                    child: _lessonBubble(),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _unitCardSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        height: 140,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }

  Widget _circleStat() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 60,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _lessonBubble() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
