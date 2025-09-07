// quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/exercises_controller.dart';
import 'package:lingolearn/home_module/controller/user_stats_controller.dart';
import 'package:lingolearn/home_module/models/exercises_model.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

final exerciseController = Get.put(ExercisesController());
final userStatsController = Get.put(UserStatsController());

class QuizScreen extends StatefulWidget {
  final List<Questions> questions;
  final String lessonId;
  const QuizScreen(
      {super.key, required this.questions, required this.lessonId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class AnswerLog {
  final int questionId;
  final int index;
  final String selected;
  final String correct;
  final int durationMs;
  final bool isCorrect;

  const AnswerLog({
    required this.questionId,
    required this.index,
    required this.selected,
    required this.correct,
    required this.durationMs,
    required this.isCorrect,
  });

  @override
  String toString() {
    return 'QID=$questionId (page ${index + 1}): selected="$selected", correct="$correct", '
        'time=${durationMs}ms, isCorrect=$isCorrect';
  }
}

class _QuizScreenState extends State<QuizScreen> with TickerProviderStateMixin {
  final PageController _controller = PageController();
  final List<AnswerLog> _logs = [];
  int _currentIndex = 0;
  String? _selected;
  bool _submitted = false;
  bool _isCorrect = false;
  late DateTime _questionStart;

  @override
  void initState() {
    super.initState();
    _questionStart = DateTime.now();
  }

  void _resetForNextQuestion() {
    _selected = null;
    _submitted = false;
    _isCorrect = false;
    _questionStart = DateTime.now();
  }

  void _submit() {
    if (_selected == null) return;

    final q = widget.questions[_currentIndex];
    final elapsedMs = DateTime.now().difference(_questionStart).inMilliseconds;
    final correct = _selected == q.answer;

    setState(() {
      _submitted = true;
      _isCorrect = correct;
    });

    _logs.add(AnswerLog(
      questionId: (q.id!),
      index: _currentIndex,
      selected: _selected!,
      correct: q.answer!,
      durationMs: elapsedMs,
      isCorrect: correct,
    ));

    // Handle hearts
    if (!correct) {
      var current = userStatsController.state?.hearts ?? 0;
      if (current > 0) {
        current = current - 1;
        userStatsController.state?.hearts = current;
      }

      if (current <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: errorBackground,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            content: const Row(
              children: [
                Icon(Icons.favorite_border, color: error, size: 20),
                SizedBox(width: 8),
                Text(
                  "Out of hearts! Submitting your quiz...",
                  style:
                      TextStyle(color: onSurface, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        _forceSubmit();
        return;
      }
    }

    // Modern feedback
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        content: _FeedbackChip(isCorrect: correct, durationMs: elapsedMs),
        duration: const Duration(milliseconds: 1200),
      ),
    );
  }

  void _forceSubmit() {
    final totalMs = _logs.fold<int>(0, (a, b) => a + b.durationMs);
    final correctCount = _logs.where((l) => l.isCorrect).length;

    final answeredIds = _logs.map((l) => l.questionId).toSet();
    final Map<String, String> answers = {
      for (final l in _logs) l.questionId.toString(): l.selected,
      for (final q in widget.questions)
        if (!answeredIds.contains(q.id)) q.id.toString(): ""
    };

    final payload = {
      "answers": answers,
      "timeTaken": totalMs,
      "lessonId": widget.lessonId,
      "correctCount": correctCount,
    };

    exerciseController.submitLesson(payload).then((value) {
      userStatsController.getUserStats();
      MyNavigator.pushReplacementNamed(
        GoPaths.resultView,
        extra: {
          "totalQuestions": widget.questions.length,
          "correctCount": value['data']['correctCount'],
          "totalDurationMs": totalMs,
          "logs": _logs,
          "data": value['data']
        },
      );
    });
  }

  void _next() {
    if (_currentIndex == widget.questions.length - 1) {
      final totalMs = _logs.fold<int>(0, (a, b) => a + b.durationMs);
      final correctCount = _logs.where((l) => l.isCorrect).length;

      final Map<String, String> answers = {
        for (final l in _logs) l.questionId.toString(): l.selected
      };

      final payload = {
        "answers": answers,
        "timeTaken": totalMs,
        "lessonId": widget.lessonId,
        "correctCount": correctCount,
      };

      exerciseController.submitLesson(payload).then((value) {
        userStatsController.getUserStats();
        MyNavigator.pushReplacementNamed(
          GoPaths.resultView,
          extra: {
            "totalQuestions": widget.questions.length,
            "correctCount": value['data']['correctCount'],
            "totalDurationMs": totalMs,
            "logs": _logs,
            "data": value['data']
          },
        );
      });
      return;
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic);
      setState(() => _currentIndex += 1);
      _resetForNextQuestion();
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.questions.length;
    final progress = (_currentIndex + 1) / total;

    return Scaffold(
      backgroundColor: surface,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Modern header with progress
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardSurface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          color: muted,
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                backgroundColor: cardSurface,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                title: const Text(
                                  "Exit Quiz?",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: onSurface,
                                  ),
                                ),
                                content: const Text(
                                  "Your progress will be lost.",
                                  style: TextStyle(color: muted),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text("Cancel"),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: error,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Exit"),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Question ${_currentIndex + 1} of $total",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: muted,
                                  ),
                                ),
                                userStatsController.obx(
                                  (state) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: errorBackground,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.favorite,
                                          color: error,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          "${state?.hearts ?? 0}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                minHeight: 8,
                                value: progress,
                                backgroundColor: border,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: total,
                itemBuilder: (context, index) {
                  final q = widget.questions[index];
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _QuestionCard(
                      key: ValueKey(index),
                      question: q,
                      selected: index == _currentIndex ? _selected : null,
                      submitted: index == _currentIndex ? _submitted : false,
                      isCorrect: index == _currentIndex ? _isCorrect : false,
                      onSelect: (value) {
                        if (_submitted) return;
                        setState(() => _selected = value);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: cardSurface,
          border: Border(top: BorderSide(color: border)),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selected == null && !_submitted
                  ? null
                  : () {
                      if (!_submitted) {
                        _submit();
                      } else {
                        _next();
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    !_submitted ? primary : (_isCorrect ? success : error),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                disabledBackgroundColor: border,
                disabledForegroundColor: muted,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    !_submitted
                        ? "Submit Answer"
                        : (_currentIndex == widget.questions.length - 1
                            ? "Finish Quiz"
                            : "Next Question"),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  if (_submitted) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Questions question;
  final String? selected;
  final bool submitted;
  final bool isCorrect;
  final ValueChanged<String> onSelect;

  const _QuestionCard({
    super.key,
    required this.question,
    required this.selected,
    required this.submitted,
    required this.isCorrect,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      question.optionA,
      question.optionB,
      question.optionC,
      question.optionD,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardSurface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              question.question ?? "",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: onSurface,
                height: 1.4,
                letterSpacing: -0.3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Options
          Expanded(
            child: ListView.separated(
              itemCount: options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final opt = options[index];
                final isSelected = selected == opt;
                final correctOpt = question.answer == opt;

                Color backgroundColor = cardSurface;
                Color borderColor = border;
                IconData? trailingIcon;
                Color? iconColor;

                if (submitted) {
                  if (correctOpt) {
                    backgroundColor = successBackground;
                    borderColor = successBorder;
                    trailingIcon = Icons.check_circle_rounded;
                    iconColor = success;
                  } else if (isSelected && !correctOpt) {
                    backgroundColor = errorBackground;
                    borderColor = errorBorder;
                    trailingIcon = Icons.cancel_rounded;
                    iconColor = error;
                  }
                } else if (isSelected) {
                  backgroundColor = selectedBackground;
                  borderColor = selectedBorder;
                  trailingIcon = Icons.radio_button_checked_rounded;
                  iconColor = primary;
                }

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  child: Material(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: submitted ? null : () => onSelect(opt!),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          border: Border.all(color: borderColor, width: 1.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                opt!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: onSurface,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            if (trailingIcon != null)
                              AnimatedScale(
                                duration: const Duration(milliseconds: 200),
                                scale: 1.0,
                                child: Icon(
                                  trailingIcon,
                                  color: iconColor,
                                  size: 24,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackChip extends StatelessWidget {
  final bool isCorrect;
  final int durationMs;
  const _FeedbackChip({required this.isCorrect, required this.durationMs});

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isCorrect ? successBackground : errorBackground;
    final iconColor = isCorrect ? success : error;
    final borderColor = isCorrect ? successBorder : errorBorder;

    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: iconColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              isCorrect ? "Correct!" : "Incorrect",
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: onSurface,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              "${(durationMs / 1000).toStringAsFixed(1)}s",
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 12,
                color: muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
