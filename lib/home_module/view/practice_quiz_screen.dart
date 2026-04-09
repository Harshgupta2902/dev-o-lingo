import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lingolearn/home_module/controller/practise_test_controller.dart';
import 'package:lingolearn/home_module/models/practice_questions_model.dart';
import 'package:lingolearn/utilities/packages/ad_helper.dart';
import 'package:lingolearn/utilities/skeleton/practice_quiz_skeleton.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class PracticeQuizScreen extends StatefulWidget {
  final String practiceId;

  const PracticeQuizScreen({super.key, required this.practiceId});

  @override
  State<PracticeQuizScreen> createState() => _PracticeQuizScreenState();
}

class _PracticeQuizScreenState extends State<PracticeQuizScreen> {
  late final PracticeSessionController practiceSessionController;

  @override
  void initState() {
    super.initState();
    practiceSessionController = Get.put(PracticeSessionController());
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
      backgroundColor: kSurface,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: kSurface,
        foregroundColor: kOnSurface,
        title: practiceSessionController.obx(
          (state) {
            final total = state?.data?.items?.length ?? 0;
            final current = practiceSessionController.current.value;
            final idx = total == 0 ? 0 : current + 1;
            return Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: total == 0 ? 0 : idx / total,
                      minHeight: 8,
                      backgroundColor: kBorder.withOpacity(0.4),
                      color: kAmberAccent,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  '$idx/$total',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: kOnSurface,
                  ),
                ),
              ],
            );
          },
          onLoading: const SizedBox.shrink(),
          onEmpty: const SizedBox.shrink(),
          onError: (_) => const SizedBox.shrink(),
        ),
      ),
      body: practiceSessionController.obx(
        (state) {
          if (state?.data?.items == null || state!.data!.items!.isEmpty) {
            return const Center(
              child: Text(
                'No questions found',
                style: TextStyle(color: kMuted, fontWeight: FontWeight.w600),
              ),
            );
          }
          return _QuizBody(
            state: state,
            controller: practiceSessionController,
          );
        },
        onLoading: const PracticeQuizSkeleton(),
        onError: (e) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded,
                    size: 48, color: errorMain),
                const SizedBox(height: 16),
                Text(
                  'Failed to load practice: $e',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: kOnSurface, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuizBody extends StatelessWidget {
  final PracticeQuestionsModel state;
  final PracticeSessionController controller;

  const _QuizBody({required this.state, required this.controller});

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
    if (items.isEmpty) return const SizedBox.shrink();

    final currentIdx = controller.current.value;
    if (currentIdx >= items.length) return const SizedBox.shrink();

    final it = items[currentIdx];
    final q = it.question;

    if (q == null) {
      return const Center(child: Text("Invalid question data"));
    }

    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 10,
                children: [
                  _Chip(
                    text: _fmtDate(state.data?.date ?? ''),
                    backgroundColor: kCardOrange,
                    textColor: kAmberAccent,
                  ),
                  Obx(
                    () => _Chip(
                      icon: Icons.timer_rounded,
                      text: _fmtElapsed(
                        controller.elapsedMs.value,
                      ),
                      backgroundColor: kCardPurple,
                      textColor: Colors.purple.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if ((q.title ?? '').isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    q.title!.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: kMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

              Text(
                q.question ?? '',
                style: const TextStyle(
                  fontFamily: 'serif',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                  color: kOnSurface,
                ),
              ),
              const SizedBox(height: 32),

              // options
              GetBuilder<PracticeSessionController>(
                id: 'options',
                builder: (controller) {
                  final selectedText =
                      controller.selected[it.questionId?.toInt() ?? -1];
                  return Column(
                    children: [
                      _OptionTile(
                        label: 'A',
                        text: q.optionA ?? '',
                        selected: selectedText == q.optionA,
                        onTap: () =>
                            controller.selectOption(it, q.optionA ?? ''),
                      ),
                      _OptionTile(
                        label: 'B',
                        text: q.optionB ?? '',
                        selected: selectedText == q.optionB,
                        onTap: () =>
                            controller.selectOption(it, q.optionB ?? ''),
                      ),
                      _OptionTile(
                        label: 'C',
                        text: q.optionC ?? '',
                        selected: selectedText == q.optionC,
                        onTap: () =>
                            controller.selectOption(it, q.optionC ?? ''),
                      ),
                      _OptionTile(
                        label: 'D',
                        text: q.optionD ?? '',
                        selected: selectedText == q.optionD,
                        onTap: () =>
                            controller.selectOption(it, q.optionD ?? ''),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),

        // footer
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: () {
                  controller.markSkipped(it);
                  if (!controller.isLast) {
                    controller.next();
                  } else {
                    controller.update();
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: kMuted,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                icon: const Icon(Icons.bolt_outlined, size: 20),
                label: const Text('SKIP',
                    style:
                        TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Obx(
                  () => ElevatedButton(
                    onPressed: controller.isSubmitting.value
                        ? null
                        : () async {
                            if (!controller.isLast) {
                              controller.next();
                              return;
                            }

                            Future<void> doSubmit() async {
                              final result = await controller.submit();
                              if (!context.mounted) return;
                              if (result == null) return; // already submitting

                              await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                showDragHandle: true,
                                backgroundColor: kSurface,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(30)),
                                ),
                                builder: (_) => _SubmitReceipt(result: result),
                              );
                              if (context.mounted) Navigator.pop(context, true);
                            }

                            try {
                              await AdsHelper.showInterstitialAd(
                                onDismissed: () async => await doSubmit(),
                                onFailedToLoad: () async => await doSubmit(),
                              );
                            } catch (e) {
                              await doSubmit();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kDarkSlate,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    child: controller.isSubmitting.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white),
                          )
                        : Text(
                            controller.isLast
                                ? 'COMPLETE PRACTICE'
                                : 'NEXT QUESTION',
                            style: const TextStyle(
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5),
                          ),
                  ),
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
  final Color? backgroundColor;
  final Color? textColor;

  const _Chip(
      {required this.text, this.icon, this.backgroundColor, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor ?? kBorder.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor ?? kOnSurface),
            const SizedBox(width: 8),
          ],
          Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 12,
              color: textColor ?? kOnSurface,
              letterSpacing: 0.2,
            ),
          ),
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
    final base = selected ? kCardBlue : Colors.white;
    final borderCol = selected ? infoMain : kBorder.withOpacity(0.5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderCol, width: 2),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: infoMain.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              else
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: selected ? infoMain : kBeigeBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: selected ? Colors.white : kOnSurface,
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    color: kOnSurface,
                    height: 1.3,
                  ),
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle_rounded,
                    color: infoMain, size: 24),
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
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: kCardGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.celebration_rounded,
                size: 40, color: successMain),
          ),
          const SizedBox(height: 24),
          const Text(
            'Keep it up!',
            style: TextStyle(
                fontFamily: 'serif',
                fontWeight: FontWeight.w900,
                fontSize: 28,
                color: kOnSurface),
          ),
          const SizedBox(height: 8),
          const Text(
            'Practice Session Completed',
            style: TextStyle(color: kMuted, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildResultStat(
                  label: 'CORRECT',
                  value: '${d['correct']}/${d['total']}',
                  color: successMain),
              _buildResultStat(
                  label: 'XP EARNED',
                  value: '+${d['earnedXp']}',
                  color: kAmberAccent),
              _buildResultStat(
                  label: 'GEMS', value: '+${d['earnedGems']}', color: infoMain),
            ],
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: kDarkSlate,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: const Text('BACK TO DASHBOARD',
                  style: TextStyle(
                      fontWeight: FontWeight.w900, letterSpacing: 1.0)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultStat(
      {required String label, required String value, required Color color}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 22, fontWeight: FontWeight.w900, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: kMuted,
              letterSpacing: 0.5),
        ),
      ],
    );
  }
}
