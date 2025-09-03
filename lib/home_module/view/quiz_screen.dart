import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/exercises_controller.dart';
import 'package:lingolearn/home_module/models/exercises_model.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';

final exerciseController = Get.put(ExercisesController());

class QuizScreen extends StatefulWidget {
  final List<Questions> questions;
  final String lessonId;
  const QuizScreen(
      {super.key, required this.questions, required this.lessonId});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class AnswerLog {
  final int questionId; // NEW
  final int index;
  final String selected;
  final String correct;
  final int durationMs;
  final bool isCorrect;

  const AnswerLog({
    required this.questionId, // NEW
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

  // timing
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

    // Subtle feedback via SnackBar
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

  void _next() {
    if (_currentIndex == widget.questions.length - 1) {
      final totalMs = _logs.fold<int>(0, (a, b) => a + b.durationMs);
      final correctCount = _logs.where((l) => l.isCorrect).length;
      for (final l in _logs) {
        print(l.toString());
      }

      final Map<String, String> answers = {
        for (final l in _logs) l.questionId.toString(): l.selected
      };

      final payload = {
        "answers": answers,
        "timeTaken": totalMs,
        "lessonId": widget.lessonId,
        "correctCount": correctCount,
      };

      exerciseController.submitLesson(payload).then(
        (value) {
          print(value['data'].toString());
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
        },
      );
      return;

      MyNavigator.pushReplacementNamed(
        GoPaths.resultView,
        extra: {
          "totalQuestions": widget.questions.length,
          "correctCount": correctCount,
          "totalDurationMs": totalMs,
          "logs": _logs,
        },
      );
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
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text("Exit Quiz?"),
                content: const Text("Your progress will be lost."),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel")),
                  FilledButton.tonal(
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
        title: const Text("Quiz"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: LinearProgressIndicator(
                minHeight: 10,
                value: progress,
                backgroundColor: const Color(0xFFEAEAF2),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text("Question ${_currentIndex + 1} of $total",
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: FilledButton(
            onPressed: () {
              if (!_submitted) {
                _submit();
              } else {
                _next();
              }
            },
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(54),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              backgroundColor: !_submitted
                  ? null
                  : (_isCorrect
                      ? const Color(0xFF16A34A)
                      : const Color(0xFFDC2626)),
            ),
            child: Text(
              !_submitted
                  ? "Submit"
                  : (_currentIndex == widget.questions.length - 1
                      ? "Finish"
                      : "Next"),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 0,
            color: Colors.white,
            surfaceTintColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Text(
                question.question ?? "",
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700, height: 1.35),
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((opt) {
            final isSelected = selected == opt;
            // color logic after submit
            final correctOpt = question.answer == opt;
            Color? bg;
            Color border = const Color(0xFFE7E7F1);
            Color textColor = Colors.black87;

            if (submitted) {
              if (correctOpt) {
                bg = const Color(0xFFE8F7EE);
                border = const Color(0xFFBEE3C7);
              } else if (isSelected && !correctOpt) {
                bg = const Color(0xFFFDECEC);
                border = const Color(0xFFF2B9B9);
              }
            } else if (isSelected) {
              bg = const Color(0xFFEFF2FF);
              border = const Color(0xFFC7CEFF);
            }

            return AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Material(
                color: bg ?? Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: BorderSide(color: border, width: 1),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: submitted ? null : () => onSelect(opt!),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            opt!,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: textColor,
                            ),
                          ),
                        ),
                        AnimatedScale(
                          duration: const Duration(milliseconds: 180),
                          scale: isSelected ? 1.0 : 0.0,
                          child: const Icon(Icons.check_circle,
                              color: Color(0xFF4F46E5)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
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
    final bg = isCorrect ? const Color(0xFFE8F7EE) : const Color(0xFFFDECEC);
    final iconColor =
        isCorrect ? const Color(0xFF16A34A) : const Color(0xFFDC2626);
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: bg.withOpacity(.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isCorrect ? Icons.check_circle : Icons.cancel,
                color: iconColor, size: 18),
            const SizedBox(width: 8),
            Text(
              isCorrect ? "Correct" : "Incorrect",
              style: const TextStyle(
                  fontWeight: FontWeight.w700, color: Colors.black),
            ),
            const SizedBox(width: 10),
            const Text("•"),
          ],
        ),
      ),
    );
  }
}
