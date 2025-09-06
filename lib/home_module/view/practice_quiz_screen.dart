import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lingolearn/home_module/controller/practise_test_controller.dart';
import 'package:lingolearn/home_module/models/practice_questions_model.dart';

final practiceSessionController = Get.put(PracticeSessionController());

class PracticeQuizScreen extends StatefulWidget {
  final String practiceId;

  const PracticeQuizScreen({super.key, required this.practiceId});

  @override
  State<PracticeQuizScreen> createState() => _PracticeQuizScreenState();
}

class _PracticeQuizScreenState extends State<PracticeQuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await practiceSessionController.getPractiseTest(widget.practiceId);
    });
  }

  @override
  void dispose() {
    Get.delete<PracticeSessionController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          title: practiceSessionController.obx(
            (state) {
              final total =
                  practiceSessionController.state?.data?.items?.length ?? 0;
              final idx =
                  total == 0 ? 0 : practiceSessionController.current.value + 1;
              return Row(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: total == 0 ? 0 : idx / total,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('$idx/$total',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              );
            },
          )),
      body: practiceSessionController.obx(
        (state) {
          if (state == null) {
            return const Center(child: Text('No questions found'));
          }
          return _QuizBody(state: state);
        },
        onLoading: const Center(child: CircularProgressIndicator()),
        onError: (e) => Center(child: Text('Failed to load: $e')),
      ),
    );
  }
}

class _QuizBody extends StatelessWidget {
  final PracticeQuestionsModel state;

  const _QuizBody({required this.state});

  String _fmtDate(String iso) {
    try {
      return DateFormat('EEE, d MMM').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = state.data?.items ?? [];
    final it = items[practiceSessionController.current.value];
    final q = it.question!;

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _Chip(
                    text: _fmtDate(state.data?.date ?? ''),
                  ),
                  Obx(
                    () => _Chip(
                      icon: Icons.timer_rounded,
                      text: _fmtElapsed(
                        practiceSessionController.elapsedMs.value,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              if ((q.title ?? '').isNotEmpty)
                Text(
                  q.title!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              const SizedBox(height: 6),

              Text(
                q.question ?? '',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 16),

              // options
              GetBuilder<PracticeSessionController>(
                id: 'options',
                builder: (_) {
                  final selectedText = practiceSessionController
                      .selected[it.questionId?.toInt() ?? -1];
                  return Column(
                    children: [
                      _OptionTile(
                        label: 'A',
                        text: q.optionA ?? '',
                        selected: selectedText == q.optionA,
                        onTap: () => practiceSessionController.selectOption(
                            it, q.optionA ?? ''),
                      ),
                      _OptionTile(
                        label: 'B',
                        text: q.optionB ?? '',
                        selected: selectedText == q.optionB,
                        onTap: () => practiceSessionController.selectOption(
                            it, q.optionB ?? ''),
                      ),
                      _OptionTile(
                        label: 'C',
                        text: q.optionC ?? '',
                        selected: selectedText == q.optionC,
                        onTap: () => practiceSessionController.selectOption(
                            it, q.optionC ?? ''),
                      ),
                      _OptionTile(
                        label: 'D',
                        text: q.optionD ?? '',
                        selected: selectedText == q.optionD,
                        onTap: () => practiceSessionController.selectOption(
                            it, q.optionD ?? ''),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // footer
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  practiceSessionController.markSkipped(it);
                  if (!practiceSessionController.isLast) {
                    practiceSessionController.next();
                  }
                  practiceSessionController.update();
                },
                icon: const Icon(Icons.keyboard_double_arrow_right_rounded,
                    size: 18),
                label: const Text('Skip'),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () async {
                    if (!practiceSessionController.isLast) {
                      practiceSessionController.next();
                      return;
                    }
                    try {
                      final result = await practiceSessionController.submit();
                      if (context.mounted) {
                        await showModalBottomSheet(
                          context: context,
                          showDragHandle: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(16)),
                          ),
                          builder: (_) => _SubmitReceipt(result: result),
                        );
                        if (context.mounted) Navigator.pop(context, true);
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Submit failed: $e')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                      practiceSessionController.isLast ? 'Submit' : 'Next'),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }

  String _fmtElapsed(int ms) {
    final totalSec = (ms / 1000).floor();
    final m = (totalSec ~/ 60).toString().padLeft(2, '0');
    final s = (totalSec % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }
}

class _Chip extends StatelessWidget {
  final String text;
  final IconData? icon;

  const _Chip({required this.text, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: Colors.black87),
            const SizedBox(width: 6),
          ],
          Text(text,
              style:
                  const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final String label;
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.label,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final base = selected ? Colors.blue.shade50 : Colors.white;
    final border = selected ? Colors.blue.shade300 : Colors.grey.shade200;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.symmetric(vertical: 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(.035),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor:
                    selected ? Colors.blue.shade300 : Colors.grey.shade300,
                child: Text(
                  label,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600, height: 1.3),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: Colors.blue, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SubmitReceipt extends StatelessWidget {
  final Map<String, dynamic> result;

  const _SubmitReceipt({required this.result});

  @override
  Widget build(BuildContext context) {
    final d = result['data'] ?? {};
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Practice Submitted',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 8),
          Text(
              'Score: ${d['correct']}/${d['total']} • XP +${d['earnedXp']} • Gems +${d['earnedGems']}'),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}
