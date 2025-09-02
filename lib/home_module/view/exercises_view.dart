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

  const ExerciseView({super.key, required this.slug});

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

class QuizScreen extends StatefulWidget {
  final List<Questions> questions;

  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final PageController _controller = PageController();
  Map<int, String> answers = {};
  int currentIndex = 0;

  bool submitted = false;
  bool isCorrect = false;

  void _onExitPressed() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text("Exit Exercise?"),
        content: const Text(
          "Do you want to quit this exercise? Your progress will be lost.",
          style: TextStyle(fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () => MyNavigator.pop(),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              MyNavigator.pop();
              MyNavigator.pop();
            },
            child: const Text("Exit"),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: _onExitPressed,
              icon: const Icon(Icons.close, size: 26),
            ),
            Expanded(
              child: LinearProgressIndicator(
                value: (currentIndex + 1) / widget.questions.length,
                backgroundColor: Colors.grey.shade300,
                color: Colors.indigo,
                minHeight: 8,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(width: 20)
          ],
        ),
      ],
    );
  }

  void _onSubmit(Questions q) {
    if (answers[currentIndex] == null) return;

    final correct = answers[currentIndex] == q.answer;
    setState(() {
      submitted = true;
      isCorrect = correct;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: correct ? Colors.green.shade200 : Colors.grey.shade400,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.fixed,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  correct ? Icons.check_circle : Icons.cancel,
                  color: Colors.black87,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    correct ? "Correct Answer 🎉" : "Wrong Answer ❌",
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            if (!correct) ...[
              const SizedBox(height: 8),
              Text(
                "Correct: ${q.answer}",
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  void _onNext() {
    if (currentIndex == widget.questions.length - 1) {
      print("All answers: $answers");
      MyNavigator.pop();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {
        submitted = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.questions[currentIndex];

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: PageView.builder(
        controller: _controller,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.questions.length,
        onPageChanged: (i) {
          setState(() => currentIndex = i);
        },
        itemBuilder: (context, index) {
          final q = widget.questions[index];
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),

                // Question
                Text(
                  "Q${index + 1}. ${q.question}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 24),

                // Options
                ...[
                  q.optionA,
                  q.optionB,
                  q.optionC,
                  q.optionD,
                ].map((opt) {
                  final isSelected = answers[index] == opt;
                  return GestureDetector(
                    onTap: () {
                      if (submitted) return; // lock after submit
                      setState(() {
                        answers[index] = opt ?? "";
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: isSelected
                            ? LinearGradient(
                                colors: [
                                  Colors.indigo.shade400,
                                  Colors.purple.shade400
                                ],
                              )
                            : null,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.shade300,
                        ),
                        color: isSelected ? null : Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        opt ?? "",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),

      // ⬇️ Fixed button
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: submitted
                    ? (isCorrect ? Colors.green.shade600 : Colors.red.shade600)
                    : Colors.indigo.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (!submitted) {
                  _onSubmit(q);
                } else {
                  _onNext();
                }
              },
              child: Text(
                !submitted
                    ? "Submit"
                    : (currentIndex == widget.questions.length - 1
                        ? "Finish"
                        : "Next"),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
