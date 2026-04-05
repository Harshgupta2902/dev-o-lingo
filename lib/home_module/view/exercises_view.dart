// exercise_view.dart
// ignore_for_file: deprecated_member_use, avoid_print, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/exercises_controller.dart';
import 'package:lingolearn/home_module/controller/user_stats_controller.dart';
import 'package:lingolearn/home_module/models/exercises_model.dart';
import 'package:lingolearn/main.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:lingolearn/home_module/widgets/course_overview_card.dart';
import 'package:lingolearn/utilities/skeleton/exercise_view_skeleton.dart';

final exerciseController = Get.put(ExercisesController());

class ExerciseView extends StatefulWidget {
  final String slug;
  final String lessonId;

  const ExerciseView({super.key, required this.slug, required this.lessonId});

  @override
  State<ExerciseView> createState() => _ExerciseViewState();
}

class _ExerciseViewState extends State<ExerciseView> {
  @override
  void initState() {
    super.initState();
    exerciseController.getExercisebyId(widget.slug);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: exerciseController.obx(
        (state) {
          final data = state?.data?.exercise;
          return Column(
            children: [
              _buildHeader(data?.title ?? "Exercise"),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 24),
                    child: CourseOverviewCard(
                      description: data?.description ?? "",
                      themeColor: kDarkSlate,
                      resources: (data?.links ?? [])
                          .map((link) => OverviewResource(
                                type: link.type ?? "info",
                                title: link.title ?? "Learn more",
                                url: link.url ?? "",
                              ))
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        onLoading: const ExerciseViewSkeleton(),
        onError: (err) => _buildErrorState(err.toString()),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader(String title) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: kBorder, width: 1.5),
        ),
      ),
      padding: const EdgeInsets.only(top: 45, left: 16, right: 24, bottom: 16),
      child: Row(
        children: [
          _buildCircleBackButton(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "LESSON OVERVIEW",
                  style: TextStyle(
                    color: kMuted,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    color: kDarkSlate,
                    height: 1.1,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: kBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => MyNavigator.pop(),
          borderRadius: BorderRadius.circular(100),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(
              Icons.arrow_back_rounded,
              color: kDarkSlate,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return userStatsController.obx((state) {
      final hasHearts = (state?.hearts ?? 0) > 0;

      return Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: kBorder, width: 1.5)),
        ),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: hasHearts ? kDarkSlate : Colors.red.shade400,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              disabledBackgroundColor: Colors.red.shade200,
            ),
            onPressed: hasHearts
                ? () {
                    MyNavigator.pushNamed(
                      GoPaths.questionnaireView,
                      extra: {
                        "lessonId": widget.lessonId,
                        "questions":
                            exerciseController.state?.data?.questions ?? [],
                      },
                    );
                  }
                : null,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hasHearts ? "START EXERCISE" : "OUT OF HEARTS",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: hasHearts ? Colors.black : Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  hasHearts
                      ? Icons.play_arrow_rounded
                      : Icons.favorite_border_rounded,
                  size: 20,
                  color: hasHearts ? Colors.black : Colors.white,
                ),
              ],
            ),
          ),
        ),
      );
    },
        onLoading: const SizedBox.shrink(),
        onError: (err) => const SizedBox.shrink());
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, size: 64, color: kMuted),
          const SizedBox(height: 16),
          const Text(
            "Something went wrong",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: kDarkSlate),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(error,
                textAlign: TextAlign.center,
                style: const TextStyle(color: kMuted)),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => exerciseController.getExercisebyId(widget.slug),
            child: const Text("RETRY"),
          ),
        ],
      ),
    );
  }
}
