import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/auth_module/view/login_view.dart';
import 'package:lingolearn/home_module/controller/profile_controller.dart';
import 'package:lingolearn/home_module/controller/social_controller.dart';
import 'package:lingolearn/home_module/models/user_profile_model.dart';
import 'package:lingolearn/home_module/view/follows_screen.dart';
import 'package:lingolearn/main.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/skeleton/profile_view_skeleton.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';
import 'package:lingolearn/utilities/packages/liquid_pull_to_refresh.dart';

final profileController = Get.put(ProfileController());
final socialController = Get.put(SocialController());

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.getUserProfile();
      userStatsController.getUserStats();
    });
  }

  Future<void> _refresh() async {
    await profileController.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: profileController.obx(
        (state) {
          return LiquidPullToRefresh(
            onRefresh: _refresh,
            color: kPrimary,
            backgroundColor: Colors.white,
            animSpeedFactor: 2.0,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(top: 60, bottom: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopNavigation(),
                  const SizedBox(height: 24),
                  _buildProfileHeader(state),
                  const SizedBox(height: 24),
                  _buildStatsGrid(state),
                  const SizedBox(height: 12),
                  _buildAchievementsSection(state?.data?.achievements ?? []),
                  const SizedBox(height: 40),
                  _buildSuggestionsSection(state?.data?.notFollowedUsers ?? []),
                ],
              ),
            ),
          );
        },
        onLoading: const AccountSkeleton(),
      ),
    );
  }

  Widget _buildTopNavigation() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Profile",
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 32,
              fontWeight: FontWeight.w600,
              color: kOnSurface,
              letterSpacing: -1,
            ),
          ),
          IconButton(
            onPressed: () => authController.googleSignOut(context),
            icon: const Icon(Icons.logout_rounded, color: kMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileModel? state) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Photo on the left
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kBeigeBg, width: 2),
            ),
            child: CircleAvatar(
              radius: 40,
              backgroundImage: NetworkImage(state?.data?.user?.profile ?? ""),
              backgroundColor: kBeigeBg,
            ),
          ),
          const SizedBox(width: 20),
          // Name and Stats on the right
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state?.data?.user?.name ?? "User",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kDarkSlate,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "Member since ${state?.data?.user?.createdAt ?? "2025"}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: kMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                // Compact horizontal stats
                Row(
                  children: [
                    _buildInstagramStat(
                      count: state?.data?.followers?.toString() ?? "0",
                      label: "Followers",
                      onTap: () => MyNavigator.pushNamed(GoPaths.followsView,
                          extra: {'type': FollowsType.followers}),
                    ),
                    const SizedBox(width: 24),
                    _buildInstagramStat(
                      count: state?.data?.following?.toString() ?? "0",
                      label: "Following",
                      onTap: () => MyNavigator.pushNamed(GoPaths.followsView,
                          extra: {'type': FollowsType.following}),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstagramStat({
    required String count,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: kDarkSlate,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: kMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserProfileModel? state) {
    final stats = [
      _StatItem(
        label: "Day Streak",
        value: "${state?.data?.stats?.streak ?? 0}",
        icon: Icons.local_fire_department_rounded,
        color: kCardPurple,
        accentColor: const Color(0xFF8B5CF6),
      ),
      _StatItem(
        label: "Lessons",
        value: "${state?.data?.lessonsCompleted ?? 0}",
        icon: Icons.school_rounded,
        color: kCardOrange,
        accentColor: const Color(0xFFF59E0B),
      ),
      _StatItem(
        label: "Diamonds",
        value: "${state?.data?.stats?.gems ?? 0}",
        icon: Icons.diamond_rounded,
        color: kCardGreen,
        accentColor: const Color(0xFF10B981),
      ),
      _StatItem(
        label: "Total XP",
        value: "${state?.data?.stats?.xp ?? 0}",
        icon: Icons.bolt_rounded,
        color: kCardBlue,
        accentColor: const Color(0xFF3B82F6),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 80,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, i) => _buildStatCard(stats[i]),
    );
  }

  Widget _buildStatCard(_StatItem item) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(item.icon, color: item.accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kOnSurface,
                  ),
                ),
                Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: kOnSurface,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(List<Achievements> achievements) {
    if (achievements.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionTitle("Achievements",
                  icon: Icons.emoji_events_rounded),
              TextButton(
                onPressed: () {},
                child: const Text("View all",
                    style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            scrollDirection: Axis.horizontal,
            itemCount: achievements.length,
            itemBuilder: (context, index) {
              final achievement = achievements[index];
              return _buildAchievementCard(achievement);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievements achievement) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: kBeigeBg, width: 2),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: kBeigeBg,
              borderRadius: BorderRadius.circular(16),
            ),
            child: (achievement.iconUrl?.isNotEmpty ?? false)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child:
                        Image.network(achievement.iconUrl!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.emoji_events_rounded,
                    color: kAmberAccent, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title ?? "Achievement",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: kOnSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  achievement.description ?? "Keep going!",
                  style: const TextStyle(
                    fontSize: 12,
                    color: kMuted,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestionsSection(List<NotFollowedUsers> users) {
    if (users.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: _buildSectionTitle("People to follow",
              icon: Icons.group_add_rounded),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 170, // Increased height for better padding
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, i) {
              final u = users[i];
              return _UserSuggestCard(
                name: u.name ?? 'User',
                avatar: u.profile ?? '',
                id: u.id.toString(),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {IconData? icon}) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'serif',
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: kOnSurface,
            letterSpacing: -0.5,
          ),
        ),
        if (icon != null) ...[
          const SizedBox(width: 8),
          Icon(icon, color: kAccent, size: 24),
        ],
      ],
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color accentColor;

  _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.accentColor,
  });
}

class _UserSuggestCard extends StatefulWidget {
  final String name;
  final String avatar;
  final String id;

  const _UserSuggestCard({
    required this.name,
    required this.avatar,
    required this.id,
  });

  @override
  State<_UserSuggestCard> createState() => _UserSuggestCardState();
}

class _UserSuggestCardState extends State<_UserSuggestCard> {
  bool isFollowing = false;
  bool isLoading = false;

  Future<void> _handleFollow() async {
    setState(() => isLoading = true);

    if (!isFollowing) {
      final res = await socialController.followUser(widget.id);
      if (res?['status'] == true) {
        setState(() {
          isFollowing = true;
          profileController.state?.data?.following =
              (profileController.state?.data?.following ?? 0) + 1;
        });
      }
    } else {
      final res = await socialController.unfollowUser(widget.id);
      if (res?['status'] == true) {
        setState(() {
          isFollowing = false;
          profileController.state?.data?.following =
              (profileController.state?.data?.following ?? 0) - 1;
        });
      }
    }
    profileController.update();
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundImage:
                (widget.avatar.isNotEmpty) ? NetworkImage(widget.avatar) : null,
            backgroundColor: kBeigeBg,
            child: widget.avatar.isEmpty
                ? const Icon(Icons.person_rounded, color: kMuted)
                : null,
          ),
          const SizedBox(height: 12),
          Text(
            widget.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: kOnSurface,
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: isLoading ? null : _handleFollow,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: isFollowing ? kBeigeBg : kPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: kOnSurface),
                      )
                    : Text(
                        isFollowing ? 'Following' : 'Follow',
                        style: TextStyle(
                          color: isFollowing ? kMuted : kOnSurface,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
