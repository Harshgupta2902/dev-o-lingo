import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LessonPathSkeleton extends StatelessWidget {
  const LessonPathSkeleton({super.key});

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

        // 🔹 Fake lesson path (scrollable)
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: 12, // placeholder lessons
            itemBuilder: (context, i) {
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
