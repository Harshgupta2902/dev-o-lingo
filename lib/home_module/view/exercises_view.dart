// ignore_for_file: deprecated_member_use, avoid_print, unnecessary_to_list_in_spreads

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/exercises_controller.dart';
import 'package:lingolearn/home_module/models/exercises_model.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:url_launcher/url_launcher.dart';

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

  Future<void> _openLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildLinkCard(Links? link) {
    IconData icon;
    Color color;

    if (link?.type == 'video') {
      icon = Icons.play_circle_fill;
      color = Colors.red.shade400;
    } else {
      icon = Icons.article_outlined;
      color = Colors.blue.shade400;
    }

    return GestureDetector(
      onTap: () => _openLink(link?.url ?? ""),
      child: Card(
        elevation: 2,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(icon, color: color),
          ),
          title: Text(
            link?.title ?? '',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            link?.url ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          trailing: const Icon(Icons.open_in_new, size: 20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo.shade500,
        foregroundColor: Colors.white,
        title: Text(exerciseController.state?.data?.exercise?.title ??
            "Exercise Details"),
      ),
      body: exerciseController.obx(
        (state) {
          final data = state?.data?.exercise;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data?.title ?? "",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  data?.description ?? "",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade800,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 28),
                Text(
                  "Resources",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.indigo.shade600,
                  ),
                ),
                const SizedBox(height: 12),

                // Links
                ...List.generate(
                  data?.links?.length ?? 0,
                  (index) {
                    return _buildLinkCard(data?.links?[index]);
                  },
                ),
                const SizedBox(height: 80), // space for button
              ],
            ),
          );
        },
        onLoading: const Center(child: CircularProgressIndicator()),
        onError: (err) => Center(child: Text("Error: $err")),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade400, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.indigo.shade600,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 3,
            ),
            onPressed: () {
              MyNavigator.pushNamed(
                GoPaths.questionnaireView,
                extra: {
                  "lessonId": widget.lessonId,
                  "questions": exerciseController.state?.data?.questions ?? [],
                },
              );
            },
            child: const Text(
              "Start Questionnaire",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

