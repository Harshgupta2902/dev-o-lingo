// leaderboard_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lingolearn/utilities/skeleton/leaderboard_skeleton.dart';

import 'package:lingolearn/utilities/theme/app_colors.dart'; // kPrimary, kSurface, kOnSurface, kMuted, kBorder
import 'package:lingolearn/home_module/controller/leaderboard_controller.dart';
import 'package:lingolearn/home_module/models/leaderboard_model.dart';

final leaderboardController = Get.put(LeaderboardController(), permanent: true);

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  int _selectedTab = 0; // 0 = weekly, 1 = monthly

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
    // fetch
    WidgetsBinding.instance.addPostFrameCallback((_) {
      leaderboardController.getLeaderboard();
    });
  }

  Future<void> _refresh() async {
    await leaderboardController.getLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: leaderboardController.obx(
          (state) {
            final weekly = state?.data?.weekly ?? const <Weekly>[];
            final monthly = state?.data?.monthly ?? const <Monthly>[];

            // choose current list
            final items = _selectedTab == 0
                ? weekly.map((e) => _LBUser(
                      name: e.name ?? 'Unknown',
                      xp: (e.xp ?? 0).toInt(),
                      avatar: e.avatar ?? '',
                      rank: (e.rank ?? 0).toInt(),
                    ))
                : monthly.map((e) => _LBUser(
                      name: e.name ?? 'Unknown',
                      xp: (e.xp ?? 0).toInt(),
                      avatar: e.avatar ?? '',
                      rank: (e.rank ?? 0).toInt(),
                    ));

            return RefreshIndicator(
              onRefresh: _refresh,
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: kPrimary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.leaderboard_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Leaderboard',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: kOnSurface,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: kSurface,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            color: kMuted,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Filter Pills
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _FilterPill(
                          label: 'Weekly',
                          isSelected: _selectedTab == 0,
                          onTap: () => setState(() => _selectedTab = 0),
                        ),
                        const SizedBox(width: 12),
                        _FilterPill(
                          label: 'Monthly',
                          isSelected: _selectedTab == 1,
                          onTap: () => setState(() => _selectedTab = 1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // List
                  Expanded(
                    child: items.isEmpty
                        ? const _EmptyState()
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: items.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) =>
                                _LeaderboardTile(user: items.elementAt(index)),
                          ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
          onLoading: const LeaderboardSkeleton(),
          onError: (err) => _ErrorState(
            message: err ?? 'Failed to load leaderboard',
            onRetry: _refresh,
          ),
        ),
      ),
    );
  }
}

/* ===================== UI PARTS ===================== */

class _FilterPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterPill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? kPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? kPrimary : kBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : kMuted,
          ),
        ),
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final _LBUser user;

  const _LeaderboardTile({required this.user});

  Widget _medal(int rank) {
    switch (rank) {
      case 1:
        return const _MedalDot(color: Color(0xFFFFD700)); // Gold
      case 2:
        return const _MedalDot(color: Color(0xFFC0C0C0)); // Silver
      case 3:
        return const _MedalDot(color: Color(0xFFCD7F32)); // Bronze
      default:
        return SizedBox(
          width: 24,
          height: 24,
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: kMuted,
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final img = (user.avatar.isEmpty)
        ? const AssetImage('assets/images/avatar_placeholder.png')
        : NetworkImage(user.avatar) as ImageProvider;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _medal(user.rank),
          const SizedBox(width: 16),
          CircleAvatar(
              radius: 20, backgroundImage: img, backgroundColor: kBorder),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              user.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: kOnSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${user.xp} XP',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: kMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedalDot extends StatelessWidget {
  final Color color;
  const _MedalDot({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child:
          const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 14),
    );
  }
}

class _LBUser {
  final String name;
  final int xp;
  final String avatar;
  final int rank;

  const _LBUser({
    required this.name,
    required this.xp,
    required this.avatar,
    required this.rank,
  });
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No leaderboard yet.',
        style: TextStyle(color: kMuted, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
