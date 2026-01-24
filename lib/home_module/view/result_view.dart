import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingolearn/home_module/view/dashboard_view.dart';
import 'package:lingolearn/home_module/view/landing_view.dart';
import 'package:lingolearn/home_module/view/quiz_screen.dart';
import 'package:lingolearn/utilities/constants/assets_path.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/theme/app_box_decoration.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

// {correctCount: 1, wrongCount: 7, earnedXP: 4, earnedGems: 1, heartsLeft: 0, percentage: 13, tagline: {title: 💪 Don’t give up! Try again!, desc: ⚡ Lightning fast!}, time: 0:09}

class ResultScreen extends StatefulWidget {
  final int totalQuestions;
  final int correctCount;
  final int totalDurationMs;
  final List<AnswerLog> logs;
  final Map<String, dynamic> data;

  const ResultScreen({
    super.key,
    required this.totalQuestions,
    required this.correctCount,
    required this.totalDurationMs,
    required this.logs,
    required this.data,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 700))
    ..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get formattedTime {
    final totalMs = widget.totalDurationMs;
    final minutes = (totalMs ~/ 60000);
    final seconds = ((totalMs % 60000) ~/ 1000);
    return '${minutes.toString().padLeft(1, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final slideTween =
        Tween<Offset>(begin: const Offset(0, .04), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Column(
            children: [
              const SizedBox(height: 6),
              const Text(
                "Lesson completed!",
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF5B5BD6)),
              ),
              const SizedBox(height: 16),

              // Illustration (network image from your provided URL)
              SlideTransition(
                position: _controller.drive(slideTween),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: SvgPicture.asset(
                    AssetPath.hiImg,
                    height: 180,
                  ),
                ),
              ),

              const SizedBox(height: kToolbarHeight),

              // Diamonds card (gradient)
              _DiamondsCard(count: widget.data['earnedGems']),

              const SizedBox(height: kToolbarHeight),

              // Stats row
              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      label: "XP Earned",
                      icon: Icons.bolt_rounded,
                      color: const Color(0xFFFFA94D),
                      child: AnimatedCount(
                        end: widget.data['earnedXP'],
                        suffix: "",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: "Time",
                      icon: Icons.timer_rounded,
                      color: const Color(0xFF5AD2B6),
                      child: AnimatedCount(
                        end: widget.totalDurationMs,
                        formatter: (v) {
                          final m = (v ~/ 60000);
                          final s = ((v % 60000) ~/ 1000);
                          return '${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}';
                        },
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      label: "Accuracy",
                      icon: Icons.pie_chart_rounded,
                      color: const Color(0xFFFF6B6B),
                      child: AnimatedCount(
                        end: widget.data['percentage'],
                        suffix: "%",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: kToolbarHeight),
              Text(
                widget.data['tagline']['title'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                widget.data['tagline']['desc'],
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await languageController.getLanguageData();
                    MyNavigator.popUntilAndPushNamed(GoPaths.dashboardView);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Continue Learning",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // void _showDetails(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     showDragHandle: true,
  //     backgroundColor: Colors.white,
  //     shape: const RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
  //     ),
  //     builder: (_) {
  //       return ListView.separated(
  //         padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
  //         itemCount: widget.logs.length,
  //         separatorBuilder: (_, __) => const Divider(height: 1),
  //         itemBuilder: (_, i) {
  //           final l = widget.logs[i];
  //           return ListTile(
  //             title: Text(
  //                 'Q${l.index + 1}: ${l.isCorrect ? "Correct" : "Incorrect"}',
  //                 style: const TextStyle(fontWeight: FontWeight.w700)),
  //             subtitle: Text('Selected: ${l.selected}\nCorrect: ${l.correct}'),
  //             trailing: Text('${l.durationMs}ms',
  //                 style: const TextStyle(fontWeight: FontWeight.w700)),
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
}

class _DiamondsCard extends StatelessWidget {
  final int count;

  const _DiamondsCard({required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6EA8FF), Color(0xFF6C5CE7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        children: [
          const Text(
            'Diamonds',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: .3,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.hexagon_rounded, color: Color(0xFF6C5CE7)),
                const SizedBox(width: 8),
                AnimatedCount(
                  end: count,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Widget child;

  const _StatCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      clipBehavior: Clip.hardEdge,
      decoration: AppBoxDecoration.getBoxDecoration(
        borderRadius: 20,
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        children: [
          Container(
            height: 50,
            width: 120,
            decoration: BoxDecoration(color: color),
            child: Center(
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
              child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 6),
              child,
            ],
          )),
        ],
      ),
    );
  }
}

class AnimatedCount extends StatelessWidget {
  final int end;
  final Duration duration;
  final TextStyle? style;
  final String? suffix; // e.g. '%', 's', etc.
  final Curve curve;
  final String Function(int value)? formatter;

  const AnimatedCount({
    super.key,
    required this.end,
    this.duration = const Duration(milliseconds: 1200),
    this.style,
    this.suffix,
    this.curve = Curves.easeOutCubic,
    this.formatter,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: end.toDouble()),
      duration: duration,
      curve: curve,
      builder: (context, value, child) {
        final v = value.floor();
        final text = formatter != null ? formatter!(v) : v.toString();
        return Text(
          suffix != null ? '$text$suffix' : text,
          style: style ?? Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}
