import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/home_module/controller/social_controller.dart';
import 'package:lingolearn/home_module/models/follows_model.dart';
import 'package:lingolearn/utilities/theme/app_colors.dart';
import 'package:lingolearn/utilities/packages/liquid_pull_to_refresh.dart';

enum FollowsType { followers, following }

final socialController = Get.put(SocialController());

class FollowsScreen extends StatefulWidget {
  final FollowsType type;
  const FollowsScreen({super.key, required this.type});

  @override
  State<FollowsScreen> createState() => _FollowsScreenState();
}

class _FollowsScreenState extends State<FollowsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (widget.type == FollowsType.followers) {
      await socialController.getFollowers();
    } else {
      await socialController.getFollowing();
    }
  }

  Future<void> _refresh() => _load();

  String get _title =>
      widget.type == FollowsType.followers ? 'Followers' : 'Following';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kSurface,
      appBar: AppBar(
        title: Text(_title),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: kOnSurface,
      ),
      body: LiquidPullToRefresh(
        onRefresh: _refresh,
        color: kPrimary,
        backgroundColor: Colors.white,
        animSpeedFactor: 2.0,
        child: socialController.obx(
          (state) {
            final items = state?.data?.items ?? [];
            if (items.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  _EmptyState(title: 'No $_title yet'),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) => _FollowTile(
                item: items[i],
                type: widget.type,
                onAction: (id) async {
                  if (widget.type == FollowsType.followers) {
                    await socialController.followUser(id.toString());
                  } else {
                    final res =
                        await socialController.unfollowUser(id.toString());
                    if (res?['status'] == true) {
                      _load();
                    }
                  }
                },
              ),
            );
          },
          onLoading: const _FollowsSkeleton(),
          onEmpty: RefreshIndicator(
            onRefresh: _refresh,
            color: kPrimary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 80),
                _EmptyState(title: 'Nothing here'),
              ],
            ),
          ),
          onError: (err) => RefreshIndicator(
            onRefresh: _refresh,
            color: kPrimary,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 80),
                _ErrorState(message: err ?? 'Failed to load'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FollowTile extends StatelessWidget {
  final Items item;
  final FollowsType type;
  final Future<void> Function(num id) onAction;

  const _FollowTile({
    required this.item,
    required this.type,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = item.avatar ?? '';
    final name = item.name ?? 'User';
    final since = (item.followedAt ?? '').trim();

    final isFollowers = type == FollowsType.followers;
    final actionLabel = isFollowers ? 'Follow' : 'Unfollow';
    const actionBg = kPrimary;
    const actionFg = Colors.white;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: kBorder),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
            backgroundColor: kBorder,
            child: avatar.isEmpty
                ? const Icon(Icons.person_rounded, color: kMuted)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: kOnSurface,
                        fontWeight: FontWeight.w700,
                        fontSize: 15)),
                if (since.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                          since,
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
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => onAction(item.userId ?? 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              decoration: BoxDecoration(
                color: actionBg,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Text(
                  actionLabel,
                  style: const TextStyle(
                    color: actionFg,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

/* ===================== Skeleton ===================== */

class _FollowsSkeleton extends StatelessWidget {
  const _FollowsSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: 8,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) => _SkelTile(),
    );
  }
}

class _SkelTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _ShimmerBox(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: kBorder),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFF3F4F6),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skelBar(width: 140),
                  const SizedBox(height: 8),
                  _skelBar(width: 90, height: 12),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 86,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _skelBar({double width = 120, double height = 14}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class _ShimmerBox extends StatefulWidget {
  final Widget child;
  const _ShimmerBox({required this.child});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _a = Tween<double>(begin: .08, end: .22).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _a,
      builder: (_, __) => Opacity(opacity: 1, child: widget.child),
    );
  }
}

/* ===================== Empty & Error ===================== */

class _EmptyState extends StatelessWidget {
  final String title;
  const _EmptyState({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.group_outlined, color: kMuted, size: 36),
        const SizedBox(height: 10),
        Text(title,
            style: const TextStyle(color: kMuted, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.error_outline_rounded, color: Colors.red, size: 36),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: kMuted, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
