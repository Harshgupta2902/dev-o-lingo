import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/profile_controller.dart';
import 'package:lingolearn/home_module/controller/social_controller.dart';
import 'package:lingolearn/home_module/models/user_profile_model.dart';
import 'package:lingolearn/home_module/view/follows_screen.dart';
import 'package:lingolearn/utilities/common/core_app_bar.dart';
import 'package:lingolearn/utilities/navigation/go_paths.dart';
import 'package:lingolearn/utilities/navigation/navigator.dart';
import 'package:lingolearn/utilities/skeleton/profile_view_skeleton.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

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
    });
  }

  Future<void> _refresh() async {
    await profileController.getUserProfile();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LiquidPullToRefresh(
        onRefresh: _refresh,
        color: kPrimary,
        backgroundColor: Colors.white,
        height: 80,
        animSpeedFactor: 2.0,
        child: profileController.obx(
          (state) {
            return SingleChildScrollView(
              child: Column(
                children: [
                  const CustomHeader(
                    title: "Profile",
                    icon: Icons.person,
                  ),
                  _buildProfileHeader(state),
                  const SizedBox(height: 32),
                  _buildAchievementsSection(state?.data?.achievements ?? []),
                  const SizedBox(height: 32),
                  _buildStatisticsSection(state),
                  const SizedBox(height: 20),
                  _buildSuggestionsSection(state?.data?.notFollowedUsers ?? []),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
          onLoading: const AccountSkeleton(),
        ),
      ),
    );
  }

  Widget _buildSuggestionsSection(List<NotFollowedUsers> users) {
    if (users.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 100,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kBorder),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.group_outlined, color: kMuted, size: 28),
              SizedBox(height: 6),
              Text(
                'No suggestions right now',
                style: TextStyle(color: kMuted, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'People to follow',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: kOnSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final u = users[i];
                return _UserSuggestCard(
                  name: u.name ?? 'User',
                  avatar: u.profile ?? '',
                  id: u.id.toString() ?? "",
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(UserProfileModel? state) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: kPrimary.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(state?.data?.user?.profile ?? ""),
              backgroundColor: kBorder,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            state?.data?.user?.name ?? "User",
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: kOnSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Member since ${state?.data?.user?.createdAt ?? "2025"}",
            style: const TextStyle(
              fontSize: 14,
              color: kMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: kBorder),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    MyNavigator.pushNamed(
                      GoPaths.followsView,
                      extra: {'type': FollowsType.followers},
                    );
                  },
                  child: _MiniStat(
                    number: state?.data?.followers?.toString() ?? "",
                    label: 'Followers',
                  ),
                ),
              ),
              _buildDivider(),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    MyNavigator.pushNamed(
                      GoPaths.followsView,
                      extra: {'type': FollowsType.following},
                    );
                  },
                  child: _MiniStat(
                    number: state?.data?.following?.toString() ?? "",
                    label: 'Following',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 40,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: kBorder,
    );
  }

  Widget _buildAchievementsSection(List<Achievements> achievements) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kOnSurface,
                  letterSpacing: -0.5,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: kPrimary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                child: const Text(
                  'View all',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          _AchievementStrip(items: achievements),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(UserProfileModel? state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                'Statistics',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: kOnSurface,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(width: 8),
              Icon(
                Icons.trending_up_rounded,
                size: 24,
                color: kAccent,
              ),
            ],
          ),
          const SizedBox(height: 16),
          StatsGrid(state: state),
        ],
      ),
    );
  }
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
      width: 150,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          CircleAvatar(
            radius: 26,
            backgroundImage:
                (widget.avatar.isNotEmpty) ? NetworkImage(widget.avatar) : null,
            backgroundColor: kBorder,
            child: widget.avatar.isEmpty
                ? const Icon(Icons.person_rounded, color: kMuted)
                : null,
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              widget.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: kOnSurface,
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: isLoading ? null : _handleFollow,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isFollowing ? Colors.grey.shade300 : Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: isLoading
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      isFollowing ? 'Following' : 'Follow',
                      style: TextStyle(
                        color: isFollowing ? Colors.black : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementStrip extends StatelessWidget {
  final List<Achievements> items;

  const _AchievementStrip({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Container(
        height: 100,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events_outlined, color: kMuted, size: 32),
            SizedBox(height: 8),
            Text(
              'No achievements yet',
              style: TextStyle(color: kMuted, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 90,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final achievement = items[i];
          return Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        kPrimary.withOpacity(0.1),
                        kSecondary.withOpacity(0.1)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: (achievement.iconUrl != null &&
                          achievement.iconUrl!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(achievement.iconUrl!,
                              fit: BoxFit.cover),
                        )
                      : const Icon(Icons.emoji_events_rounded,
                          color: kPrimary, size: 24),
                ),
                const SizedBox(width: 12),

                // text
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // title + time on same line
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              achievement.title ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color: kOnSurface,
                              ),
                            ),
                          ),
                          if ((achievement.achievedAt ?? '').isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.schedule_rounded,
                                      size: 12, color: kMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    achievement.achievedAt!, // "3m ago"
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: kMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // description
                      Text(
                        achievement.description ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: kMuted,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String number;
  final String label;

  const _MiniStat({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: kOnSurface,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: kMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class StatsGrid extends StatelessWidget {
  const StatsGrid({super.key, this.state});

  final UserProfileModel? state;

  @override
  Widget build(BuildContext context) {
    final cards = <_StatCardData>[
      _StatCardData(
        icon: Icons.local_fire_department_rounded,
        iconColor: const Color(0xFFEF4444),
        backgroundColor: const Color(0xFFEF4444).withOpacity(0.1),
        value: "${state?.data?.stats?.streak ?? 0}",
        label: 'Day Streak',
      ),
      _StatCardData(
        icon: Icons.school_rounded,
        iconColor: const Color(0xFF8B5CF6),
        backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
        value: "${state?.data?.lessonsCompleted ?? 0}",
        label: 'Lessons',
      ),
      _StatCardData(
        icon: Icons.diamond_rounded,
        iconColor: const Color(0xFF06B6D4),
        backgroundColor: const Color(0xFF06B6D4).withOpacity(0.1),
        value: "${state?.data?.stats?.gems ?? 0}",
        label: 'Diamonds',
      ),
      _StatCardData(
        icon: Icons.bolt_rounded,
        iconColor: const Color(0xFFF59E0B),
        backgroundColor: const Color(0xFFF59E0B).withOpacity(0.1),
        value: "${state?.data?.stats?.xp ?? 0}",
        label: 'Total XP',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 80,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, i) => _StatCard(data: cards[i]),
    );
  }
}

class _StatCardData {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String value;
  final String label;

  _StatCardData({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.value,
    required this.label,
  });
}

class _StatCard extends StatelessWidget {
  final _StatCardData data;

  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.backgroundColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: kOnSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: kMuted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
