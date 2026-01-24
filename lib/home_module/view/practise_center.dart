import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/practise_center_controller.dart';
import 'package:lingolearn/utilities/common/core_app_bar.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

import '../models/review_models.dart';

class PracticeCenterScreen extends StatelessWidget {
  const PracticeCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PractiseCenterController());

    return Scaffold(
      backgroundColor: kSurface,
      body: SafeArea(
        child: controller.obx(
          (state) => _buildContent(context, state),
          onLoading: const _LoadingView(),
          onEmpty: const _EmptyView(),
          onError: (err) => _ErrorView(
            message: err ?? 'Something went wrong',
            onRetry: () => controller.getWrongQuestions(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ReviewResponseModel? state) {
    final List<ReviewItem> reviewData = state?.data ?? [];
    final wrong = reviewData.where((e) => e.type == 'wrong').toList();
    final skipped = reviewData.where((e) => e.type == 'skipped').toList();

    return Column(
      children: [
        const CustomHeader(title: "Practice Center", icon: Icons.book_outlined),

        // Main Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section
                // Container(
                //   padding: const EdgeInsets.all(20),
                //   decoration: BoxDecoration(
                //     gradient: const LinearGradient(
                //       begin: Alignment.topLeft,
                //       end: Alignment.bottomRight,
                //       colors: [primary, secondary],
                //     ),
                //     borderRadius: BorderRadius.circular(20),
                //     boxShadow: [
                //       BoxShadow(
                //         color: primary.withOpacity(0.30),
                //         blurRadius: 20,
                //         offset: const Offset(0, 8),
                //       ),
                //     ],
                //   ),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       const Text(
                //         'Review your recent mistakes & skipped questions',
                //         style: TextStyle(
                //           fontSize: 24,
                //           fontWeight: FontWeight.bold,
                //           color: Colors.white,
                //         ),
                //       ),
                //       const SizedBox(height: 16),
                //       Container(
                //         padding: const EdgeInsets.symmetric(
                //           horizontal: 12,
                //           vertical: 6,
                //         ),
                //         decoration: BoxDecoration(
                //           color: Colors.white.withOpacity(0.20),
                //           borderRadius: BorderRadius.circular(12),
                //         ),
                //         child: Text(
                //           '$totalMistakes+ items found',
                //           style: const TextStyle(
                //             color: Colors.white,
                //             fontWeight: FontWeight.w600,
                //             fontSize: 14,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                //
                // const SizedBox(height: 24),
                //
                // // Action Buttons
                // ElevatedButton(
                //   onPressed: () {
                //     MyNavigator.pushNamed(GoPaths.practisePremiumView);
                //   },
                //   style: ElevatedButton.styleFrom(
                //     backgroundColor: kPrimary,
                //     foregroundColor: Colors.white,
                //     padding: const EdgeInsets.symmetric(vertical: 16),
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(16),
                //     ),
                //     elevation: 0,
                //   ),
                //   child: const Row(
                //     mainAxisAlignment: MainAxisAlignment.center,
                //     children: [
                //       Icon(Icons.play_arrow, size: 20),
                //       SizedBox(width: 8),
                //       Text(
                //         'Start • +20 points',
                //         style: TextStyle(
                //           fontSize: 16,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                //
                // const SizedBox(height: 24),

                // Stats Section
                Row(
                  children: [
                    _buildStatCard(
                      title: 'Incorrect',
                      count: wrong.length,
                      color: errorMain,
                      backgroundColor: errorBackground,
                    ),
                    const SizedBox(width: 12),
                    _buildStatCard(
                      title: 'Skipped',
                      count: skipped.length,
                      color: warningMain,
                      backgroundColor: warningBackground,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Questions List
                const Text(
                  'Recent items',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kOnSurface,
                  ),
                ),
                const SizedBox(height: 16),

                ...reviewData.map((item) => _buildQuestionCard(item)),

                const SizedBox(height: kBottomNavigationBarHeight),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required int count,
    required Color color,
    required Color backgroundColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionCard(ReviewItem item) {
    final bool isWrong = item.type == 'wrong';
    final Color accentColor = isWrong ? errorMain : warningMain;
    final Color pillBg = isWrong ? errorBackground : warningBackground;
    final String pillText = isWrong ? 'Incorrect' : 'Skipped';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: dot + title + pill
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.question.title,
                  style: const TextStyle(
                    color: infoMain,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  pillText,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Question
          Text(
            item.question.question,
            style: const TextStyle(
              color: kOnSurface,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),

          // User Answer
          if (item.userAnswer != null && item.userAnswer!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Your Answer: ${item.userAnswer}',
                style: const TextStyle(
                  color: kMuted,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------- Loading, Empty, and Error Views ----------
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(infoMain),
          ),
          SizedBox(height: 16),
          Text(
            'Fetching your mistakes...',
            style: TextStyle(
              color: kMuted,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: successBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.celebration,
              color: successMain,
              size: 50,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No mistakes found! 🎉',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kOnSurface,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'You’re doing great — keep going!',
            style: TextStyle(
              color: kMuted,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: errorBackground,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                color: errorMain,
                size: 50,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              message,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kOnSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: infoMain,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
