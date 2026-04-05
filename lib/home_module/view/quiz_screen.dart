// quiz_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/exercises_controller.dart';
import 'package:lingolearn/home_module/controller/user_stats_controller.dart';
import 'package:lingolearn/home_module/models/exercises_model.dart';
import 'package:lingolearn/main.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

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

  bool _isSubmitting = false;

  void _submit() {
    if (_selected == null || _isSubmitting) return;
    HapticFeedback.mediumImpact();

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
        userStatsController.updateHearts(current);
      }

      if (current <= 0) {
        // Delay slightly for UI feedback before forcing exit
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) _forceSubmit();
        });
        return;
      }
    }
  }

  Future<void> _forceSubmit() async {
    if (_isSubmitting) return;
    _isSubmitting = true;

    // Collect all answers
    final Map<String, String> finalAnswers = {};
    for (final q in widget.questions) {
      final log = _logs.firstWhereOrNull((l) => l.questionId == q.id);
      finalAnswers[q.id.toString()] = log?.selected ?? "";
    }

    final totalMs = _logs.fold<int>(0, (a, b) => a + b.durationMs);
    final correctCount = _logs.where((l) => l.isCorrect).length;

    final payload = {
      "answers": finalAnswers,
      "timeTaken": totalMs,
      "lessonId": widget.lessonId,
      "correctCount": correctCount,
    };

    try {
      final value = await exerciseController.submitLesson(payload);
      await userStatsController.getUserStats();

      if (mounted) {
        MyNavigator.pushReplacementNamed(
          GoPaths.resultView,
          extra: {
            "totalQuestions": widget.questions.length,
            "correctCount": value['data']['correctCount'],
            "totalDurationMs": totalMs,
            "logs": _logs,
            "data": value['data'],
          },
        );
      }
    } catch (e) {
      _isSubmitting = false;
    }
  }

  void _next() {
    if (_isSubmitting) return;
    if (_currentIndex == widget.questions.length - 1) {
      _forceSubmit();
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutExpo,
      );
      setState(() => _currentIndex += 1);
      _resetForNextQuestion();
    }
  }

  Future<bool> _onWillPop() async {
    if (_isSubmitting) return false;

    final bool? result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          "Exit Quiz?",
          style: TextStyle(
              fontFamily: 'serif',
              fontWeight: FontWeight.w800,
              fontSize: 24,
              color: kDarkSlate),
        ),
        content: const Text(
          "Leaving will submit your quiz with current progress and mark the remaining questions as incorrect.",
          style: TextStyle(fontSize: 16, color: kMuted, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Keep Going",
                style: TextStyle(color: kMuted, fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Exit & Submit",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (result == true) {
      await _forceSubmit();
      return false; // Very important: _forceSubmit will handle navigation
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: kSurface,
        body: Column(
          children: [
            _buildModernHeader(),
            const SizedBox(height: 12),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  final q = widget.questions[index];
                  return _QuestionCard(
                    question: q,
                    index: index,
                    total: widget.questions.length,
                    selected: index == _currentIndex ? _selected : null,
                    submitted: index == _currentIndex ? _submitted : false,
                    isCorrect: index == _currentIndex ? _isCorrect : false,
                    onSelect: (value) {
                      if (_submitted) return;
                      setState(() => _selected = value);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildModernHeader() {
    final progress = (_currentIndex + 1) / widget.questions.length;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: kBorder, width: 1.5)),
      ),
      padding: const EdgeInsets.only(top: 40, left: 16, right: 24, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCircleCloseButton(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "QUESTION ${_currentIndex + 1}/${widget.questions.length}",
                      style: const TextStyle(
                        color: kMuted,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                        letterSpacing: 2.0,
                      ),
                    ),
                    _buildHeartsIndicator(),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    minHeight: 6,
                    value: progress,
                    backgroundColor: kSurface,
                    valueColor: const AlwaysStoppedAnimation<Color>(kDarkSlate),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleCloseButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(color: kBorder, width: 2),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            if (await _onWillPop()) {
              // Navigation handled in _onWillPop
            }
          },
          borderRadius: BorderRadius.circular(100),
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Icon(Icons.close_rounded, color: kDarkSlate, size: 20),
          ),
        ),
      ),
    );
  }

  Widget _buildHeartsIndicator() {
    return userStatsController.obx(
      (state) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 18),
          const SizedBox(width: 4),
          Text(
            "${state?.hearts ?? 0}",
            style: const TextStyle(
                fontWeight: FontWeight.w900, fontSize: 14, color: kDarkSlate),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    final isLast = _currentIndex == widget.questions.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kBorder, width: 1.5)),
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
              backgroundColor: !_submitted
                  ? kDarkSlate
                  : (_isCorrect ? Colors.green.shade400 : Colors.red.shade400),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              disabledBackgroundColor: kBorder,
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  !_submitted
                      ? "CHECK ANSWER"
                      : (isLast ? "FINISH QUIZ" : "CONTINUE"),
                  style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 1.2),
                ),
                const SizedBox(width: 8),
                Icon(
                    !_submitted
                        ? Icons.search_rounded
                        : (isLast
                            ? Icons.celebration_rounded
                            : Icons.arrow_forward_rounded),
                    size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final Questions question;
  final int index;
  final int total;
  final String? selected;
  final bool submitted;
  final bool isCorrect;
  final ValueChanged<String> onSelect;

  const _QuestionCard({
    required this.question,
    required this.index,
    required this.total,
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
    ].whereType<String>().toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.question ?? "",
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: kDarkSlate,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 32),
          ...options.map((opt) {
            final isSelected = selected == opt;
            final isAnswer = question.answer == opt;

            Color bgColor = Colors.white;
            Color borderColor = kBorder;
            Color textColor = kDarkSlate;

            if (submitted) {
              if (isAnswer) {
                bgColor = Colors.green.shade50;
                borderColor = Colors.green.shade400;
                textColor = Colors.green.shade700;
              } else if (isSelected) {
                bgColor = Colors.red.shade50;
                borderColor = Colors.red.shade400;
                textColor = Colors.red.shade700;
              }
            } else if (isSelected) {
              bgColor = kSurface;
              borderColor = kDarkSlate;
              textColor = kDarkSlate;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: InkWell(
                onTap: submitted ? null : () => onSelect(opt),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: borderColor, width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          opt,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: textColor),
                        ),
                      ),
                      if (submitted && isAnswer)
                        const Icon(Icons.check_circle_rounded,
                            color: Colors.green, size: 24)
                      else if (submitted && isSelected)
                        const Icon(Icons.cancel_rounded,
                            color: Colors.redAccent, size: 24)
                      else if (isSelected)
                        const Icon(Icons.radio_button_checked_rounded,
                            color: kDarkSlate, size: 24),
                    ],
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
