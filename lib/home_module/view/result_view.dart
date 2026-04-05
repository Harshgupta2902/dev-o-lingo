import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lingolearn/home_module/view/landing_view.dart';
import 'package:lingolearn/home_module/view/quiz_screen.dart';
import 'package:lingolearn/utilities/constants/assets_path.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

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

class _ResultScreenState extends State<ResultScreen> with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    _buildIllustration(),
                    const SizedBox(height: 32),
                    _buildTitle(),
                    const SizedBox(height: 8),
                    _buildTagline(),
                    const SizedBox(height: 40),
                    _buildGemReward(),
                    const SizedBox(height: 24),
                    _buildStatsGrid(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return FadeTransition(
      opacity: _controller,
      child: ScaleTransition(
        scale: CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
        child: SvgPicture.asset(
          AssetPath.hiImg,
          height: 180,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      "Lesson Completed!",
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: kDarkSlate,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildTagline() {
    final tagline = widget.data['tagline'] ?? {};
    return Column(
      children: [
        Text(
          tagline['title'] ?? "Great job!",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: kDarkSlate,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          tagline['desc'] ?? "Keep up the momentum.",
          style: const TextStyle(
            fontSize: 15,
            color: kMuted,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGemReward() {
    final gems = widget.data['earnedGems'] ?? 0;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.diamond_rounded, color: Colors.blueAccent, size: 32),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "GEMS EARNED",
                style: TextStyle(
                  color: kMuted,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedCount(
                end: gems,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: kDarkSlate,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        Expanded(
          child: _SmallStatCard(
            label: "XP",
            value: widget.data['earnedXP'] ?? 0,
            icon: Icons.bolt_rounded,
            iconColor: Colors.orange,
            bgColor: Colors.orange.shade50,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SmallStatCard(
            label: "TIME",
            value: widget.totalDurationMs,
            icon: Icons.timer_rounded,
            iconColor: Colors.teal,
            bgColor: Colors.teal.shade50,
            isTime: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _SmallStatCard(
            label: "ACCURACY",
            value: widget.data['percentage'] ?? 0,
            icon: Icons.track_changes_rounded,
            iconColor: Colors.redAccent,
            bgColor: Colors.red.shade50,
            suffix: "%",
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: kBorder, width: 1.5)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            await languageController.getLanguageData();
            MyNavigator.popUntilAndPushNamed(GoPaths.dashboardView);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: kDarkSlate,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "CONTINUE",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, letterSpacing: 1.2),
              ),
              SizedBox(width: 8),
              Icon(Icons.arrow_forward_rounded, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  final String label;
  final num value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final String? suffix;
  final bool isTime;

  const _SmallStatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.suffix,
    this.isTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kBorder, width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          AnimatedCount(
            end: value.toInt(),
            isTime: isTime,
            suffix: suffix,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kDarkSlate),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: kMuted, fontWeight: FontWeight.w800, fontSize: 10, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

class AnimatedCount extends StatelessWidget {
  final int end;
  final TextStyle? style;
  final String? suffix;
  final bool isTime;

  const AnimatedCount({
    super.key,
    required this.end,
    this.style,
    this.suffix,
    this.isTime = false,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: end.toDouble()),
      duration: const Duration(seconds: 2),
      curve: Curves.easeOutExpo,
      builder: (context, value, child) {
        final v = value.toInt();
        String text;
        if (isTime) {
          final m = (v ~/ 60000);
          final s = ((v % 60000) ~/ 1000);
          text = '${m.toString()}:${s.toString().padLeft(2, '0')}';
        } else {
          text = v.toString();
        }
        return Text(
          suffix != null ? '$text$suffix' : text,
          style: style,
        );
      },
    );
  }
}
