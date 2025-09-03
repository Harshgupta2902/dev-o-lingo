// account_screen.dart
// ignore_for_file: deprecated_member_use, prefer_const_declarations

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lingolearn/auth_module/view/onboarding_view.dart';
import 'package:lingolearn/home_module/controller/profile_controller.dart';
import 'package:lingolearn/utilities/firebase/core_prefs.dart';
import 'package:lingolearn/utilities/skeleton/profile_view_skeleton.dart';

final profileController = Get.put(ProfileController());

const Color kPrimary = Color(0xFF6C5CE7);
const Color kBg = Color(0xFFF4F5F7);
const Color kMuted = Color(0xFF6B7280);
const Color kAccentGreen = Color(0xFF16A34A);

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return profileController.obx((state) {
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 8),
              _buildAvatar(state?.data?.user?.profile ?? ""),
                  // "https://hebbkx1anhila5yf.public.blob.vercel-storage.com/image-BpiFKF1V8IoM5PLvNI67cuDMAy5xFu.png"),
              const SizedBox(height: 12),
              Text(
                state?.data?.user?.name ?? "User",
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Joined Since ${state?.data?.user?.createdAt ?? "2025"}",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: kMuted,
                ),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),
              _buildTopCountRow(40, 50, state?.data?.stats?.xp ?? 0),
              const SizedBox(height: 16),
              const _ActionButtonsRow(),
              const SizedBox(height: 20),
              const _SectionHeader(
                title: 'Your Statistics',
                trailing: Icon(
                  Icons.insights,
                  size: 20,
                  color: kAccentGreen,
                ),
              ),
              const SizedBox(height: 12),
              const _StatsGrid(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      );
    }, onLoading: const AccountSkeleton());
  }

  _buildAvatar(String url) {
    return CircleAvatar(
      radius: 44,
      backgroundImage: NetworkImage(url),
      backgroundColor: Colors.grey.shade200,
    );
  }

  _buildTopCountRow(int followers, int following, int xp) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(number: '$followers', label: 'followers'),
        ),
        const _VerticalDivider(),
        Expanded(
          child: _MiniStat(number: '$following', label: 'following'),
        ),
        const _VerticalDivider(),
        Expanded(
          child: _MiniStat(number: '$xp', label: 'lifetime XP'),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String number;
  final String label;

  const _MiniStat({required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          number,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: kMuted),
        ),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: VerticalDivider(
        width: 24,
        thickness: 1,
        color: Colors.grey.shade300,
      ),
    );
  }
}

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    final primary = kPrimary;

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              authController.googleSignOut(context);
              clearPrefs();
            },
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: const Text('Edit Profile'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: primary, width: 1.5),
              foregroundColor: primary,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: const Text('Message'),
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          trailing!,
        ]
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    final cards = <_StatCardData>[
      _StatCardData(
        icon: Icons.local_fire_department_outlined,
        iconColor: Colors.orange,
        value: '127',
        label: 'Challenges',
      ),
      _StatCardData(
        icon: Icons.calendar_month_outlined,
        iconColor: Colors.pink,
        value: '458',
        label: 'Lessons Passed',
      ),
      _StatCardData(
        icon: Icons.diamond_outlined,
        iconColor: Colors.blue,
        value: '957',
        label: 'Total Diamonds',
      ),
      _StatCardData(
        icon: Icons.bolt_outlined,
        iconColor: Colors.amber,
        value: '15,274',
        label: 'Total Lifetime XP',
      ),
      _StatCardData(
        icon: Icons.track_changes,
        iconColor: Colors.redAccent,
        value: '289',
        label: 'Correct Practices',
      ),
      _StatCardData(
        icon: Icons.emoji_events_outlined,
        iconColor: Colors.teal,
        value: '36',
        label: 'Top 3 Positions',
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cards.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisExtent: 70,
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
  final String value;
  final String label;

  _StatCardData({
    required this.icon,
    required this.iconColor,
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
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: data.iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(data.icon, color: data.iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: kMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
