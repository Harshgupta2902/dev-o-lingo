import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/other_user_profile_controller.dart';
import 'package:lingolearn/home_module/models/public_user_model.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';

class OtherUserProfileScreen extends StatefulWidget {
  final int userId;
  const OtherUserProfileScreen({super.key, required this.userId});

  @override
  State<OtherUserProfileScreen> createState() =>
      _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen> {
  late final OtherUserProfileController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = Get.put(OtherUserProfileController(widget.userId),
        tag: 'user_${widget.userId}');
  }

  @override
  void dispose() {
    Get.delete<OtherUserProfileController>(tag: 'user_${widget.userId}');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      body: SafeArea(
        child: Column(
          children: [
            // ── Custom Header ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: kSecondary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: kSecondary.withOpacity(0.5), width: 1.5),
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded,
                          color: kOnSurface.withOpacity(0.8), size: 16),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    "Profile",
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'serif',
                      fontWeight: FontWeight.w700,
                      color: kOnSurface,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),

            // ── Body ──
            Expanded(
              child: _ctrl.obx(
                (state) => _buildBody(state!),
                onLoading: const Center(
                    child: CircularProgressIndicator(color: kAmberAccent)),
                onError: (err) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.red, size: 40),
                      const SizedBox(height: 12),
                      Text(err ?? 'Something went wrong',
                          style: const TextStyle(color: kMuted)),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => _ctrl.getPublicProfile(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PublicUserModel state) {
    final data = state.data;
    if (data == null) return const SizedBox.shrink();

    final avatar = data.profile ?? '';
    final name = data.name ?? 'User';

    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 28, bottom: 40),
      child: Column(
        children: [
          // ── Avatar ──
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kAmberAccent, width: 2.5),
            ),
            child: CircleAvatar(
              radius: 52,
              backgroundImage:
                  avatar.isNotEmpty ? NetworkImage(avatar) : null,
              backgroundColor: kBeigeBg,
              child: avatar.isEmpty
                  ? const Icon(Icons.person_rounded,
                      color: kMuted, size: 44)
                  : null,
            ),
          ),
          const SizedBox(height: 16),

          // ── Name ──
          Text(
            name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: kDarkSlate,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),

          // ── Level ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: kCardOrange,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${data.level?.emoji ?? '🐣'} ${data.level?.title ?? 'Beginner'}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: kDarkSlate,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Followers / Following row ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.symmetric(vertical: 18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                _countStat(
                    '${data.followerCount ?? 0}', 'Followers'),
                Container(width: 1, height: 36, color: kBorder),
                _countStat(
                    '${data.followingCount ?? 0}', 'Following'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── Stats Grid ──
          _buildStatsGrid(data),
          const SizedBox(height: 28),

          // ── Follow / Unfollow Button ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _FollowButton(
              isFollowing: data.isFollowing ?? false,
              onFollow: () async {
                await _ctrl.followUser();
              },
              onUnfollow: () async {
                await _ctrl.unfollowUser();
                if (context.mounted) Navigator.of(context).pop(true);
              },
            ),
          ),
          const SizedBox(height: 12),

          // ── Report & Block buttons row ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _ActionOutlineButton(
                    label: 'Report',
                    icon: Icons.flag_outlined,
                    color: Colors.orange,
                    onTap: () => _showReportDialog(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ActionOutlineButton(
                    label: 'Block',
                    icon: Icons.block_rounded,
                    color: Colors.red,
                    onTap: () => _showBlockDialog(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _countStat(String count, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: kDarkSlate,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: kMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(Data data) {
    final stats = [
      _StatItem(
        label: "Day Streak",
        value: "${data.streak ?? 0}",
        icon: Icons.local_fire_department_rounded,
        color: kCardPurple,
        accentColor: const Color(0xFF8B5CF6),
      ),
      _StatItem(
        label: "Total XP",
        value: "${data.xp ?? 0}",
        icon: Icons.bolt_rounded,
        color: kCardBlue,
        accentColor: const Color(0xFF3B82F6),
      ),
      _StatItem(
        label: "Diamonds",
        value: "${data.gems ?? 0}",
        icon: Icons.diamond_rounded,
        color: kCardGreen,
        accentColor: const Color(0xFF10B981),
      ),
      _StatItem(
        label: "Hearts",
        value: "${data.hearts ?? 5}",
        icon: Icons.favorite_rounded,
        color: kCardPink,
        accentColor: const Color(0xFFEC4899),
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
      itemBuilder: (_, i) => _buildStatCard(stats[i]),
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

  void _showReportDialog() {
    final reasonCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.flag_rounded, color: Colors.orange, size: 24),
            SizedBox(width: 8),
            Text('Report User',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Why are you reporting this user?',
              style: TextStyle(color: kMuted, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe the issue...',
                hintStyle: const TextStyle(color: kMuted, fontSize: 13),
                filled: true,
                fillColor: kBeigeBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: kAmberAccent, width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: kMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok =
                  await _ctrl.reportUser(reasonCtrl.text.trim());
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'User reported successfully'
                        : 'Failed to report'),
                    backgroundColor: ok ? successMain : errorMain,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Report',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.block_rounded, color: Colors.red, size: 24),
            SizedBox(width: 8),
            Text('Block User',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ],
        ),
        content: const Text(
          'This user will no longer be able to follow you or appear in your feeds. Are you sure?',
          style: TextStyle(color: kMuted, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('Cancel', style: TextStyle(color: kMuted)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final ok = await _ctrl.blockUser();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'User blocked successfully'
                        : 'Failed to block'),
                    backgroundColor: ok ? successMain : errorMain,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                );
                if (ok) Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Block',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Widgets ──

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color, accentColor;

  _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.accentColor,
  });
}

class _FollowButton extends StatefulWidget {
  final bool isFollowing;
  final Future<void> Function() onFollow;
  final Future<void> Function() onUnfollow;

  const _FollowButton({
    required this.isFollowing,
    required this.onFollow,
    required this.onUnfollow,
  });

  @override
  State<_FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<_FollowButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final following = widget.isFollowing;

    return GestureDetector(
      onTap: _loading
          ? null
          : () async {
              setState(() => _loading = true);
              if (following) {
                await widget.onUnfollow();
              } else {
                await widget.onFollow();
              }
              setState(() => _loading = false);
            },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: following ? Colors.white : kPrimary,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: following ? kBorder : kPrimary, width: 1.5),
        ),
        child: Center(
          child: _loading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: kOnSurface),
                )
              : Text(
                  following ? 'Following' : 'Follow',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: following ? kMuted : kOnSurface,
                  ),
                ),
        ),
      ),
    );
  }
}

class _ActionOutlineButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionOutlineButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
