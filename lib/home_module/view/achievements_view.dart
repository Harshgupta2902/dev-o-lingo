import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/achievement_controller.dart';
import 'package:lingolearn/home_module/models/user_profile_model.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';
import 'package:lingolearn/utilities/packages/liquid_pull_to_refresh.dart';

class AchievementsView extends StatefulWidget {
  const AchievementsView({super.key});

  @override
  State<AchievementsView> createState() => _AchievementsViewState();
}

class _AchievementsViewState extends State<AchievementsView> {
  final achievementController = Get.find<AchievementController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      achievementController.getAllAchievements();
    });
  }

  Future<void> _refresh() async {
    await achievementController.getAllAchievements();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: const Text(
          "Achievements",
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: kOnSurface,
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: kOnSurface,
        surfaceTintColor: Colors.transparent,
      ),
      body: Scrollbar(
        radius: const Radius.circular(8),
        child: achievementController.obx(
          (state) {
            if (state == null || state.isEmpty) {
              return LiquidPullToRefresh(
                onRefresh: _refresh,
                color: kPrimary,
                backgroundColor: Colors.white,
                animSpeedFactor: 2.0,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: const [
                    SizedBox(height: 100),
                    Center(
                      child: Text(
                        "No achievements found",
                        style: TextStyle(
                            color: kMuted, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            }

            final unlocked = state.where((a) => a.unlocked ?? false).toList();
            final locked = state.where((a) => !(a.unlocked ?? false)).toList();

            return LiquidPullToRefresh(
              onRefresh: _refresh,
              color: kPrimary,
              backgroundColor: Colors.white,
              animSpeedFactor: 2.0,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (unlocked.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                        child: Text(
                          "Unlocked",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: kOnSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 185,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: unlocked.length,
                          itemBuilder: (context, index) {
                            return Container(
                              width: 130,
                              margin: const EdgeInsets.only(right: 12),
                              child: _AchievementTile(
                                  achievement: unlocked[index]),
                            );
                          },
                        ),
                      ),
                    ],
                    if (locked.isNotEmpty) ...[
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                        child: Text(
                          "Locked Achievements",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: kOnSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          mainAxisExtent: 135,
                        ),
                        itemCount: locked.length,
                        itemBuilder: (context, index) {
                          return _AchievementTile(achievement: locked[index]);
                        },
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
          onLoading: const _AchievementsSkeleton(),
          onError: (error) => LiquidPullToRefresh(
            onRefresh: _refresh,
            color: kPrimary,
            backgroundColor: Colors.white,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 100),
                Center(
                  child: Column(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.red, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        error ?? "Failed to load achievements",
                        style: const TextStyle(
                            color: kMuted, fontWeight: FontWeight.w600),
                      ),
                      TextButton(
                        onPressed: _refresh,
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievements achievement;

  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final bool isUnlocked = achievement.unlocked ?? false;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isUnlocked ? kBorder : kBorder.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isUnlocked ? kCardPurple : kBeigeBg.withOpacity(0.8),
              borderRadius: BorderRadius.circular(18),
            ),
            child: isUnlocked
                ? _buildIcon(isUnlocked)
                : const Icon(Icons.lock_rounded, color: kMuted, size: 28),
          ),
          const SizedBox(height: 12),
          // Info
          Text(
            achievement.title ?? "Achievement",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isUnlocked ? kOnSurface : kMuted,
              letterSpacing: -0.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            achievement.description ?? "Complete",
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 9,
              color: kMuted,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (isUnlocked && achievement.achievedAt != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: successBackground,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                shortAgo(achievement.achievedAt),
                style: const TextStyle(
                  fontSize: 10,
                  color: successMain,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildIcon(bool isUnlocked) {
    return (achievement.iconUrl?.isNotEmpty ?? false)
        ? ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Image.network(
              achievement.iconUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                  Icons.emoji_events_rounded,
                  color: kAmberAccent,
                  size: 24),
            ),
          )
        : const Icon(Icons.emoji_events_rounded, color: kAmberAccent, size: 24);
  }

  String shortAgo(String? date) {
    if (date == null) return "";
    try {
      final DateTime d = DateTime.parse(date);
      final diff = DateTime.now().difference(d).inSeconds;
      if (diff < 60) return "just now";
      if (diff < 3600) return "${(diff / 60).floor()}m ago";
      if (diff < 86400) return "${(diff / 3600).floor()}h ago";
      return "${d.day} ${_getMonth(d.month)} ${d.year}";
    } catch (e) {
      return date;
    }
  }

  String _getMonth(int m) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return months[m - 1];
  }
}

class _AchievementsSkeleton extends StatelessWidget {
  const _AchievementsSkeleton();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Unlocked Section Skeleton
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: _SkeletonBox(width: 100, height: 20),
          ),
          SizedBox(
            height: 185,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (_, __) => Container(
                width: 130,
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder, width: 2),
                ),
                child: const _AchievementSkeletonTile(),
              ),
            ),
          ),

          // Locked Section Skeleton
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 32, 16, 12),
            child: _SkeletonBox(width: 160, height: 20),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 175,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder, width: 2),
                ),
                child: const _AchievementSkeletonTile(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AchievementSkeletonTile extends StatelessWidget {
  const _AchievementSkeletonTile();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: kBeigeBg,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        const SizedBox(height: 10),
        const _SkeletonBox(width: 70, height: 10),
        const SizedBox(height: 4),
        const _SkeletonBox(width: 50, height: 8),
      ],
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  final double width;
  final double height;
  const _SkeletonBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: kBeigeBg,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
